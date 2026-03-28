const express = require('express');
const cors = require('cors');
const http = require('http');
const { Server } = require('socket.io');
const { Client } = require('@elastic/elasticsearch');

const app = express();
const server = http.createServer(app);
const io = new Server(server, { 
  cors: { origin: "*" } 
});

const client = new Client({ 
  node: 'http://localhost:9200',
  enableCompatibilityMode: true 
});

app.use(cors());
app.use(express.json());

// WebSocket Connection Logging
io.on('connection', (socket) => {
  console.log('📱 User Connected to WebSocket: ' + socket.id);
});

// GET: Search History from Elasticsearch
app.get('/search', async (req, res) => {
  try {
    const { q } = req.query;
    if (!q) return res.json([]);
    const result = await client.search({
      index: 'sensors_data',
      query: { match: { sensor_name: { query: q, fuzziness: "AUTO" } } }
    });
    res.json(result.hits.hits);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// POST: Ingest Sensor Data & Broadcast Live
app.post('/add', async (req, res) => {
  try {
    const { name, value } = req.body;
    const timestamp = new Date();

    // 1. Save to Database (Elasticsearch)
    const result = await client.index({
      index: 'sensors_data',
      document: { sensor_name: name, sensor_value: parseFloat(value), timestamp },
      refresh: true
    });

    // 2. Push Real-time Update to Flutter via WebSocket
    io.emit('sensor_update', { 
      id: result._id, 
      name, 
      value, 
      timestamp 
    });

    console.log(`📡 Live Broadcast: ${name} = ${value}`);
    res.json({ status: "success" });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// DELETE: Remove Item
app.delete('/delete/:id', async (req, res) => {
  try {
    const { id } = req.params;
    await client.delete({ index: 'sensors_data', id: id, refresh: true });
    io.emit('item_deleted', id); // מודיע ל-Flutter למחוק מהמסך
    res.json({ message: "Deleted" });
  } catch (e) { res.status(500).send(e.message); }
});


server.listen(3000, () => console.log('🚀 Real-time Server (v2.0.0) on port 3000'));
