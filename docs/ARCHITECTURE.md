# Architecture Overview

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                       OPC UA Server Core                        │
│                     (opcua_server.py)                           │
│                                                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐           │
│  │ Temperature │  │  Pressure   │  │   Counter   │  ...      │
│  │   (Float)   │  │   (Float)   │  │    (Int)    │           │
│  └─────────────┘  └─────────────┘  └─────────────┘           │
│         │                 │                 │                  │
│         └─────────────────┴─────────────────┘                  │
│                           │                                     │
│                    Tag Updates                                 │
│                           ↓                                     │
│                 ┌──────────────────┐                           │
│                 │ Publisher Manager│                           │
│                 │  (publishers.py) │                           │
│                 └──────────────────┘                           │
│                           │                                     │
│         ┌─────────────────┼─────────────────┐                 │
│         ↓                 ↓                 ↓                   │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐           │
│  │    MQTT     │  │  REST API   │  │  WebSocket  │           │
│  │  Publisher  │  │  Publisher  │  │  (Future)   │           │
│  └─────────────┘  └─────────────┘  └─────────────┘           │
└─────────────────────────────────────────────────────────────────┘
         │                 │                 │
         ↓                 ↓                 ↓
┌─────────────────────────────────────────────────────────────────┐
│                        External Systems                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  MQTT Broker          Web Apps/APIs       WebSocket Clients    │
│  ┌──────────┐         ┌──────────┐        ┌──────────┐        │
│  │ Eclipse  │         │  React   │        │ Browser  │        │
│  │Mosquitto │         │Dashboard │        │   UI     │        │
│  └──────────┘         └──────────┘        └──────────┘        │
│       │                    │                    │              │
│       ↓                    ↓                    ↓              │
│  IoT Devices          Analytics         Real-time Display      │
│  Cloud Platforms      Data Storage       Monitoring            │
│  Node-RED             Business Logic     Visualization         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Data Flow

```
1. Tag Simulation
   ┌──────────────────────────────────────┐
   │ OPC UA Server generates tag values:  │
   │  • Random values                     │
   │  • Sine waves                        │
   │  • Incrementing counters             │
   │  • Static values                     │
   └──────────────────────────────────────┘
                  ↓
2. Tag Update Event
   ┌──────────────────────────────────────┐
   │ Every UPDATE_INTERVAL seconds:       │
   │  • update_tags() called              │
   │  • New values calculated             │
   │  • Timestamp added                   │
   └──────────────────────────────────────┘
                  ↓
3. Publish to All Protocols
   ┌──────────────────────────────────────┐
   │ publisher_manager.publish_to_all()   │
   │  ↓         ↓         ↓               │
   │ MQTT    REST API  WebSocket          │
   └──────────────────────────────────────┘
                  ↓
4. Protocol-Specific Handling
   ┌──────────────────────────────────────┐
   │ MQTT:                                │
   │  • Format as JSON                    │
   │  • Publish to topic                  │
   │  • Topic: prefix/tag_name            │
   │                                      │
   │ REST API:                            │
   │  • Update in-memory cache            │
   │  • Available via GET /api/tags       │
   │                                      │
   │ Future protocols...                  │
   └──────────────────────────────────────┘
```

## Configuration Flow

```
config/config_with_mqtt.json
           │
           ├─→ "tags" section
           │      │
           │      └─→ OPC UA Server
           │             │
           │             └─→ Creates OPC UA variables
           │
           └─→ "publishers" section
                  │
                  ├─→ "mqtt" config
                  │      └─→ MQTTPublisher
                  │
                  ├─→ "rest_api" config
                  │      └─→ RESTAPIPublisher
                  │
                  └─→ [Future publisher configs]
```

## Class Structure

```
┌──────────────────────────────────┐
│       DataPublisher (ABC)        │
│  Base class for all publishers   │
├──────────────────────────────────┤
│ + start()                        │
│ + stop()                         │
│ + publish(tag, value, timestamp) │
└──────────────────────────────────┘
            △
            │ Inherits
   ┌────────┴────────┬──────────────┐
   │                 │              │
┌──────────┐  ┌──────────┐  ┌──────────────┐
│  MQTT    │  │   REST   │  │  WebSocket   │
│Publisher │  │  API     │  │  Publisher   │
│          │  │Publisher │  │  (Future)    │
└──────────┘  └──────────┘  └──────────────┘

┌──────────────────────────────────┐
│      PublisherManager            │
│  Orchestrates all publishers     │
├──────────────────────────────────┤
│ + initialize_publishers()        │
│ + start_all()                    │
│ + stop_all()                     │
│ + publish_to_all()               │
└──────────────────────────────────┘
```

## MQTT Message Format

### JSON Format (Default)
```json
{
  "tag": "Temperature",
  "value": 22.5,
  "timestamp": 1736476800.123
}
```

### String Format (Optional)
```
22.5
```

**Topic Structure:**
```
{topic_prefix}/{tag_name}

Example:
industrial/opcua/Temperature
industrial/opcua/Pressure
industrial/opcua/Counter
```

## REST API Response Format

### GET /api/tags
```json
{
  "tags": {
    "Temperature": {
      "value": 22.5,
      "timestamp": 1736476800.123
    },
    "Pressure": {
      "value": 101.3,
      "timestamp": 1736476800.124
    }
  },
  "count": 2
}
```

### GET /api/tags/Temperature
```json
{
  "value": 22.5,
  "timestamp": 1736476800.123
}
```

## Deployment Scenarios

### Scenario 1: Edge Device with Cloud MQTT
```
┌─────────────────┐
│  Edge Device    │
│  ┌───────────┐  │       ┌─────────────┐
│  │ OPC UA    │  │       │ Cloud MQTT  │
│  │ Server    │──┼──────→│ (AWS IoT)   │
│  └───────────┘  │       └─────────────┘
│                 │              ↓
└─────────────────┘       ┌─────────────┐
                          │ Analytics   │
                          │ Dashboard   │
                          └─────────────┘
```

### Scenario 2: Local SCADA + Web Dashboard
```
┌─────────────────────────────────────┐
│       Local Network                 │
│                                     │
│  ┌──────────┐                       │
│  │ OPC UA   │                       │
│  │ Server   │                       │
│  └─────┬────┘                       │
│        │                            │
│    ┌───┴────┬────────┐             │
│    ↓        ↓        ↓             │
│  ┌───┐  ┌─────┐  ┌──────┐          │
│  │OPC│  │MQTT │  │ REST │          │
│  │UA │  │Broker│  │ API  │          │
│  └───┘  └─────┘  └──────┘          │
│    │       │        │               │
│    ↓       ↓        ↓               │
│  SCADA   IoT     Web App            │
│  System  Devices Dashboard          │
│                                     │
└─────────────────────────────────────┘
```

### Scenario 3: Multi-Site Integration
```
Site A              Site B              Cloud
┌──────────┐       ┌──────────┐       ┌──────────┐
│ OPC UA   │       │ OPC UA   │       │  MQTT    │
│ Server   │───────┼─ Server  │───────┤  Broker  │
│   +      │ MQTT  │    +     │ MQTT  │          │
│Publishers│       │Publishers│       │          │
└──────────┘       └──────────┘       └────┬─────┘
                                           │
                                           ↓
                                    ┌──────────────┐
                                    │ Centralized  │
                                    │  Analytics   │
                                    └──────────────┘
```

## Extension Points

### Adding a New Publisher

1. Create new class extending `DataPublisher`:
```python
class KafkaPublisher(DataPublisher):
    def start(self):
        # Initialize Kafka producer
        pass
    
    def stop(self):
        # Close Kafka connection
        pass
    
    def publish(self, tag_name, value, timestamp):
        # Send to Kafka topic
        pass
```

2. Register in `PublisherManager.initialize_publishers()`:
```python
kafka_config = publishers_config.get("kafka", {})
if kafka_config.get("enabled", False):
    kafka_pub = KafkaPublisher(kafka_config, self.logger)
    self.publishers.append(kafka_pub)
```

3. Add configuration section:
```json
{
  "publishers": {
    "kafka": {
      "enabled": true,
      "bootstrap_servers": "localhost:9092",
      "topic": "industrial-data"
    }
  }
}
```

## Security Considerations

```
┌────────────────────────────────────────┐
│         Security Layers                │
├────────────────────────────────────────┤
│ OPC UA:                                │
│  • Network isolation                   │
│  • Authentication (future)             │
│                                        │
│ MQTT:                                  │
│  • TLS/SSL encryption                  │
│  • Username/password auth              │
│  • Certificate-based auth              │
│                                        │
│ REST API:                              │
│  • CORS configuration                  │
│  • HTTPS (via reverse proxy)           │
│  • API keys (future)                   │
│  • Rate limiting (future)              │
└────────────────────────────────────────┘
```

## Performance Characteristics

| Component | Typical Latency | Throughput |
|-----------|----------------|------------|
| OPC UA Update | ~1-2ms | 1000+ tags/sec |
| MQTT Publish | ~5-10ms | 10000+ msgs/sec |
| REST API | ~10-50ms | 1000+ req/sec |
| Total Tag Update | ~20-100ms | Depends on publishers |

**Bottlenecks:**
- Network latency (MQTT, REST)
- Simulation complexity
- Number of enabled publishers
- Update interval configuration

**Optimizations:**
- Disable unused publishers
- Increase update interval for less critical tags
- Use QoS 0 for non-critical MQTT data
- Cache REST API responses
