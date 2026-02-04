import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  late final MobileScannerController _controller;

  bool _hasScanned = false;
  bool _isSwitchingCamera = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final value = barcodes.first.rawValue;
    if (value == null || value.isEmpty) return;

    _hasScanned = true;

    // Stop camera explicitly to avoid resource races
    _controller.stop();

    if (mounted) {
      Navigator.of(context).pop(value);
    }
  }

  Future<void> _switchCameraSafely() async {
    if (_isSwitchingCamera) return;

    _isSwitchingCamera = true;
    await _controller.switchCamera();
    _isSwitchingCamera = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        actions: [
          // Torch button
          ValueListenableBuilder(
            valueListenable: _controller,
            builder: (context, state, _) {
              final torchUnavailable =
                  state.torchState == TorchState.unavailable;

              return IconButton(
                icon: Icon(
                  state.torchState == TorchState.on
                      ? Icons.flash_on
                      : state.torchState == TorchState.auto
                      ? Icons.flash_auto
                      : Icons.flash_off,
                  color: state.torchState == TorchState.on
                      ? Colors.yellow
                      : Colors.grey,
                ),
                onPressed: torchUnavailable ? null : _controller.toggleTorch,
              );
            },
          ),

          // Camera switch button
          ValueListenableBuilder(
            valueListenable: _controller,
            builder: (context, state, _) {
              return IconButton(
                icon: Icon(
                  state.cameraDirection == CameraFacing.front
                      ? Icons.camera_front
                      : Icons.camera_rear,
                ),
                onPressed: _switchCameraSafely,
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final cutOutSize = constraints.biggest.shortestSide * 0.7;

          return MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            overlayBuilder: (_, __) {
              return Container(
                decoration: ShapeDecoration(
                  shape: QrScannerOverlayShape(
                    borderColor: Colors.blueAccent,
                    borderRadius: 12,
                    borderLength: 32,
                    borderWidth: 8,
                    cutOutSize: cutOutSize,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;
  final double cutOutBottomOffset;

  const QrScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 10,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
    this.cutOutBottomOffset = 0,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final cutOutRect = Rect.fromCenter(
      center: Offset(rect.center.dx, rect.center.dy - cutOutBottomOffset),
      width: cutOutSize,
      height: cutOutSize,
    );

    return Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(rect)
      ..addRRect(
        RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius)),
      );
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final cutOutRect = Rect.fromCenter(
      center: Offset(rect.center.dx, rect.center.dy - cutOutBottomOffset),
      width: cutOutSize,
      height: cutOutSize,
    );

    // Dark overlay
    final overlayPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    // Border
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    // Create hole
    final path = Path()
      ..addRect(rect)
      ..addRRect(
        RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius)),
      )
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, overlayPaint);

    // Corners
    void drawCorner(Offset start, Offset h, Offset v) {
      canvas.drawLine(start, h, borderPaint);
      canvas.drawLine(start, v, borderPaint);
    }

    drawCorner(
      cutOutRect.topLeft,
      cutOutRect.topLeft + Offset(borderLength, 0),
      cutOutRect.topLeft + Offset(0, borderLength),
    );
    drawCorner(
      cutOutRect.topRight,
      cutOutRect.topRight + Offset(-borderLength, 0),
      cutOutRect.topRight + Offset(0, borderLength),
    );
    drawCorner(
      cutOutRect.bottomLeft,
      cutOutRect.bottomLeft + Offset(borderLength, 0),
      cutOutRect.bottomLeft + Offset(0, -borderLength),
    );
    drawCorner(
      cutOutRect.bottomRight,
      cutOutRect.bottomRight + Offset(-borderLength, 0),
      cutOutRect.bottomRight + Offset(0, -borderLength),
    );
  }

  @override
  ShapeBorder scale(double t) => this;
}
