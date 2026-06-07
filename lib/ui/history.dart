import 'package:flutter/material.dart';
import 'package:luan_van_tot_nghiep_dh52200960/models/history_model.dart';
import 'package:luan_van_tot_nghiep_dh52200960/services/history_service.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  final List<HistoryModel> histories = HistoryService.getAllHistories();

  IconData _getHistoryIcon(String type) {
    if (type == 'success') {
      return Icons.check_circle;
    }

    if (type == 'delete') {
      return Icons.delete_outline;
    }

    if (type == 'add') {
      return Icons.add_circle_outline;
    }

    if (type == 'edit'){
      return Icons.edit;
    }

    return Icons.touch_app;
  }

  Color _getHistoryColor(String type) {
    if (type == 'success') {
      return Colors.green;
    }

    if (type == 'delete') {
      return Colors.redAccent;
    }

    if (type == 'add') {
      return Colors.blueAccent;
    }

    if(type == 'edit'){
      return Colors.purpleAccent;
    }

    return Colors.orangeAccent;
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Xóa lịch sử?'),
          content: const Text(
            'Bạn có chắc chắn muốn xóa toàn bộ lịch sử thao tác không?',
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
                await HistoryService.clearHistories();

                if (!context.mounted) return;
                if (!dialogContext.mounted) return;

                Navigator.of(dialogContext).pop();

                setState(() {});
              },
              child: const Text(
                'Xóa hết',
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

  @override
  Widget build(BuildContext context) {
    final int totalHistory = histories.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Lịch sử thao tác',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (histories.isNotEmpty)
            IconButton(
              onPressed: _showClearHistoryDialog,
              icon: const Icon(
                Icons.delete_sweep,
                color: Colors.redAccent,
              ),
            ),
        ],
      ),
      body: histories.isEmpty
          ? _buildEmptyHistoryView()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tổng số thao tác: $totalHistory',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Thẻ hiển thị kết quả Commissioning chính
                  Container(
                    // width: double.infinity,
                    // padding: const EdgeInsets.all(20),
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),

                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: histories.length,
                      itemBuilder: (context, index) {
                        final HistoryModel history = histories[index];
                        final bool isLast = index == histories.length - 1;

                        return _buildTimelineItem(
                          time: history.time,
                          deviceName: history.deviceName,
                          action: history.action,
                          type: history.type,
                          isLast: isLast,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyHistoryView(){
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history, size: 60, color: Colors.grey),
              SizedBox(height: 12),
              Text('Chưa có lịch sử thao tác', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              SizedBox(height: 6),
              Text(
                'Các thao tác thêm, bật/tắt, chỉnh sửa hoặc xóa thiết bị sẽ hiển thị tại đây.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black45),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // Widget vẽ từng dòng log dạng Timeline cây thư mục/tiến trình
  Widget _buildTimelineItem({
    required String time,
    required String deviceName,
    required String action,
    required String type,
    required bool isLast,
  }) {

    // Tự động chọn màu sắc cho icon dựa trên loại log
    final Color dotColor = _getHistoryColor(type);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              time,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
                fontSize: 12,
              ),
            ),
          ),

          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: dotColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getHistoryIcon(type),
                  size: 18,
                  color: dotColor,
                ),
              ),

              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey.shade300,
                  ),
                ),
            ],
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deviceName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      action,
                      style: TextStyle(
                        fontSize: 14,
                        color: dotColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}