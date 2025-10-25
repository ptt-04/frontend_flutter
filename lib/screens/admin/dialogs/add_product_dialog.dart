import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../providers/product_provider.dart';
// import '../../../config/api_config.dart';

class AddProductDialog extends StatefulWidget {
  const AddProductDialog({super.key});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController(text: '0');
  // Bỏ nhập URL: chỉ cho phép thư viện ảnh, tối đa 5 ảnh
  
  int? _selectedCategoryId;
  bool _isLoading = false;
  // Danh sách tối đa 5 ảnh
  List<File> _selectedImages = [];
  List<Uint8List> _selectedImagesBytes = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (images.isNotEmpty) {
        if (kIsWeb) {
          final newBytes = <Uint8List>[];
          for (final img in images.take(5 - _selectedImagesBytes.length)) {
            newBytes.add(await img.readAsBytes());
          }
          setState(() {
            _selectedImagesBytes.addAll(newBytes);
            if (_selectedImagesBytes.length > 5) {
              _selectedImagesBytes = _selectedImagesBytes.take(5).toList();
            }
          });
        } else {
          final newFiles = <File>[];
          for (final img in images.take(5 - _selectedImages.length)) {
            newFiles.add(File(img.path));
          }
          setState(() {
            _selectedImages.addAll(newFiles);
            if (_selectedImages.length > 5) {
              _selectedImages = _selectedImages.take(5).toList();
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi chọn ảnh: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeImageAt(int index) {
    setState(() {
      if (kIsWeb) {
        if (index >= 0 && index < _selectedImagesBytes.length) {
          _selectedImagesBytes.removeAt(index);
        }
      } else {
        if (index >= 0 && index < _selectedImages.length) {
          _selectedImages.removeAt(index);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Thêm sản phẩm mới'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên sản phẩm',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tên sản phẩm';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Mô tả',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mô tả';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Giá (VNĐ)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập giá';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Giá không hợp lệ';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _stockController,
                        decoration: const InputDecoration(
                          labelText: 'Số lượng',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập số lượng';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Số lượng không hợp lệ';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Consumer<ProductProvider>(
                  builder: (context, productProvider, child) {
                    // Tạo danh sách items với option "Không có danh mục"
                    List<DropdownMenuItem<int?>> items = [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Không có danh mục'),
                      ),
                    ];
                    
                    items.addAll(productProvider.categories.map((category) {
                      return DropdownMenuItem<int?>(
                        value: category.id,
                        child: Text(category.name),
                      );
                    }).toList());
                    
                    return DropdownButtonFormField<int?>(
                      initialValue: _selectedCategoryId,
                      decoration: const InputDecoration(
                        labelText: 'Danh mục (tùy chọn)',
                        border: OutlineInputBorder(),
                      ),
                      items: items,
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoryId = value;
                        });
                      },
                      // Không bắt buộc phải chọn danh mục
                      validator: null,
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Image selection section (tối đa 5 ảnh từ thư viện)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hình ảnh sản phẩm',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Preview danh sách ảnh đã chọn
                      Builder(builder: (context) {
                        final items = kIsWeb
                            ? _selectedImagesBytes.map((b) => ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(b, fit: BoxFit.cover),
                                ))
                            : _selectedImages.map((f) => ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(f, fit: BoxFit.cover),
                                ));
                        final count = kIsWeb ? _selectedImagesBytes.length : _selectedImages.length;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (count > 0)
                              SizedBox(
                                height: 120,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: count,
                                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                                  itemBuilder: (context, index) {
                                    return Stack(
                                      children: [
                                        Container(
                                          width: 160,
                                          height: 120,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.grey[300]!),
                                          ),
                                          clipBehavior: Clip.antiAlias,
                                          child: items.elementAt(index),
                                        ),
                                        Positioned(
                                          top: 6,
                                          right: 6,
                                          child: InkWell(
                                            onTap: () => _removeImageAt(index),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black.withValues(alpha: 0.5),
                                                shape: BoxShape.circle,
                                              ),
                                              padding: const EdgeInsets.all(4),
                                              child: const Icon(Icons.close, color: Colors.white, size: 16),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _pickImage,
                                    icon: const Icon(Icons.add_photo_alternate),
                                    label: Text('Chọn ảnh từ thư viện ($count/5)'),
                                  ),
                                ),
                              ],
                            ),
                            if (count == 0)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  'Chưa chọn ảnh (tối đa 5 ảnh)',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                ),
                              ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _addProduct,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Thêm'),
        ),
      ],
    );
  }

  Future<void> _addProduct() async {
    if (!_formKey.currentState!.validate()) return;
    // Không bắt buộc phải có danh mục

    setState(() {
      _isLoading = true;
    });

    try {
      final productProvider = context.read<ProductProvider>();

      // Upload nhiều ảnh từ thư viện (tối đa 5)
      List<String> galleryUrls = [];
      if (kIsWeb && _selectedImagesBytes.isNotEmpty) {
        final filenames = List<String>.generate(
          _selectedImagesBytes.length,
          (i) => 'product_${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
        );
        galleryUrls = await productProvider.uploadProductImagesBytes(
          _selectedImagesBytes,
          filenames,
        );
      } else if (!kIsWeb && _selectedImages.isNotEmpty) {
        galleryUrls = await productProvider.uploadProductImages(
          _selectedImages,
        );
      }

      // Ảnh thumbnail lấy ảnh đầu của gallery nếu có
      final String? imageUrl = galleryUrls.isNotEmpty ? galleryUrls.first : null;

      await productProvider.createProduct(
        name: _nameController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        categoryId: _selectedCategoryId,
        imageUrl: imageUrl,
        stockQuantity: int.parse(_stockController.text),
        imageGallery: galleryUrls,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã thêm sản phẩm thành công'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
