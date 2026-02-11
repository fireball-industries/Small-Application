# Dashboard Proxy Bug: Emberburn Returns 404 "Not Found"

## Status: CONFIRMED DASHBOARD-SIDE ISSUE

Emberburn (Flask web UI on port 5000) is running and reachable — the proxy connects. But the iframe shows Flask's default 404: "The requested URL was not found on the server."

---

## What's Happening

1. Dashboard "Launch UI" opens an iframe proxying to the Emberburn pod
2. The connection succeeds (port 5000, Flask web UI)
3. Flask receives the request but returns **404 Not Found**
4. This means the **URL path being forwarded to Flask doesn't match any route**

## Emberburn's Flask Routes

These are the valid routes registered in `web_app.py` (Blueprint: `web_ui`):

| Route | Handler |
|-------|---------|
| `/` | `index()` → renders `index.html` |
| `/dashboard` | `dashboard()` → renders `index.html` |
| `/tags` | `tags()` → renders `tags.html` |
| `/publishers` | `publishers()` → renders `publishers.html` |
| `/alarms` | `alarms()` → renders `alarms.html` |
| `/config` | `config_page()` → renders `config.html` |
| `/tag-generator` | `tag_generator()` → renders `tag_generator.html` |
| `/health` | JSON health check |
| `/ready` | JSON readiness check |

## Root Cause: Path Forwarding

The dashboard's reverse proxy handler (`internal/proxy/handlers.go`) receives requests at:

```
/api/proxy?target=http://<PodIP>:5000
```

When it creates the `httputil.ReverseProxy`, it must forward the request with path `/` (root) for the initial page load. If the handler is instead forwarding with the **original request path** from the browser (e.g., `/api/proxy`), Flask won't match that path → 404.

### What to Check in the Dashboard Code

1. **`internal/proxy/handlers.go`**: Look at how `req.URL.Path` is set before proxying. The path sent to the target should be `/`, not the dashboard's own path.

2. **Rancher K8s API Proxy** (Strategy A): If `RANCHER_URL` is set and the launch URL uses the pattern:
   ```
   /k8s/clusters/local/api/v1/namespaces/<ns>/services/http:<svc>:<port>/proxy/
   ```
   The Rancher proxy should strip the prefix, but verify it forwards `/` to the pod.

3. **Path rewriting**: The proxy handler should ideally do:
   ```go
   // Strip the proxy prefix — forward only the subpath to the target
   req.URL.Path = "/"  // or preserve subpath for deep linking
   ```

### Quick Diagnostic

From a shell on the cluster, test direct connectivity:

```bash
# Test from any pod in the cluster
curl -v http://<EMBERBURN_POD_IP>:5000/
# Expected: 200 OK with HTML content

curl -v http://<EMBERBURN_POD_IP>:5000/health
# Expected: 200 OK with JSON {"status": "healthy"}

# Test what the proxy actually sends (check dashboard logs)
kubectl logs <dashboard-pod> -n fireball-system | grep -i proxy
```

If `curl http://<PodIP>:5000/` returns 200, Emberburn is fine. The fix is in the dashboard's proxy handler path rewriting.

## Flask Static Files Note

Emberburn's Blueprint serves static files at `/static/web/` (configured via `static_url_path='/static/web'`). After fixing the proxy path, the dashboard may also need to rewrite static asset URLs in the proxied HTML, or Flask needs to serve with correct relative paths. If the CSS/JS doesn't load after fixing the 404, this is the next thing to check.

---

*Generated from Emberburn v3.5.6 debugging session — 2026-02-10*
