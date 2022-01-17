import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
// import 'package:scan/scan.dart';

class QRScanPage extends StatefulWidget {
  const QRScanPage({Key? key}) : super(key: key);

  @override
  _QRScanPageState createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        Navigator.pop(context, scanData.code);
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return QRView(
      onQRViewCreated: _onQRViewCreated,
      key: qrKey,
      formatsAllowed: const [BarcodeFormat.qrcode],
    );
  }
}
