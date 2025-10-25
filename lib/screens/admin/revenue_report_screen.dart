import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../providers/product_provider.dart';

class RevenueReportScreen extends StatefulWidget {
  const RevenueReportScreen({super.key});

  @override
  State<RevenueReportScreen> createState() => _RevenueReportScreenState();
}

class _RevenueReportScreenState extends State<RevenueReportScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'Tháng này';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadDashboardStats();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
          children: [
          _buildHeader(context),
          _buildTabBar(context),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                _buildRevenueChart(context),
                _buildServiceStats(context),
                _buildBookingStats(context),
                ],
              ),
            ),
          ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Báo cáo & Thống kê',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              DropdownButton<String>(
                value: _selectedPeriod,
              items: const [
                DropdownMenuItem(value: 'Tuần này', child: Text('Tuần này')),
                DropdownMenuItem(value: 'Tháng này', child: Text('Tháng này')),
                  DropdownMenuItem(value: 'Quý này', child: Text('Quý này')),
                  DropdownMenuItem(value: 'Năm nay', child: Text('Năm nay')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedPeriod = value!;
                });
              },
            ),
            ],
          ),
          const SizedBox(height: 16),
          Consumer<AdminProvider>(
            builder: (context, adminProvider, child) {
              if (adminProvider.dashboardStats == null) {
                return const SizedBox.shrink();
              }
              
              final stats = adminProvider.dashboardStats!;
              return Row(
                children: [
                  _buildQuickStat(
                    'Doanh thu tháng',
                    '${(stats.monthlyRevenue / 1000000).toStringAsFixed(1)}M VNĐ',
                    Icons.attach_money,
                    Colors.green,
                  ),
                  const SizedBox(width: 16),
                  _buildQuickStat(
                    'Lịch hẹn hôm nay',
                    '${stats.todayBookings}',
                    Icons.calendar_today,
                    Colors.blue,
          ),
          const SizedBox(width: 16),
                  _buildQuickStat(
                    'Tỷ lệ hoàn thành',
                    '${stats.completedBookings > 0 ? ((stats.completedBookings / (stats.completedBookings + stats.cancelledBookings)) * 100).toStringAsFixed(1) : '0'}%',
                    Icons.check_circle,
                    Colors.orange,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        ),
      );
    }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: Theme.of(context).colorScheme.primary,
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: Theme.of(context).colorScheme.primary,
        tabs: const [
          Tab(text: 'Doanh thu'),
          Tab(text: 'Dịch vụ'),
          Tab(text: 'Lịch hẹn'),
        ],
      ),
    );
  }

  Widget _buildRevenueChart(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Revenue Chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                        'Biểu đồ doanh thu',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                      IconButton(
                        onPressed: () {
                          // TODO: Export chart
                        },
                        icon: const Icon(Icons.download),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildMockChart(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Revenue Summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tóm tắt doanh thu',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Consumer<AdminProvider>(
                    builder: (context, adminProvider, child) {
                      if (adminProvider.dashboardStats == null) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      final stats = adminProvider.dashboardStats!;
                      return Column(
                        children: [
                          _buildRevenueRow('Doanh thu tháng này', stats.monthlyRevenue),
                          _buildRevenueRow('Doanh thu trung bình/ngày', stats.monthlyRevenue / 30),
                          _buildRevenueRow('Doanh thu dự kiến tháng sau', stats.monthlyRevenue * 1.1),
                          const Divider(),
                          _buildRevenueRow('Tổng doanh thu năm', stats.monthlyRevenue * 12, isTotal: true),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockChart() {
    // Mock data for the last 7 days
    final mockData = [
      {'day': 'T2', 'revenue': 1200000},
      {'day': 'T3', 'revenue': 1800000},
      {'day': 'T4', 'revenue': 1500000},
      {'day': 'T5', 'revenue': 2200000},
      {'day': 'T6', 'revenue': 2800000},
      {'day': 'T7', 'revenue': 3200000},
      {'day': 'CN', 'revenue': 2500000},
    ];

    final maxRevenue = mockData.map((e) => e['revenue'] as int).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: mockData.map((data) {
          final height = (data['revenue'] as int) / maxRevenue;
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${((data['revenue'] as int) / 1000000).toStringAsFixed(1)}M',
                style: const TextStyle(fontSize: 10),
              ),
              const SizedBox(height: 4),
              Container(
                width: 30,
                height: height * 150,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                data['day'] as String,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRevenueRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '${(amount / 1000000).toStringAsFixed(1)}M VNĐ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Theme.of(context).colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceStats(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          if (productProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
        children: [
              // Service Performance
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                        'Hiệu suất dịch vụ',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                      const SizedBox(height: 16),
                      ...productProvider.products.map((product) {
                        // Mock popularity data
                        final popularity = (product.id * 15) % 100;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      product.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${product.price.toStringAsFixed(0)} VNĐ',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: LinearProgressIndicator(
                                      value: popularity / 100,
                                      backgroundColor: Colors.grey[300],
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '$popularity%',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                ],
              ),
            ),
          ),
              const SizedBox(height: 20),
              
              // Service Categories
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                        'Phân loại dịch vụ',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                      _buildCategoryItem('Cắt tóc', 45, Colors.blue),
                      _buildCategoryItem('Gội đầu', 25, Colors.green),
                      _buildCategoryItem('Styling', 20, Colors.orange),
                      _buildCategoryItem('Nhuộm/Uốn', 10, Colors.purple),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryItem(String name, int percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(name),
          ),
          Text('$percentage%'),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingStats(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          if (adminProvider.dashboardStats == null) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final stats = adminProvider.dashboardStats!;
          
          return Column(
            children: [
              // Booking Status Overview
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                      Text(
                        'Tổng quan lịch hẹn',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
            children: [
                          Expanded(
                            child: _buildBookingStatCard(
                              'Chờ xác nhận',
                              stats.pendingBookings,
                              Colors.orange,
                              Icons.schedule,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildBookingStatCard(
                              'Đã xác nhận',
                              stats.confirmedBookings,
                Colors.blue,
                              Icons.check_circle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildBookingStatCard(
                              'Hoàn thành',
                              stats.completedBookings,
                Colors.green,
                              Icons.done_all,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildBookingStatCard(
                              'Đã hủy',
                              stats.cancelledBookings,
                              Colors.red,
                              Icons.cancel,
                            ),
                          ),
                        ],
              ),
            ],
          ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Booking Trends
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                        'Xu hướng đặt lịch',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTrendItem('Lịch hẹn hôm nay', stats.todayBookings, '+12%'),
                      _buildTrendItem('Lịch hẹn tuần này', stats.todayBookings * 7, '+8%'),
                      _buildTrendItem('Lịch hẹn tháng này', stats.todayBookings * 30, '+15%'),
                      _buildTrendItem('Tỷ lệ hoàn thành', 
                        ((stats.completedBookings / (stats.completedBookings + stats.cancelledBookings)) * 100).round(), 
                        '+5%'),
                    ],
                  ),
                    ),
                  ),
                  const SizedBox(height: 20),
              
              // Customer Insights
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thông tin khách hàng',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInsightItem('Tổng khách hàng', stats.customersCount),
                      _buildInsightItem('Khách hàng mới tháng này', (stats.customersCount * 0.1).round()),
                      _buildInsightItem('Khách hàng thân thiết', (stats.customersCount * 0.3).round()),
                      _buildInsightItem('Tỷ lệ quay lại', '78%'),
                ],
              ),
            ),
          ),
        ],
          );
        },
      ),
    );
  }

  Widget _buildBookingStatCard(String title, int count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTrendItem(String label, int value, String change) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Row(
        children: [
              Text(
                '$value',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  change,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            '$value',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
