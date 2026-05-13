import 'dart:io';

import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadResult {
  final bool success;
  final String? path;
  final String? errorMessage;

  const DownloadResult({required this.success, this.path, this.errorMessage});
}

class FileDownloader {
  FileDownloader._();

  static final Dio _dio = Dio();

  static Future<DownloadResult> downloadAndOpenPdf({
    required String url,
    required String fileName,
    void Function(int received, int total)? onProgress,
  }) async {
    try {
      final dir = await _resolveDownloadDir();
      if (dir == null) {
        return const DownloadResult(
          success: false,
          errorMessage: 'Storage permission denied',
        );
      }

      final safeName = _ensurePdfExtension(_sanitize(fileName));
      final savePath = await _uniquePath(dir, safeName);

      await _dio.download(url, savePath, onReceiveProgress: onProgress);

      await OpenFilex.open(savePath, type: 'application/pdf');

      return DownloadResult(success: true, path: savePath);
    } catch (e) {
      return DownloadResult(success: false, errorMessage: e.toString());
    }
  }

  static Future<Directory?> _resolveDownloadDir() async {
    if (Platform.isAndroid) {
      if (await _ensureAndroidStoragePermission()) {
        final publicDownloads = Directory('/storage/emulated/0/Download');
        try {
          if (!await publicDownloads.exists()) {
            await publicDownloads.create(recursive: true);
          }
          final probe = File(
            '${publicDownloads.path}/.rinsr_probe',
          );
          await probe.writeAsString('ok', flush: true);
          await probe.delete();
          return publicDownloads;
        } catch (_) {
          // fall through to app-private storage
        }
      }
      final external = await getExternalStorageDirectory();
      if (external != null) {
        final dir = Directory('${external.path}/Download');
        if (!await dir.exists()) await dir.create(recursive: true);
        return dir;
      }
    }
    return getApplicationDocumentsDirectory();
  }

  static Future<bool> _ensureAndroidStoragePermission() async {
    if (!Platform.isAndroid) return true;
    final storage = await Permission.storage.status;
    if (storage.isGranted) return true;
    final requested = await Permission.storage.request();
    return requested.isGranted || requested.isLimited;
  }

  static String _sanitize(String name) =>
      name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();

  static String _ensurePdfExtension(String name) =>
      name.toLowerCase().endsWith('.pdf') ? name : '$name.pdf';

  static Future<String> _uniquePath(Directory dir, String fileName) async {
    final base = fileName.substring(0, fileName.length - 4);
    var candidate = '${dir.path}/$fileName';
    var counter = 1;
    while (await File(candidate).exists()) {
      candidate = '${dir.path}/$base ($counter).pdf';
      counter++;
    }
    return candidate;
  }
}
