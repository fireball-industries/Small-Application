# InfluxDB + Grafana Integration Guide

*By Patrick Ryan, CTO - Fireball Industries*  
*"Because 'what was the temperature 3 days ago?' is a question you WILL be asked"*

---

## What This Is

InfluxDB is a time-series database purpose-built for storing metrics, events, and analytics. Grafana is a visualization platform that makes pretty dashboards. Together, they're like peanut butter and jelly for industrial IoT.

This guide shows you how to:
1. Store OPC UA tag data in InfluxDB
2. Build sick Grafana dashboards
3. Query historical data
4. Set up alerting
5. Look like a hero when someone asks "what happened last Tuesday?"

**Why you want this:**
- Historical data storage (because memory fades, databases don't)
- Trend analysis (see patterns humans miss)
- Grafana dashboards (make stakeholders happy)
- Alerting (know when things go wrong)
- Compliance/audit trails (CYA in database form)

---

## Quick Start (The "Just Make It Work" Edition)

### Step 1: Install InfluxDB

**Using Docker (Recommended):**
```bash
docker run -d \
  --name influxdb \
  -p 8086:8086 \
  -v influxdb-data:/var/lib/influxdb2 \
  -e DOCKER_INFLUXDB_INIT_MODE=setup \
  -e DOCKER_INFLUXDB_INIT_USERNAME=admin \
  -e DOCKER_INFLUXDB_INIT_PASSWORD=fireball123 \
  -e DOCKER_INFLUXDB_INIT_ORG=fireball-industries \
  -e DOCKER_INFLUXDB_INIT_BUCKET=industrial-data \
  -e DOCKER_INFLUXDB_INIT_ADMIN_TOKEN=super-secret-token \
  influxdb:2.7
```

**Or install locally:**
- Download from: https://portal.influxdata.com/downloads/
- Run the installer
- Access UI at: http://localhost:8086

### Step 2: Create InfluxDB Token

1. Open InfluxDB UI: http://localhost:8086
2. Login with your credentials
3. Go to **Data → API Tokens**
4. Click **Generate API Token** → **All Access Token**
5. Copy the token (you'll need it)

### Step 3: Configure OPC UA Server

Edit your config file (or create `config_influxdb.json`):

```json
{
  "publishers": {
    "influxdb": {
      "enabled": true,
      "url": "http://localhost:8086",
      "token": "your-token-from-step-2",
      "org": "fireball-industries",
      "bucket": "industrial-data",
      "measurement": "opcua_tags",
      "batch_size": 100,
      "flush_interval": 1000,
      "tags": {
        "source": "opcua_server",
        "location": "factory_floor",
        "line": "line_1"
      }
    }
  }
}
```

**Config Options:**
- `url`: InfluxDB server URL
- `token`: API token from InfluxDB
- `org`: Organization name
- `bucket`: Bucket (database) name
- `measurement`: Measurement name (like a table)
- `batch_size`: Number of points to batch (default: 100)
- `flush_interval`: Milliseconds between flushes (default: 1000)
- `tags`: Global tags added to all data points (for filtering)

### Step 4: Install Dependencies

```bash
pip install influxdb-client
# Or
pip install -r requirements.txt
```

### Step 5: Start OPC UA Server

```bash
python opcua_server.py -c config/config_influxdb.json
```

You should see:
```
InfluxDB publisher started: http://localhost:8086 -> industrial-data
```

### Step 6: Verify Data is Flowing

**Using InfluxDB UI:**
1. Go to **Data Explorer**
2. Select bucket: `industrial-data`
3. Select measurement: `opcua_tags`
4. Click **Submit**
5. See your beautiful data

**Using Flux Query:**
```flux
from(bucket: "industrial-data")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "opcua_tags")
  |> filter(fn: (r) => r.tag == "Temperature")
```

---

## Grafana Setup

### Install Grafana

**Using Docker:**
```bash
docker run -d \
  --name grafana \
  -p 3000:3000 \
  -v grafana-storage:/var/lib/grafana \
  grafana/grafana:10.2.3
```

**Or install locally:**
- Download from: https://grafana.com/grafana/download
- Run the installer
- Access UI at: http://localhost:3000
- Default login: `admin/admin`

### Add InfluxDB Data Source

1. Open Grafana: http://localhost:3000
2. Go to **Configuration → Data Sources**
3. Click **Add data source**
4. Select **InfluxDB**
5. Configure:
   - **Query Language:** Flux
   - **URL:** http://localhost:8086
   - **Organization:** fireball-industries
   - **Token:** (your InfluxDB token)
   - **Default Bucket:** industrial-data
6. Click **Save & Test**

Should see: ✅ "Data source is working"

---

## Creating Dashboards

### Quick Dashboard (1-Minute Setup)

1. Click **+ → Dashboard**
2. Click **Add visualization**
3. Select your InfluxDB data source
4. Use this Flux query:

```flux
from(bucket: "industrial-data")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "opcua_tags")
  |> filter(fn: (r) => r._field == "value")
  |> aggregateWindow(every: 10s, fn: mean, createEmpty: false)
```

5. Click **Apply**
6. Repeat for each tag you want to visualize

### Better Dashboard (With Variables)

**Create Variable for Tag Selection:**

1. Go to **Dashboard Settings → Variables**
2. Click **Add variable**
3. Configure:
   - **Name:** `tag_name`
   - **Type:** Query
   - **Data source:** InfluxDB
   - **Query:**
   ```flux
   import "influxdata/influxdb/schema"
   
   schema.tagValues(
     bucket: "industrial-data",
     tag: "tag"
   )
   ```
4. Save

**Create Panel with Variable:**

```flux
from(bucket: "industrial-data")
  |> range(start: v.timeRangeStart, stop: v.timeRangeStop)
  |> filter(fn: (r) => r._measurement == "opcua_tags")
  |> filter(fn: (r) => r.tag == "${tag_name}")
  |> filter(fn: (r) => r._field == "value")
  |> aggregateWindow(every: v.windowPeriod, fn: mean, createEmpty: false)
```

Now you have a dropdown to select different tags!

---

## Example Dashboards

### Manufacturing Dashboard

**Panels:**
1. **Current Values** (Stat panel)
   ```flux
   from(bucket: "industrial-data")
     |> range(start: -5m)
     |> filter(fn: (r) => r._measurement == "opcua_tags")
     |> filter(fn: (r) => r._field == "value")
     |> last()
   ```

2. **Trend Graph** (Time series)
   ```flux
   from(bucket: "industrial-data")
     |> range(start: v.timeRangeStart, stop: v.timeRangeStop)
     |> filter(fn: (r) => r._measurement == "opcua_tags")
     |> filter(fn: (r) => r._field == "value")
     |> aggregateWindow(every: 1m, fn: mean, createEmpty: false)
   ```

3. **Production Counter** (Counter panel)
   ```flux
   from(bucket: "industrial-data")
     |> range(start: -24h)
     |> filter(fn: (r) => r._measurement == "opcua_tags")
     |> filter(fn: (r) => r.tag == "Counter")
     |> filter(fn: (r) => r._field == "value_int")
     |> max()
   ```

4. **Tag Heatmap** (Heatmap)
   ```flux
   from(bucket: "industrial-data")
     |> range(start: -24h)
     |> filter(fn: (r) => r._measurement == "opcua_tags")
     |> filter(fn: (r) => r.tag == "Temperature")
     |> aggregateWindow(every: 1h, fn: mean, createEmpty: false)
   ```

### Process Monitoring Dashboard

**Temperature Gauge:**
- Visualization: Gauge
- Query: Last value of Temperature tag
- Thresholds: Green (15-20), Yellow (20-23), Red (>23)

**Pressure Timeline:**
- Visualization: Time series
- Query: Pressure over last 6 hours
- Alert when > 102 kPa

**Flow Rate with Annotations:**
```flux
from(bucket: "industrial-data")
  |> range(start: -2h)
  |> filter(fn: (r) => r._measurement == "opcua_tags")
  |> filter(fn: (r) => r.tag == "FlowRate")
  |> filter(fn: (r) => r._field == "value")
```

---

## Advanced Queries

### Calculate Average by Hour

```flux
from(bucket: "industrial-data")
  |> range(start: -24h)
  |> filter(fn: (r) => r._measurement == "opcua_tags")
  |> filter(fn: (r) => r.tag == "Temperature")
  |> aggregateWindow(every: 1h, fn: mean, createEmpty: false)
```

### Compare Today vs Yesterday

```flux
today = from(bucket: "industrial-data")
  |> range(start: today(), stop: now())
  |> filter(fn: (r) => r.tag == "Temperature")
  |> aggregateWindow(every: 1h, fn: mean, createEmpty: false)

yesterday = from(bucket: "industrial-data")
  |> range(start: -24h, stop: today())
  |> filter(fn: (r) => r.tag == "Temperature")
  |> aggregateWindow(every: 1h, fn: mean, createEmpty: false)
  |> timeShift(duration: 24h)

union(tables: [today, yesterday])
```

### Find Min/Max/Mean for Last Week

```flux
from(bucket: "industrial-data")
  |> range(start: -7d)
  |> filter(fn: (r) => r._measurement == "opcua_tags")
  |> filter(fn: (r) => r.tag == "Pressure")
  |> group(columns: ["tag"])
  |> reduce(
      fn: (r, accumulator) => ({
        min: if r._value < accumulator.min then r._value else accumulator.min,
        max: if r._value > accumulator.max then r._value else accumulator.max,
        sum: accumulator.sum + r._value,
        count: accumulator.count + 1.0
      }),
      identity: {min: 999999.0, max: -999999.0, sum: 0.0, count: 0.0}
    )
  |> map(fn: (r) => ({
      min: r.min,
      max: r.max,
      mean: r.sum / r.count
    }))
```

### Detect Anomalies (Sudden Changes)

```flux
from(bucket: "industrial-data")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "opcua_tags")
  |> filter(fn: (r) => r.tag == "Temperature")
  |> derivative(unit: 1m, nonNegative: false)
  |> map(fn: (r) => ({
      r with
      is_spike: if math.abs(x: r._value) > 5.0 then "SPIKE" else "normal"
    }))
```

---

## Alerting in Grafana

### Setup Alert Rule

1. **Create Alert Panel:**
   - Add new panel
   - Configure query for what you want to monitor
   - Go to **Alert** tab
   - Click **Create Alert**

2. **Configure Conditions:**
   ```
   WHEN last() OF query(A, 5m, now)
   IS ABOVE 100
   ```

3. **Configure Notifications:**
   - Go to **Alerting → Contact Points**
   - Add Email, Slack, or Webhook
   - Link to alert rule

### Example: High Temperature Alert

**Query:**
```flux
from(bucket: "industrial-data")
  |> range(start: -5m)
  |> filter(fn: (r) => r._measurement == "opcua_tags")
  |> filter(fn: (r) => r.tag == "Temperature")
  |> last()
```

**Alert Condition:**
- If Temperature > 24°C for 2 minutes
- Send to: email, Slack

**Alert Message:**
```
🚨 High Temperature Alert!
Value: {{ $values.Temperature }}°C
Threshold: 24°C
Time: {{ $timestamp }}
```

---

## Data Retention & Downsampling

### Configure Retention Policy

InfluxDB automatically manages retention through **Tasks**.

**Example: Keep raw data for 7 days, downsampled for 1 year**

1. Go to **Tasks** in InfluxDB UI
2. Create new task:

```flux
option task = {name: "Downsample to hourly", every: 1h}

from(bucket: "industrial-data")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "opcua_tags")
  |> aggregateWindow(every: 1h, fn: mean, createEmpty: false)
  |> to(bucket: "industrial-data-hourly")
```

3. Create bucket for downsampled data with 1-year retention
4. Update Grafana queries to use downsampled bucket for long time ranges

---

## Performance Tips

1. **Use Appropriate Flush Intervals:**
   - High-frequency tags: 500-1000ms
   - Low-frequency tags: 2000-5000ms
   - Balance between latency and database load

2. **Tag vs Field:**
   - Use tags for metadata (tag name, location, line)
   - Use fields for measurements (value, value_int, value_float)
   - Tags are indexed, fields are not

3. **Batch Writes:**
   - Default batch_size: 100 is good for most cases
   - Increase for high-volume scenarios
   - Decrease for real-time requirements

4. **Query Optimization:**
   - Always use time ranges
   - Filter early in the query
   - Use aggregateWindow for large datasets
   - Limit data returned with |> limit(n: 1000)

---

## Troubleshooting

### "Failed to start InfluxDB publisher"

**Check:**
- Is InfluxDB running? `docker ps` or check service
- Is URL correct? Try accessing http://localhost:8086 in browser
- Is token valid? Test in InfluxDB UI
- Firewall blocking port 8086?

### "No data in InfluxDB"

**Debug:**
```bash
# Check OPC UA server logs
tail -f logs/opcua_server.log

# Verify InfluxDB is receiving writes
docker logs influxdb

# Query directly
influx query 'from(bucket:"industrial-data") |> range(start:-1h) |> limit(n:10)'
```

### "Grafana can't connect to InfluxDB"

**Fix:**
- If using Docker for both: use `http://influxdb:8086` instead of localhost
- Check network connectivity: `docker network ls`
- Verify token has read permissions
- Try "Save & Test" in data source settings

### "Grafana shows 'No Data'"

**Checklist:**
- ✅ Time range includes data (try "Last 24 hours")
- ✅ Bucket name is correct
- ✅ Measurement name matches ("opcua_tags")
- ✅ Field name is correct ("value", "value_float", etc.)
- ✅ Data actually exists (check in InfluxDB UI)

---

## Docker Compose Setup (All-in-One)

Create `docker-compose.yml`:

```yaml
version: '3.8'

services:
  influxdb:
    image: influxdb:2.7
    container_name: influxdb
    ports:
      - "8086:8086"
    environment:
      - DOCKER_INFLUXDB_INIT_MODE=setup
      - DOCKER_INFLUXDB_INIT_USERNAME=admin
      - DOCKER_INFLUXDB_INIT_PASSWORD=fireball123
      - DOCKER_INFLUXDB_INIT_ORG=fireball-industries
      - DOCKER_INFLUXDB_INIT_BUCKET=industrial-data
      - DOCKER_INFLUXDB_INIT_ADMIN_TOKEN=super-secret-token
    volumes:
      - influxdb-data:/var/lib/influxdb2
    networks:
      - industrial

  grafana:
    image: grafana/grafana:10.2.3
    container_name: grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=fireball123
    volumes:
      - grafana-data:/var/lib/grafana
    networks:
      - industrial
    depends_on:
      - influxdb

volumes:
  influxdb-data:
  grafana-data:

networks:
  industrial:
    driver: bridge
```

**Start everything:**
```bash
docker-compose up -d
```

**Access:**
- InfluxDB: http://localhost:8086 (admin/fireball123)
- Grafana: http://localhost:3000 (admin/fireball123)

---

## Production Recommendations

1. **Security:**
   - Use HTTPS for InfluxDB and Grafana
   - Strong passwords/tokens (not "fireball123")
   - Restrict network access
   - Enable authentication

2. **Backup:**
   - Regular InfluxDB backups
   - Export Grafana dashboards to JSON
   - Store configs in version control

3. **Monitoring:**
   - Monitor InfluxDB disk usage
   - Set up retention policies
   - Alert on write failures

4. **Scalability:**
   - Use InfluxDB clustering for high availability
   - Consider InfluxDB Cloud for managed solution
   - Implement data downsampling

---

## Example: Complete Manufacturing Setup

**Scenario:** Monitor production line with 20 tags

**InfluxDB Config:**
```json
{
  "influxdb": {
    "enabled": true,
    "url": "http://influxdb:8086",
    "token": "production-token",
    "org": "factory-ops",
    "bucket": "line-1-data",
    "measurement": "sensors",
    "tags": {
      "line": "line_1",
      "location": "building_a",
      "shift": "day"
    }
  }
}
```

**Grafana Dashboard Panels:**
1. **Production Rate** (last hour)
2. **Temperature Trends** (all zones)
3. **Downtime Analysis** (based on IsRunning tag)
4. **Quality Metrics** (defect rate from Counter)
5. **Alarm History** (threshold violations)

**Alerts:**
- Temperature > 30°C: Email maintenance team
- Production stopped > 5min: SMS supervisor
- Pressure out of range: Slack channel

---

## Resources

**InfluxDB:**
- Docs: https://docs.influxdata.com/
- Flux language: https://docs.influxdata.com/flux/
- Community: https://community.influxdata.com/

**Grafana:**
- Docs: https://grafana.com/docs/
- Dashboard examples: https://grafana.com/grafana/dashboards/
- Plugins: https://grafana.com/grafana/plugins/

**This Project:**
- InfluxDB publisher: `publishers.py` (InfluxDBPublisher class)
- Example config: `config/config_influxdb.json`
- Flux query examples: (this doc)

---

## Conclusion

InfluxDB + Grafana transforms your OPC UA server from "data provider" to "industrial intelligence platform." You get:

✅ Historical data storage  
✅ Beautiful dashboards  
✅ Real-time monitoring  
✅ Alerting capabilities  
✅ Compliance documentation  
✅ The ability to answer "what happened?" questions  

Now go build some dashboards and make your stakeholders think you're a wizard.

---

*Last updated: 2026-01-10*  
*Written with moderate enthusiasm and multiple Grafana theme changes*

**Patrick Ryan**  
*CTO, Fireball Industries*  
*"Turning time-series data into time-series insights since 2024"*
