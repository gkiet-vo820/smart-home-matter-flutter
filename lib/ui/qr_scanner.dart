import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScanner extends StatefulWidget {
  const QrScanner({super.key});

  @override
  State<QrScanner> createState() => _QrScannerState();
}
class _QrScannerState extends State<QrScanner> {

  final MobileScannerController _scannerController = MobileScannerController();
  bool _isScanned  = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture){
    if(_isScanned ) return;
    final List<Barcode> barcodes = capture.barcodes;
    if(barcodes.isEmpty) return;
    final String? code = barcodes.first.rawValue;
    if(code == null || code.isEmpty) return;
    _isScanned  = true;
    Navigator.of(context).pop(code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Quét mã QR Matter', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: (){
              _scannerController.toggleTorch();
            },
            icon: const Icon(Icons.flash_on),
          ),
          IconButton(
            onPressed: (){
              _scannerController.switchCamera();
            },
            icon: const Icon(Icons.cameraswitch),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: _onDetect,
            controller: _scannerController,
          ),
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.blueAccent,
                  width: 4,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          
          Positioned(
            left: 24,
            right: 24,
            bottom: 40,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Đưa mã QR Matter vào khung để quét. \nNếu không có QR hãy quay lại và nhập mã setup.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

}