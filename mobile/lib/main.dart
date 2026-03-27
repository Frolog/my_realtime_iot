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
    socket = IO.io('http://localhost:3000', 
      IO.OptionBuilder().setTransports(['websocket']).build());

    socket.onConnect((_) {
      setState(() => isConnected = true);
      print('Connected to Server ✅');
    });

    socket.onDisconnect((_) => setState(() => isConnected = false));

    // Listen for real-time sensor updates
    socket.on('sensor_update', (data) {
      setState(() {
        results.insert(0, {
          '_id': data['id'],
          '_source': {
            'sensor_name': data['name'],
            'sensor_value': data['value'],
            'timestamp': data['timestamp']
          }
        });
      });
    });

    // Sync deletions across clients
    socket.on('item_deleted', (id) {
      setState(() => results.removeWhere((item) => item['_id'] == id));
    });
  }

  Future<void> deleteItem(String id) async {
    final response = await http.delete(Uri.parse('http://localhost:3000/delete/$id'));
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Item Deleted")));
    }
  }

  @override
  void dispose() {
    socket.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("IoT Live Monitor v2.0"),
        actions: [
          Icon(Icons.circle, color: isConnected ? Colors.green : Colors.red, size: 12),
          SizedBox(width: 10)
        ],
      ),
      body: Column(
        children: [
          if (!isConnected) LinearProgressIndicator(color: Colors.orange),
          Expanded(
            child: ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                final item = results[index];
                final source = item['_source'];
                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    leading: Icon(Icons.speed, color: Colors.blueAccent),
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
          ),
        ],
      ),
    );
  }
}
