import 'dart:convert';
import 'package:luan_van_tot_nghiep_dh52200960/models/history_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryService {
  static const String _historyKey = 'histories';
  static final List<HistoryModel> histories = [];
  static List<HistoryModel> getAllHistories(){
    return histories;
  }

  static Future<void> loadHistories() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? historiesJson = preferences.getString(_historyKey);
    if(historiesJson == null){
      histories.clear();
      return;
    }

    final List<dynamic> decodedList = jsonDecode(historiesJson);
    histories.clear();
    histories.addAll(
      decodedList.map((item){
        return HistoryModel.fromJson(item);
      }).toList(),
    );
  }

  static Future<void> saveHistories() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> historyMapList = histories.map((history){
      return history.toJson();
    }).toList();
    final String historiesJson = jsonEncode(historyMapList);
    await preferences.setString(_historyKey, historiesJson);
  }

  static Future<void> addHistory({required String deviceName, required String action, required String type}) async {
    final DateTime now = DateTime.now();
    final String time = '${now.day}/${now.month}/${now.year} - ${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    histories.insert(
      0,
      HistoryModel(
        id: 'history_${now.millisecondsSinceEpoch}',
        deviceName: deviceName,
        action: action,
        time: time,
        type: type
      )
    );

    if(histories.length > 100) {
      histories.removeRange(100, histories.length);
    }
    await saveHistories();
  }

  static Future<void> clearHistories() async {
    histories.clear();
    await saveHistories();

    // final SharedPreferences preferences = await SharedPreferences.getInstance();
    // await preferences.remove(_historyKey);
    // histories.clear();
  }
}