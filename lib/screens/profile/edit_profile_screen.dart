import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  
  DateTime? _selectedDate;
  String? _selectedGender;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      _emailController.text = user.email;
      _phoneController.text = user.phoneNumber ?? '';
      _selectedDate = user.dateOfBirth;
      _selectedGender = user.gender;
      
      if (_selectedDate != null) {
        _dateOfBirthController.text = '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}';
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateOfBirthController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  void _changeProfileImage(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        final File imageFile = File(image.path);
        final authProvider = context.read<AuthProvider>();
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        final success = await authProvider.uploadProfileImage(imageFile);
        
        if (mounted && context.mounted) {
          if (success) {
            scaffoldMessenger.showSnackBar(
              const SnackBar(
                content: Text('Đã cập nhật ảnh đại diện thành công!'),
                backgroundColor: Colors.green,
              ),
            );
            // Reload the screen to show updated image
            setState(() {});
          } else {
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text('Lỗi: ${authProvider.error ?? 'Không thể cập nhật ảnh đại diện'}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
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
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.user;
      
      if (user == null) {
        throw Exception('Không tìm thấy thông tin người dùng');
      }

      // Gọi API cập nhật profile
      final success = await authProvider.updateProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty ? '' : _phoneController.text.trim(),
        dateOfBirth: _selectedDate ?? user.dateOfBirth,
        gender: _selectedGender ?? user.gender,
      );
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật thông tin thành công!'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: ${authProvider.error ?? 'Không thể cập nhật thông tin'}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
          tooltip: 'Quay lại',
        ),
        title: const Text('Chỉnh sửa thông tin'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Lưu'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Section
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      backgroundImage: context.watch<AuthProvider>().user?.profileImageUrl != null
                          ? NetworkImage(context.watch<AuthProvider>().user!.profileImageUrl!)
                          : null,
                      child: context.watch<AuthProvider>().user?.profileImageUrl == null
                          ? Text(
                              _firstNameController.text.isNotEmpty 
                                  ? _firstNameController.text[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _changeProfileImage(context),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Đổi ảnh đại diện'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Personal Information
              Text(
                'Thông tin cá nhân',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'Họ',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập họ';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Tên',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập tên';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Email không hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    if (!RegExp(r'^[0-9]{10,11}$').hasMatch(value.trim())) {
                      return 'Số điện thoại không hợp lệ';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date of Birth
              TextFormField(
                controller: _dateOfBirthController,
                decoration: InputDecoration(
                  labelText: 'Ngày sinh',
                  prefixIcon: const Icon(Icons.calendar_today),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_month),
                    onPressed: _selectDate,
                  ),
                ),
                readOnly: true,
                onTap: _selectDate,
                validator: (value) {
                  if (_selectedDate == null) {
                    return 'Vui lòng chọn ngày sinh';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Gender
              DropdownButtonFormField<String>(
                initialValue: _selectedGender,
                decoration: const InputDecoration(
                  labelText: 'Giới tính',
                  prefixIcon: Icon(Icons.person),
                ),
                items: const [
                  DropdownMenuItem(value: 'Nam', child: Text('Nam')),
                  DropdownMenuItem(value: 'Nữ', child: Text('Nữ')),
                  DropdownMenuItem(value: 'Khác', child: Text('Khác')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng chọn giới tính';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 16),
                            Text('Đang lưu...'),
                          ],
                        )
                      : const Text('Lưu thay đổi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
