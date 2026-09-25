
import 'package:lastanswer/common_imports.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Full-screen camera scanner that pops with the decoded pairing code
/// (string). Push it with [Navigator.push]; the awaited value is the
/// raw code, or `null` when dismissed.
class MeshQrScanPage extends StatefulWidget {
  const MeshQrScanPage({super.key});

  @override
  State<MeshQrScanPage> createState() => _MeshQrScanPageState();
}

class _MeshQrScanPageState extends State<MeshQrScanPage> {
  final _controller = MobileScannerController();
  var _completed = false;

  @override
  void dispose() {
    unawaited(_controller.dispose());
    super.dispose();
  }

  void _onDetect(final BarcodeCapture capture) {
    if (_completed) return;
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;
      if (value == null || value.isEmpty) continue;
      _completed = true;
      Navigator.of(context).pop(value);
      return;
    }
  }

  @override
  Widget build(final BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.storageMeshScanQr)),
    body: MobileScanner(controller: _controller, onDetect: _onDetect),
  );
}
