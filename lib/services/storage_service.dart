import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload a profile photo and return the download URL
  Future<String> uploadProfilePhoto(String userId, File file) async {
    final ref = _storage.ref('profile_photos/$userId.jpg');
    final task = await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return await task.ref.getDownloadURL();
  }

  // Upload a file shared in a group chat
  Future<String> uploadGroupFile(
    String groupId,
    String fileName,
    File file,
  ) async {
    final ref = _storage.ref('groups/$groupId/$fileName');
    final task = await ref.putFile(file);
    return await task.ref.getDownloadURL();
  }

  Future<void> deleteFile(String downloadUrl) async {
    final ref = _storage.refFromURL(downloadUrl);
    await ref.delete();
  }
}