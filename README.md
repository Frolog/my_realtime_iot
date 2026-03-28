# 🚀 Real-Time IoT Dashboard (v2.1.2)

A high-performance Full-Stack IoT monitoring system featuring **WebSockets**, **Node.js**, **Elasticsearch**, and **Flutter**. This project is fully automated for rapid deployment and real-time data visualization.

ESP/Arduino → transport → backend → database → realtime UI)

sensor_sim.py → REST POST → Node.js → Elasticsearch → Socket.io → Flutter

sys v 2.1.2 include: 
✔ Backend Node
✔ Realtime עם WebSocket
✔ Database (Elastic)
✔ Frontend UI
✔ Simulator
✔ Automation script
✔ Docker infra

---

## 📂 Project Structure

```text
my_realtime_iot/
├── mobile/              # Flutter Frontend (Smart UI Color Logic)
├── server/              # Node.js + Socket.io (Real-time Hub)
├── venv/                # Python Virtual Environment (Isolated)
├── docker-compose.yml   # Infrastructure (Elastic & Kibana)
├── sensor_sim.py        # Virtual Sensor (With Error Handlers)
├── setup_and_run.sh     # Master Automation Script
└── README.md            # Documentation

🛠 1. Clean Installation (Fresh Start)
If you want to start fresh or deploy on a new machine, follow these steps:
Clone the Repository
Location: Your Projects directory (~/Projects)
bash
git clone https://github.com/Frolog/my_realtime_iot
cd my_realtime_iot

Run the Master Automation Script
This script performs a full system check, installs all dependencies (npm, flutter, python), fixes system-level repository errors, and launches all terminals automatically.
bash
chmod +x setup_and_run.sh
./setup_and_run.sh

for utomatically close all the terminals:
./stop_system.sh

🏃 2. Daily Execution & Terminals
The automation script will automatically open three synchronized terminals:
[BACKEND]: Node.js server running on port 3000.
[SENSOR]: Python script sending simulated data every 5 seconds.
[FLUTTER]: The UI dashboard running in Chrome.
💡 Key Features in v2.1.2
Smart Color UI: Circle indicators change color based on value:
🔴 Red: ≥ 28°C
🟢 Green: 23°C - 27°C
🔵 Blue: ≤ 22°C
Live Sync: Instant updates via WebSockets (no more WiFi congestion).
CRUD Operations: Support for adding and Deleting entries directly from the UI.
Auto-Fixer: The script automatically resolves gnome-terminal missing errors and broken NodeSource repositories.
📡 Data Flow
Python Sensor ➔ Node.js (POST) ➔ Elasticsearch (Storage) ➔ Socket.io (Broadcast) ➔ Flutter UI (Live Update)
🛡 Maintenance
To stop the system: Run sudo docker-compose down and close the terminal tabs.
To reset and update: Perform a git pull and run ./setup_and_run.sh again.
