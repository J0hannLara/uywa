import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageService {

  Future<File?> convertToWebp(
    File file,
  ) async {

    final targetPath =
        '${file.path}.webp';

    final result =
        await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      format: CompressFormat.webp,
      quality: 80,
    );

    if (result == null) {
      return null;
    }

    return File(result.path);
  }
}