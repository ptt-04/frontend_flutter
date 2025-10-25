import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider_new.dart';
import '../../config/api_config.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => context.go('/home'),
          tooltip: 'Về trang chủ',
        ),
        title: const Text('Cửa hàng'),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () => context.go('/cart'),
                  ),
                  if (cartProvider.itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${cartProvider.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          if (productProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (productProvider.products.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Chưa có sản phẩm nào',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: productProvider.products.length,
            itemBuilder: (context, index) {
              final product = productProvider.products[index];
              final images = product.imageGallery.isNotEmpty
                  ? product.imageGallery
                  : (product.imageUrl != null ? [product.imageUrl!] : <String>[]);
              final thumbUrl = images.isNotEmpty ? ApiConfig.resolveImageUrl(images.first) : null;

              return InkWell(
                onTap: () => context.go('/shop/product/${product.id}'),
                child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                        ),
                        child: thumbUrl != null
                            ? Image.network(
                                thumbUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.image_not_supported,
                                    size: 48,
                                    color: Colors.grey,
                                  );
                                },
                              )
                            : const Icon(
                                Icons.image_not_supported,
                                size: 48,
                                color: Colors.grey,
                              ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: Theme.of(context).textTheme.titleSmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              product.category?.name ?? 'Không có danh mục',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (product.hasDiscount)
                                      Text(
                                        '${product.price.toStringAsFixed(0)}đ',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          decoration: TextDecoration.lineThrough,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    Text(
                                      '${product.finalPrice.toStringAsFixed(0)}đ',
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Consumer<CartProvider>(
                                  builder: (context, cartProvider, child) {
                                    final isInCart = cartProvider.isInCart(product.id);
                                    return IconButton(
                                      icon: Icon(
                                        isInCart ? Icons.shopping_cart : Icons.add_shopping_cart,
                                        color: isInCart 
                                            ? Theme.of(context).colorScheme.primary 
                                            : Colors.grey,
                                      ),
                                      onPressed: () {
                                        if (isInCart) {
                                          // Find cart item ID and remove it
                                          final cartItem = cartProvider.items.firstWhere(
                                            (item) => item.productId == product.id,
                                          );
                                          cartProvider.removeFromCart(cartItem.id);
                                        } else {
                                          cartProvider.addToCart(
                                            productId: product.id,
                                            quantity: 1,
                                          );
                                        }
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
