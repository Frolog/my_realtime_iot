#!/bin/bash

# --- Parameters ---
PROJECT_NAME="my_realtime_iot"
OLD_PROJECT="my_elastic_app"
ROOT_DIR=$(pwd)

echo "🚀 Starting Master Automation v2.1.3 for $PROJECT_NAME..."

# 1. 🛠 SYSTEM FIXES: Fix NodeSource and Install Terminal
if [ -f /etc/apt/sources.list.d/nodesource.list ]; then
    sudo rm /etc/apt/sources.list.d/nodesource.list
fi

if ! command -v gnome-terminal &> /dev/null; then
    sudo apt update && sudo apt install gnome-terminal -y
fi

# 2. 📁 DIRECTORY & CODE SETUP
if [ ! -d "server" ] || [ ! -d "mobile" ]; then
    echo "🏗 First time setup: Creating structure..."
    mkdir -p server mobile/lib
    
    # --- Server Setup ---
    cd server
    npm init -y > /dev/null
    # התקנת הספריות שביקשת
    npm install express cors socket.io @elastic/elasticsearch@8 > /dev/null
    
    cat <<EOF > index.js
const express = require('express');
const cors = require('cors');
const http = require('http');
const { Server } = require('socket.io');
const { Client } = require('@elastic/elasticsearch');

const app = express();
const server = http.createServer(app);
const io = new Server(server, { cors: { origin: "*" } });
const client = new Client({ node: 'http://localhost:9200', enableCompatibilityMode: true });

app.use(cors()); app.use(express.json());

app.post('/add', async (req, res) => {
  try {
    const { name, value } = req.body;
    const timestamp = new Date();
    const result = await client.index({
      index: 'sensors_data',
      document: { sensor_name: name, sensor_value: parseFloat(value), timestamp },
      refresh: true
    });
    io.emit('sensor_update', { id: result._id, name, value, timestamp });
    res.json({ status: "success" });
  } catch (error) { 
    console.error("ADD ERROR 500:", error.message);
    res.status(500).json({ error: error.message }); 
  }
});

app.delete('/delete/:id', async (req, res) => {
  try {
    await client.delete({ index: 'sensors_data', id: req.params.id, refresh: true });
    io.emit('item_deleted', req.params.id);
    res.json({ message: "deleted" });
  } catch (e) { res.status(500).send(e.message); }
});

server.listen(3000, () => console.log('🚀 Server v2.1.3 Live on 3000'));
EOF
    cd ..

    # --- Flutter Setup ---
    flutter create mobile --overwrite > /dev/null
    cd mobile
    flutter pub add http socket_io_client > /dev/null
    cd ..
fi

# --- ALWAYS UPDATE main.dart (Smart UI & Color Logic) ---
cat <<EOF > mobile/lib/main.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;

void main() => runApp(MaterialApp(
  home: RealTimeMonitor(),
  theme: ThemeData.dark(),
  debugShowCheckedModeBanner: false,
));

class RealTimeMonitor extends StatefulWidget {
  @override
  _RealTimeMonitorState createState() => _RealTimeMonitorState();
}

class _RealTimeMonitorState extends State<RealTimeMonitor> {
  List results = [];
  late IO.Socket socket;
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    initSocket();
  }

  void initSocket() {
    socket = IO.io('http://localhost:3000', IO.OptionBuilder().setTransports(['websocket']).build());
    socket.onConnect((_) => setState(() => isConnected = true));
    socket.onDisconnect((_) => setState(() => isConnected = false));
    socket.on('sensor_update', (data) => setState(() {
      results.insert(0, {
        '_id': data['id'],
        '_source': {'sensor_name': data['name'], 'sensor_value': data['value'], 'timestamp': data['timestamp']}
      });
    }));
    socket.on('item_deleted', (id) => setState(() => results.removeWhere((item) => item['_id'] == id)));
  }

  Color getStatusColor(dynamic value) {
    double temp = double.tryParse(value.toString()) ?? 0;
    if (temp >= 28) return Colors.redAccent;
    if (temp <= 22) return Colors.blueAccent;
    return Colors.greenAccent;
  }

  Future<void> deleteItem(String id) async {
    await http.delete(Uri.parse('http://localhost:3000/delete/\$id'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("IoT Monitor v2.1.3"),
        actions: [
          Icon(Icons.circle, color: isConnected ? Colors.green : Colors.red, size: 12),
          SizedBox(width: 10)
        ],
      ),
      body: ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          final item = results[index];
          final source = item['_source'];
          return Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: getStatusColor(source['sensor_value']),
                child: Icon(Icons.thermostat, color: Colors.white),
              ),
              title: Text("\${source['sensor_name']}: \${source['sensor_value']}°C"),
              subtitle: Text("Time: \${source['timestamp']}"),
              trailing: IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => deleteItem(item['_id']),
              ),
            ),
          );
        },
      ),
    );
  }
}
EOF

# 3. 🐍 Python Venv check
if [ ! -d "venv" ]; then
    python3 -m venv venv
    source venv/bin/activate && pip install requests > /dev/null && deactivate
fi

# 4. 🐳 Infrastructure & Dependencies Check (ALWAYS RUN)
echo "📦 Finalizing dependencies..."
cd server && npm install > /dev/null && cd ..

if [ ! "$(sudo docker ps -q -f name=elasticsearch)" ]; then
    sudo docker-compose up -d
    echo "⏳ Waiting 40s for Database..."
    sleep 40
fi

# 5. 🧹 CLEAN OLD SESSIONS
pkill -f "node index.js" 2>/dev/null
pkill -f "python3 sensor_sim.py" 2>/dev/null

# 6. 🖥 LAUNCH TERMINALS
echo "🖥 Opening terminals..."
gnome-terminal --tab --title="SERVER" -- bash -c "cd '$ROOT_DIR/server' && node index.js; exec bash"
gnome-terminal --tab --title="SENSOR" -- bash -c "cd '$ROOT_DIR' && source venv/bin/activate && python3 sensor_sim.py; exec bash"
gnome-terminal --tab --title="FLUTTER" -- bash -c "cd '$ROOT_DIR/mobile' && flutter run -d chrome; exec bash"

echo "✅ System v2.1.3 is up and running!"
