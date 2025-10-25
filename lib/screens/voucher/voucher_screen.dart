import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VoucherScreen extends StatefulWidget {
  const VoucherScreen({super.key});

  @override
  State<VoucherScreen> createState() => _VoucherScreenState();
}

class _VoucherScreenState extends State<VoucherScreen> with TickerProviderStateMixin {
  bool _isLoading = false;
  List<VoucherItem> _availableVouchers = [];
  List<VoucherItem> _myVouchers = [];
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadVouchers();
  }

  Future<void> _loadVouchers() async {
    setState(() {
      _isLoading = true;
    });

    // TODO: Load vouchers from API
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
      _availableVouchers = _getMockAvailableVouchers();
      _myVouchers = _getMockMyVouchers();
    });
  }

  List<VoucherItem> _getMockAvailableVouchers() {
    return [
      VoucherItem(
        id: 1,
        code: 'WELCOME10',
        name: 'Giảm 10% cho khách hàng mới',
        description: 'Áp dụng cho đơn hàng đầu tiên',
        discountAmount: 10,
        discountType: 'Percentage',
        minimumOrderAmount: 100000,
        validTo: DateTime.now().add(const Duration(days: 30)),
        isUsed: false,
      ),
      VoucherItem(
        id: 2,
        code: 'SAVE50K',
        name: 'Giảm 50k cho đơn hàng từ 300k',
        description: 'Áp dụng cho đơn hàng từ 300k',
        discountAmount: 50000,
        discountType: 'FixedAmount',
        minimumOrderAmount: 300000,
        validTo: DateTime.now().add(const Duration(days: 15)),
        isUsed: false,
      ),
      VoucherItem(
        id: 3,
        code: 'LOYALTY20',
        name: 'Giảm 20% cho thành viên VIP',
        description: 'Dành cho khách hàng có trên 1000 điểm',
        discountAmount: 20,
        discountType: 'Percentage',
        minimumOrderAmount: 200000,
        validTo: DateTime.now().add(const Duration(days: 7)),
        isUsed: false,
      ),
    ];
  }

  List<VoucherItem> _getMockMyVouchers() {
    return [
      VoucherItem(
        id: 1,
        code: 'WELCOME10',
        name: 'Giảm 10% cho khách hàng mới',
        description: 'Áp dụng cho đơn hàng đầu tiên',
        discountAmount: 10,
        discountType: 'Percentage',
        minimumOrderAmount: 100000,
        validTo: DateTime.now().add(const Duration(days: 25)),
        isUsed: false,
        usedAt: null,
      ),
      VoucherItem(
        id: 4,
        code: 'BIRTHDAY15',
        name: 'Giảm 15% sinh nhật',
        description: 'Voucher sinh nhật đặc biệt',
        discountAmount: 15,
        discountType: 'Percentage',
        minimumOrderAmount: 150000,
        validTo: DateTime.now().add(const Duration(days: 5)),
        isUsed: true,
        usedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  Future<void> _claimVoucher(VoucherItem voucher) async {
    // TODO: Claim voucher via API
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã nhận voucher ${voucher.code}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => context.go('/home'),
          tooltip: 'Về trang chủ',
        ),
        title: const Text('Voucher'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadVouchers,
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: TabController(
                length: 2,
                vsync: this,
                initialIndex: _selectedTabIndex,
              ),
              onTap: (index) {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
              tabs: const [
                Tab(text: 'Có thể nhận'),
                Tab(text: 'Của tôi'),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _selectedTabIndex == 0
                    ? _buildAvailableVouchers()
                    : _buildMyVouchers(),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableVouchers() {
    if (_availableVouchers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.card_giftcard_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Không có voucher nào',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _availableVouchers.length,
      itemBuilder: (context, index) {
        final voucher = _availableVouchers[index];
        return _buildVoucherCard(voucher, isAvailable: true);
      },
    );
  }

  Widget _buildMyVouchers() {
    if (_myVouchers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.card_giftcard_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Bạn chưa có voucher nào',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _myVouchers.length,
      itemBuilder: (context, index) {
        final voucher = _myVouchers[index];
        return _buildVoucherCard(voucher, isAvailable: false);
      },
    );
  }

  Widget _buildVoucherCard(VoucherItem voucher, {required bool isAvailable}) {
    final isExpired = voucher.validTo.isBefore(DateTime.now());
    final daysLeft = voucher.validTo.difference(DateTime.now()).inDays;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: isExpired
                ? [Colors.grey[300]!, Colors.grey[200]!]
                : voucher.isUsed
                    ? [Colors.green[100]!, Colors.green[50]!]
                    : [Colors.blue[100]!, Colors.blue[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          voucher.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isExpired ? Colors.grey[600] : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          voucher.description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isExpired ? Colors.grey[500] : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isExpired
                          ? Colors.grey[400]
                          : voucher.isUsed
                              ? Colors.green
                              : Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      voucher.code,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Icon(
                    Icons.local_offer,
                    size: 16,
                    color: isExpired ? Colors.grey[500] : Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    voucher.discountType == 'Percentage'
                        ? 'Giảm ${voucher.discountAmount.toInt()}%'
                        : 'Giảm ${voucher.discountAmount.toStringAsFixed(0)}đ',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isExpired ? Colors.grey[500] : Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.shopping_cart,
                    size: 16,
                    color: isExpired ? Colors.grey[500] : Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Từ ${voucher.minimumOrderAmount.toStringAsFixed(0)}đ',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isExpired ? Colors.grey[500] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: isExpired ? Colors.red : Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isExpired
                            ? 'Đã hết hạn'
                            : daysLeft <= 0
                                ? 'Hết hạn hôm nay'
                                : 'Còn $daysLeft ngày',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isExpired ? Colors.red : Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (isAvailable && !isExpired)
                    ElevatedButton(
                      onPressed: () => _claimVoucher(voucher),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: const Text('Nhận ngay'),
                    )
                  else if (!isAvailable && voucher.isUsed)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Đã sử dụng',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VoucherItem {
  final int id;
  final String code;
  final String name;
  final String description;
  final double discountAmount;
  final String discountType;
  final double minimumOrderAmount;
  final DateTime validTo;
  final bool isUsed;
  final DateTime? usedAt;

  VoucherItem({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.discountAmount,
    required this.discountType,
    required this.minimumOrderAmount,
    required this.validTo,
    required this.isUsed,
    this.usedAt,
  });
}





