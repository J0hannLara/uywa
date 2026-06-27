import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {

  final supabase = Supabase.instance.client;

  Future<String?> uploadImage({

    required File file,

    required String bucket,

    required String path,

  }) async {

    try {

      await supabase.storage
          .from(bucket)
          .upload(
            path,
            file,
            fileOptions: const FileOptions(
              upsert: false,
            ),
          );

      final imageUrl = supabase.storage
          .from(bucket)
          .getPublicUrl(path);

      return imageUrl;

    } catch (e) {

      print(
        'ERROR uploadImage: $e',
      );

      return null;
    }
  }
}