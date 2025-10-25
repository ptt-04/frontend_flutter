import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'dialogs/add_category_dialog.dart';
import 'dialogs/edit_category_dialog.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategories();
    });
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final categories = await _apiService.getCategories();
      if (mounted) {
        setState(() {
          _categories = categories;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addCategory() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const AddCategoryDialog(),
    );

    if (result == true) {
      _loadCategories();
    }
  }

  Future<void> _editCategory(Map<String, dynamic> category) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => EditCategoryDialog(category: category),
    );

    if (result == true) {
      _loadCategories();
    }
  }

  Future<void> _deleteCategory(Map<String, dynamic> category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa danh mục "${category['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final response = await _apiService.deleteCategory(category['id']);
        if (mounted) {
          // Parse response to get detailed message
          String message = response['message'] ?? 'Xóa danh mục thành công';
          if (response.containsKey('productsAffected') && response['productsAffected'] > 0) {
            message += '\nĐã chuyển ${response['productsAffected']} sản phẩm sang không có danh mục';
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              duration: const Duration(seconds: 4),
            ),
          );
          _loadCategories();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi xóa danh mục: $e')),
          );
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Quản lý Danh mục',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _loadCategories,
                      icon: const Icon(Icons.refresh, color: Colors.white),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: _buildContent(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCategory,
        backgroundColor: const Color(0xFF667eea),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang tải danh mục...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Lỗi: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCategories,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_categories.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Chưa có danh mục nào',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Nhấn nút + để thêm danh mục đầu tiên',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Stats
        Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Tổng danh mục',
                  _categories.length.toString(),
                  Icons.category,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Đang hoạt động',
                  _categories.where((c) => c['isActive'] == true).length.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
            ],
          ),
        ),
        // Categories List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              return _buildCategoryCard(category);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: category['isActive'] ? Colors.green : Colors.grey,
          child: Icon(
            Icons.category,
            color: Colors.white,
          ),
        ),
        title: Text(
          category['name'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (category['description'] != null && category['description'].isNotEmpty)
              Text(category['description']),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  category['isActive'] ? Icons.check_circle : Icons.cancel,
                  size: 16,
                  color: category['isActive'] ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  category['isActive'] ? 'Hoạt động' : 'Không hoạt động',
                  style: TextStyle(
                    color: category['isActive'] ? Colors.green : Colors.red,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.inventory, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${category['productCount'] ?? 0} sản phẩm',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _editCategory(category);
                break;
              case 'delete':
                _deleteCategory(category);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Chỉnh sửa'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Xóa', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
