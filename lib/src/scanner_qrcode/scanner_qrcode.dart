import 'dart:io';

import 'package:events_time_microapp_ds/events_time_microapp_ds.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:scanning_effect/scanning_effect.dart';

export 'package:qr_code_scanner/src/types/barcode.dart';

class ScannerQRCode {
  GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? _controller;

  void reassemble() {
    try {
      if (Platform.isAndroid) {
        pauseCamera();
      } else if (Platform.isIOS) {
        resumeCamera();
      }
    } catch (_) {}
  }

  void dispose() {
    if (_controller != null) {
      _controller!.dispose();
    }
  }

  void pauseCamera() {
    if (_controller != null) {
      _controller!.pauseCamera();
    }
  }

  void resumeCamera() {
    if (_controller != null) {
      _controller!.resumeCamera();
    }
  }

  Widget view(Function(Barcode) onListen, BuildContext context) {
    final double width = MediaQuery.of(context).size.width - 40;

    return SizedBox(
      height: width,
      width: width,
      child: ScanningEffect(
        scanningColor: DSColors.primary.light,
        borderLineColor: DSColors.primary.base,
        delay: Duration.zero,
        duration: const Duration(seconds: 2),
        child: QRView(
          key: qrKey,
          onQRViewCreated: (QRViewController controller) => _onQRViewCreated(
            controller,
            onListen,
          ),
        ),
      ),
    );
  }

  void _onQRViewCreated(
    QRViewController newControlller,
    Function(Barcode) onListen,
  ) {
    _controller = newControlller;
    _controller!.scannedDataStream.listen((Barcode barcode) {
      _controller!.dispose();
      pauseCamera();
      onListen(barcode);
    });
  }
}
