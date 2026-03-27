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

server.listen(3000, () => console.log('🚀 Server v2.1.0 Live on 3000'));
