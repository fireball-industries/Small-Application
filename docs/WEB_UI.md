# 🔥 EmberBurn Web Configuration UI

**A Beautiful, Real-Time Dashboard for Your Industrial IoT Gateway**

By Patrick Ryan, CTO - Fireball Industries

---

## Overview

Look, I get it. Not everyone wants to edit JSON files all day (though between you and me, there's something zen about a perfectly formatted config file). That's why we built **EmberBurn** - a slick web-based UI that lets you manage your entire OPC UA gateway without touching a single line of JSON.

### What You Get

- **Real-Time Tag Monitoring** - Watch your industrial data flow in real-time
- **Publisher Management** - Enable/disable protocols with a single click
- **Alarm Dashboard** - See active alarms instantly
- **Tag Management** - Monitor all your OPC UA tags without memorizing node IDs
- **Configuration Interface** - Manage settings through a beautiful UI instead of vim (though vim is cool too)

---

## 🚀 Quick Start

### 1. Make Sure Your Server is Running

```bash
python opcua_server.py
```

### 2. Open the Web UI

Open your browser and navigate to:

```
http://localhost:5000/
```

**Wait, what?** The REST API automatically serves the web UI! No separate web server needed. We're efficient like that.

### 3. Start Monitoring

That's it. You're done. Welcome to the future.

---

## 🎨 UI Features

### Dashboard View 🏠

The main dashboard gives you the bird's-eye view:

- **Active Tags Counter** - How many tags are being monitored
- **Publisher Status** - Which protocols are enabled (out of 12!)
- **Active Alarms** - Critical/warning alarm counts
- **Live Tag Table** - Real-time values updating every 2 seconds

**Pro Tip:** The tag values have a subtle pulse animation when they're live. If they stop pulsing, something's wrong.

### Tag Monitor 🏷️

See ALL your tags in one beautiful table:

- **Tag Name** - The OPC UA node identifier
- **Current Value** - Live, real-time value
- **Data Type** - Float, int, string, boolean, etc.
- **Last Update** - Timestamp of last change
- **Actions** - View history (when we add InfluxDB integration)

**Performance Note:** We're using React with automatic updates every 2 seconds. If you have 10,000 tags, you might want to add pagination. Or buy a better server. Your call.

### Publishers View 📡

Manage all 12 protocols from one screen:

Each publisher shows:
- **Status Badge** - ENABLED (green) or DISABLED (gray)
- **Protocol Icon** - Because icons are fun
- **Toggle Button** - Enable/disable with one click
- **Config Button** - Quick access to settings (coming soon)

**Publisher List:**
- 📨 MQTT
- 🌐 REST API (you're using it right now!)
- 🔷 GraphQL
- ⚡ Sparkplug B
- 🎯 Kafka
- 🐰 AMQP (RabbitMQ)
- 🔌 WebSocket
- 📊 InfluxDB
- 🔧 MODBUS TCP
- 🔗 OPC UA Client
- 🚨 Alarms & Notifications

**Warning:** Don't disable the REST API publisher while you're using the web UI. That's like sawing off the branch you're sitting on.

### Alarms View 🚨

See all active alarms at a glance:

- **Priority** - INFO (blue), WARNING (orange), CRITICAL (red)
- **Alarm Name** - The rule that triggered
- **Tag** - Which tag caused the alarm
- **Value** - The value that triggered it
- **Message** - Human-readable description
- **Timestamp** - When it happened

**Best Part:** When there are no alarms, you get a big green checkmark and "All Systems Normal". Because good news deserves celebration.

### Configuration View ⚙️

Quick access to:

- **Server Information** - OPC UA endpoint, API URLs
- **Quick Actions** - Restart, export/import config, view logs (coming soon)
- **System Status** - Platform version, protocol count

---

## 🎭 Design Philosophy

### Color Scheme

We went with a **fire-themed** dark mode design because:

1. It's called **EmberBurn** (duh)
2. Dark mode is objectively superior
3. Orange/yellow on dark gray looks sick
4. It won't blind you at 2 AM when debugging production

**Color Palette:**
- `--flame-orange: #ff6b35` - Primary brand color
- `--flame-red: #ff4136` - Danger/critical states
- `--ember-dark: #1a1a1a` - Background
- `--ember-gray: #2d2d2d` - Cards and panels
- `--fire-yellow: #ffd700` - Highlights and active values
- `--success-green: #28a745` - Success states

### ASCII Art Branding

We have TWO beautiful ASCII art logos:

1. **Fireball Industries** - Company branding
2. **EmberBurn** - Product branding

Both rendered in glorious monospace font with fire-colored gradients. Because we're professionals, but we're also having fun.

### Animations

- **Pulse Effect** - Live data indicators breathe (2s cycle)
- **Hover Transforms** - Cards lift up when you hover
- **Smooth Transitions** - Everything eases over 0.3s
- **Loading Spinner** - Rotating ring of fire

We kept animations subtle. This is industrial software, not a Vegas casino.

---

## 🔧 Technical Architecture

### Frontend Stack

- **React 18** - Via CDN (no build step needed!)
- **Babel Standalone** - JSX compilation in the browser
- **Pure CSS** - No frameworks, no dependencies, just clean styles
- **Vanilla JavaScript** - Because sometimes less is more

**Why No Build Step?**

Simple: I wanted you to be able to deploy this to an industrial PC without needing Node.js, npm, webpack, babel config, postcss, and the entire JavaScript ecosystem. Just drop the HTML file on the server and go.

Want to customize it? Edit the HTML file. That's it.

### Backend Integration

The UI talks to three endpoints:

1. **REST API** (`http://localhost:5000/api/*`)
   - `/api/tags` - Get all tag values
   - `/api/publishers` - Get publisher statuses
   - `/api/publishers/{name}/toggle` - Enable/disable publishers
   - `/api/alarms/active` - Get active alarms

2. **GraphQL API** (`http://localhost:5002/graphql`)
   - Used for advanced queries (if you want to customize)
   - Full schema available at GraphiQL interface

3. **WebSocket** (Optional)
   - Real-time push updates
   - Reduces polling overhead
   - Enable the WebSocket publisher for this

### Data Flow

```
OPC UA Server → Publishers → REST API Cache → Web UI
                     ↓
                Tag Updates
                (every 2s)
```

**Polling Interval:** 2 seconds

Why 2 seconds? Because 1 second is too aggressive, and 5 seconds feels sluggish. 2 seconds is the Goldilocks zone.

**Want Real-Time Push?** Enable the WebSocket publisher and modify the frontend to use WebSocket instead of polling. I left it as polling for simplicity.

---

## 🎯 API Reference

### GET /api/tags

Get all tag values.

**Response:**
```json
{
  "tags": {
    "Temperature": {
      "value": 23.5,
      "timestamp": 1704931200.0
    },
    "Pressure": {
      "value": 101.3,
      "timestamp": 1704931200.0
    }
  },
  "count": 2
}
```

### GET /api/publishers

Get all publisher statuses.

**Response:**
```json
{
  "publishers": [
    {
      "name": "MQTT",
      "enabled": true,
      "class": "MQTTPublisher"
    },
    {
      "name": "GraphQL",
      "enabled": true,
      "class": "GraphQLPublisher"
    }
  ]
}
```

### POST /api/publishers/{name}/toggle

Toggle a publisher on/off.

**Example:**
```bash
curl -X POST http://localhost:5000/api/publishers/MQTT/toggle
```

**Response:**
```json
{
  "success": true,
  "publisher": "MQTT"
}
```

### GET /api/alarms/active

Get active alarms.

**Response:**
```json
{
  "alarms": [
    {
      "rule_name": "HighTemperature",
      "tag": "ns=2;i=2",
      "priority": "CRITICAL",
      "triggered_value": 85.0,
      "threshold": 80.0,
      "condition": ">",
      "message": "Temperature exceeded safe limit",
      "triggered_at": 1704931200.0
    }
  ]
}
```

---

## 🎨 Customization Guide

### Changing Colors

Edit the CSS `:root` variables at the top of `index.html`:

```css
:root {
    --flame-orange: #ff6b35;  /* Your brand color */
    --ember-dark: #1a1a1a;    /* Background */
    --fire-yellow: #ffd700;   /* Highlights */
}
```

### Adding New Views

1. Create a new component function:

```javascript
function MyCustomView({ data }) {
    return (
        <div>
            <h1>My Custom View</h1>
            {/* Your content here */}
        </div>
    );
}
```

2. Add to the navigation menu:

```javascript
const menuItems = [
    // ... existing items
    { id: 'custom', label: 'My View', icon: '🎯' }
];
```

3. Add to the view router:

```javascript
{currentView === 'custom' && <MyCustomView data={someData} />}
```

### Changing Update Interval

Find this line in the `App` component:

```javascript
const interval = setInterval(fetchData, 2000); // 2000ms = 2 seconds
```

Change `2000` to whatever you want (in milliseconds).

**Warning:** Going below 500ms is probably overkill and might hammer your server.

### Adding Charts

We included Recharts via CDN. Example usage:

```javascript
const { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend } = Recharts;

function MyChart({ data }) {
    return (
        <LineChart width={600} height={300} data={data}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="timestamp" />
            <YAxis />
            <Tooltip />
            <Legend />
            <Line type="monotone" dataKey="value" stroke="#ff6b35" />
        </LineChart>
    );
}
```

---

## 🚀 Deployment Options

### Option 1: Built-in Flask Server (Development)

Already works! The REST API serves the HTML file automatically.

**Pros:** Dead simple, zero configuration
**Cons:** Flask development server isn't production-grade

### Option 2: Production WSGI Server

Use Gunicorn or uWSGI:

```bash
pip install gunicorn
gunicorn opcua_server:app -w 4 -b 0.0.0.0:5000
```

### Option 3: Separate Web Server

Put the HTML file behind nginx/Apache and proxy API calls:

```nginx
server {
    listen 80;
    server_name emberburn.local;
    
    location / {
        root /var/www/emberburn;
        try_files $uri $uri/ /index.html;
    }
    
    location /api/ {
        proxy_pass http://localhost:5000;
        proxy_set_header Host $host;
    }
}
```

### Option 4: Docker/K3s (Recommended)

See `docs/DEPLOYMENT.md` (coming soon) for containerization setup.

---

## 🔐 Security Considerations

### Current State: Wide Open 🚨

As requested, we skipped security. **This is fine for:**
- Internal networks
- K3s clusters with ingress authentication
- Development environments
- Demonstrations

**This is NOT fine for:**
- Public internet exposure
- Production without network security
- Compliance-heavy industries (pharma, finance)

### Adding Authentication (If You Change Your Mind)

1. **JWT Tokens:**
   - Add authentication endpoint
   - Store token in localStorage
   - Include in all API requests

2. **API Keys:**
   - Generate keys for each user/system
   - Validate on every request

3. **SSL/TLS:**
   - Let your ingress controller handle it (K3s/nginx)
   - Or use Flask-Talisman for HTTPS

4. **CORS:**
   - Already configured (Flask-CORS)
   - Lock it down to specific origins in production

---

## 🐛 Troubleshooting

### "Can't connect to API"

**Check:**
1. Is the OPC UA server running? (`python opcua_server.py`)
2. Is the REST API publisher enabled? (check `config.json`)
3. Is port 5000 accessible? (firewall rules)
4. Are you on the same network? (check IP addresses)

**Test:**
```bash
curl http://localhost:5000/api/tags
```

### "No data showing up"

**Check:**
1. Are tags actually being published? (check server logs)
2. Is the update interval too slow? (default: 2 seconds)
3. Open browser console - any JavaScript errors?
4. Check network tab - are API calls succeeding?

### "Publishers won't toggle"

**Possible Causes:**
1. Publisher has a configuration error (check logs)
2. Missing dependencies (MQTT library, Kafka, etc.)
3. Port conflicts (another service using the same port)
4. Permissions (firewall blocking outbound connections)

### "UI looks broken"

**Check:**
1. Is your browser modern? (Chrome 90+, Firefox 88+, Safari 14+)
2. Are CDN resources loading? (React, Babel, etc.)
3. Check browser console for errors
4. Try hard refresh (Ctrl+Shift+R)

### "Everything is on fire" 🔥

1. Check server logs: `tail -f opcua_server.log`
2. Check browser console: F12 → Console tab
3. Test API manually: `curl http://localhost:5000/api/tags`
4. Restart the server: `python opcua_server.py`
5. Clear browser cache
6. Sacrifice a rubber duck to the debugging gods

---

## 🎯 Future Enhancements

### Coming Soon™

- **Tag Value Writing** - Modify tag values from the UI
- **Historical Charts** - InfluxDB integration with trend graphs
- **Configuration Editor** - Edit JSON configs through the UI
- **Log Viewer** - Real-time server logs
- **Alarm Acknowledgment** - Acknowledge and clear alarms
- **Tag Import/Export** - Bulk tag management
- **Dark/Light Mode Toggle** - For the 3 people who prefer light mode
- **Mobile Responsive** - Works on tablets/phones
- **Multi-User Support** - Different permission levels
- **Dashboard Customization** - Drag-and-drop widgets

### Wish List

- **Automatic Tag Discovery** - Scan OPC UA servers
- **Tag Grouping** - Organize tags into categories
- **Custom Dashboards** - Build your own views
- **Notification Center** - In-app notifications for alarms
- **System Health Metrics** - CPU, memory, network stats
- **Backup/Restore** - Config backup and restore
- **Multi-Language** - i18n support (if we go global)

---

## 📊 Performance Tips

### For Many Tags (1000+)

1. **Enable Pagination:**
   - Modify `TagsView` to only show 50 tags at a time
   - Add "Next/Previous" buttons

2. **Increase Update Interval:**
   - Change from 2s to 5s or 10s
   - Only update on user interaction

3. **Filter Displayed Tags:**
   - Add search/filter functionality
   - Only render visible tags

### For Slow Networks

1. **Use WebSocket Instead of Polling:**
   - Enable WebSocket publisher
   - Switch to push-based updates
   - Reduces HTTP overhead

2. **Compress Responses:**
   - Enable gzip in Flask
   - Reduces payload size

3. **CDN Alternatives:**
   - Host React/Babel locally instead of CDN
   - Faster load times on slow connections

---

## 🏆 Best Practices

### Do's ✅

- **Monitor the Dashboard** - It's literally what it's for
- **Test Publisher Changes** - Toggle in dev before production
- **Keep Browser Tab Open** - Auto-updates stop when you close it
- **Use Modern Browser** - Chrome/Firefox/Edge (not IE11)
- **Check Logs** - Server logs tell you everything

### Don'ts ❌

- **Don't Disable REST API** - You'll lock yourself out
- **Don't Refresh Rapidly** - 2-second updates are enough
- **Don't Ignore Alarms** - They're there for a reason
- **Don't Run Without Network Security** - At least use a firewall
- **Don't Trust the UI Blindly** - Verify critical values

---

## 🎓 FAQ

**Q: Why React instead of Vue?**
A: Both are great. React has slightly better CDN support and I know it better. Feel free to port to Vue if you want.

**Q: Why no TypeScript?**
A: Keeping it simple. No build step = easy deployment. Want TypeScript? Fork it and add a build pipeline.

**Q: Can I use this in production?**
A: Sure, but add proper security first. And maybe use a real WSGI server instead of Flask dev mode.

**Q: Will you add feature X?**
A: Maybe? Open an issue or submit a PR. Or fork it and do it yourself - it's your code now.

**Q: Why is it called EmberBurn?**
A: Because "Industrial IoT Gateway Web UI" is boring, and marketing said we needed a brand.

**Q: Can I change the ASCII art?**
A: Absolutely! It's just text in the HTML. Go wild. Make it say "SKYNET" for all I care.

**Q: Is this better than editing JSON?**
A: For most people, yes. For vim enthusiasts, nothing beats JSON. To each their own.

---

## 🙏 Credits

Built with:
- **React** - Facebook's gift to web developers
- **Recharts** - Beautiful charts without the pain
- **Flask** - Python's micro-framework (not so micro anymore)
- **Lucide Icons** - Clean, modern icons
- **Coffee** - The real MVP
- **Late Nights** - Too many to count

---

## 📝 License

Same as the main project. Use it, modify it, ship it to production. Just don't sue me if your plant explodes.

---

**Remember:** This UI is a tool, not a crutch. Learn how the underlying systems work. Understand the protocols. Read the logs. Be a better engineer.

But also, enjoy the pretty dashboard. We worked hard on it. 🔥

---

*Built with 🔥 by Patrick Ryan, CTO - Fireball Industries*

*"Making Industrial IoT Sexy Since 2026"*
