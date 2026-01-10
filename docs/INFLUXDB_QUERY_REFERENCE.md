# InfluxDB Flux Query Quick Reference

*Quick copy-paste queries for common tasks*

## Basic Queries

### Get last value of a tag
```flux
from(bucket: "industrial-data")
  |> range(start: -5m)
  |> filter(fn: (r) => r._measurement == "opcua_tags")
  |> filter(fn: (r) => r.tag == "Temperature")
  |> filter(fn: (r) => r._field == "value")
  |> last()
```

### Get all tags (last hour)
```flux
from(bucket: "industrial-data")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "opcua_tags")
  |> filter(fn: (r) => r._field == "value")
```

### Get specific tag with time range
```flux
from(bucket: "industrial-data")
  |> range(start: v.timeRangeStart, stop: v.timeRangeStop)
  |> filter(fn: (r) => r._measurement == "opcua_tags")
  |> filter(fn: (r) => r.tag == "Temperature")
  |> filter(fn: (r) => r._field == "value")
  |> aggregateWindow(every: v.windowPeriod, fn: mean, createEmpty: false)
```

## Aggregations

### Average by minute
```flux
from(bucket: "industrial-data")
  |> range(start: -1h)
  |> filter(fn: (r) => r.tag == "Temperature")
  |> aggregateWindow(every: 1m, fn: mean, createEmpty: false)
```

### Min/Max/Mean for a time range
```flux
from(bucket: "industrial-data")
  |> range(start: -24h)
  |> filter(fn: (r) => r.tag == "Temperature")
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

## Filtering

### Multiple tags
```flux
from(bucket: "industrial-data")
  |> range(start: -1h)
  |> filter(fn: (r) => r.tag == "Temperature" or r.tag == "Pressure")
```

### By location (global tags)
```flux
from(bucket: "industrial-data")
  |> range(start: -1h)
  |> filter(fn: (r) => r.location == "factory_floor")
```

### Values above threshold
```flux
from(bucket: "industrial-data")
  |> range(start: -1h)
  |> filter(fn: (r) => r.tag == "Temperature")
  |> filter(fn: (r) => r._value > 24.0)
```

## Advanced

### Calculate rate of change
```flux
from(bucket: "industrial-data")
  |> range(start: -1h)
  |> filter(fn: (r) => r.tag == "Temperature")
  |> derivative(unit: 1m, nonNegative: false)
```

### Pivot (tags as columns)
```flux
from(bucket: "industrial-data")
  |> range(start: -1h)
  |> filter(fn: (r) => r._field == "value")
  |> pivot(rowKey:["_time"], columnKey: ["tag"], valueColumn: "_value")
```

### Compare current vs previous hour
```flux
current = from(bucket: "industrial-data")
  |> range(start: -1h)
  |> filter(fn: (r) => r.tag == "Temperature")

previous = from(bucket: "industrial-data")
  |> range(start: -2h, stop: -1h)
  |> filter(fn: (r) => r.tag == "Temperature")
  |> timeShift(duration: 1h)

union(tables: [current, previous])
```

## Grafana Variables

### Get all tag names
```flux
import "influxdata/influxdb/schema"

schema.tagValues(
  bucket: "industrial-data",
  tag: "tag"
)
```

### Get all locations
```flux
import "influxdata/influxdb/schema"

schema.tagValues(
  bucket: "industrial-data",
  tag: "location"
)
```

## CLI Queries

### Query from command line
```bash
influx query 'from(bucket:"industrial-data") |> range(start:-1h) |> limit(n:10)'
```

### Export to CSV
```bash
influx query 'from(bucket:"industrial-data") |> range(start:-24h)' --raw > data.csv
```

---

*Keep this handy - you'll use these constantly*
