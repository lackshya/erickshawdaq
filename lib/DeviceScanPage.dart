import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DeviceScanPage extends StatefulWidget {
  const DeviceScanPage({super.key});

  @override
  State<DeviceScanPage> createState() => _DeviceScanPageState();
}



class _DeviceScanPageState extends State<DeviceScanPage> {
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  List<ScanResult> scanResults = [];
  bool isScanning = false;

  void _startScan() {
    setState(() {
      scanResults.clear();
      isScanning = true;
    });

    flutterBlue.scan(timeout: Duration(seconds: 10)).listen((scanResult) {
      setState(() {
        scanResults.add(scanResult);
      });
    });
  }

  void _stopScan() {
    flutterBlue.stopScan();
    setState(() {
      isScanning = false;
    });
  }

  @override
  void initState() {
    _startScan();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold());
  }
}
