import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

/// Keeps uploaded photos under the backend's hard size limit.
///
/// The API rejects images larger than 5 MB, so every photo is re-encoded
/// before upload until it fits. Camera/gallery originals (especially HEIC or
/// high-megapixel shots) routinely exceed that; this downscales + drops JPEG
/// quality progressively until the file is under the cap.
class ImageCompressor {
  /// Backend ceiling. Kept a touch below 5 MB to leave room for multipart
  /// overhead and avoid a boundary rejection.
  static const int maxUploadBytes = 5 * 1024 * 1024 - 256 * 1024; // ~4.75 MB

  /// Progressive (maxDimension, quality) passes, smallest output wins. The
  /// first pass barely touches typical camera photos; later passes rescue
  /// very large gallery images.
  static const List<(int, int)> _passes = [
    (2560, 90),
    (1920, 85),
    (1600, 75),
    (1280, 65),
    (1024, 55),
    (800, 45),
  ];

  /// Returns a path to a JPEG no larger than [maxBytes]. If the original is
  /// already small enough it's returned untouched. Best-effort: on any
  /// compression failure the original path is returned so the upload still
  /// proceeds (the backend, not the app, is the final gatekeeper).
  static Future<String> compressForUpload(
    String path, {
    int maxBytes = maxUploadBytes,
  }) async {
    try {
      final original = File(path);
      if (!await original.exists()) return path;
      if (await original.length() <= maxBytes) return path;

      final dir = await getTemporaryDirectory();
      final stamp = DateTime.now().microsecondsSinceEpoch;

      String? bestPath;
      int bestSize = 1 << 62;

      for (var i = 0; i < _passes.length; i++) {
        final (dimension, quality) = _passes[i];
        final target = '${dir.path}/upload_${stamp}_$i.jpg';
        final result = await FlutterImageCompress.compressAndGetFile(
          path,
          target,
          minWidth: dimension,
          minHeight: dimension,
          quality: quality,
          format: CompressFormat.jpeg,
        );
        if (result == null) continue;

        final size = await File(result.path).length();
        if (size < bestSize) {
          bestSize = size;
          bestPath = result.path;
        }
        // Good enough — stop at the first (highest-quality) pass under the cap.
        if (size <= maxBytes) return result.path;
      }

      // Nothing hit the cap (extreme input) — send the smallest we produced.
      if (bestPath != null) return bestPath;
    } catch (e) {
      if (kDebugMode) debugPrint('[IMG_COMPRESS] failed for $path: $e');
    }
    return path;
  }
}
