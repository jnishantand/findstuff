import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial_plus/flutter_bluetooth_serial_plus.dart';


class BluetoothServerApp extends StatefulWidget {
  @override
  State<BluetoothServerApp> createState() => _BluetoothServerAppState();
}

class _BluetoothServerAppState extends State<BluetoothServerApp> {
  FlutterBluetoothSerial bluetooth = FlutterBluetoothSerial.instance;
  BluetoothConnection? connection;
  List<String> messages = [];
  BluetoothDevice? selectedDevice;

  @override
  void initState() {
    super.initState();
    bluetooth.requestEnable();
  }

  Future<void> selectDeviceAndConnect() async {
    // Get bonded devices (already paired)
    List<BluetoothDevice> devices = await bluetooth.getBondedDevices();

    BluetoothDevice? device = await showDialog<BluetoothDevice>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Select Device"),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: devices.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(devices[index].name ?? "Unknown"),
                  subtitle: Text(devices[index].address.toString()),
                  onTap: () => Navigator.pop(context, devices[index]),
                );
              },
            ),
          ),
        );
      },
    );

    if (device != null) {
      setState(() {
        selectedDevice = device;
      });
      connectToDevice(device);
    }
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      connection = await BluetoothConnection.toAddress(device.address);
      print('Connected to ${device.name}');
      attachInput(connection!);
    } catch (e) {
      print("Connection error: $e");
    }
  }

  void attachInput(BluetoothConnection conn) {
    conn.input?.listen((data) {
      setState(() {
        messages.add(utf8.decode(data));
      });
    }).onDone(() {
      print("Disconnected");
    });
  }

  @override
  void dispose() {
    connection?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Bluetooth Server")),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: selectDeviceAndConnect,
            child: Text("Select Device"),
          ),
          if (selectedDevice != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Connected to: ${selectedDevice?.name}"),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) =>
                  ListTile(title: Text(messages[index])),
            ),
          ),
        ],
      ),
    );
  }
}
