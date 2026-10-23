import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import 'storage_service.dart';

class ProductService {
  final CollectionReference _productsRef =
      FirebaseFirestore.instance.collection('products');
  final StorageService _storageService = StorageService();

  // Lắng nghe danh sách sản phẩm thời gian thực (Stream)
  Stream<List<Product>> getProductsStream({String? category}) {
    Query query = _productsRef;
    if (category != null && category.isNotEmpty && category != 'Tất cả') {
      query = query.where('category', isEqualTo: category);
    }
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Thêm sản phẩm mới (tên, loại, giá, Image)
  Future<void> addProduct({
    required String name,
    required String category,
    required double price,
    String description = '',
    File? imageFile,
    String? imageUrl,
  }) async {
    final docRef = _productsRef.doc();
    String? finalImageUrl = imageUrl;

    if (imageFile != null) {
      finalImageUrl = await _storageService.uploadProductImage(imageFile, docRef.id);
    }

    final product = Product(
      id: docRef.id,
      name: name,
      category: category,
      price: price,
      description: description,
      imageUrl: finalImageUrl,
      createdAt: DateTime.now(),
    );

    await docRef.set(product.toMap());
  }

  // Cập nhật sản phẩm
  Future<void> updateProduct({
    required String id,
    required String name,
    required String category,
    required double price,
    String description = '',
    File? newImageFile,
    String? currentImageUrl,
  }) async {
    String? finalImageUrl = currentImageUrl;

    if (newImageFile != null) {
      finalImageUrl = await _storageService.uploadProductImage(newImageFile, id);
    }

    await _productsRef.doc(id).update({
      'name': name,
      'category': category,
      'price': price,
      'description': description,
      'imageUrl': finalImageUrl,
      'Image': finalImageUrl,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // Xóa sản phẩm
  Future<void> deleteProduct(String id, String? imageUrl) async {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      await _storageService.deleteImage(imageUrl);
    }
    await _productsRef.doc(id).delete();
  }
}
