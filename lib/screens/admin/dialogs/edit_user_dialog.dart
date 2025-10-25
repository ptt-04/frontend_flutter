import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user.dart';
import '../../../providers/admin_provider.dart';

class EditUserDialog extends StatefulWidget {
  final User user;

  const EditUserDialog({super.key, required this.user});

  @override
  State<EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  
  late DateTime _selectedDate;
  late String _selectedGender;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _phoneController = TextEditingController(text: widget.user.phoneNumber);
    _selectedDate = widget.user.dateOfBirth;
    _selectedGender = widget.user.gender;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Chỉnh sửa ${widget.user.firstName} ${widget.user.lastName}'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Display non-editable fields
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Thông tin không thể chỉnh sửa',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Email: ${widget.user.email}'),
                        Text('Username: @${widget.user.username}'),
                        Text('Vai trò: ${widget.user.role.displayName}'),
                        Text('Ngày tạo: ${_formatDate(widget.user.createdAt)}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Editable fields
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(
                          labelText: 'Tên',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập tên';
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
                          labelText: 'Họ',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập họ';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Số điện thoại',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập số điện thoại';
                    }
                    if (!RegExp(r'^[0-9]{10,11}$').hasMatch(value)) {
                      return 'Số điện thoại không hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedGender,
                        decoration: const InputDecoration(
                          labelText: 'Giới tính',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Male', child: Text('Nam')),
                          DropdownMenuItem(value: 'Female', child: Text('Nữ')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: _selectDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Ngày sinh',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          ),
                        ),
                      ),
                    ),
                  ],
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
          onPressed: _isLoading ? null : _updateUser,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Cập nhật'),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 16)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _updateUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final adminProvider = context.read<AdminProvider>();
      
      final success = await adminProvider.updateUser(
        userId: widget.user.id,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        dateOfBirth: _selectedDate,
        gender: _selectedGender,
      );

      if (success && mounted) {
        Navigator.pop(context);
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Đã cập nhật thông tin người dùng'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(adminProvider.error ?? 'Có lỗi xảy ra'),
            backgroundColor: Colors.red,
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
