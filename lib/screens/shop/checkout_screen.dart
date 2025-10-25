import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/cart_provider_new.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/order.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _deliveryAddressController = TextEditingController();
  final _deliveryPhoneController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _selectedPaymentMethod = 'Cash';
  String _selectedDeliveryMethod = 'Pickup';
  int? _selectedBranchId;
  int? _selectedVoucherId;
  final int _loyaltyPointsUsed = 0;

  final List<String> _paymentMethods = [
    'Cash',
    'VNPay',
    'Momo',
    'ZaloPay',
  ];

  final List<String> _deliveryMethods = [
    'Pickup',
    'Delivery',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadBranches();
    });
  }

  @override
  void dispose() {
    _deliveryAddressController.dispose();
    _deliveryPhoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }


  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final cartProvider = context.read<CartProvider>();
    final orderProvider = context.read<OrderProvider>();

    if (cartProvider.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Giỏ hàng trống')),
      );
      return;
    }

    if (_selectedDeliveryMethod == 'Pickup' && _selectedBranchId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn chi nhánh nhận hàng')),
      );
      return;
    }

    if (_selectedDeliveryMethod == 'Delivery' && _deliveryAddressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập địa chỉ giao hàng')),
      );
      return;
    }

    try {
      final orderItems = cartProvider.items.map((item) => OrderItem(
        productId: item.productId,
        quantity: item.quantity,
      )).toList();

      final request = CreateOrderRequest(
        orderItems: orderItems,
        paymentMethod: _selectedPaymentMethod,
        deliveryMethod: _selectedDeliveryMethod,
        branchId: _selectedBranchId,
        deliveryAddress: _deliveryAddressController.text.isEmpty ? null : _deliveryAddressController.text,
        deliveryPhone: _deliveryPhoneController.text.isEmpty ? null : _deliveryPhoneController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        voucherId: _selectedVoucherId,
        loyaltyPointsUsed: _loyaltyPointsUsed > 0 ? _loyaltyPointsUsed : null,
      );

      final order = await orderProvider.createOrder(request);
      
      if (order != null) {
        if (_selectedPaymentMethod == 'VNPay') {
          // Redirect to VNPay payment
          final paymentRequest = VNPayPaymentRequest(
            orderId: order.id,
            amount: order.totalAmount,
          );
          
          final paymentResponse = await orderProvider.createVNPayPayment(paymentRequest);
          if (paymentResponse != null) {
            // Clear cart
            await cartProvider.clearCart();
            
            if (mounted) {
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đơn hàng đã được tạo. Chuyển hướng đến VNPay...'),
                  backgroundColor: Colors.green,
                ),
              );
              
              // TODO: Open VNPay payment URL
              // For now, just navigate back to shop
              context.go('/shop');
            }
          }
        } else {
          // Clear cart for cash payment
          await cartProvider.clearCart();
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đơn hàng đã được tạo thành công!'),
                backgroundColor: Colors.green,
              ),
            );
            
            context.go('/shop');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer3<CartProvider, OrderProvider, AuthProvider>(
        builder: (context, cartProvider, orderProvider, authProvider, child) {
          if (cartProvider.items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Giỏ hàng trống', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Summary
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tóm tắt đơn hàng',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          ...cartProvider.items.map((item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(item.productName),
                                ),
                                Text('${item.quantity}x'),
                                const SizedBox(width: 8),
                                Text('${item.finalPrice.toStringAsFixed(0)}đ'),
                              ],
                            ),
                          )),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Tổng cộng:',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                '${cartProvider.totalPrice.toStringAsFixed(0)}đ',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Delivery Method
                  Text(
                    'Phương thức nhận hàng',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: _deliveryMethods.map((method) => ListTile(
                      title: Text(method == 'Pickup' ? 'Nhận tại cửa hàng' : 'Giao hàng tận nơi'),
                      leading: Radio<String>(
                        value: method,
                        // ignore: deprecated_member_use
                        groupValue: _selectedDeliveryMethod,
                        // ignore: deprecated_member_use
                        onChanged: (value) {
                          setState(() {
                            _selectedDeliveryMethod = value!;
                            if (value == 'Pickup') {
                              _selectedBranchId = null;
                            }
                          });
                        },
                      ),
                      onTap: () {
                        setState(() {
                          _selectedDeliveryMethod = method;
                          if (method == 'Pickup') {
                            _selectedBranchId = null;
                          }
                        });
                      },
                    )).toList(),
                  ),
                  
                  // Branch Selection (for Pickup)
                  if (_selectedDeliveryMethod == 'Pickup') ...[
                    const SizedBox(height: 16),
                    Text(
                      'Chọn chi nhánh',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      initialValue: _selectedBranchId,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Chọn chi nhánh',
                      ),
                      items: orderProvider.branches.map((branch) => DropdownMenuItem<int>(
                        value: branch['id'] as int,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(branch['name'] as String),
                            Text(
                              branch['address'] as String,
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      )).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedBranchId = value;
                        });
                      },
                      validator: (value) {
                        if (_selectedDeliveryMethod == 'Pickup' && value == null) {
                          return 'Vui lòng chọn chi nhánh';
                        }
                        return null;
                      },
                    ),
                  ],
                  
                  // Delivery Address (for Delivery)
                  if (_selectedDeliveryMethod == 'Delivery') ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _deliveryAddressController,
                      decoration: const InputDecoration(
                        labelText: 'Địa chỉ giao hàng',
                        border: OutlineInputBorder(),
                        hintText: 'Nhập địa chỉ giao hàng',
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (_selectedDeliveryMethod == 'Delivery' && (value == null || value.isEmpty)) {
                          return 'Vui lòng nhập địa chỉ giao hàng';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _deliveryPhoneController,
                      decoration: const InputDecoration(
                        labelText: 'Số điện thoại giao hàng',
                        border: OutlineInputBorder(),
                        hintText: 'Nhập số điện thoại',
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  // Payment Method
                  Text(
                    'Phương thức thanh toán',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: _paymentMethods.map((method) => ListTile(
                      title: Text(_getPaymentMethodName(method)),
                      leading: Radio<String>(
                        value: method,
                        // ignore: deprecated_member_use
                        groupValue: _selectedPaymentMethod,
                        // ignore: deprecated_member_use
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentMethod = value!;
                          });
                        },
                      ),
                      onTap: () {
                        setState(() {
                          _selectedPaymentMethod = method;
                        });
                      },
                    )).toList(),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Notes
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Ghi chú (tùy chọn)',
                      border: OutlineInputBorder(),
                      hintText: 'Nhập ghi chú cho đơn hàng',
                    ),
                    maxLines: 3,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Place Order Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: orderProvider.isLoading ? null : _placeOrder,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: orderProvider.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Đặt hàng',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getPaymentMethodName(String method) {
    switch (method) {
      case 'Cash':
        return 'Thanh toán tiền mặt';
      case 'VNPay':
        return 'VNPay';
      case 'Momo':
        return 'MoMo';
      case 'ZaloPay':
        return 'ZaloPay';
      default:
        return method;
    }
  }
}
