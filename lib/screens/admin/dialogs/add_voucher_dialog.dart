import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/admin_provider.dart';
import '../../../models/voucher.dart';

class AddVoucherDialog extends StatefulWidget {
  const AddVoucherDialog({super.key});

  @override
  State<AddVoucherDialog> createState() => _AddVoucherDialogState();
}

class _AddVoucherDialogState extends State<AddVoucherDialog> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _discountAmountController = TextEditingController();
  final _minimumOrderAmountController = TextEditingController();
  final _maxUsageCountController = TextEditingController();

  String _discountType = 'Percentage';
  DateTime _validFrom = DateTime.now();
  DateTime _validTo = DateTime.now().add(const Duration(days: 30));
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _discountAmountController.dispose();
    _minimumOrderAmountController.dispose();
    _maxUsageCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Thêm voucher mới'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    labelText: 'Mã voucher',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập mã voucher';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên voucher',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập tên voucher';
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
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _discountType,
                  decoration: const InputDecoration(
                    labelText: 'Loại giảm giá',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Percentage', child: Text('Phần trăm (%)')),
                    DropdownMenuItem(value: 'FixedAmount', child: Text('Số tiền cố định (đ)')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _discountType = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _discountAmountController,
                  decoration: InputDecoration(
                    labelText: _discountType == 'Percentage' ? 'Phần trăm giảm (%)' : 'Số tiền giảm (đ)',
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập số tiền giảm';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Số tiền phải lớn hơn 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _minimumOrderAmountController,
                  decoration: const InputDecoration(
                    labelText: 'Đơn hàng tối thiểu (đ)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập đơn hàng tối thiểu';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount < 0) {
                      return 'Đơn hàng tối thiểu phải >= 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _maxUsageCountController,
                  decoration: const InputDecoration(
                    labelText: 'Số lần sử dụng tối đa',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập số lần sử dụng';
                    }
                    final count = int.tryParse(value);
                    if (count == null || count <= 0) {
                      return 'Số lần sử dụng phải lớn hơn 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: const Text('Từ ngày'),
                        subtitle: Text('${_validFrom.day}/${_validFrom.month}/${_validFrom.year}'),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _validFrom,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            setState(() {
                              _validFrom = date;
                            });
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: const Text('Đến ngày'),
                        subtitle: Text('${_validTo.day}/${_validTo.month}/${_validTo.year}'),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _validTo,
                            firstDate: _validFrom,
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            setState(() {
                              _validTo = date;
                            });
                          }
                        },
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
          onPressed: _isLoading ? null : _createVoucher,
          child: _isLoading
              ? const CircularProgressIndicator(strokeWidth: 2)
              : const Text('Tạo voucher'),
        ),
      ],
    );
  }

  Future<void> _createVoucher() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final voucherDto = CreateVoucherDto(
        code: _codeController.text.trim(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        discountAmount: double.parse(_discountAmountController.text),
        discountType: _discountType,
        minimumOrderAmount: double.parse(_minimumOrderAmountController.text),
        maxUsageCount: int.parse(_maxUsageCountController.text),
        validFrom: _validFrom,
        validTo: _validTo,
      );

      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final adminProvider = context.read<AdminProvider>();
      final success = await adminProvider.createVoucher(voucherDto);

      if (success && mounted) {
        Navigator.pop(context);
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Đã tạo voucher thành công'),
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
}
