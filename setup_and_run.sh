#!/bin/bash
# v2.1.2 - Master Automation

PROJECT_NAME="my_realtime_iot"
# Smart Path: Check if we are already in the project folder
if [[ "$(basename "$(pwd)")" == "$PROJECT_NAME" ]]; then
    ROOT_DIR=$(pwd)
else
    ROOT_DIR=$(pwd)/$PROJECT_NAME
    mkdir -p $ROOT_DIR
fi

echo "🚀 Running Automation in: $ROOT_DIR"
cd "$ROOT_DIR"

# 1. 🛠 SYSTEM FIXES
if [ -f /etc/apt/sources.list.d/nodesource.list ]; then
    sudo rm /etc/apt/sources.list.d/nodesource.list
fi
if ! command -v gnome-terminal &> /dev/null; then
    sudo apt update && sudo apt install gnome-terminal -y
fi

# 2. 📁 DIRECTORY & CODE SETUP
if [ ! -d "server" ] || [ ! -d "mobile" ]; then
    echo "🏗 First time setup: Creating structure..."
    mkdir -p "$ROOT_DIR/server" "$ROOT_DIR/mobile/lib"
    
    # --- Server Setup & index.js (Including Delete) ---
    cd "$ROOT_DIR/server"
    npm init -y > /dev/null
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

server.listen(3000, () => console.log('🚀 Server v2.1.2 Live on 3000'));
EOF
    cd "$ROOT_DIR"

    # --- Flutter Setup & main.dart (Including Colors & Delete) ---
    flutter create mobile --overwrite > /dev/null
    cd mobile
    flutter pub add http socket_io_client > /dev/null
    cat <<EOF > lib/main.dart
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;

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
    socket.on('item_deleted', (id) => setState(() => results.removeWhere((item) => item['id'] == id)));
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
      appBar: AppBar(title: Text("IoT Monitor v2.1.2")),
      body: ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          final item = results[index];
          return Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              leading: CircleAvatar(backgroundColor: getStatusColor(item['value']), child: Icon(Icons.thermostat)),
              title: Text("\${item['name']}: \${item['value']}°C"),
              trailing: IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => deleteItem(item['id'])),
            ),
          );
        },
      ),
    );
  }
}
EOF
    cd "$ROOT_DIR"
fi

# 3. 🐍 Python Venv (Sensor)
if [ ! -d "venv" ]; then
    python3 -m venv venv
    source venv/bin/activate && pip install requests > /dev/null && deactivate
fi

# 4. 🐳 Infrastructure
if [ ! "$(sudo docker ps -q -f name=elasticsearch)" ]; then
    sudo docker-compose up -d
    echo "⏳ Waiting 20s for Database..."
    sleep 20
fi

# 5. 🖥 Launch Terminals
echo "🖥 Opening System Terminals..."
gnome-terminal --tab --title="SERVER" -- bash -c "cd '$ROOT_DIR/server' && node index.js; exec bash"
gnome-terminal --tab --title="SENSOR" -- bash -c "cd '$ROOT_DIR' && source venv/bin/activate && python3 sensor_sim.py; exec bash"
gnome-terminal --tab --title="FLUTTER" -- bash -c "cd '$ROOT_DIR/mobile' && flutter run -d chrome; exec bash"

echo "✅ All systems fired up!"
