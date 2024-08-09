import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class BatteryInfo {
  final double time;
  final double batteryPercentage;

  BatteryInfo({required this.time, required this.batteryPercentage});
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final List<BatteryInfo> batteryList = [

    ];

    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'Settings > History',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListView(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Battery (Today)',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height/50,),
                SfCartesianChart(
                  series: [
                    AreaSeries(
                      dataSource: batteryList,
                      xValueMapper: (BatteryInfo data, _) => data.time,
                      yValueMapper: (BatteryInfo data, _) => data.batteryPercentage,
                    )
                  ],
                )
              ],
            ),
          ),
        )
    );
  }
}
