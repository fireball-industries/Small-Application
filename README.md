# 🔥 EMBERBURN 🔥
### The Industrial Simulator That Got Completely Out of Hand

> **By Patrick Ryan, CTO @ Fireball Industries**
>
> *"I started building a simple OPC UA server. I blacked out. When I came to, it supported 15 protocols and had a web UI. I regret nothing."*

---

Look, you clicked on this repo, so either you're into industrial automation, you Googled something cursed, or GitHub's algorithm finally snapped. Either way — welcome. Buckle up. This README is the only therapy session you're getting.

## So What the Hell Is This?

Emberburn is a **fully simulated industrial data gateway** written in Python. It pretends to be an entire factory floor so you don't have to buy one. It generates fake-but-realistic OPC UA tag data — temperatures, pressures, counters, booleans, strings, the whole nine yards — and then absolutely **firehoses** that data out to every protocol known to mankind.

Think of it as a digital twin, except the twin has ADHD and subscriptions to 15 different messaging services.

**The core loop is stupidly simple:**
1. Spin up an OPC UA server
2. Create tags that simulate industrial data (random noise, sine waves, incrementing counters, or just... sit there)
3. Publish that data to literally whatever protocol your stakeholders are asking about this week
4. Serve it all through a sleek fire-themed web dashboard because we're not animals

That's it. That's the app. The rest is just scope creep that I've chosen to rebrand as "features."

## Why Does This Exist?

Because every industrial automation engineer has had this exact conversation:

> **You:** "I need test data to develop against."
>
> **Your Boss:** "Just connect to the production PLC."
>
> **You:** "The one controlling the $4 million press that will literally crush things if I mess up?"
>
> **Your Boss:** "Yeah that one."
>
> **You:** *(opens laptop, starts building Emberburn)*

Real PLCs cost money. Real SCADA systems cost *more* money. Real production environments cost "update your resume" money when you break them. Emberburn costs you nothing but the mass of Python packages currently having a party in your virtual environment.

**Use it for:**
- 🧪 **Development** — Build and test your OPC UA clients against something that won't fire you
- 🎭 **Demos** — Impress stakeholders with "live data" that has a 100% uptime SLA (it's fake, it literally can't fail)
- 🔌 **Integration Testing** — Validate your SCADA/HMI/historian pipelines without holding anyone's production environment hostage
- 📚 **Training** — Teach people OPC UA without needing a $50K PLC training rig
- 🌉 **Protocol Bridging** — OPC UA to MQTT? OPC UA to Kafka? OPC UA to carrier pigeon? (okay not that last one... yet)
- 💀 **Chaos Engineering** — Send garbage data to your systems on purpose and see what happens. Growth mindset.

## The Protocol Addiction Problem (15 and Counting)

What started as "let me add MQTT real quick" has spiraled into something my therapist would describe as "concerning." Here's the full damage report:

| Protocol | What It Does | Why I Added It | Emotional State When I Added It |
|----------|-------------|----------------|-------------------------------|
| **OPC UA Server** | The core. Serves tags to any OPC UA client. | This was the original idea. Pure. Innocent. | 😊 Hopeful |
| **MQTT** | Publishes tag data to any MQTT broker | "IoT is the future" | 🤔 Optimistic |
| **Sparkplug B** | Native Ignition Edge protocol | "Inductive will love this" | 😏 Strategic |
| **REST API** | HTTP endpoints for tag CRUD | "Even my PM knows what REST is" | 😐 Practical |
| **GraphQL** | Modern query interface for tags | "REST is so 2015" | 🧐 Pretentious |
| **Apache Kafka** | Enterprise event streaming | "I need to justify my Confluent subscription" | 💼 Corporate |
| **AMQP (RabbitMQ)** | Enterprise message queuing | "The rabbit just keeps hopping" | 🐰 Unhinged |
| **WebSocket** | Real-time browser push | "Dashboards should dance" | 💃 Vibing |
| **MODBUS TCP** | Legacy PLC and SCADA comms | "Respect your elders (even from 1979)" | 👴 Nostalgic |
| **InfluxDB** | Time-series database storage | "I should probably store this somewhere" | 📊 Responsible |
| **Prometheus** | Operational metrics endpoint | "Gotta monitor the thing that monitors things" | 🤯 Meta |
| **OPC UA Client** | Push data TO other OPC UA servers | "Bidirectional baby" | 🔄 Chaotic |
| **Alarms** | Threshold alerting via email/Slack/SMS | "Wake me up at 3AM, I dare you" | 😴 Masochistic |
| **SQLite Persistence** | Local historical storage + audit logs | "Data should survive a reboot, probably" | 🗄️ Adulting |
| **Data Transformation** | Unit conversion, scaling, computed tags | "Math is a protocol now, fight me" | 🧮 Deranged |

All of these run **simultaneously**. At the same time. In the same process. Like a one-man-band at the intersection of DevOps and industrial automation. Is it beautiful? Debatable. Does it work? Absolutely. Will I add more? My keyboard is warm and my impulse control is nonexistent.

## The Tag System (Where the Magic Happens)

Tags are the heartbeat of any industrial system, and Emberburn lets you define them all through JSON config files because YAML had its chance and blew it.

Every tag gets:
- **A data type** — `float`, `int`, `string`, `bool` — because the real world has variety
- **A simulation mode** — how the value changes over time:
  - `random` — Chaotic. Unpredictable. Like your sprint velocity.
  - `sine` — Smooth, oscillating, beautiful. Engineers get unreasonably excited about this one.
  - `increment` — Goes up. Resets at max. Repeat. The Sisyphus of simulation modes.
  - `static` — Doesn't change. For when you want your simulation to have the personality of a brick.
- **Min/max bounds** — Keep your fake data within the realm of plausibility (or don't, I'm not your dad)
- **Metadata** — Engineering units, descriptions, alarm thresholds, whatever you want to slap on there

Here's the vibe:

```json
{
  "tags": {
    "Reactor_Temperature": {
      "type": "float",
      "initial_value": 350.0,
      "simulate": true,
      "simulation_type": "sine",
      "min": 300.0,
      "max": 400.0,
      "description": "If this hits 500 we have bigger problems"
    },
    "Emergency_Stop": {
      "type": "bool",
      "initial_value": false,
      "simulate": false,
      "description": "The panic button. Static. Please stay false."
    }
  }
}
```

We've got example configs for days in the [config/](config/) directory — simple setups, full manufacturing simulations, process control scenarios, multi-protocol configs. Pick one, run it, feel powerful.

## The Web UI (It's Gorgeous and I'm Not Humble About It)

Emberburn ships with a full **Python Flask web application** — fire-themed dark mode, real-time dashboards, the works. No React. No webpack. No `node_modules` folder that weighs more than your actual code. Just Flask, Jinja2 templates, and vanilla JavaScript like the founding fathers intended.

**What you get:**
- 📊 **Dashboard** — Live metrics, tag counts, publisher statuses, and a general sense of accomplishment
- 🏷️ **Tag Monitor** — Every tag, every value, updating in real-time. It's like watching the Matrix but for industrial data.
- 📡 **Publishers** — See which protocols are running, enable/disable them, feel like a DJ mixing data streams
- 🚨 **Alarms** — Active alerts, alarm history, threshold configuration. Sleep is overrated anyway.
- ⚙️ **Configuration** — Edit settings without touching JSON files. We're civilized now.
- 🏗️ **Tag Generator** — Create new OPC UA tags from the browser. Point and click your way to industrial simulation.

The UI updates every 2 seconds because real-time means REAL TIME, and it's all wrapped in a dark mode fire aesthetic because we're EmberBurn, not EmberBoring.

## Architecture (For the Diagram People)

```
                        ┌─────────────────────────┐
                        │   JSON Configuration     │
                        │   (tags + publishers)     │
                        └────────────┬────────────┘
                                     │
                                     ▼
                        ┌─────────────────────────┐
                        │   OPC UA Server (Core)   │
                        │   Generates & manages    │
                        │   simulated tag data     │
                        └────────────┬────────────┘
                                     │
                                     ▼
                        ┌─────────────────────────┐
                        │   Publisher Manager       │
                        │   "The Traffic Cop"       │
                        └────────────┬────────────┘
                                     │
            ┌──────────┬─────────┬───┴───┬─────────┬──────────┐
            ▼          ▼         ▼       ▼         ▼          ▼
         ┌──────┐ ┌────────┐ ┌──────┐ ┌──────┐ ┌───────┐ ┌────────┐
         │ MQTT │ │  REST  │ │Kafka │ │MODBUS│ │GraphQL│ │InfluxDB│
         └──────┘ └────────┘ └──────┘ └──────┘ └───────┘ └────────┘
            │         │         │        │         │          │
     ...and Sparkplug B, AMQP, WebSocket, OPC UA Client,
        Prometheus, Alarms, SQLite, Data Transforms...

                        ┌─────────────────────────┐
                        │   🔥 EmberBurn Web UI    │
                        │   Flask + Jinja2 + JS    │
                        │   (fire-themed, yes)     │
                        └─────────────────────────┘
```

The OPC UA server is the brain. The Publisher Manager is the nervous system. Everything else is just... appendages we keep growing. Each publisher runs independently in its own thread. If one dies, the others keep vibing. It's the cockroach architecture — unkillable, persistent, slightly unnerving.

All publishers are **opt-in via config**. Don't want Kafka? Don't enable it. Don't have a RabbitMQ instance? Cool, AMQP stays asleep. The app only loads what you ask for. We're chaotic, not wasteful.

## Deployment (Many Flavors of "Run This Thing")

**Docker?** Yep. Multi-arch images for AMD64 and ARM64. Run it on a Raspberry Pi, an AWS Graviton instance, your M-series Mac, or that mysterious server in the closet that nobody admits to owning.

**Kubernetes/Helm?** Obviously. There's a full Helm chart with configurable values, persistent volume claims, service definitions, and enough YAML to make your eyes bleed (ironic, I know, since I trash-talked YAML earlier).

**Systemd?** Old school, I respect it. Service files included. Set it and forget it like a crockpot.

**Just... Python?** `pip install -r requirements.txt` and `python opcua_server.py`. You're an adult. I believe in you.

## Environment Variables

For the "I refuse to edit config files" crowd (honestly, same):

| Variable | Default | What It Does |
|----------|---------|-------------|
| `OPC_ENDPOINT` | `opc.tcp://0.0.0.0:4840/freeopcua/server/` | Where the OPC UA server lives |
| `OPC_SERVER_NAME` | `Python OPC UA Server` | The name your clients see |
| `OPC_NAMESPACE` | `http://opcua.edge.server` | OPC UA namespace URI |
| `OPC_DEVICE_NAME` | `EdgeDevice` | Device folder in the OPC UA tree |
| `UPDATE_INTERVAL` | `2` | How often tags update (seconds). Set to 0.1 if you hate your CPU. |

## Documentation (We Actually Wrote Some)

Look, I know nobody reads docs. But if you're going to ignore them, at least ignore the *right* ones:

**Understanding the System:**
- [Architecture Overview](docs/ARCHITECTURE_OVERVIEW.md) — How all the pieces fit together (with diagrams and everything)
- [Configuration Guide](docs/CONFIGURATION.md) — Every knob, switch, and lever explained
- [Multi-Protocol Summary](docs/MULTI_PROTOCOL_SUMMARY.md) — All 15 protocols, side by side, questioning my life choices
- [Protocol Comparison Guide](docs/PROTOCOL_GUIDE.md) — "Which protocol should I use?" answered once and for all

**The Web UI:**
- [EmberBurn Web UI Guide](docs/PYTHON_WEB_APP.md) — The Flask app in all its fire-themed glory
- [Web UI Features](docs/WEB_UI.md) — Complete feature documentation
- [Web UI Quick Start](docs/WEB_UI_QUICKSTART.md) — 60 seconds to dashboard nirvana

**Integration Guides (Pick Your Poison):**
- [Ignition Edge](docs/IGNITION_INTEGRATION.md) — Sparkplug B + OPC UA Client for Inductive's ecosystem
- [Node-RED](docs/NODERED_INTEGRATION.md) — Flow-based programming for the visual thinkers
- [MODBUS](docs/MODBUS_INTEGRATION.md) — Legacy PLC integration (1979 called, it wants its protocol back... but it still works)
- [OPC UA Client Mode](docs/OPCUA_CLIENT_INTEGRATION.md) — Push data to other OPC UA servers
- [GraphQL](docs/GRAPHQL_INTEGRATION.md) — For when REST feels too pedestrian
- [InfluxDB + Grafana](docs/INFLUXDB_GRAFANA_INTEGRATION.md) — Time-series storage and those dashboards your boss loves
- [Alarms & Notifications](docs/ALARMS_NOTIFICATIONS.md) — Get yelled at by email, Slack, or SMS when thresholds breach

**Advanced Stuff:**
- [Data Transformation](docs/DATA_TRANSFORMATION.md) — Unit conversions, scaling, computed tags
- [Prometheus Integration](docs/PROMETHEUS_INTEGRATION.md) — Monitor the thing that monitors things (inception)
- [SQLite Persistence](docs/SQLITE_PERSISTENCE.md) — Because data should survive a reboot
- [ARM64 Deployment](docs/ARM64_DEPLOYMENT.md) — Running on ARM because x86 is basic

## Project Structure

```
├── opcua_server.py       # The brain. Main OPC UA server + tag simulation engine.
├── publishers.py         # 3,800 lines of publisher madness. Every protocol lives here.
├── web_app.py            # Flask web UI blueprint. Fire-themed. No apologies.
├── tags_config.json      # Default tag config for the commitment-phobic.
├── requirements.txt      # The dependency party guest list.
├── Dockerfile            # Containerize it. Ship it. Forget it.
├── config/               # Pre-built configs for every scenario imaginable.
├── docs/                 # Extensive docs. Yes, really. I'm as surprised as you.
├── helm/                 # Kubernetes Helm chart. Enterprise-ready (allegedly).
├── static/               # CSS, JS, images for the web UI.
├── templates/            # Jinja2 templates. Server-side rendering like it's 2012 (complimentary).
├── scripts/              # Build scripts, install scripts, management scripts.
├── systemd/              # Service files for the systemd faithful.
└── web/                  # Static web assets.
```

## Contributing

Found a bug? Feature idea? Existential crisis about protocol selection? PRs are welcome. Just include:
- What you changed and why
- Tests if you're feeling heroic
- Your worst industrial automation horror story (mandatory)

Seriously though — if you have an idea, open an issue. The bar for "should we add this" is apparently on the floor, as evidenced by the 15 protocols currently in this repo.

## License

**MIT** — Do literally whatever you want with this. Fork it, ship it, tattoo the source code on your body. I'm not your mom and this is not legal advice.

## One Last Thing

This project started as a weekend hack to test some Ignition tags. It now has more protocols than most enterprise integration platforms, a full web UI, Helm charts, multi-arch Docker images, and documentation that I actually maintain. Feature creep isn't a bug — it's a lifestyle.

If Emberburn saves you from plugging your laptop into a production PLC and accidentally shutting down a conveyor belt (ask me how I know), then it was all worth it.

Star the repo if you're feeling generous. Open an issue if you're feeling brave. Add another protocol if you're feeling unhinged.

**Let's go.** 🔥

---

*Built by Patrick Ryan @ [Fireball Industries](https://github.com/embernet-ai) with mass quantities of caffeine, mass quantities of mass existential dread about industrial cybersecurity, and a mass refusal to stop adding protocols.*

*Made with ☕ and the kind of ambition that borders on a personality disorder.*
