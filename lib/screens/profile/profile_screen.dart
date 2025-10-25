import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => context.go('/home'),
          tooltip: 'Về trang chủ',
        ),
        title: const Text('Cá nhân'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;

          if (user == null) {
            return const Center(child: Text('Không có thông tin người dùng'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Header
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          backgroundImage: user.profileImageUrl != null
                              ? NetworkImage(user.profileImageUrl!)
                              : null,
                          child: user.profileImageUrl == null
                              ? Text(
                                  user.firstName.isNotEmpty
                                      ? user.firstName[0].toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.fullName,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          user.email,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _StatItem(
                              icon: Icons.stars,
                              label: 'Điểm thưởng',
                              value: '${user.loyaltyPoints}',
                            ),
                            _StatItem(
                              icon: Icons.calendar_today,
                              label: 'Thành viên từ',
                              value:
                                  '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Menu Items
                _MenuSection(
                  title: 'Tài khoản',
                  items: [
                    _MenuItem(
                      icon: Icons.edit,
                      title: 'Chỉnh sửa thông tin',
                      onTap: () {
                        print('Navigating to edit profile');
                        context.go('/profile/edit');
                      },
                    ),
                    _MenuItem(
                      icon: Icons.lock,
                      title: 'Đổi mật khẩu',
                      onTap: () {
                        print('Navigating to change password');
                        context.go('/profile/change-password');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _MenuSection(
                  title: 'Dịch vụ',
                  items: [
                    _MenuItem(
                      icon: Icons.history,
                      title: 'Lịch sử đặt lịch',
                      onTap: () {
                        context.go('/profile/booking-history');
                      },
                    ),
                    _MenuItem(
                      icon: Icons.shopping_bag,
                      title: 'Đơn hàng của tôi',
                      onTap: () {
                        context.go('/profile/my-orders');
                      },
                    ),
                    _MenuItem(
                      icon: Icons.card_giftcard,
                      title: 'Voucher của tôi',
                      onTap: () => context.go('/vouchers'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _MenuSection(
                  title: 'Hỗ trợ',
                  items: [
                    _MenuItem(
                      icon: Icons.help,
                      title: 'Trung tâm trợ giúp',
                      onTap: () {
                        context.go('/profile/help-center');
                      },
                    ),
                    _MenuItem(
                      icon: Icons.chat,
                      title: 'Liên hệ hỗ trợ',
                      onTap: () {
                        context.go('/profile/contact-support');
                      },
                    ),
                    _MenuItem(
                      icon: Icons.info,
                      title: 'Về ứng dụng',
                      onTap: () {
                        context.go('/profile/about-app');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Đăng xuất'),
                          content: const Text(
                            'Bạn có chắc chắn muốn đăng xuất?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Hủy'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Đăng xuất'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        await authProvider.logout();
                        if (context.mounted) {
                          context.go('/login');
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Đăng xuất'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;

  const _MenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(child: Column(children: items)),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
