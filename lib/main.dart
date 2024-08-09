import 'dart:convert';
import 'package:erickshaw_dashboard/history_screen.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:erickshaw_dashboard/notification_service.dart';
import 'package:erickshaw_dashboard/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:url_launcher/url_launcher.dart';
import 'accident_detection_setting.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EVD Connect',
      home: MyHomePage(),
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  List<ScanResult> scanResults = [];
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
  }

  void _startScan() {
    setState(() {
      scanResults.clear();
      isScanning = true;
    });

    flutterBlue.scan(timeout: Duration(seconds: 10)).listen((scanResult) {
      setState(() {
        scanResults.add(scanResult);
        if (scanResult.device.name == 'EVD Connect') {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => DeviceFoundDialog(
              onRetry: () {
                Navigator.pop(context);
                _startScan();
              },
              onContinue: () async {
                await scanResult.device.connect();
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DeviceScreen(
                      device: scanResult.device,
                    ),
                  ),
                );
              },
            ),
          );
        }
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: MediaQuery.of(context).size.height/3,
              child: Column(
                children: [
                  Icon(
                    Icons.bluetooth_searching,
                    size: 100,
                    color: Colors.blue.shade400,
                  ),
                  SizedBox(height: 20,),
                  Text(
                      'Search for your E-Rickshaw Device',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10,),
                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Text(
                      'Make sure Bluetooth and Location services are ON before searching',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height/3),
            ElevatedButton(
              child: Text(
                  isScanning ? 'Stop Scan' : 'Start Scan',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: isScanning ? _stopScan : _startScan,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.grey.shade300),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height/10,),
          ],
        ),
      ),
    );
  }
}

class DeviceFoundDialog extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onContinue;

  const DeviceFoundDialog({
    required this.onRetry,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: MediaQuery.of(context).size.height/3,
                child: Column(
                  children: [
                    Icon(
                      Icons.electric_rickshaw,
                      size: 100,
                      color: Colors.blue.shade400,
                    ),
                    SizedBox(height: 20,),
                    Text(
                      'Device Found!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10,),
                    Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Text(
                        'We found your E-Rickshaw device, would you like to connect to it?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height/3),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  OutlinedButton(
                      onPressed: onRetry,
                      child: Container(
                        width: MediaQuery.of(context).size.width/3,
                        height: MediaQuery.of(context).size.height/20,
                          child: Align(
                            alignment: Alignment.center,
                              child: Text(
                                  'Cancel',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ))
                      )
                  ),
                  ElevatedButton(
                      onPressed: onContinue,
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.blue),
                      ),
                      child: Container(
                          width: MediaQuery.of(context).size.width/3,
                          height: MediaQuery.of(context).size.height/20,
                          child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                  'Continue',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ))
                      )
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height/10,),
            ],
          ),
        )
    );
    // return AlertDialog(
    //   title: Text('Device found successfully'),
    //   actions: [
    //     ElevatedButton(
    //       child: Text('Retry'),
    //       onPressed: onRetry,
    //     ),
    //     ElevatedButton(
    //       child: Text('Continue'),
    //       onPressed: onContinue,
    //     ),
    //   ],
    // );
  }
}

class DeviceScreen extends StatefulWidget {
  final BluetoothDevice device;
  String number = '8657420684';

  DeviceScreen({Key? key, required this.device}) : super(key: key);

  @override
  _DeviceScreenState createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  NotificationsServices notificationsServices = NotificationsServices();
  bool isLoading = true;
  BluetoothCharacteristic? ambientTemperatureCharacteristic;
  BluetoothCharacteristic? batteryTemperatureCharacteristic;
  BluetoothCharacteristic? speedCharacteristic;
  BluetoothCharacteristic? batteryPercentageCharacteristic;
  BluetoothCharacteristic? accidentDetectionCharacteristic;

  String ambientTemperature = '--';
  String batteryTemperature = '--';
  String speed = "--";
  String batteryPercentage = '--';
  String deviceState = '--';
  String accidentDetection = '0';

  double distance = 0;
  double currentSpeed = 0;
  DateTime previousTime = DateTime.now();


  @override
  void initState() {
    super.initState();
    _discoverCharacteristics();
    _deviceConnectionState();
    notificationsServices.initializeNotifications();
  }

  void calculateDistance() {
    DateTime currentTime = DateTime.now();
    Duration timeInterval = currentTime.difference(previousTime);
    previousTime = currentTime;

    double distanceCovered = currentSpeed * timeInterval.inSeconds.toDouble();
    distance += distanceCovered;
    print(distance);
  }

  _deviceConnectionState () {
    widget.device.state.listen((event) {
      print(event);
      if (event == BluetoothDeviceState.connected) {
        setState(() {
          deviceState = 'CONNECTED';
        });
      } else if (event == BluetoothDeviceState.disconnected) {
        setState(() {
          deviceState = 'DISCONNECTED';
        });
      } else {
        setState(() {
          deviceState = '--';
        });
      }
    });
  }

  void _discoverCharacteristics() async {
    try {
      List<BluetoothService> services = await widget.device.discoverServices();
      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          if (characteristic.uuid.toString() ==
              '4b64f858-d0d0-4c67-94a1-370a362facfe') {
            ambientTemperatureCharacteristic = characteristic;
            ambientTemperatureCharacteristic!.setNotifyValue(true);
            ambientTemperatureCharacteristic!.value.listen((value) {
              setState(() {
                print("${characteristic.uuid} ${utf8.decode(value)}");
                ambientTemperature = utf8.decode(value);
              });
            });
          } else if (characteristic.uuid.toString() ==
              'd2854860-fc93-40bf-8fff-cb120f00cf59') {
            batteryTemperatureCharacteristic = characteristic;
            batteryTemperatureCharacteristic!.setNotifyValue(true);
            batteryTemperatureCharacteristic!.value.listen((value) {
              setState(() {
                print("${characteristic.uuid} ${utf8.decode(value)}");
                batteryTemperature = utf8.decode(value);
              });
              if (int.parse(batteryTemperature) > 50) {
                notificationsServices.sendNotification(
                  '⚠️ WARNING: BATTERY TEMPERATURE IS TOO HIGH!',
                  'Battery temperature has reached dangerous levels. Park the vehicle in a safe place and de-board',
                );
              }
            });
          } else if (characteristic.uuid.toString() ==
              '51c06bfa-8e0e-4467-a8b4-0c89251fe45b') {
            batteryPercentageCharacteristic = characteristic;
            batteryPercentageCharacteristic!.setNotifyValue(true);
            batteryPercentageCharacteristic!.value.listen((value) async {
              setState(() {
                print("${characteristic.uuid} ${utf8.decode(value)}");
                batteryPercentage = utf8.decode(value);
              });
              if (int.parse(batteryPercentage) < 20) {
                notificationsServices.sendNotification(
                  '⚠️ WARNING: Battery % Low',
                  'Battery may run out soon, find a charging station and charge the vehicle',
                );
              }
            });
          } else if (characteristic.uuid.toString() ==
              'e51d8640-8004-4496-83ca-febb97b74c38') {
            speedCharacteristic = characteristic;
            speedCharacteristic!.setNotifyValue(true);
            speedCharacteristic!.value.listen((value) {
              setState(() {
                print("${characteristic.uuid} ${utf8.decode(value)}");
                speed = utf8.decode(value);
                currentSpeed = double.parse(speed);
                calculateDistance();
              });
            });
          } else if (characteristic.uuid.toString() ==
              '0aab7a77-60b0-4f62-a986-0e0ce891ff5a') {
            accidentDetectionCharacteristic = characteristic;
            accidentDetectionCharacteristic!.setNotifyValue(true);
            accidentDetectionCharacteristic!.value.listen((value) async {
              setState(() async {
                print("${characteristic.uuid} ${utf8.decode(value)}");
                accidentDetection = utf8.decode(value);
              });
              if (accidentDetection == '1') {
                const number = '9920334887'; //set the number here
                bool? res = await FlutterPhoneDirectCaller.callNumber('${number}');
                notificationsServices.sendNotification(
                  '⚠️ ACCIDENT DETECTED',
                  'A call has been initiated to ${widget.number}',
                );
                print(res);
              }
            });
          }
        }
      }
    } catch (e) {
      print('Error discovering characteristics: $e');
    }

    setState(() {
      isLoading = false;
    });
  }


  Future getCharacteristicValue(BluetoothCharacteristic characteristic) async {
    if (await characteristic.value.isEmpty) {
      return 'No value';
    } else {
      // Assuming the value is in UTF-8 encoding
      return '${await characteristic.value}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: Column(
          children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey.shade100,
                    child: Icon(
                      Icons.electric_rickshaw,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '${widget.device.name}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height/400,),
                      Text(
                          deviceState,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: deviceState == 'CONNECTED'? Colors.green : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      color: Colors.grey.shade100,
                    ),
                    height: MediaQuery.of(context).size.height/20,
                    width: MediaQuery.of(context).size.width/5,
                    //color: Colors.grey.shade100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                            '${ambientTemperature} ℃',
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                    ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SettingsScreen(),
                          ),
                        );
                      },
                      child: Icon(
                        Icons.settings,
                        color: Colors.black,
                      )
                  ),
                ],
              ),
            SizedBox(
              height: MediaQuery.of(context).size.height/50,
            ),
            SfRadialGauge(
              enableLoadingAnimation: true,
              axes: [
                RadialAxis(
                  annotations: [
                    GaugeAnnotation(
                      axisValue: 50,
                        positionFactor: 0.1,
                        widget: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                                speed == '--' ? '--' :'${int.parse(speed)}',
                              style: TextStyle(
                                fontSize: 58,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'KMPH',
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ],
                        )
                    ),
                  ],
                  pointers: [
                    RangePointer(
                      value: speed == '--' ? 0 : double.parse(speed),
                      width: 0.15,
                      sizeUnit: GaugeSizeUnit.factor,
                      color: Colors.blue.shade400,
                    )
                  ],
                  minimum: 0,
                  maximum: 80,
                  axisLineStyle: AxisLineStyle(
                    thickness: 0.15,
                    thicknessUnit: GaugeSizeUnit.factor,
                    color: Colors.grey.shade200,
                  ),
                )
              ],
            ),
            Container(
              width: MediaQuery.of(context).size.width/1.7,
              height: MediaQuery.of(context).size.height/4,
              child: SfRadialGauge(
                enableLoadingAnimation: true,
                axes: [
                  RadialAxis(
                    showLastLabel: true,
                    annotations: [
                      GaugeAnnotation(
                          axisValue: 50,
                          positionFactor: 0.1,
                          widget: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: batteryPercentage == '--' ? '--' :'${int.parse(batteryPercentage)}',
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    TextSpan(
                                        text: '%'
                                    )
                                  ]
                                )
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height/100,
                              ),
                              Text(
                                'BATTERY',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                      ),
                    ],
                    pointers: [
                      RangePointer(
                        value: batteryPercentage == '--' ? 0 : double.parse(batteryPercentage),
                        width: 0.15,
                        sizeUnit: GaugeSizeUnit.factor,
                        color: Colors.green.shade400,
                      )
                    ],
                    minimum: 0,
                    maximum: 100,
                    axisLineStyle: AxisLineStyle(
                      thickness: 0.15,
                      thicknessUnit: GaugeSizeUnit.factor,
                      color: Colors.grey.shade200,
                    ),
                  )
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width/3,
                  height: MediaQuery.of(context).size.height/18,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Align(
                    child: Text(
                      '${batteryTemperature} ℃',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width/3,
                  height: MediaQuery.of(context).size.height/18,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Align(
                    child: Text(
                      '${distance} KM',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height/18,),
            ElevatedButton(
                onPressed: () async {
                  MapsLauncher.launchCoordinates(19.129434648176726, 72.82121120779068);
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.green),
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width/2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                          Icons.map,
                        color: Colors.white,
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width/20,),
                      Text(
                          'Open Google Maps',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
            ),
          ],
        ),
            ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.close)
                    ),
                    Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height/40,
                ),
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HistoryScreen(),
                        ),
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.grey.shade200),
                    ),
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height/20,
                        child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              'History',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ))
                    )
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height/40,
                ),
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AccidentDetectionSetting(),
                        ),
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.grey.shade200),
                    ),
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height/20,
                        child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Accident Detection',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ))
                    )
                ),
              ],
            ),
          ),
        )
    );
  }
}

class AccidentDetectionSetting extends StatefulWidget {
  const AccidentDetectionSetting({super.key});

  @override
  State<AccidentDetectionSetting> createState() => _AccidentDetectionSettingState();
}

class _AccidentDetectionSettingState extends State<AccidentDetectionSetting> {
  late String inputValue = '';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.close)
                    ),
                    Text(
                      'Settings > Accident Detection',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height/40,
                ),
                Text(
                  'Enter phone number to which call will be initiated in an event of accident',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height/40,
                ),
                IntlPhoneField(
                  initialValue: '8657420684',
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(),
                    ),
                  ),
                  initialCountryCode: 'IN',
                  onChanged: (phone) {
                    print(phone.completeNumber);
                    inputValue = phone as String;
                  },
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height/40,
                ),
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.grey.shade200),
                    ),
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height/20,
                        child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Save',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                        )
                    )
                ),
              ],
            ),
          ),
        )
    );
  }
}




