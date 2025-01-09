import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:vibration/vibration.dart';

import '../../../craft_dynamic.dart';
import '../../network/dynamic_request.dart';

class QRScanner extends StatefulWidget {
  final ModuleItem moduleItem;
  final FormItem formItem;
  final BuildContext context;

  const QRScanner(
      {Key? key,
      required this.moduleItem,
      required this.formItem,
      required this.context})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final _dynamicRequest = DynamicFormRequest();
  Map<String, dynamic> input = {};
  bool scanSuccess = false;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildQrView(context),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: scanSuccess ? Colors.blue : Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      var code = scanData.code;
      validateQR(code ?? "", controller);
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  void validateQR(String code, QRViewController controller) {
    if (code.isNotEmpty) {
      AppLogger.appLogD(tag: "qr code", message: "scanning qr ----> $code");
      input.addAll({"ACCOUNTID": code});
      CommonUtils.showToast("Successfully scanned QR");
      controller.dispose();
      setState(() {
        scanSuccess = true;
      });
      Future.delayed(const Duration(milliseconds: 1000), () {
        Navigator.of(context).pop();
        Provider.of<PluginState>(widget.context, listen: false)
            .setScanValidationLoading(true);
        _dynamicRequest
            .dynamicRequest(widget.moduleItem,
                formItem: widget.formItem,
                dataObj: input,
                context: widget.context,
                tappedButton: true)
            .then((value) => DynamicPostCall.processDynamicResponse(
                value!.dynamicData!, widget.context, widget.formItem.controlId!,
                moduleItem: widget.moduleItem));
        Vibration.vibrate();
      });
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
