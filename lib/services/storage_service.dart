import 'dart:convert';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  // Chỉ định chính xác bucket từ google-services.json
  final FirebaseStorage _storage = FirebaseStorage.instanceFor(
    bucket: 'ecomer-a01f9.firebasestorage.app',
  );

  // Upload file ảnh sản phẩm lên Storage, có fallback Base64 nếu Storage chưa kích hoạt
  Future<String> uploadProductImage(File imageFile, String productId) async {
    try {
      final ref = _storage.ref().child('products/$productId.jpg');
      final uploadTask = await ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      // Nếu Firebase Storage chưa được kích hoạt trên Firebase Console (object-not-found),
      // tự động chuyển đổi file ảnh thành Base64 Data URI để lưu trực tiếp vào Firestore
      // Đảm bảo không bao giờ bị crash hay chặn thêm sản phẩm!
      final bytes = await imageFile.readAsBytes();
      final base64String = base64Encode(bytes);
      return 'data:image/jpeg;base64,$base64String';
    }
  }

  // Xóa ảnh cũ khi sửa hoặc xóa sản phẩm
  Future<void> deleteImage(String imageUrl) async {
    if (!imageUrl.startsWith('http')) return; // Bỏ qua nếu là base64
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      // Bỏ qua lỗi nếu file không tồn tại
    }
  }
}
