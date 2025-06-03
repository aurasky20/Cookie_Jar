import 'dart:io';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:image_picker/image_picker.dart';

class Utils {
  static pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      throw Exception('No image selected');
    }

    File imageFile = File(pickedFile.path);
    String key = '${DateTime.now().millisecondsSinceEpoch}.jpg';

    try {
      final result = await Amplify.Storage.uploadFile(
        localFile: AWSFile.fromPath(imageFile.path),
        path: StoragePath.fromString('product/$key'),
      );

      print('${result.operationId} - ${result.result}');

      final urlResult = await Amplify.Storage.getUrl(
        path: StoragePath.fromString('product/$key'),
      );

      final publicUrl = await urlResult.result;
      print('Image uploaded. Public URL: ${publicUrl.url}');
      return [publicUrl.url, imageFile.path];
    } catch (e) {
      print('Upload failed: $e');
      throw Exception('Image upload failed: $e');
    }
  }
}
