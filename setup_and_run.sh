#!/bin/bash

# --- Parameters ---
PROJECT_NAME="my_realtime_iot"
OLD_PROJECT="my_elastic_app"
ROOT_DIR=$(pwd)/$PROJECT_NAME

echo "🚀 Starting Full Automation for $PROJECT_NAME..."

# 1. Clean & Create Structure
rm -rf $PROJECT_NAME
mkdir -p $PROJECT_NAME/{server,mobile/lib}
cd $PROJECT_NAME

# 2. Setup Node.js (Server)
echo "📦 Setting up Server..."
cd server
npm init -y > /dev/null
npm install express cors socket.io @elastic/elasticsearch@8 > /dev/null

# --- CREATE server/index.js (The Handler) ---
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
  } catch (error) { res.status(500).json({ error: error.message }); }
});

app.get('/search', async (req, res) => {
  const { q } = req.query;
  const result = await client.search({
    index: 'sensors_data',
    query: { match: { sensor_name: { query: q, fuzziness: "AUTO" } } }
  });
  res.json(result.hits.hits);
});

server.listen(3000, () => console.log('🚀 Server v2.0.0 Live on 3000'));
EOF
cd ..

# 3. Setup Flutter (Mobile)
echo "💙 Setting up Flutter..."
flutter create mobile --overwrite > /dev/null
cd mobile
flutter pub add http socket_io_client > /dev/null

# --- CREATE mobile/lib/main.dart (The Handler) ---
cat <<EOF > lib/main.dart
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:convert';

void main() => runApp(MaterialApp(home: RealTimeApp(), theme: ThemeData.dark(), debugShowCheckedModeBanner: false));

class RealTimeApp extends StatefulWidget {
  @override
  _RealTimeAppState createState() => _RealTimeAppState();
}

class _RealTimeAppState extends State<RealTimeApp> {
  List results = [];
  late IO.Socket socket;

  @override
  void initState() {
    super.initState();
    socket = IO.io('http://localhost:3000', IO.OptionBuilder().setTransports(['websocket']).build());
    socket.on('sensor_update', (data) => setState(() => results.insert(0, data)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("IoT Live Monitor v2.0")),
      body: ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          final item = results[index];
          return ListTile(
            leading: Icon(Icons.sensors, color: Colors.blue),
            title: Text("\${item['name']}: \${item['value']}°C"),
            subtitle: Text("Time: \${item['timestamp']}"),
          );
        },
      ),
    );
  }
}
EOF
cd ..

# 4. Setup Python & Sensor Sim
echo "🐍 Setting up Python Sensor..."
python3 -m venv venv
source venv/bin/activate
pip install requests > /dev/null

cat <<EOF > sensor_sim.py
import requests, time, random
url = "http://localhost:3000/add"
while True:
    temp = round(random.uniform(20.0, 30.0), 2)
    try:
        requests.post(url, json={"name": "Living_Room", "value": temp})
        print(f"Sent: {temp}C")
    except: pass
    time.sleep(5)
EOF
deactivate

# 5. Infrastructure (Docker)
cp ~/Projects/$OLD_PROJECT/docker-compose.yml .
sudo docker-compose up -d

echo "⏳ Waiting 15s for Database..."
sleep 15

# 6. --- START TERMINALS ---
echo "🖥 Opening terminals..."
gnome-terminal --tab --title="SERVER" -- bash -c "cd $ROOT_DIR/server && node index.js; exec bash"
gnome-terminal --tab --title="SENSOR" -- bash -c "cd $ROOT_DIR && source venv/bin/activate && python3 sensor_sim.py; exec bash"
gnome-terminal --tab --title="FLUTTER" -- bash -c "cd $ROOT_DIR/mobile && flutter run -d chrome; exec bash"

echo "✅ All systems GO! Check Chrome and Terminals."
