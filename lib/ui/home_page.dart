import 'package:flutter/material.dart';
import 'package:luan_van_tot_nghiep_dh52200960/models/device_model.dart';
import 'package:luan_van_tot_nghiep_dh52200960/services/device_service.dart';
import 'package:luan_van_tot_nghiep_dh52200960/services/history_service.dart';
import 'package:luan_van_tot_nghiep_dh52200960/services/matter_channel_service.dart';
import 'package:luan_van_tot_nghiep_dh52200960/ui/device_detail.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  final List<DeviceModel> devices = DeviceService.getAllDevices();
  final Set<String> _loadingDeviceIds = {};

  void _navigateToDetail(BuildContext context, DeviceModel device) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeviceDetail(deviceModel: device),
      ),
    ).then((_) {
      setState(() {});
    });
  }

  List<Widget> _buildDevicesByRoom(String roomName) {
    return devices
        .where((device) => device.room == roomName)
        .map(
          (device) => _buildDeviceCard(
            device: device,
            isLoading: _loadingDeviceIds.contains(device.id),
            onTap: () => _navigateToDetail(context, device),
            // onPowerTap: () {
            //   setState(() {
            //     DeviceService.toggleDevice(device);
            //   });
            // },
            onPowerTap: () async {
              if(_loadingDeviceIds.contains(device.id)) return;
              setState(() {
                _loadingDeviceIds.add(device.id);
              });
              try {
                final bool targetState = !device.isOn;
                final bool success = await MatterChannelService.toggleDevice(
                  deviceId: device.id, 
                  targetState: targetState
                );
                if(success){
                  await DeviceService.toggleDevice(device);
                  
                  await HistoryService.addHistory(
                    deviceName: device.name,
                    action: device.isOn ? 'Bật thiết bị' : 'Tắt thiết bị',
                    type: 'action',
                  );
                  setState(() {});
                } else {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Điều khiển thiết bị thất bại'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Lỗi điều khiển thiết bị: $e'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              } finally {
                if(mounted) {
                  setState(() {
                    _loadingDeviceIds.remove(device.id);
                  });
                }
              }
            },
          ),
        )
        .toList();
  }

  void _showClearAllDevicesDialog(BuildContext context) {
    showDialog(
      context: context, 
      builder: (BuildContext dialogContext){
        return AlertDialog(
          title: const Text('Xóa tất cả thiết bị?'),
          content: const Text(
            'Bạn có chắc chắn muốn xóa toàn bộ thiết bị khỏi danh sách không?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(), 
              child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                final int deletedCount = devices.length;
                await DeviceService.clearAllDevices();

                await HistoryService.addHistory(
                  deviceName: 'Tất cả thiết bị',
                  action: 'Xóa toàn bộ $deletedCount thiết bị',
                  type: 'delete',
                );

                if (!mounted) return;
                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();
                setState(() {});
                // nếu ghi hàm này ở ngoài _HomePageState thì xài cách này
                // final state = context.findAncestorStateOfType<_HomePageState>();
                // state?.setState((){});
              }, 
              child: const Text('Xóa hết', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final int totalDevices = devices.length;
    final int activeDevices = devices.where((device) => device.isOn).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Smart Home Matter',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => const History(),
              //   ),
              // );
              Navigator.pushNamed(context, '/history');
            },
            icon: const Icon(Icons.history, size: 24),
            padding: const EdgeInsets.symmetric(horizontal: 15),
          ),

          IconButton(
            onPressed: () {
              _showClearAllDevicesDialog(context);
            },
            icon: Icon(Icons.delete_sweep, color: Colors.redAccent, size: 24),
            padding: const EdgeInsets.symmetric(horizontal: 15),
          ),

        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Xin chào Kiệt',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => const AddMatterDevice(),
                  //   ),
                  // );
                  Navigator.pushNamed(context, '/add-device').then((_){
                    setState(() {});
                  });
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Thêm thiết bị Matter',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 2,
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Tổng quan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                _buildOverviewCard(
                  totalDevices.toString(),
                  'Thiết bị',
                  Colors.blueAccent.withValues(alpha: 0.1),
                  Colors.blueAccent,
                ),
                const SizedBox(width: 12),
                _buildOverviewCard(
                  activeDevices.toString(),
                  'Đang bật',
                  Colors.orangeAccent.withValues(alpha: 0.1),
                  Colors.orangeAccent,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // _buildRoomSection(
            //   'Phòng khách',
            //   _buildDevicesByRoom('Phòng khách'),
            // ),
            //
            // _buildRoomSection(
            //   'Phòng ngủ',
            //   _buildDevicesByRoom('Phòng ngủ'),
            // ),
            if(devices.isEmpty)
              _buildEmptyDeviceView()
            else
              ...devices.map((device) => device.room)
                  .toSet()
                  .map((roomName){
                    return _buildRoomSection(
                      roomName,
                      _buildDevicesByRoom(roomName)
                    );
              }),
          ],
        ),
      ),
    );
  }
}

Widget _buildOverviewCard(
  String value,
  String label,
  Color bgColor,
  Color textColor,
) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: textColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildRoomSection(String roomName, List<Widget> devices) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        roomName,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
      ),
      const SizedBox(height: 8),
      ...devices,
      const SizedBox(height: 16),
    ],
  );
}

Widget _buildDeviceCard({
  required DeviceModel device,
  required bool isLoading,
  required VoidCallback onTap,
  required VoidCallback onPowerTap,
}) {
  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 2,
    clipBehavior: Clip.antiAlias, // Sử dụng ClipRTL để hiệu ứng gợn sóng InkWell không bị tràn ra ngoài góc bo của Card
    child: InkWell(
      onTap: onTap, // Kích hoạt hàm chuyển màn hình khi bấm vào Card
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Tên thiết bị và trạng thái Online/Offline
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  device.isConnected ? 'Đã kết nối' : 'Mất kết nối',
                  style: TextStyle(
                    fontSize: 13,
                    color: device.isConnected ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            // Nút Bật/Tắt (ON/OFF)
            OutlinedButton(
              onPressed: isLoading ? null : onPowerTap,
              style: OutlinedButton.styleFrom(
                backgroundColor: device.isOn
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.1),
                side: BorderSide(
                  color: device.isOn ? Colors.green : Colors.grey,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              child: isLoading ? 
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ) :
                Text(
                  device.isOn ? 'ON' : 'OFF',
                  style: TextStyle(
                    color: device.isOn ? Colors.green : Colors.grey[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildEmptyDeviceView(){
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: Colors.black12.withValues(alpha: 0.08),
      ),
    ),
    child: const Column(
      children: [
        Icon(Icons.devices_other, size: 56, color: Colors.grey),
        SizedBox(height: 12),
        Text(
            'Chưa có thiết bị nào',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        SizedBox(height: 6),
        Text(
          'Hãy thêm thiết bị Matter để bắt đầu điều khiển',
          style: TextStyle(fontSize: 14, color: Colors.black45),
        )
      ],
    ),
  );
}