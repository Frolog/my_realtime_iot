import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

void main() => runApp(MaterialApp(
  home: RealTimeApp(), 
  theme: ThemeData.dark(), 
  debugShowCheckedModeBanner: false
));

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

  Color getStatusColor(dynamic value) {
    double temp = double.tryParse(value.toString()) ?? 0;
    if (temp >= 28) return Colors.redAccent;
    if (temp <= 22) return Colors.blueAccent;
    return Colors.greenAccent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("IoT Live Monitor v2.1")),
      body: ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          final item = results[index];
          return Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: getStatusColor(item['value']),
                child: Icon(Icons.thermostat, color: Colors.white),
              ),
              title: Text("${item['name']}: ${item['value']}°C", style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Time: ${item['timestamp']}"),
            ),
          );
        },
      ),
    );
  }
}
