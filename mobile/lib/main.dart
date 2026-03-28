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
    await http.delete(Uri.parse('http://localhost:3000/delete/$id'));
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
              title: Text("${source['sensor_name']}: ${source['sensor_value']}°C"),
              subtitle: Text("Time: ${source['timestamp']}"),
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
