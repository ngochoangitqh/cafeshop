import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/product_image_widget.dart';

class AdminProductFormScreen extends StatefulWidget {
  final Product? product; // null nếu là thêm mới, có giá trị nếu sửa

  const AdminProductFormScreen({super.key, this.product});

  @override
  State<AdminProductFormScreen> createState() => _AdminProductFormScreenState();
}

class _AdminProductFormScreenState extends State<AdminProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProductService _productService = ProductService();
  final ImagePicker _picker = ImagePicker();

  late String _name;
  late String _category;
  late double _price;
  late String _description;
  String? _imageUrl;
  File? _selectedImageFile;
  bool _isLoading = false;

  final List<String> _categories = [
    'Cà phê',
    'Trà',
    'Sinh tố',
    'Bánh',
    'Khác',
  ];

  @override
  void initState() {
    super.initState();
    _name = widget.product?.name ?? '';
    _category = widget.product?.category ?? 'Cà phê';
    _price = widget.product?.price ?? 0.0;
    _description = widget.product?.description ?? '';
    _imageUrl = widget.product?.imageUrl;

    if (!_categories.contains(_category)) {
      _categories.insert(0, _category);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 70, // Nén ảnh nhẹ tối ưu lưu trữ
        maxWidth: 800,
        maxHeight: 800,
      );
      if (picked != null) {
        setState(() {
          _selectedImageFile = File(picked.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể chọn ảnh: $e')),
        );
      }
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
      if (widget.product == null) {
        // Thêm sản phẩm mới
        await _productService.addProduct(
          name: _name,
          category: _category,
          price: _price,
          description: _description,
          imageFile: _selectedImageFile,
          imageUrl: _imageUrl,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Thêm sản phẩm thành công!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Cập nhật sản phẩm
        await _productService.updateProduct(
          id: widget.product!.id,
          name: _name,
          category: _category,
          price: _price,
          description: _description,
          newImageFile: _selectedImageFile,
          currentImageUrl: _imageUrl,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Cập nhật sản phẩm thành công!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditing ? 'Sửa sản phẩm' : 'Thêm sản phẩm mới'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Chọn ảnh đại diện sản phẩm (Image)
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (ctx) => SafeArea(
                      child: Wrap(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.photo_library),
                            title: const Text('Chọn ảnh từ thư viện'),
                            onTap: () {
                              Navigator.pop(ctx);
                              _pickImage(ImageSource.gallery);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.camera_alt),
                            title: const Text('Chụp ảnh mới'),
                            onTap: () {
                              Navigator.pop(ctx);
                              _pickImage(ImageSource.camera);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: _selectedImageFile != null
                        ? Image.file(_selectedImageFile!, fit: BoxFit.cover, width: double.infinity)
                        : (_imageUrl != null && _imageUrl!.isNotEmpty)
                            ? ProductImageWidget(
                                imageUrl: _imageUrl,
                                width: double.infinity,
                                height: 180,
                                fit: BoxFit.cover,
                              )
                            : _buildPlaceholder(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'Chạm vào khung để chọn hình ảnh sản phẩm',
                  style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                ),
              ),
              const SizedBox(height: 20),

              // Nhập Tên sản phẩm
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(
                  labelText: 'Tên sản phẩm *',
                  hintText: 'Ví dụ: Cà phê sữa đá',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Vui lòng nhập tên sản phẩm' : null,
                onSaved: (val) => _name = val!.trim(),
              ),
              const SizedBox(height: 16),

              // Chọn Loại sản phẩm
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: InputDecoration(
                  labelText: 'Loại sản phẩm *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: _categories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _category = val);
                },
              ),
              const SizedBox(height: 16),

              // Nhập Giá
              TextFormField(
                initialValue: _price > 0 ? _price.toStringAsFixed(0) : '',
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Giá sản phẩm (VNĐ) *',
                  hintText: 'Ví dụ: 29000',
                  suffixText: 'đ',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Vui lòng nhập giá';
                  final numVal = double.tryParse(val.replaceAll('.', '').replaceAll(',', ''));
                  if (numVal == null || numVal <= 0) return 'Giá phải là số lớn hơn 0';
                  return null;
                },
                onSaved: (val) {
                  _price = double.parse(val!.replaceAll('.', '').replaceAll(',', ''));
                },
              ),
              const SizedBox(height: 16),

              // Nhập Mô tả
              TextFormField(
                initialValue: _description,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Mô tả chi tiết',
                  hintText: 'Cà phê đậm đà, sữa đặc béo ngậy...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onSaved: (val) => _description = val?.trim() ?? '',
              ),
              const SizedBox(height: 28),

              // Nút Lưu
              ElevatedButton(
                onPressed: _isLoading ? null : _saveProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        isEditing ? 'CẬP NHẬT SẢN PHẨM' : 'THÊM SẢN PHẨM',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade100,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_a_photo_outlined, size: 48, color: AppColors.primary),
          SizedBox(height: 8),
          Text('Thêm hình ảnh sản phẩm', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
