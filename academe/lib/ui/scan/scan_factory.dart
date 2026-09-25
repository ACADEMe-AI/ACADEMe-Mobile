import '../../data/repositories/photo_repository.dart';
import '../../data/repositories/scan_repository.dart';
import '../../domain/models/scan.dart';
import 'view_models/scan_flow_view_model.dart';

class ScanFactory {
  const ScanFactory({
    required this.scanRepository,
    required this.photoRepository,
  });

  final ScanRepository scanRepository;
  final PhotoRepository photoRepository;

  ScanFlowViewModel flow(ScanMode mode, {Scan? scan}) => ScanFlowViewModel(
    scanRepository: scanRepository,
    photoRepository: photoRepository,
    mode: mode,
    scan: scan,
  );
}
