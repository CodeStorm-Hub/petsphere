import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';

// Dummy Marketplace Data
final _initialProducts = [
  ProductModel(
    id: 'prod-1',
    name: 'Premium Salmon Kibble 5kg',
    price: 49.99,
    vendorId: 'vendor-xyz',
    description: 'High quality salmon-based dry food for adult dogs. Rich in Omega-3 for a shiny coat.',
    images: ['https://images.unsplash.com/photo-1589924691995-400dc9ecc119?q=80&w=400&auto=format&fit=crop'],
    stock: 50,
    category: 'Food',
  ),
  ProductModel(
    id: 'prod-2',
    name: 'Indestructible Chew Toy',
    price: 15.99,
    vendorId: 'vendor-abc',
    description: 'Made from tough natural rubber. Perfect for aggressive chewers.',
    images: ['https://images.unsplash.com/photo-1541599540903-216a46ca1dc0?q=80&w=400&auto=format&fit=crop'],
    stock: 120,
    category: 'Toys',
  ),
  ProductModel(
    id: 'prod-3',
    name: 'Self-Cleaning Litter Box',
    price: 199.99,
    vendorId: 'vendor-kitty',
    description: 'Automatic litter box that sifts and cleans itself after every use. WiFi enabled.',
    images: ['https://images.unsplash.com/photo-1629898074987-a2f26792375b?q=80&w=400&auto=format&fit=crop'],
    stock: 15,
    category: 'Accessories',
  ),
  ProductModel(
    id: 'prod-4',
    name: 'Organic Catnip 2oz',
    price: 8.50,
    vendorId: 'vendor-farm',
    description: '100% natural and organic catnip harvested locally. Your cat will go crazy!',
    images: ['https://images.unsplash.com/photo-1596704017254-9b121068fb29?q=80&w=400&auto=format&fit=crop'],
    stock: 200,
    category: 'Treats',
  ),
];

class MarketplaceState {
  final List<ProductModel> products;
  final String? filterCategory;

  MarketplaceState({
    required this.products,
    this.filterCategory,
  });

  MarketplaceState copyWith({
    List<ProductModel>? products,
    String? filterCategory,
  }) {
    return MarketplaceState(
      products: products ?? this.products,
      filterCategory: filterCategory ?? this.filterCategory,
    );
  }
}

class MarketplaceController extends Notifier<MarketplaceState> {
  @override
  MarketplaceState build() {
    return MarketplaceState(products: _initialProducts);
  }

  void setFilter(String? category) {
    if (category == null || category.isEmpty) {
      state = MarketplaceState(products: _initialProducts, filterCategory: null);
    } else {
      final filtered = _initialProducts.where((p) => p.category == category).toList();
      state = MarketplaceState(products: filtered, filterCategory: category);
    }
  }
}

final marketplaceProvider = NotifierProvider<MarketplaceController, MarketplaceState>(() {
  return MarketplaceController();
});
