import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../models/booking.dart';

class BookingManagementScreen extends StatefulWidget {
  const BookingManagementScreen({super.key});

  @override
  State<BookingManagementScreen> createState() => _BookingManagementScreenState();
}

class _BookingManagementScreenState extends State<BookingManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadAllBookings();
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
                  _buildBookingList(adminProvider.getPendingBookings(), 'Chờ xác nhận'),
                  _buildBookingList(adminProvider.getConfirmedBookings(), 'Đã xác nhận'),
                  _buildBookingList(adminProvider.getCompletedBookings(), 'Hoàn thành'),
                  _buildBookingList(adminProvider.getCancelledBookings(), 'Đã hủy'),
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
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quản lý lịch hẹn',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Quản lý và theo dõi tất cả lịch hẹn của khách hàng',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              adminProvider.loadAllBookings();
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Làm mới',
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
          // Search bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Tìm kiếm theo tên khách hàng hoặc dịch vụ...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 16),
          // Tab bar
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: const [
              Tab(text: 'Chờ xác nhận'),
              Tab(text: 'Đã xác nhận'),
              Tab(text: 'Hoàn thành'),
              Tab(text: 'Đã hủy'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookingList(List<Booking> bookings, String status) {
    final filteredBookings = bookings.where((booking) {
      if (_searchQuery.isEmpty) return true;
      return booking.service.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    if (filteredBookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Không có lịch hẹn $status',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tất cả lịch hẹn sẽ hiển thị ở đây',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredBookings.length,
      itemBuilder: (context, index) {
        final booking = filteredBookings[index];
        return _buildBookingCard(booking);
      },
    );
  }

  Widget _buildBookingCard(Booking booking) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(booking.status),
          child: Icon(
            _getStatusIcon(booking.status),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          booking.service.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          '${booking.bookingDateTime.day}/${booking.bookingDateTime.month}/${booking.bookingDateTime.year} - ${booking.bookingDateTime.hour}:${booking.bookingDateTime.minute.toString().padLeft(2, '0')}',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(booking.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getStatusColor(booking.status).withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                booking.status,
                style: TextStyle(
                  color: _getStatusColor(booking.status),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (value) => _handleBookingAction(booking, value),
              itemBuilder: (context) => _buildBookingActions(booking),
              icon: const Icon(Icons.more_vert),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer Information
                _buildInfoRow('Khách hàng', 'ID: ${booking.userId}'),
                const SizedBox(height: 8),
                _buildInfoRow('Chi nhánh', _getBranchName(booking.branchId ?? 1)),
                const SizedBox(height: 8),
                _buildInfoRow('Thợ cắt tóc', _getBarberName(booking.barberId)),
                const SizedBox(height: 8),
                _buildInfoRow('Dịch vụ', booking.service.name),
                const SizedBox(height: 8),
                _buildInfoRow('Mô tả', booking.service.description),
                const SizedBox(height: 8),
                _buildInfoRow('Giá', '${booking.service.price.toStringAsFixed(0)} VNĐ'),
                const SizedBox(height: 8),
                _buildInfoRow('Thời gian', '${booking.service.durationMinutes} phút'),
                const SizedBox(height: 8),
                _buildInfoRow('Ngày đặt', '${booking.createdAt.day}/${booking.createdAt.month}/${booking.createdAt.year}'),
                if (booking.notes != null && booking.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow('Ghi chú', booking.notes!),
                ],
                if (booking.loyaltyPointsUsed != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow('Điểm sử dụng', '${booking.loyaltyPointsUsed} điểm'),
                ],
                if (booking.loyaltyPointsEarned != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow('Điểm tích lũy', '${booking.loyaltyPointsEarned} điểm'),
                ],
                const SizedBox(height: 16),
                // Action buttons
                _buildActionButtons(booking),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Booking booking) {
    return Row(
      children: [
        if (booking.status == 'Pending') ...[
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _confirmBooking(booking),
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Xác nhận'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _cancelBooking(booking),
              icon: const Icon(Icons.cancel, size: 18),
              label: const Text('Hủy'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
        if (booking.status == 'Confirmed') ...[
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _completeBooking(booking),
              icon: const Icon(Icons.done_all, size: 18),
              label: const Text('Hoàn thành'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  List<PopupMenuEntry<String>> _buildBookingActions(Booking booking) {
    List<PopupMenuEntry<String>> actions = [];

    switch (booking.status) {
      case 'Pending':
        actions.addAll([
          const PopupMenuItem(
            value: 'confirm',
            child: Row(
              children: [
                Icon(Icons.check, color: Colors.blue),
                SizedBox(width: 8),
                Text('Xác nhận'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'cancel',
            child: Row(
              children: [
                Icon(Icons.cancel, color: Colors.red),
                SizedBox(width: 8),
                Text('Hủy'),
              ],
            ),
          ),
        ]);
        break;
      case 'Confirmed':
        actions.add(
          const PopupMenuItem(
            value: 'complete',
            child: Row(
              children: [
                Icon(Icons.done_all, color: Colors.green),
                SizedBox(width: 8),
                Text('Hoàn thành'),
              ],
            ),
          ),
        );
        break;
    }

    actions.add(
      const PopupMenuItem(
        value: 'view_details',
        child: Row(
          children: [
            Icon(Icons.info_outline),
            SizedBox(width: 8),
            Text('Xem chi tiết'),
          ],
        ),
      ),
    );

    return actions;
  }

  void _handleBookingAction(Booking booking, String action) {
    switch (action) {
      case 'confirm':
        _confirmBooking(booking);
        break;
      case 'cancel':
        _cancelBooking(booking);
        break;
      case 'complete':
        _completeBooking(booking);
        break;
      case 'view_details':
        _showBookingDetails(booking);
        break;
    }
  }

  Future<void> _confirmBooking(Booking booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận lịch hẹn'),
        content: Text('Bạn có chắc chắn muốn xác nhận lịch hẹn "${booking.service.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      final success = await adminProvider.confirmBooking(booking.id);
      
      if (mounted && context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã xác nhận lịch hẹn thành công'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(adminProvider.error ?? 'Có lỗi xảy ra'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _completeBooking(Booking booking) async {
    int? loyaltyPoints = 0;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Hoàn thành lịch hẹn'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Bạn có chắc chắn muốn hoàn thành lịch hẹn "${booking.service.name}"?'),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Điểm tích lũy (tùy chọn)',
                  hintText: 'Nhập số điểm tích lũy cho khách hàng',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  loyaltyPoints = int.tryParse(value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hoàn thành'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      final success = await adminProvider.completeBooking(
        booking.id,
        loyaltyPointsEarned: loyaltyPoints,
      );
      
      if (mounted && context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loyaltyPoints != null && loyaltyPoints! > 0 
                  ? 'Đã hoàn thành lịch hẹn và tích $loyaltyPoints điểm cho khách hàng'
                  : 'Đã hoàn thành lịch hẹn'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(adminProvider.error ?? 'Có lỗi xảy ra'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _cancelBooking(Booking booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy lịch hẹn'),
        content: Text('Bạn có chắc chắn muốn hủy lịch hẹn "${booking.service.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hủy lịch hẹn'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      final success = await adminProvider.cancelBooking(booking.id);
      
      if (mounted && context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã hủy lịch hẹn thành công'),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(adminProvider.error ?? 'Có lỗi xảy ra'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showBookingDetails(Booking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Chi tiết lịch hẹn - ${booking.service.name}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('ID', booking.id.toString()),
              _buildDetailRow('Khách hàng', 'ID: ${booking.userId}'),
              _buildDetailRow('Dịch vụ', booking.service.name),
              _buildDetailRow('Mô tả', booking.service.description),
              _buildDetailRow('Giá', '${booking.service.price.toStringAsFixed(0)} VNĐ'),
              _buildDetailRow('Thời gian', '${booking.service.durationMinutes} phút'),
              _buildDetailRow('Ngày hẹn', '${booking.bookingDateTime.day}/${booking.bookingDateTime.month}/${booking.bookingDateTime.year}'),
              _buildDetailRow('Giờ hẹn', '${booking.bookingDateTime.hour}:${booking.bookingDateTime.minute.toString().padLeft(2, '0')}'),
              _buildDetailRow('Trạng thái', booking.status),
              _buildDetailRow('Ngày đặt', '${booking.createdAt.day}/${booking.createdAt.month}/${booking.createdAt.year}'),
              if (booking.notes != null && booking.notes!.isNotEmpty)
                _buildDetailRow('Ghi chú', booking.notes!),
              if (booking.loyaltyPointsUsed != null)
                _buildDetailRow('Điểm sử dụng', '${booking.loyaltyPointsUsed} điểm'),
              if (booking.loyaltyPointsEarned != null)
                _buildDetailRow('Điểm tích lũy', '${booking.loyaltyPointsEarned} điểm'),
            ],
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getBranchName(int branchId) {
    final branches = {
      1: '30SAI Quận 1 - 123 Nguyễn Huệ, Q1, TP.HCM',
      2: '30SAI Quận 3 - 456 Lê Văn Sỹ, Q3, TP.HCM',
      3: '30SAI Quận 7 - 789 Nguyễn Thị Thập, Q7, TP.HCM',
      4: '30SAI Quận 10 - 321 Cách Mạng Tháng 8, Q10, TP.HCM',
      5: '30SAI Quận Bình Thạnh - 654 Xô Viết Nghệ Tĩnh, Bình Thạnh, TP.HCM',
      6: '30SAI Quận Tân Bình - 987 Cộng Hòa, Tân Bình, TP.HCM',
      7: '30SAI Quận Gò Vấp - 147 Quang Trung, Gò Vấp, TP.HCM',
      8: '30SAI Quận Phú Nhuận - 258 Hoàng Văn Thụ, Phú Nhuận, TP.HCM',
      9: '30SAI Quận Thủ Đức - 369 Võ Văn Ngân, Thủ Đức, TP.HCM',
      10: '30SAI Quận 12 - 741 Tân Thới Hiệp, Q12, TP.HCM',
    };
    return branches[branchId] ?? 'Chi nhánh không xác định';
  }

  String _getBarberName(int? barberId) {
    if (barberId == null) {
      return 'Hệ thống sẽ chọn ngẫu nhiên';
    }
    
    final barbers = {
      1: 'Nguyễn Văn A',
      2: 'Trần Thị B',
      3: 'Lê Văn C',
      4: 'Phạm Thị D',
      5: 'Hoàng Văn E',
      6: 'Vũ Thị F',
      7: 'Đặng Văn G',
      8: 'Bùi Thị H',
      9: 'Phan Văn I',
      10: 'Ngô Thị K',
    };
    return barbers[barberId] ?? 'Thợ cắt tóc không xác định';
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'confirmed':
        return Icons.check_circle;
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }
}
