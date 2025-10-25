import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
          'Trung tâm trợ giúp',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm câu hỏi...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          // Content
          Expanded(
            child: _searchQuery.isEmpty ? _buildHelpCategories() : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpCategories() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        // Quick help
        _buildQuickHelpSection(),
        const SizedBox(height: 16),
        // FAQ categories
        _buildFAQSection(),
        const SizedBox(height: 16),
        // Contact support
        _buildContactSection(),
      ],
    );
  }

  Widget _buildQuickHelpSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trợ giúp nhanh',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuickHelpItem(
                    icon: Icons.phone,
                    title: 'Gọi hỗ trợ',
                    subtitle: '1900-xxxx',
                    onTap: () => _showCallDialog(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickHelpItem(
                    icon: Icons.chat,
                    title: 'Chat trực tiếp',
                    subtitle: 'Trò chuyện ngay',
                    onTap: () => context.go('/profile/contact-support'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickHelpItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQSection() {
    final faqCategories = [
      {
        'title': 'Đặt lịch & Dịch vụ',
        'icon': Icons.calendar_today,
        'questions': [
          'Làm thế nào để đặt lịch?',
          'Có thể hủy lịch không?',
          'Thay đổi thời gian đặt lịch?',
        ],
      },
      {
        'title': 'Thanh toán',
        'icon': Icons.payment,
        'questions': [
          'Các phương thức thanh toán?',
          'Có thể hoàn tiền không?',
          'Sử dụng voucher như thế nào?',
        ],
      },
      {
        'title': 'Tài khoản',
        'icon': Icons.person,
        'questions': [
          'Quên mật khẩu?',
          'Thay đổi thông tin cá nhân?',
          'Xóa tài khoản?',
        ],
      },
      {
        'title': 'Sản phẩm & Đơn hàng',
        'icon': Icons.shopping_bag,
        'questions': [
          'Theo dõi đơn hàng?',
          'Đổi trả sản phẩm?',
          'Chính sách giao hàng?',
        ],
      },
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Câu hỏi thường gặp',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...faqCategories.map((category) => _buildFAQCategory(category)),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQCategory(Map<String, dynamic> category) {
    return ExpansionTile(
      leading: Icon(
        category['icon'],
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        category['title'],
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      children: (category['questions'] as List<String>).map((question) {
        return ListTile(
          title: Text(
            question,
            style: const TextStyle(fontSize: 14),
          ),
          onTap: () => _showFAQAnswer(question),
        );
      }).toList(),
    );
  }

  Widget _buildContactSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Liên hệ hỗ trợ',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildContactItem(
              icon: Icons.email,
              title: 'Email hỗ trợ',
              subtitle: 'support@30sai.com',
              onTap: () => _showEmailDialog(),
            ),
            const SizedBox(height: 8),
            _buildContactItem(
              icon: Icons.phone,
              title: 'Hotline',
              subtitle: '1900-xxxx (8:00 - 22:00)',
              onTap: () => _showCallDialog(),
            ),
            const SizedBox(height: 8),
            _buildContactItem(
              icon: Icons.location_on,
              title: 'Địa chỉ',
              subtitle: '123 Đường ABC, Quận XYZ, TP.HCM',
              onTap: () => _showLocationDialog(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildSearchResults() {
    // Mock search results
    final results = [
      'Làm thế nào để đặt lịch?',
      'Có thể hủy lịch không?',
      'Các phương thức thanh toán?',
      'Sử dụng voucher như thế nào?',
      'Quên mật khẩu?',
    ].where((item) => item.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy kết quả',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Hãy thử từ khóa khác',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(results[index]),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showFAQAnswer(results[index]),
          ),
        );
      },
    );
  }

  void _showFAQAnswer(String question) {
    // Mock answers
    final answers = {
      'Làm thế nào để đặt lịch?': 'Bạn có thể đặt lịch bằng cách:\n1. Chọn dịch vụ\n2. Chọn ngày giờ\n3. Chọn thợ cắt tóc\n4. Xác nhận đặt lịch',
      'Có thể hủy lịch không?': 'Có, bạn có thể hủy lịch trước 2 giờ. Vào màn hình "Lịch sử đặt lịch" để hủy.',
      'Các phương thức thanh toán?': 'Chúng tôi hỗ trợ:\n- Tiền mặt\n- VNPay\n- Thẻ ngân hàng',
      'Sử dụng voucher như thế nào?': 'Vào màn hình "Voucher của tôi" để xem và sử dụng voucher.',
      'Quên mật khẩu?': 'Vào màn hình đăng nhập, chọn "Quên mật khẩu" để reset.',
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(question),
        content: Text(answers[question] ?? 'Câu trả lời sẽ được cập nhật sớm.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showCallDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gọi hỗ trợ'),
        content: const Text('Bạn có muốn gọi đến hotline 1900-xxxx?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đang kết nối...'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Gọi'),
          ),
        ],
      ),
    );
  }

  void _showEmailDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gửi email'),
        content: const Text('Bạn có muốn gửi email đến support@30sai.com?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đang mở ứng dụng email...'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Gửi'),
          ),
        ],
      ),
    );
  }

  void _showLocationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Địa chỉ cửa hàng'),
        content: const Text('123 Đường ABC, Quận XYZ, TP.HCM\n\nGiờ mở cửa: 8:00 - 22:00'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đang mở bản đồ...'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Chỉ đường'),
          ),
        ],
      ),
    );
  }
}
