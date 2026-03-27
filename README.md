# 🚀 Real-Time IoT Dashboard (v2.1.1)

A professional Full-Stack IoT monitoring system featuring **WebSockets**, **Node.js**, **Elasticsearch**, and **Flutter**. This version introduces **Intelligent Automation**, **Smart UI Color Logic**, and automated system dependency fixes.

---

## 📂 Project Structure

```text
my_realtime_iot/
├── mobile/              # Flutter Frontend (v2.1.1 Smart UI)
├── server/              # Node.js + Socket.io (Real-time Hub)
├── venv/                # Python Virtual Environment (Isolated)
├── docker-compose.yml   # Infrastructure (Elastic & Kibana)
├── sensor_sim.py        # Virtual Sensor (With Error Handlers)
├── setup_and_run.sh     # Master Automation Script
└── README.md            # Documentation (This file)


🛠 1. One-Click Setup & Run
The entire environment is now managed by a single intelligent script. It handles:
System Fixes: Auto-removes broken NodeSource repos and installs gnome-terminal.
Environment: Installs all npm, Flutter, and Python dependencies.
Automation: Launches all 4 required terminals in synchronized tabs.
First Time Setup / Daily Run
Location: Root Directory (~/Projects/my_realtime_iot)
bash
chmod +x setup_and_run.sh
./setup_and_run.sh


🏃 2. Manual Component Access
If you need to access specific components manually:
Terminal 1: Backend Hub (Node.js)
CD: cd server | Command: node index.js
Terminal 2: Sensor Simulation (Python)
CD: Root | Command: source venv/bin/activate && python3 sensor_sim.py
Terminal 3: UI Dashboard (Flutter)
CD: cd mobile | Command: flutter run -d chrome
Terminal 4: Analytics (Kibana)
URL: http://localhost:5601
💡 New in Version 2.1.1
Smart UI Logic: The Flutter app now dynamically changes colors based on sensor values:
🔴 Red: Temperature ≥ 28°C (High Alert)
🟢 Green: Temperature 23°C - 27°C (Normal)
🔵 Blue: Temperature ≤ 22°C (Low/Cold)
Error Handlers: Integrated log scanning for 500 (Internal Server Error) and 404 (Not Found) errors between Sensor, Server, and Database.
Auto-Cleanup: The run script automatically kills stale processes before launching new ones to prevent port conflicts.
📡 Architecture: Event-Driven Push
Unlike traditional REST APIs that "poll" every few seconds, this system uses a persistent WebSocket pipe.
Real-time: Zero latency between sensor trigger and UI update.
Efficiency: Drastically reduces WiFi congestion and server CPU load.
Persistence: All data is indexed in Elasticsearch for long-term historical analysis.
🛡 Security & Maintenance
Local Dev: Security is disabled for easy development; ready for JWT integration.
Deployment: Pre-configured for Oracle Cloud (Always Free) ARM architecture.