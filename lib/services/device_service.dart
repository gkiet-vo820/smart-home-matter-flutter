import 'dart:convert';
import 'package:luan_van_tot_nghiep_dh52200960/models/device_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceService {
  static const String _deviceKey = 'devices';
  static final List<DeviceModel> devices = [];
  static List<DeviceModel> getAllDevices(){
    return devices;
  }

  static Future<void> loadDevices() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? devicesJson = preferences.getString(_deviceKey);
    if(devicesJson == null){
      devices.clear();

      devices.addAll([
        DeviceModel(
          id: 'light_001',
          name: 'Đèn Matter',
          room: 'Phòng khách',
          type: 'Light',
          endpoint: '1',
          cluster: 'OnOff',
          isOn: true,
          isConnected: true,
        ),
        DeviceModel(
          id: 'outlet_001',
          name: 'Ổ cắm Matter',
          room: 'Phòng khách',
          type: 'Outlet',
          endpoint: '1',
          cluster: 'OnOff',
          isOn: false,
          isConnected: true,
        ),
        DeviceModel(
          id: 'esp32_light_001',
          name: 'ESP32 Light',
          room: 'Phòng ngủ',
          type: 'Light',
          endpoint: '1',
          cluster: 'OnOff',
          isOn: true,
          isConnected: true,
        ),
      ]);
      await saveDevices();
      return;
    }

    final List<dynamic> decodedList = jsonDecode(devicesJson);
    devices.clear();

    devices.addAll(
      decodedList.map((item){
        return DeviceModel.fromJson(item);
      }).toList(),
    );
  }

  static Future<void> saveDevices() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> deviceMapList = devices.map((device){
      return device.toJson();
    }).toList();
    final String devicesJson = jsonEncode(deviceMapList);
    await preferences.setString(_deviceKey, devicesJson);
  }


  static Future<void> addDevice(DeviceModel device) async {
    devices.add(device);
    await saveDevices();
  }

  static Future<void> toggleDevice(DeviceModel device) async {
    device.isOn = !device.isOn;
    await saveDevices();
  }

  static Future<void> removeDevice(DeviceModel device) async {
    devices.removeWhere((item) => item.id == device.id);
    await saveDevices();
  }

  static Future<void> updateDevice(DeviceModel updateDevice) async {
    final int index = devices.indexWhere((device) => device.id == updateDevice.id);
    if(index != -1){
      devices[index] = updateDevice;
      await saveDevices();
    }
  }

  static Future<void> clearAllDevices() async {
    // Xóa key 'devices' khỏi SharedPreferences. Khi chạy lại app, loadDevices() sẽ thấy devicesJson == null
    // nên sẽ tạo lại danh sách thiết bị mẫu ban đầu (này là xóa hết và chạy lại sẽ vẫn còn dữ liệu mẫu)
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove(_deviceKey);
    devices.clear();

    // Xóa toàn bộ danh sách và lưu danh sách rỗng [] vào SharedPreferences. Khi chạy lại app, danh sách vẫn rỗng, 
    //không tự tạo lại dữ liệu mẫu (này là xóa hết và mất hết)
    // devices.clear();
    // await saveDevices();
  }
}