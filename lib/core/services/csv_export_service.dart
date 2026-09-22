import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class CsvExportService {
  CsvExportService._();

  /// Converts 2D list to CSV and triggers a client-side browser file download
  static void exportToCsv({
    required String fileName,
    required List<List<dynamic>> rows,
  }) {
    final csvContent = const ListToCsvConverter().convert(rows);
    final bytes = utf8.encode(csvContent);

    if (kIsWeb) {
      final blob = html.Blob([bytes], 'text/csv;charset=utf-8;');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute('download', fileName.endsWith('.csv') ? fileName : '$fileName.csv')
        ..click();
      html.Url.revokeObjectUrl(url);
    }
  }
}
