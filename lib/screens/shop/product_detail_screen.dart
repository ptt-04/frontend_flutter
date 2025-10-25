import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/api_config.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider_new.dart';

class ProductDetailScreen extends StatelessWidget {
  final int productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => context.go('/home'),
          tooltip: 'Về trang chủ',
        ),
        title: const Text('Chi tiết sản phẩm'),
      ),
      body: FutureBuilder(
        future: Provider.of<ProductProvider>(context, listen: false).getProduct(productId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Không tìm thấy sản phẩm'));
          }
          final product = snapshot.data!;
          final images = product.imageGallery.isNotEmpty
              ? product.imageGallery
              : (product.imageUrl != null ? [product.imageUrl!] : <String>[]);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image slider
                if (images.isNotEmpty)
                  SizedBox(
                    height: 320,
                    child: PageView.builder(
                      itemCount: images.length,
                      controller: PageController(viewportFraction: 0.92),
                      itemBuilder: (context, index) {
                        final url = images[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              ApiConfig.resolveImageUrl(url),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stack) => Container(
                                color: Colors.grey[200],
                                alignment: Alignment.center,
                                child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    height: 240,
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey)),
                  ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name, style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (product.hasDiscount)
                            Text(
                              '${product.price.toStringAsFixed(0)}đ',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                              ),
                            ),
                          const SizedBox(width: 8),
                          Text(
                            '${product.finalPrice.toStringAsFixed(0)}đ',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(product.description),
                      const SizedBox(height: 24),
                      
                      // Add to cart button
                      Consumer<CartProvider>(
                        builder: (context, cartProvider, child) {
                          final isInCart = cartProvider.isInCart(product.id);
                          return SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                if (isInCart) {
                                  // Find cart item ID and remove it
                                  final cartItem = cartProvider.items.firstWhere(
                                    (item) => item.productId == product.id,
                                  );
                                  cartProvider.removeFromCart(cartItem.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Đã xóa sản phẩm khỏi giỏ hàng'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                } else {
                                  cartProvider.addToCart(
                                    productId: product.id,
                                    quantity: 1,
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Đã thêm sản phẩm vào giỏ hàng'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              },
                              icon: Icon(
                                isInCart ? Icons.remove_shopping_cart : Icons.add_shopping_cart,
                              ),
                              label: Text(
                                isInCart ? 'Xóa khỏi giỏ hàng' : 'Thêm vào giỏ hàng',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isInCart 
                                    ? Colors.red 
                                    : Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 16),
                    ],
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





