import 'package:flutter/material.dart';
import 'package:luan_van_tot_nghiep_dh52200960/services/device_service.dart';
import 'package:luan_van_tot_nghiep_dh52200960/services/history_service.dart';
import 'package:luan_van_tot_nghiep_dh52200960/ui/add_device.dart';
import 'package:luan_van_tot_nghiep_dh52200960/ui/history.dart';
import 'package:luan_van_tot_nghiep_dh52200960/ui/home_page.dart';

void main()  async {
  WidgetsFlutterBinding.ensureInitialized();
  await DeviceService.loadDevices();
  await HistoryService.loadHistories();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App điều khiển thiết bị',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
      routes: {
        '/home': (context) => const HomePage(),
        '/add-device': (context) => const AddMatterDevice(),
        '/history': (context) => const History(),
      },
    );
  }
}