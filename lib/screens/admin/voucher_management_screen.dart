import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../models/voucher.dart';
import 'dialogs/add_voucher_dialog.dart';
import 'dialogs/edit_voucher_dialog.dart';

class VoucherManagementScreen extends StatefulWidget {
  const VoucherManagementScreen({super.key});

  @override
  State<VoucherManagementScreen> createState() => _VoucherManagementScreenState();
}

class _VoucherManagementScreenState extends State<VoucherManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadVouchers();
      context.read<AdminProvider>().loadUserVouchers();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        return Column(
          children: [
            TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: 'Quản lý Voucher', icon: Icon(Icons.local_offer)),
                Tab(text: 'Voucher của người dùng', icon: Icon(Icons.people)),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildVoucherList(adminProvider),
                  _buildUserVoucherList(adminProvider),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildVoucherList(AdminProvider adminProvider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Add button
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 400) {
                return Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showAddVoucherDialog(context),
                        child: const Icon(Icons.add),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => adminProvider.loadVouchers(),
                        child: const Icon(Icons.refresh),
                      ),
                    ),
                  ],
                );
              } else {
                return Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showAddVoucherDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Thêm voucher'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () => adminProvider.loadVouchers(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Làm mới'),
                    ),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 16),

          // Vouchers List
          Expanded(
            child: adminProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : adminProvider.vouchers.isEmpty
                    ? const Center(
                        child: Text('Chưa có voucher nào'),
                      )
                    : ListView.builder(
                        itemCount: adminProvider.vouchers.length,
                        itemBuilder: (context, index) {
                          final voucher = adminProvider.vouchers[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(voucher.name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Mã: ${voucher.code}'),
                                  Text('Giảm: ${voucher.discountAmount.toStringAsFixed(0)}${voucher.discountType == 'Percentage' ? '%' : 'đ'}'),
                                  Text('Tối thiểu: ${voucher.minimumOrderAmount.toStringAsFixed(0)}đ'),
                                  Text('Còn lại: ${voucher.maxUsageCount - voucher.usedCount}/${voucher.maxUsageCount}'),
                                  Text('HSD: ${_formatDate(voucher.validTo)}'),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showEditVoucherDialog(context, voucher);
                                  } else if (value == 'delete') {
                                    _showDeleteConfirmation(context, voucher);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Chỉnh sửa'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Xóa'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserVoucherList(AdminProvider adminProvider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Refresh button
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 400) {
                return Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => adminProvider.loadUserVouchers(),
                        child: const Icon(Icons.refresh),
                      ),
                    ),
                  ],
                );
              } else {
                return Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => adminProvider.loadUserVouchers(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Làm mới'),
                    ),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 16),

          // User Vouchers List
          Expanded(
            child: adminProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : adminProvider.userVouchers.isEmpty
                    ? const Center(
                        child: Text('Chưa có voucher nào được phát hành'),
                      )
                    : ListView.builder(
                        itemCount: adminProvider.userVouchers.length,
                        itemBuilder: (context, index) {
                          final userVoucher = adminProvider.userVouchers[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(userVoucher.voucher.name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Mã: ${userVoucher.voucher.code}'),
                                  Text('User ID: ${userVoucher.userId}'),
                                  Text('Trạng thái: ${userVoucher.usedAt != null ? 'Đã sử dụng' : 'Chưa sử dụng'}'),
                                  if (userVoucher.usedAt != null)
                                    Text('Sử dụng lúc: ${_formatDateTime(userVoucher.usedAt!)}'),
                                  Text('Nhận lúc: ${_formatDateTime(userVoucher.createdAt)}'),
                                ],
                              ),
                              leading: Icon(
                                userVoucher.usedAt != null ? Icons.check_circle : Icons.pending,
                                color: userVoucher.usedAt != null ? Colors.green : Colors.orange,
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _showAddVoucherDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddVoucherDialog(),
    );
  }

  void _showEditVoucherDialog(BuildContext context, Voucher voucher) {
    showDialog(
      context: context,
      builder: (context) => EditVoucherDialog(voucher: voucher),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Voucher voucher) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa voucher "${voucher.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final adminProvider = context.read<AdminProvider>();
              final success = await adminProvider.deleteVoucher(voucher.id);
              if (success && mounted) {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Đã xóa voucher thành công'),
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
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}
