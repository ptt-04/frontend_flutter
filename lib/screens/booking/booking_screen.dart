import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/booking_provider.dart';
import 'service_selection_screen.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _currentStep = 0;
  bool _showWelcomeDialog = true;

  // Booking data
  List<int> _selectedServiceIds = [];
  DateTime? _selectedDateTime;
  int? _selectedBarberId;
  int? _selectedBranchId;

  // Branch data
  final List<Map<String, dynamic>> _branches = [
    {
      'id': 1,
      'name': '30SAI Quận 1',
      'address': '123 Nguyễn Huệ, Quận 1, TP.HCM',
      'phone': '028 1234 5678',
      'hours': '8:00 - 22:00',
      'rating': 4.8,
    },
    {
      'id': 2,
      'name': '30SAI Quận 3',
      'address': '456 Lê Văn Sỹ, Quận 3, TP.HCM',
      'phone': '028 1234 5679',
      'hours': '8:00 - 22:00',
      'rating': 4.7,
    },
    {
      'id': 3,
      'name': '30SAI Quận 7',
      'address': '789 Nguyễn Thị Thập, Quận 7, TP.HCM',
      'phone': '028 1234 5680',
      'hours': '8:00 - 22:00',
      'rating': 4.6,
    },
    {
      'id': 4,
      'name': '30SAI Quận 10',
      'address': '321 Cách Mạng Tháng 8, Quận 10, TP.HCM',
      'phone': '028 1234 5681',
      'hours': '8:00 - 22:00',
      'rating': 4.5,
    },
    {
      'id': 5,
      'name': '30SAI Quận Bình Thạnh',
      'address': '654 Xô Viết Nghệ Tĩnh, Bình Thạnh, TP.HCM',
      'phone': '028 1234 5682',
      'hours': '8:00 - 22:00',
      'rating': 4.4,
    },
    {
      'id': 6,
      'name': '30SAI Quận Tân Bình',
      'address': '987 Cộng Hòa, Tân Bình, TP.HCM',
      'phone': '028 1234 5683',
      'hours': '8:00 - 22:00',
      'rating': 4.3,
    },
    {
      'id': 7,
      'name': '30SAI Quận Gò Vấp',
      'address': '147 Quang Trung, Gò Vấp, TP.HCM',
      'phone': '028 1234 5684',
      'hours': '8:00 - 22:00',
      'rating': 4.2,
    },
    {
      'id': 8,
      'name': '30SAI Quận Phú Nhuận',
      'address': '258 Hoàng Văn Thụ, Phú Nhuận, TP.HCM',
      'phone': '028 1234 5685',
      'hours': '8:00 - 22:00',
      'rating': 4.1,
    },
    {
      'id': 9,
      'name': '30SAI Quận Thủ Đức',
      'address': '369 Võ Văn Ngân, Thủ Đức, TP.HCM',
      'phone': '028 1234 5686',
      'hours': '8:00 - 22:00',
      'rating': 4.0,
    },
    {
      'id': 10,
      'name': '30SAI Quận 12',
      'address': '741 Tân Thới Hiệp, Quận 12, TP.HCM',
      'phone': '028 1234 5687',
      'hours': '8:00 - 22:00',
      'rating': 3.9,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Load services when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookingProvider>(context, listen: false).loadServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.home_rounded, color: Colors.black),
          onPressed: () => context.go('/home'),
        ),
        title: const Text(
          'Đặt lịch giữ chỗ',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {
              // TODO: Show menu
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main booking content
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Booking Steps
                _buildBookingSteps(),
                const SizedBox(height: 40),

                // Action Button
                _buildActionButton(),
                const SizedBox(height: 16),

                // Disclaimer
                _buildDisclaimer(),
              ],
            ),
          ),

          // Welcome Dialog
          if (_showWelcomeDialog) _buildWelcomeDialog(),
        ],
      ),
    );
  }

  Widget _buildBookingSteps() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step 1: Choose Salon
        _buildStepItem(
          stepNumber: 1,
          title: 'Chọn salon',
          isActive: _currentStep >= 0,
          children: [
            if (_selectedBranchId == null) ...[
              const Text(
                'Chọn chi nhánh 30SAI gần bạn nhất:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount: _branches.length,
                  itemBuilder: (context, index) {
                    final branch = _branches[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                            child: Icon(
                              Icons.location_on,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          title: Text(
                            branch['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                branch['address'],
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                                  const SizedBox(width: 4),
                                  Text(
                                    branch['hours'],
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Icon(Icons.star, size: 14, color: Colors.amber),
                                  const SizedBox(width: 2),
                                  Text(
                                    branch['rating'].toString(),
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.arrow_forward_ios,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedBranchId = branch['id'];
                                _currentStep = 1;
                              });
                            },
                          ),
                          onTap: () {
                            setState(() {
                              _selectedBranchId = branch['id'];
                              _currentStep = 1;
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ] else ...[
              // Selected branch display
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _branches.firstWhere((b) => b['id'] == _selectedBranchId)['name'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _branches.firstWhere((b) => b['id'] == _selectedBranchId)['address'],
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: Theme.of(context).colorScheme.primary,
                      ),
            onPressed: () {
                        setState(() {
                          _selectedBranchId = null;
                        });
            },
          ),
        ],
      ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 24),

        // Step 2: Choose Service
        _buildStepItem(
          stepNumber: 2,
          title: 'Chọn dịch vụ',
          isActive: _currentStep >= 1,
          children: [
            Consumer<BookingProvider>(
        builder: (context, bookingProvider, child) {
          if (bookingProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

                if (bookingProvider.error != null) {
                  return Center(
              child: Column(
                children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Lỗi: ${bookingProvider.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            bookingProvider.loadServices();
                          },
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                }

                if (bookingProvider.services.isEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        Icon(Icons.info_outline, size: 48, color: Colors.blue),
                        const SizedBox(height: 16),
                        const Text('Không có dịch vụ nào'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            bookingProvider.loadServices();
                          },
                          child: const Text('Tải lại'),
                  ),
                ],
              ),
            );
          }

                return Column(
                  children: [
                    _buildOptionButton(
                      icon: Icons.content_cut_rounded,
                      title: _selectedServiceIds.isNotEmpty
                          ? 'Đã chọn ${_selectedServiceIds.length} dịch vụ'
                          : 'Xem tất cả dịch vụ hấp dẫn',
                      subtitle: _selectedServiceIds.isNotEmpty
                          ? 'Tap để thay đổi'
                          : 'Cắt tóc, gội đầu, styling...',
                      onTap: () async {
                        final selectedServiceIds =
                            await Navigator.push<List<int>>(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ServiceSelectionScreen(),
                              ),
                            );

                        if (selectedServiceIds != null &&
                            selectedServiceIds.isNotEmpty) {
                          setState(() {
                            _selectedServiceIds = selectedServiceIds;
                            _currentStep = 2;
                          });
                        }
                      },
                    ),
                    if (_selectedServiceIds.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildSelectedServicesList(),
                    ],
                  ],
                );
              },
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Step 3: Choose Date, Time & Stylist
        _buildStepItem(
          stepNumber: 3,
          title: 'Chọn ngày, giờ & stylist',
          isActive: _currentStep >= 2,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildOptionButton(
                    icon: Icons.calendar_today_rounded,
                    title: _selectedDateTime != null
                        ? '${_selectedDateTime!.day}/${_selectedDateTime!.month}/${_selectedDateTime!.year}'
                        : 'Hôm nay, T3 (21/10)',
                    subtitle: 'Chọn ngày',
                    onTap: () {
                      _selectDate();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Ngày thường',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                        color: Colors.green[700],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Barber Selection
            _buildBarberSelector(),
          ],
        ),
      ],
    );
  }

  Widget _buildStepItem({
    required int stepNumber,
    required String title,
    required bool isActive,
    required List<Widget> children,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step indicator
        Container(
          width: 4,
          height: 60,
          decoration: BoxDecoration(
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 16),

        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isActive
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$stepNumber',
                        style: TextStyle(
                          color: isActive ? Colors.white : Colors.grey[600],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.black : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...children,
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    bool isPrimary = false,
    bool isDisabled = false,
  }) {
    final effectiveColor = isDisabled
        ? Colors.grey[300]
        : (isPrimary ? Theme.of(context).colorScheme.primary : Colors.grey[50]);
    final effectiveTextColor = isDisabled
        ? Colors.grey[500]
        : (isPrimary ? Colors.white : Colors.black);
    final effectiveSubtitleColor = isDisabled
        ? Colors.grey[400]
        : (isPrimary ? Colors.white70 : Colors.grey[600]);

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        width: double.infinity,
            padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: effectiveColor,
          borderRadius: BorderRadius.circular(12),
          border: isPrimary || isDisabled
              ? null
              : Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isPrimary
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isPrimary ? Colors.white : Colors.grey[600],
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
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: effectiveTextColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: effectiveSubtitleColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: isPrimary ? Colors.white : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    final canProceed =
        _currentStep >= 2 &&
        _selectedServiceIds.isNotEmpty &&
        _selectedDateTime != null &&
        _selectedBranchId != null;
        // Removed _selectedBarberId != null requirement to allow random selection

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canProceed
            ? () {
                _createBooking();
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canProceed
              ? Theme.of(context).colorScheme.primary
              : Colors.grey[300],
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          canProceed
              ? 'CHỐT GIỜ CẮT (${_selectedServiceIds.length} dịch vụ)'
              : 'CHỐT GIỜ CẮT',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: canProceed ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Center(
      child: Text(
        'Cắt xong trả tiền, huỷ lịch không sao',
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildWelcomeDialog() {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Close button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _showWelcomeDialog = false;
                      });
                    },
                    icon: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),

              // Logo and welcome text
              Row(
                children: [
                  Icon(
                    Icons.star_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '30SAI ✨✂️',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                'Chào mừng bạn đến với',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),

              const SizedBox(height: 8),

              Text(
                '30SAI ✨✂️',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Bạn cho chúng mình biết bạn có thể sử dụng dịch vụ của chúng tôi khi nào không!',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Name input
              // TextField(
              //   decoration: InputDecoration(
              //     hintText: 'Tên bạn là...',
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(12),
              //       borderSide: BorderSide(color: Colors.grey[300]!),
              //     ),
              //     focusedBorder: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(12),
              //       borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
              //     ),
              //     contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              //   ),
              // ),

              // const SizedBox(height: 24),

              // Book now button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showWelcomeDialog = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'ĐẶT LỊCH NGAY',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Cắt xong trả tiền, huỷ lịch không sao',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // TextButton(
              //   onPressed: () {
              //     setState(() {
              //       _showWelcomeDialog = false;
              //     });
              //   },
              //   child: Text(
              //     'Bỏ qua',
              //     style: TextStyle(
              //       color: Colors.grey[600],
              //       fontSize: 14,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null) {
      setState(() {
        _selectedDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          9, // Default time 9:00 AM
          0,
        );
        _currentStep = 2;
      });
    }
  }

  Widget _buildSelectedServicesList() {
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, child) {
        final selectedServices = bookingProvider.services
            .where((service) => _selectedServiceIds.contains(service.id))
            .toList();

        if (selectedServices.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Dịch vụ đã chọn (${selectedServices.length})',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...selectedServices.map(
                (service) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${service.price.toStringAsFixed(0)} VNĐ - ${service.durationMinutes} phút',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _selectedServiceIds.remove(service.id);
                          });
                        },
                        icon: Icon(
                          Icons.remove_circle_outline,
                          color: Colors.red[400],
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBarberSelector() {
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, child) {
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: bookingProvider.getBarbers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildOptionButton(
                icon: Icons.person_outline_rounded,
                title: 'Đang tải danh sách thợ cắt tóc...',
                subtitle: 'Vui lòng chờ',
                onTap: null,
                isDisabled: true,
              );
            }

            if (snapshot.hasError) {
              return _buildOptionButton(
                icon: Icons.error_outline_rounded,
                title: 'Lỗi tải danh sách thợ cắt tóc',
                subtitle: 'Tap để thử lại',
                onTap: () {
                  setState(() {});
                },
              );
            }

            final barbers = snapshot.data ?? [];

            if (barbers.isEmpty) {
              return _buildOptionButton(
                icon: Icons.person_off_rounded,
                title: 'Không có thợ cắt tóc nào',
                subtitle: 'Vui lòng liên hệ admin',
                onTap: null,
                isDisabled: true,
              );
            }

            // Find selected barber
            final selectedBarber = barbers.firstWhere(
              (barber) => barber['id'] == _selectedBarberId,
              orElse: () => barbers.first,
            );

            return _buildOptionButton(
              icon: Icons.person_outline_rounded,
              title: _selectedBarberId != null
                  ? '${selectedBarber['firstName']} ${selectedBarber['lastName']}'
                  : 'Để hệ thống chọn ngẫu nhiên',
              subtitle: _selectedBarberId != null
                  ? 'Tap để thay đổi'
                  : 'Chúng tôi sẽ chọn thợ cắt tóc phù hợp nhất',
              onTap: () {
                _showBarberSelectionDialog(barbers);
              },
              );
            },
          );
        },
    );
  }

  void _showBarberSelectionDialog(List<Map<String, dynamic>> barbers) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.person_outline_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Text('Chọn thợ cắt tóc'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Random barber option
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange.withValues(alpha: 0.1),
                      child: Icon(
                        Icons.shuffle,
                        color: Colors.orange,
                      ),
                    ),
                    title: const Text(
                      'Để hệ thống chọn ngẫu nhiên',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: const Text(
                      'Chúng tôi sẽ chọn thợ cắt tóc phù hợp nhất',
                      style: TextStyle(fontSize: 14),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onTap: () {
                      setState(() {
                        _selectedBarberId = null; // null means random
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Hoặc chọn thợ cắt tóc cụ thể:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                itemCount: barbers.length,
                itemBuilder: (context, index) {
                  final barber = barbers[index];
                  final isSelected = _selectedBarberId == barber['id'];
                  final isAvailable = _isBarberAvailable(barber['id']);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey[300],
                        child: Icon(
                          Icons.person,
                          color: isSelected ? Colors.white : Colors.grey[600],
                        ),
                      ),
                      title: Text(
                        '${barber['firstName']} ${barber['lastName']}',
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isAvailable ? null : Colors.grey[500],
                        ),
                      ),
                      subtitle: Text(
                        isAvailable ? 'Có sẵn' : 'Đã có lịch',
                        style: TextStyle(
                          color: isAvailable ? Colors.green[600] : Colors.red[600],
                          fontSize: 12,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                      onTap: isAvailable
                          ? () {
                              setState(() {
                                _selectedBarberId = barber['id'];
                              });
                              Navigator.pop(context);
                            }
                          : null,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          if (_selectedBarberId != null)
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedBarberId = null;
                });
                Navigator.pop(context);
              },
              child: const Text('Bỏ chọn'),
            ),
        ],
      ),
    );
  }

  bool _isBarberAvailable(int barberId) {
    if (_selectedDateTime == null) return true;

    // TODO: Implement actual availability check with API
    // For now, return true for all barbers
    return true;
  }

  Future<void> _createBooking() async {
    if (_selectedServiceIds.isEmpty || _selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất một dịch vụ và thời gian'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedBarberId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn thợ cắt tóc'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final bookingProvider = Provider.of<BookingProvider>(
      context,
      listen: false,
    );

    // Tạo booking cho dịch vụ đầu tiên (có thể mở rộng để tạo nhiều booking)
    final success = await bookingProvider.createBooking(
      serviceId: _selectedServiceIds.first,
      barberId: _selectedBarberId,
      bookingDateTime: _selectedDateTime!,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đặt lịch thành công cho ${_selectedServiceIds.length} dịch vụ!',
          ),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/home');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bookingProvider.error ?? 'Đặt lịch thất bại'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
