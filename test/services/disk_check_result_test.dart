import 'package:flutter_test/flutter_test.dart';
import 'package:me2_pack_loader/models/disk_check_result.dart';

void main() {
  group('DiskCheckResult.compute', () {
    test('reports "enough" when free space exceeds need by more than the margin',
        () {
      final result = DiskCheckResult.compute(
        neededBytes: 1_000_000_000,
        freeBytes: 10_000_000_000,
      );

      expect(result.verdict, equals(DiskVerdict.enough));
      expect(result.marginAfterMoveBytes, equals(9_000_000_000));
    });

    test('reports "insufficient" when need exceeds free space', () {
      final result = DiskCheckResult.compute(
        neededBytes: 10_000_000_000,
        freeBytes: 5_000_000_000,
      );

      expect(result.verdict, equals(DiskVerdict.insufficient));
      expect(result.marginAfterMoveBytes, lessThan(0));
    });

    test('reports "tight" when post-move margin is below 2 GB', () {
      final result = DiskCheckResult.compute(
        neededBytes: 9_000_000_000,
        freeBytes: 10_000_000_000,
      );

      expect(result.verdict, equals(DiskVerdict.tight));
      expect(result.marginAfterMoveBytes, equals(1_000_000_000));
    });
  });
}
