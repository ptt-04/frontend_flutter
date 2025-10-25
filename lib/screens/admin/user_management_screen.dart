import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../models/user.dart';
import '../../widgets/responsive_widgets.dart';
import 'dialogs/add_user_dialog.dart';
import 'dialogs/edit_user_dialog.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  Role? _filterRole;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadUsers();
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
            _buildHeader(context, adminProvider),
            _buildSearchAndFilter(context),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildUserList(adminProvider.getCustomers(), 'Khách hàng'),
                  _buildUserList(adminProvider.getBarbers(), 'Thợ cắt tóc'),
                  _buildUserList(adminProvider.getAdmins(), 'Quản trị viên'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, AdminProvider adminProvider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ResponsiveText(
              'Quản lý người dùng',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          const SizedBox(width: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 500) {
                // Màn hình nhỏ - chỉ hiển thị icon
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () => _showAddUserDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Icon(Icons.add),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => adminProvider.loadUsers(),
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Làm mới',
                    ),
                  ],
                );
              } else {
                // Màn hình lớn - hiển thị đầy đủ
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showAddUserDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Thêm Barber'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => adminProvider.loadUsers(),
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Làm mới',
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Tìm kiếm theo tên, email...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Flexible(
                child: DropdownButton<Role?>(
                  value: _filterRole,
                  hint: const Text('Lọc theo vai trò'),
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem<Role?>(
                      value: null,
                      child: Text('Tất cả'),
                    ),
                    ...Role.values.map(
                      (role) => DropdownMenuItem<Role?>(
                        value: role,
                        child: Text(role.displayName),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _filterRole = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(List<User> users, String title) {
    final filteredUsers = users.where((user) {
      final matchesSearch = _searchQuery.isEmpty ||
          user.firstName.toLowerCase().contains(_searchQuery) ||
          user.lastName.toLowerCase().contains(_searchQuery) ||
          user.email.toLowerCase().contains(_searchQuery) ||
          user.username.toLowerCase().contains(_searchQuery);

      final matchesRole = _filterRole == null || user.role == _filterRole;

      return matchesSearch && matchesRole;
    }).toList();

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Khách hàng'),
            Tab(text: 'Thợ cắt tóc'),
            Tab(text: 'Quản trị viên'),
          ],
        ),
        Expanded(
          child: filteredUsers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Không có người dùng nào',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return _buildUserCard(user);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildUserCard(User user) {
    return ResponsiveCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: user.profileImageUrl != null
              ? NetworkImage(user.profileImageUrl!)
              : null,
          child: user.profileImageUrl == null
              ? Text(user.firstName[0].toUpperCase())
              : null,
        ),
        title: Text('${user.firstName} ${user.lastName}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            Text('@${user.username}'),
            Row(
              children: [
                Icon(
                  _getRoleIcon(user.role),
                  size: 16,
                  color: _getRoleColor(user.role),
                ),
                const SizedBox(width: 4),
                Text(
                  user.role.displayName,
                  style: TextStyle(
                    color: _getRoleColor(user.role),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(value, user),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Chỉnh sửa'),
                ],
              ),
            ),
            if (user.role != Role.admin)
              const PopupMenuItem(
                value: 'change_role',
                child: Row(
                  children: [
                    Icon(Icons.swap_horiz),
                    SizedBox(width: 8),
                    Text('Đổi vai trò'),
                  ],
                ),
              ),
            if (user.role != Role.admin)
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Xóa', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  IconData _getRoleIcon(Role role) {
    switch (role) {
      case Role.customer:
        return Icons.person;
      case Role.barber:
        return Icons.person_outline;
      case Role.admin:
        return Icons.admin_panel_settings;
    }
  }

  Color _getRoleColor(Role role) {
    switch (role) {
      case Role.customer:
        return Colors.blue;
      case Role.barber:
        return Colors.green;
      case Role.admin:
        return Colors.purple;
    }
  }

  void _handleMenuAction(String action, User user) {
    switch (action) {
      case 'edit':
        _showEditUserDialog(context, user);
        break;
      case 'change_role':
        _showChangeRoleDialog(context, user);
        break;
      case 'delete':
        _showDeleteConfirmDialog(context, user);
        break;
    }
  }

  void _showAddUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddUserDialog(),
    );
  }

  void _showEditUserDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (context) => EditUserDialog(user: user),
    );
  }

  void _showChangeRoleDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Đổi vai trò cho ${user.firstName} ${user.lastName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: Role.values
              .where((role) => role != user.role)
              .map(
                (role) => ListTile(
                  leading: Icon(_getRoleIcon(role), color: _getRoleColor(role)),
                  title: Text(role.displayName),
                  onTap: () async {
                    Navigator.pop(context);
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    final success = await context
                        .read<AdminProvider>()
                        .updateUserRole(user.id, role);
                    
                    if (success && mounted) {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text('Đã đổi vai trò thành ${role.displayName}'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                ),
              )
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc chắn muốn xóa người dùng ${user.firstName} ${user.lastName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final success = await context
                  .read<AdminProvider>()
                  .deleteUser(user.id);
              
              if (success && mounted) {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Đã xóa người dùng'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
