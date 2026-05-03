import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/petfolio_widgets.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return GlassCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: product.images.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: product.images[0],
                        fit: BoxFit.cover,
                        memCacheWidth: 400,
                        placeholder: (context, url) => Container(
                          color: colorScheme.surfaceContainerHigh,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: colorScheme.surfaceContainerHigh,
                          child: Icon(
                            Icons.broken_image,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : Container(
                        color: colorScheme.surfaceContainerHigh,
                        child: Icon(
                          Icons.inventory_2_outlined,
                          size: 48,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppTheme.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppTheme.xs),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          currencyFormat.format(product.price),
                          style: textTheme.titleLarge?.copyWith(
                            color: colorScheme.primary,
                            fontSize: 18,
                          ),
                        ),
                        InkWell(
                          onTap: onAdd,
                          child: Container(
                            padding: const EdgeInsets.all(AppTheme.xs),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              shape: BoxShape.circle,
                              boxShadow: Theme.of(
                                context,
                              ).extension<PetfolioShadows>()?.button,
                            ),
                            child: Icon(
                              Icons.add,
                              color: colorScheme.onPrimary,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
