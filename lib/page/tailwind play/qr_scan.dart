import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrScan extends StatefulWidget {
  const QrScan({super.key});

  @override
  State<QrScan> createState() => _QrScanState();
}

class _QrScanState extends State<QrScan> {
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? _qrController;

  @override
  void reassemble() {
    if (Platform.isAndroid) {
      _qrController!.pauseCamera();
    }
    _qrController!.resumeCamera();
    super.reassemble();
  }

  @override
  void dispose() {
    _qrController?.dispose();
    super.dispose();
  }

  @override
  Widget build(context) {
    return WillPopScope(
      onWillPop: () async {
        if (result == null) {
          Navigator.of(context).pop('');
        } else {
          Navigator.of(context).pop(result!.code);
        }

        return false;
      },
      child: Scaffold(
        body: Stack(
          alignment: Alignment.center,
          children: [
            QRView(
              key: _qrKey,
              onQRViewCreated: (QRViewController controller) {
                setState(() {
                  _qrController = controller;
                });

                _qrController!.scannedDataStream.listen((data) {
                  setState(() {
                    result = data;
                  });
                });
              },
              onPermissionSet: (ctl, p) {
                if (!p) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('no Permission')),
                  );
                }
              },
              overlay: QrScannerOverlayShape(
                borderColor: Theme.of(context).colorScheme.primary,
                borderRadius: 16,
                borderLength: 35,
                borderWidth: 12,
                cutOutSize: MediaQuery.of(context).size.width * 0.8,
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: (result != null)
                    ? const Text('Content found.')
                    : const Text(
                        'Scan qr code to generate Tailwind play token.'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
