import 'package:flutter/material.dart';
import 'package:luan_van_tot_nghiep_dh52200960/models/device_model.dart';
import 'package:luan_van_tot_nghiep_dh52200960/services/device_service.dart';
import 'package:luan_van_tot_nghiep_dh52200960/services/history_service.dart';
import 'package:luan_van_tot_nghiep_dh52200960/services/matter_channel_service.dart';

class DeviceDetail extends StatefulWidget {
  final DeviceModel deviceModel;

  const DeviceDetail({
    super.key,
    required this.deviceModel,
  });

  @override
  State<DeviceDetail> createState() => _DeviceDetailState();
}

class _DeviceDetailState extends State<DeviceDetail> {
  late bool _isDeviceOn;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isDeviceOn = widget.deviceModel.isOn;
  }

  IconData _getDeviceIcon() {
    if (widget.deviceModel.type == 'Outlet') {
      return Icons.power;
    }

    return Icons.lightbulb_rounded;
  }

  Color _getDeviceColor() {
    if (!_isDeviceOn) {
      return Colors.grey;
    }

    if (widget.deviceModel.type == 'Outlet') {
      return Colors.blueAccent;
    }

    return Colors.amber;
  }

  // void _toggleDevice() {
  //   setState(() {
  //     DeviceService.toggleDevice(widget.deviceModel);
  //     _isDeviceOn = widget.deviceModel.isOn;
  //   });
  // }
  void _toggleDevice() async {
    if(_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final bool targetState = !widget.deviceModel.isOn;
      final bool success = await MatterChannelService.toggleDevice(
        deviceId: widget.deviceModel.id, 
        targetState: targetState
      );

      if(success){
        await DeviceService.toggleDevice(widget.deviceModel);
      
        await HistoryService.addHistory(
          deviceName: widget.deviceModel.name,
          action: widget.deviceModel.isOn ? 'Bật thiết bị' : 'Tắt thiết bị',
          type: 'action',
        );

        setState(() {
          _isDeviceOn = widget.deviceModel.isOn;
        });
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
      if (mounted){
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color deviceColor = _getDeviceColor();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Chi tiết thiết bị',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _isDeviceOn
                          ? deviceColor.withValues(alpha: 0.2)
                          : Colors.grey.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getDeviceIcon(),
                      size: 64,
                      color: deviceColor,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    widget.deviceModel.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    widget.deviceModel.type,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            _buildQuickInfo(
              'Trạng thái:',
              _isDeviceOn ? 'Đang bật' : 'Đang tắt',
              _isDeviceOn ? Colors.green : Colors.grey,
            ),

            _buildQuickInfo(
              'Kết nối:',
              widget.deviceModel.isConnected ? 'Đã kết nối' : 'Mất kết nối',
              widget.deviceModel.isConnected ? Colors.green : Colors.red,
            ),

            _buildQuickInfo(
              'Phòng:',
              widget.deviceModel.room,
              Colors.black87,
            ),

            const SizedBox(height: 24),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Công tắc',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Bật / tắt thiết bị',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ),

                    OutlinedButton(
                      onPressed: _isLoading ? null : _toggleDevice,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: _isDeviceOn
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.grey.withValues(alpha: 0.1),
                        side: BorderSide(
                          color: _isDeviceOn ? Colors.green : Colors.grey,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      child: _isLoading ?
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ) :
                        Text(
                          _isDeviceOn ? 'ON' : 'OFF',
                          style: TextStyle(
                            color: _isDeviceOn ? Colors.green : Colors.grey[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Thông tin Matter',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.black12.withValues(alpha: 0.05),
                ),
              ),
              child: Column(
                children: [
                  _buildMatterSpec('Device ID', widget.deviceModel.id),
                  const Divider(height: 24),
                  _buildMatterSpec('Endpoint', widget.deviceModel.endpoint),
                  const Divider(height: 24),
                  _buildMatterSpec('Cluster', widget.deviceModel.cluster),
                  const Divider(height: 24),
                  _buildMatterSpec('Device type', widget.deviceModel.type),
                ],
              ),
            ),

            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                  onPressed: (){
                    _showEditDeviceDialog(context, widget.deviceModel);
                  },
                  icon: Icon(Icons.edit, color: Colors.white),
                  label: const Text(
                      'Chỉnh sửa thiết bị',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    )
                  ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: TextButton.icon(
                onPressed: () {
                  _showDeleteConfirmDialog(context, widget.deviceModel);
                },
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                ),
                label: const Text(
                  'Xóa thiết bị',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(
                    color: Colors.redAccent,
                    width: 1,
                  ),
                  backgroundColor: Colors.redAccent.withValues(alpha: 0.05),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildQuickInfo(String label, String value, Color valueColor) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    ),
  );
}

Widget _buildMatterSpec(String label, String value) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          color: Colors.black54,
        ),
      ),
      Text(
        value,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    ],
  );
}

void _showDeleteConfirmDialog(BuildContext context, DeviceModel device) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Xóa thiết bị?'),
        content: Text(
          'Bạn có chắc chắn muốn xóa thiết bị "${device.name}" ra khỏi hệ thống Matter không?',
          // 'Bạn có chắc chắn muốn xóa thiết bị "' + device.name + '" ra khỏi hệ thống Matter không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              'Hủy',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              // DeviceService.removeDevice(device);
              await DeviceService.removeDevice(device);

              await HistoryService.addHistory(
                deviceName: device.name,
                action: 'Xóa thiết bị',
                type: 'delete',
              );

              if (!dialogContext.mounted) return;
              if (!context.mounted) return;

              Navigator.of(dialogContext).pop(); // đóng hộp thoại
              Navigator.of(context).pop(); // quay về HomePage
            },
            child: const Text(
              'Xóa',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    },
  );
}

void _showEditDeviceDialog(BuildContext context, DeviceModel device){
  final TextEditingController nameController = TextEditingController(text: device.name);
  final TextEditingController newRoomController  = TextEditingController();
  String selectedRoom = device.room;
  bool isAddingNewRoom = false;
  final List<String> rooms = [
    'Phòng bếp',
    'Phòng khách',
    'Phòng ngủ',
    'Phòng tắm',
    '+ Thêm phòng mới',
  ];

  if(!rooms.contains(selectedRoom)){
    rooms.insert(rooms.length - 1, selectedRoom);
  }
  
  showDialog(
      context: context,
      builder: (BuildContext dialogContext){
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState){
            return AlertDialog(
              title: const Text('Chỉnh sửa thiết bị'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Tên thiết bị',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: isAddingNewRoom ? '+ Thêm phòng mới' : selectedRoom,
                    decoration: const InputDecoration(
                      labelText: 'Phòng',
                    ),
                    items: rooms.map((room){
                      return DropdownMenuItem<String>(
                        value: room,
                        child: Text(room),
                      );
                    }).toList(),
                    onChanged: (value){
                      if(value == null) return;
                      setDialogState((){
                        if(value == '+ Thêm phòng mới'){
                          isAddingNewRoom = true;
                          newRoomController.clear();
                        } else {
                          isAddingNewRoom = false;
                          selectedRoom = value;
                        }
                      });
                    },
                  ),

                  if(isAddingNewRoom)...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: newRoomController ,
                      decoration: const InputDecoration(
                        labelText: 'Tên phòng mới',
                        hintText: 'Ví dụ: Phòng làm việc',
                      ),
                    ),
                  ],
                ],
              ),

              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Hủy'),
                ),
                TextButton(
                  onPressed: () async {
                    final String newName = nameController.text.trim();
                    final String newRoom = isAddingNewRoom ? newRoomController.text.trim() : selectedRoom;
                    if(newName.isEmpty || newRoom.isEmpty) return;
                    final DeviceModel updatedDevice = device.copyWith(
                      name: newName,
                      room: newRoom,
                    );
                    await DeviceService.updateDevice(updatedDevice);
                    await HistoryService.addHistory(
                      deviceName: newName,
                      action: 'Chỉnh sửa thông tin thiết bị',
                      type: 'edit',
                    );

                    if (!dialogContext.mounted) return;
                    if (!context.mounted) return;
                    Navigator.of(dialogContext).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Lưu', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          }
        );
      }
  );
}