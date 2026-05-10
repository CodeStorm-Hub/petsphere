import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:petfolio/features/marketplace/data/models/product_model.dart';

class ProductCard extends StatelessWidget {

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onAdd,
  });
  final ProductModel product;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Semantics(
      label: '${product.name}, ${product.category}, ${currencyFormat.format(product.price)}, ${product.rating} stars',
      button: true,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(
                theme.brightness == Brightness.dark ? 40 : 12,
              ),
              blurRadius: 25,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Minimalist Image Pedestal ───────────────────────────────────
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  color: theme.brightness == Brightness.dark
                      ? colorScheme.surfaceContainerHigh
                      : const Color(0xFFF2F2F2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      Center(
                        child: product.images.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: product.images[0],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              )
                            : Icon(
                                Icons.pets_rounded,
                                color: colorScheme.primary.withAlpha(50),
                                size: 40,
                              ),
                      ),
                      // Rating Badge (Top Right)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.surface.withAlpha(200),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Colors.amber,
                                size: 12,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                product.rating.toString(),
                                style: GoogleFonts.dmSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Clean Info Section ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.dmSans(
                      textStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.category,
                    style: GoogleFonts.dmSans(
                      textStyle: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        currencyFormat.format(product.price),
                        style: GoogleFonts.dmSans(
                          textStyle: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color:
                                colorScheme.primary, // Using PetFolio primary
                          ),
                        ),
                      ),
                      // Subtle Add Button matching the image detail page's theme
                      Semantics(
                        label: 'Add ${product.name} to cart',
                        button: true,
                        child: GestureDetector(
                          onTap: onAdd,
                          behavior: HitTestBehavior.opaque,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              minWidth: 48,
                              minHeight: 48,
                            ),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.add_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
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
    );
  }
}
