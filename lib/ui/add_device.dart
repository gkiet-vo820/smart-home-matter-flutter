import 'package:flutter/material.dart';
import 'package:luan_van_tot_nghiep_dh52200960/models/device_model.dart';
import 'package:luan_van_tot_nghiep_dh52200960/services/device_service.dart';
import 'package:luan_van_tot_nghiep_dh52200960/services/history_service.dart';
import 'package:luan_van_tot_nghiep_dh52200960/services/matter_channel_service.dart';
import 'package:luan_van_tot_nghiep_dh52200960/ui/qr_scanner.dart';

class AddMatterDevice extends StatefulWidget {
  const AddMatterDevice({super.key});
  @override
  State<AddMatterDevice> createState() => _AddMatterDeviceState();
}
class _AddMatterDeviceState extends State<AddMatterDevice> {

  // 0: Chưa bắt đầu, 1: Đang tìm thiết bị, 2: Đang ghép nối, 3: Thêm thành công
  int _currentStatus = 0;
  final TextEditingController _setUpCodeController = TextEditingController();
  bool get _isCommissioning => _currentStatus == 1 || _currentStatus == 2;
  
  // Hàm giả lập quá trình Commissioning Matter
  void _startCommissioning() async {
    final String setupCode = _setUpCodeController.text.trim();
    if(setupCode.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng nhập mã setup trước khi commissioning'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    try {
      setState(() {
        _currentStatus = 1;
      });
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _currentStatus = 2;
      });
      await Future.delayed(const Duration(seconds: 1));

      final Map<String, dynamic> nativeDevice = await MatterChannelService.commissionDevice(
        setupCode: setupCode,
      );

      setState(() {
        _currentStatus = 3;
      });
      
      // final DeviceModel newDevice = DeviceModel(
      //   id: 'matter_${DateTime.now().millisecondsSinceEpoch}',
      //   name: 'Thiết bị Matter mới',
      //   room: 'Phòng khách',
      //   type: 'Light',
      //   endpoint: '1',
      //   cluster: 'OnOff',
      //   isOn: false,
      //   isConnected: true,
      // );
      
      final DeviceModel newDevice = DeviceModel(
        id: nativeDevice['id'] ?? 'matter_${DateTime.now().millisecondsSinceEpoch}', 
        name: nativeDevice['name'] ?? 'Thiết bị Matter mới', 
        room: nativeDevice['room'] ?? 'Phòng khách', 
        type: nativeDevice['type'] ?? 'Light', 
        endpoint: nativeDevice['endpoint'] ?? '1', 
        cluster: nativeDevice['cluster'] ?? 'OnOff', 
        isOn: nativeDevice['isOn'] ?? false, 
        isConnected: nativeDevice['isConnected'] ?? true,
      );

      await DeviceService.addDevice(newDevice);

      await HistoryService.addHistory(
        deviceName: newDevice.name,
        action: 'Thêm thiết bị Matter',
        type: 'add',
      );
      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _currentStatus = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Thêm thiết bị thất bại: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  void dispose() {
    _setUpCodeController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(), 
          icon: const Icon(Icons.arrow_back, color: Colors.black87,),
        ),
        title: const Text('Thêm thiết bị Matter', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Kết nối thiết bị mới', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 20),

            // Khu vực Quét mã QR Matter
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),

              child: Column(
                children: [
                  const Icon(Icons.qr_code_scanner, size: 64, color: Colors.blueAccent),
                  const SizedBox(height: 12),
                  const Text('QR Matter', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isCommissioning ? null
                    : () async {
                      final String? qrCode = await Navigator.push<String>(
                          context, 
                          MaterialPageRoute(builder: (context) => const QrScanner()),
                      );
                      if(qrCode == null || qrCode.isEmpty) return;
                      setState(() {
                        _setUpCodeController.text = qrCode;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Quét mã QR', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text('Hoặc', style: TextStyle(fontSize: 14, color: Colors.black45, fontWeight: FontWeight(500))),  
              ),
            ),
            

            // Ô nhập mã Setup thủ công
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: TextField(
                controller: _setUpCodeController,
                decoration: InputDecoration(
                  labelText: 'Nhập mã setup',
                  labelStyle: const TextStyle(color: Colors.grey),
                  floatingLabelStyle: const TextStyle(color: Colors.blueAccent),

                  hintText: 'Ví dụ: 1234-5678-901',
                  hintStyle: const TextStyle(color: Colors.grey),

                  prefixIcon: const Icon(Icons.keyboard, color: Colors.blueAccent),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blueAccent),
                  ),
                ),
                keyboardType: TextInputType.text,
                enabled: !_isCommissioning,
              ),
            ),
            const SizedBox(height: 28),

            // Nút Bắt đầu Commissioning
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isCommissioning ? null : _startCommissioning,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 52, 128, 199),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  disabledBackgroundColor: Colors.grey,
                ),
                child: _currentStatus == 1 || _currentStatus == 2 ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                ) : const Text(
                  'Bắt đầu Commissioning', 
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Khu vực hiển thị trạng thái log kết nối
            const Text('Trạng thái', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildStatusRow('Chưa bắt đầu', _currentStatus == 0, isDone: _currentStatus > 0),
                  const Divider(height: 24),
                  _buildStatusRow('Đang tìm thiết bị', _currentStatus == 1, isDone: _currentStatus > 1),
                  const Divider(height: 24),
                  _buildStatusRow('Đang ghép nối', _currentStatus == 2, isDone: _currentStatus > 2),
                  const Divider(height: 24),
                  _buildStatusRow('Thêm thiết bị thành công', _currentStatus == 3, isDone: _currentStatus >= 3, isSuccessStep: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );   
  }
}

Widget _buildStatusRow(String text, bool isActive, {bool isDone = false, bool isSuccessStep = true}) {

  Color iconColor = Colors.grey.shade300;
  IconData iconData = Icons.radio_button_off;

  if(isActive){
    iconColor = isSuccessStep ? Colors.green : Colors.blueAccent;
    iconData = isSuccessStep ? Icons.check_circle : Icons.radio_button_checked;
  } else if(isDone){
    iconColor = Colors.green;
    iconData = Icons.check_circle;
  }
  return Row(
    children: [
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Icon(iconData, color: iconColor, key: ValueKey(iconData), size: 24),
      ),
      const SizedBox(width: 14),
      Text(
        text, 
        style: TextStyle(
          fontSize: 15, 
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal, 
          color: isActive ? (isSuccessStep ? Colors.green : Colors.blueAccent) : (isDone ? Colors.black87 : Colors.black38)
        ),
      ),
      if(isActive && !isSuccessStep) ... [
        const Spacer(),
        const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blueAccent),
        )
      ]
    ],
  );
}