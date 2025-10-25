import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => context.go('/home'),
        ),
        title: const Text(
          'Về ứng dụng',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // App info card
            _buildAppInfoCard(context),
            const SizedBox(height: 16),
            // Features card
            _buildFeaturesCard(context),
            const SizedBox(height: 16),
            // Team card
            _buildTeamCard(context),
            const SizedBox(height: 16),
            // Legal card
            _buildLegalCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // App logo
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.content_cut_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            // App name
            Text(
              '30SAI',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            // Version
            Text(
              'Phiên bản 1.0.0',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            // Description
            Text(
              'Ứng dụng đặt lịch cắt tóc và mua sắm sản phẩm chăm sóc tóc chuyên nghiệp. Trải nghiệm dịch vụ chất lượng cao với đội ngũ thợ cắt tóc giàu kinh nghiệm.',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesCard(BuildContext context) {
    final features = [
      {
        'icon': Icons.calendar_today,
        'title': 'Đặt lịch dễ dàng',
        'description': 'Đặt lịch cắt tóc nhanh chóng với thợ cắt tóc yêu thích',
      },
      {
        'icon': Icons.shopping_bag,
        'title': 'Mua sắm tiện lợi',
        'description': 'Mua sản phẩm chăm sóc tóc chất lượng cao',
      },
      {
        'icon': Icons.stars,
        'title': 'Tích điểm thưởng',
        'description': 'Tích điểm và đổi voucher hấp dẫn',
      },
      {
        'icon': Icons.support_agent,
        'title': 'Hỗ trợ 24/7',
        'description': 'Đội ngũ hỗ trợ luôn sẵn sàng giúp đỡ',
      },
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tính năng nổi bật',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...features.map((feature) => _buildFeatureItem(
              context,
              icon: feature['icon'] as IconData,
              title: feature['title'] as String,
              description: feature['description'] as String,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Đội ngũ phát triển',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildTeamMember(
              context,
              name: 'Nguyễn Văn A',
              role: 'Lead Developer',
              email: 'dev@30sai.com',
            ),
            const SizedBox(height: 12),
            _buildTeamMember(
              context,
              name: 'Trần Thị B',
              role: 'UI/UX Designer',
              email: 'design@30sai.com',
            ),
            const SizedBox(height: 12),
            _buildTeamMember(
              context,
              name: 'Lê Văn C',
              role: 'Backend Developer',
              email: 'backend@30sai.com',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamMember(BuildContext context, {
    required String name,
    required String role,
    required String email,
  }) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            name[0],
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                role,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              Text(
                email,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegalCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thông tin pháp lý',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildLegalItem(
              context,
              icon: Icons.privacy_tip,
              title: 'Chính sách bảo mật',
              onTap: () => _showPrivacyPolicy(context),
            ),
            const SizedBox(height: 8),
            _buildLegalItem(
              context,
              icon: Icons.description,
              title: 'Điều khoản sử dụng',
              onTap: () => _showTermsOfService(context),
            ),
            const SizedBox(height: 8),
            _buildLegalItem(
              context,
              icon: Icons.copyright,
              title: 'Bản quyền',
              onTap: () => _showCopyright(context),
            ),
            const SizedBox(height: 16),
            // Copyright notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '© 2024 30SAI. Tất cả quyền được bảo lưu.\n\nỨng dụng được phát triển với ❤️ tại Việt Nam',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalItem(BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.primary,
        size: 20,
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chính sách bảo mật'),
        content: const SingleChildScrollView(
          child: Text(
            'Chúng tôi cam kết bảo vệ thông tin cá nhân của bạn. Thông tin được thu thập chỉ nhằm mục đích cung cấp dịch vụ tốt nhất.\n\n'
            '• Thông tin cá nhân được mã hóa và bảo mật\n'
            '• Không chia sẻ thông tin với bên thứ ba\n'
            '• Bạn có quyền xóa hoặc chỉnh sửa thông tin\n'
            '• Tuân thủ các quy định về bảo vệ dữ liệu cá nhân',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Điều khoản sử dụng'),
        content: const SingleChildScrollView(
          child: Text(
            'Bằng việc sử dụng ứng dụng 30SAI, bạn đồng ý với các điều khoản sau:\n\n'
            '• Sử dụng ứng dụng đúng mục đích\n'
            '• Không vi phạm các quy định pháp luật\n'
            '• Tôn trọng quyền sở hữu trí tuệ\n'
            '• Chúng tôi có quyền từ chối dịch vụ nếu vi phạm\n'
            '• Điều khoản có thể được cập nhật theo thời gian',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showCopyright(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bản quyền'),
        content: const Text(
          'Tất cả nội dung trong ứng dụng 30SAI bao gồm:\n\n'
          '• Thiết kế giao diện\n'
          '• Mã nguồn ứng dụng\n'
          '• Hình ảnh và logo\n'
          '• Nội dung văn bản\n\n'
          'Đều thuộc bản quyền của 30SAI và được bảo vệ bởi luật bản quyền Việt Nam.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}
