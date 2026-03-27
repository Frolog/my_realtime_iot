# 🚀 Real-Time IoT Dashboard (v2.0.0)

A high-performance Full-Stack IoT monitoring system using **WebSockets**, **Node.js**, **Elasticsearch**, and **Flutter**. This architecture replaces legacy HTTP polling with a real-time "Push" model to optimize network bandwidth.

---

## 📂 Project Structure

```text
my_realtime_iot/
├── mobile/              # Flutter Frontend (Web/Desktop/Mobile)
├── server/              # Node.js + Socket.io (Real-time Backend)
├── venv/                # Python Virtual Environment (Sensor Simulation)
├── docker-compose.yml   # Infrastructure (Elasticsearch & Kibana)
├── sensor_sim.py        # Virtual Sensor (Python Script)
├── setup.sh             # Automation Script (Run from Root)
└── README.md            # Documentation


🛠 1. Installation & Setup
Before running the system, you must initialize the environment.
Run the Setup Script
This script installs all npm packages, Flutter dependencies, and creates the Python virtual environment.
Location: Root Directory (~/Projects/my_realtime_iot)
bash
chmod +x setup.sh
./setup.sh


Launch Infrastructure (Docker)
Start the Elasticsearch database and Kibana dashboard.
Location: Root Directory (~/Projects/my_realtime_iot)
bash
sudo docker-compose up -d


Note: Wait ~30 seconds for Elasticsearch to fully initialize.
🏃 2. How to Run (Step-by-Step)
Open four separate terminals and run the components in this specific order:
Terminal 1: Real-time Backend (Node.js)
Location: cd server
bash
node index.js


Terminal 2: Sensor Simulator (Python)
Location: Root Directory (~/Projects/my_realtime_iot)
bash
source venv/bin/activate
python3 sensor_sim.py


Terminal 3: Frontend Application (Flutter)
Location: cd mobile
bash
flutter run -d chrome


Terminal 4: Data Visualization (Kibana)
Location: Any Browser
Access the graphical dashboard at:
http://localhost:5601
💡 Architecture: WebSocket vs REST
REST (Old): The app "polled" the server for data every 5 seconds. High WiFi overhead and latency.
WebSocket (New): A persistent bi-directional "pipe" is opened. The server pushes data to Flutter the millisecond the sensor sends a request.
Benefits: 90% less network traffic, instant UI updates, and higher battery efficiency.
🛡 Security & Scalability
Elasticsearch: Enterprise-grade indexing for millions of sensor logs.
Socket.io: Efficient event broadcasting for multiple concurrent users.
Future-Ready: Built to support JWT Authentication and Oracle Cloud (Always Free) deployment.
