# Smart Home Matter Flutter

Ứng dụng Android điều khiển thiết bị IoT hỗ trợ Matter.

## Chức năng chính

- Hiển thị danh sách thiết bị theo phòng
- Thêm thiết bị Matter bằng mã setup
- Quét QR Matter
- Bật/tắt thiết bị
- Xem chi tiết thiết bị
- Chỉnh sửa tên thiết bị và phòng
- Thêm phòng mới
- Xóa thiết bị
- Lưu lịch sử thao tác
- Lưu dữ liệu cục bộ bằng SharedPreferences
- Giao tiếp Flutter với Kotlin qua MethodChannel
- Mô phỏng Matter Manager để chuẩn bị tích hợp Matter SDK thật

## Công nghệ sử dụng

- Flutter
- Dart
- Kotlin Android
- MethodChannel
- SharedPreferences
- mobile_scanner

## Trạng thái hiện tại

Ứng dụng hiện đang chạy ở chế độ mô phỏng Matter.  
Phần `MatterManager.kt` đã được tách riêng để sau này tích hợp Google Home Mobile SDK hoặc Matter Android SDK thật.

## Cách chạy project

```bash
flutter pub get
flutter run
