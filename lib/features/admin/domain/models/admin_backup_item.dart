import '../../../../core/utils/json_parsers.dart';

class AdminBackupItem {
  final String fileName;
  final String filePath;
  final String? modifiedAt;
  final int sizeBytes;

  const AdminBackupItem({
    required this.fileName,
    required this.filePath,
    this.modifiedAt,
    required this.sizeBytes,
  });

  factory AdminBackupItem.fromJson(Map<String, dynamic> json) {
    return AdminBackupItem(
      fileName: JsonParsers.toStringValue(json['fileName']),
      filePath: JsonParsers.toStringValue(json['filePath']),
      modifiedAt: JsonParsers.toNullableString(json['modifiedAt']),
      sizeBytes: JsonParsers.toInt(json['sizeBytes']),
    );
  }
}