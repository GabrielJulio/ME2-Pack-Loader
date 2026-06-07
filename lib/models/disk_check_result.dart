enum DiskVerdict { enough, tight, insufficient }

class DiskCheckResult {
  final int neededBytes;
  final int freeBytes;
  final int marginAfterMoveBytes;
  final DiskVerdict verdict;

  const DiskCheckResult({
    required this.neededBytes,
    required this.freeBytes,
    required this.marginAfterMoveBytes,
    required this.verdict,
  });

  static const int tightMarginBytes = 2 * 1024 * 1024 * 1024;

  factory DiskCheckResult.compute({
    required int neededBytes,
    required int freeBytes,
  }) {
    final margin = freeBytes - neededBytes;
    final DiskVerdict verdict;
    if (margin < 0) {
      verdict = DiskVerdict.insufficient;
    } else if (margin < tightMarginBytes) {
      verdict = DiskVerdict.tight;
    } else {
      verdict = DiskVerdict.enough;
    }
    return DiskCheckResult(
      neededBytes: neededBytes,
      freeBytes: freeBytes,
      marginAfterMoveBytes: margin,
      verdict: verdict,
    );
  }
}
