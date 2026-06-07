import 'package:flutter/services.dart';

class MatterChannelService{
  static const MethodChannel _channel = MethodChannel('com.kiet.smart_home_matter/matter');
  static Future<Map<String, dynamic>> commissionDevice({required String setupCode}) async {
    try{
      final Map<dynamic, dynamic>? result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
      'commissionDevice', 
      {
        'setupCode': setupCode,
      },
    );

    if(result == null) {
      //return {};
      throw Exception('Không nhận được dữ liệu từ Kotlin');
    }

    return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      throw Exception('Lỗi MethodChannel: ${e.message}');
    } catch (e){
      throw Exception('Lỗi commissioning: $e');
    }
    
  }

  static Future<bool> toggleDevice({required String deviceId, required bool targetState}) async {
    try {
      final bool? result = await _channel.invokeMethod<bool>(
        'toggleDevice',
        {
          'deviceId': deviceId,
          'targetState': targetState,
        },
      );

      return result ?? false;
    } on PlatformException catch (e){
      throw Exception('Lỗi MethodChannel: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi điều khiển thiết bị: $e');
    }
  }
}