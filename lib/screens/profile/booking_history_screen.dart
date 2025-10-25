import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  String _selectedStatus = 'Tất cả';
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final apiService = ApiService();
      final bookings = await apiService.getMyBookings();
      
      setState(() {
        _bookings = bookings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
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
          'Lịch sử đặt lịch',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _loadBookings,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, color: Colors.black),
            onSelected: (value) {
              setState(() {
                _selectedStatus = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Tất cả', child: Text('Tất cả')),
              const PopupMenuItem(value: 'Pending', child: Text('Đang chờ')),
              const PopupMenuItem(value: 'Confirmed', child: Text('Đã xác nhận')),
              const PopupMenuItem(value: 'Completed', child: Text('Hoàn thành')),
              const PopupMenuItem(value: 'Cancelled', child: Text('Đã hủy')),
            ],
          ),
        ],
      ),
      body: _buildBookingList(),
    );
  }

  Widget _buildBookingList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Lỗi tải dữ liệu',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadBookings,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    final filteredBookings = _bookings.where((booking) {
      if (_selectedStatus == 'Tất cả') return true;
      return booking['status'] == _selectedStatus;
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
              'Chưa có lịch hẹn nào',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Hãy đặt lịch để trải nghiệm dịch vụ',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/booking'),
              child: const Text('Đặt lịch ngay'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Filter chip
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                'Bộ lọc: ',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              Chip(
                label: Text(_selectedStatus),
                backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        // Booking list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filteredBookings.length,
            itemBuilder: (context, index) {
              final booking = filteredBookings[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                booking['serviceName'] ?? 'Dịch vụ không xác định',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(booking['status'] as String).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getStatusText(booking['status'] as String),
                                style: TextStyle(
                                  color: _getStatusColor(booking['status'] as String),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatDate(booking['bookingDate']),
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatTime(booking['bookingDate']),
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        if (booking['barberName'] != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.person,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                booking['barberName'] as String,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Giá: ${_formatPrice(booking['totalPrice'])} VNĐ',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            if (booking['status'] == 'Pending')
                              TextButton(
                                onPressed: () {
                                  _showCancelDialog(booking['id'] as int);
                                },
                                child: const Text(
                                  'Hủy lịch',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Confirmed':
        return Colors.blue;
      case 'Completed':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'Pending':
        return 'Đang chờ';
      case 'Confirmed':
        return 'Đã xác nhận';
      case 'Completed':
        return 'Hoàn thành';
      case 'Cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      DateTime dateTime;
      if (date is String) {
        dateTime = DateTime.parse(date);
      } else if (date is DateTime) {
        dateTime = date;
      } else {
        return 'N/A';
      }
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return 'N/A';
    }
  }

  String _formatTime(dynamic date) {
    if (date == null) return 'N/A';
    try {
      DateTime dateTime;
      if (date is String) {
        dateTime = DateTime.parse(date);
      } else if (date is DateTime) {
        dateTime = date;
      } else {
        return 'N/A';
      }
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'N/A';
    }
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '0';
    try {
      if (price is double) {
        return price.toStringAsFixed(0);
      } else if (price is int) {
        return price.toString();
      } else if (price is String) {
        return double.parse(price).toStringAsFixed(0);
      }
      return '0';
    } catch (e) {
      return '0';
    }
  }

  void _showCancelDialog(int bookingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy lịch hẹn'),
        content: const Text('Bạn có chắc chắn muốn hủy lịch hẹn này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final apiService = ApiService();
                await apiService.cancelBooking(bookingId);
                await _loadBookings(); // Reload data
                if (mounted && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã hủy lịch hẹn'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi hủy lịch: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Có', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
