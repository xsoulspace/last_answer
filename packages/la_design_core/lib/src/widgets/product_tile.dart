import 'package:flutter/material.dart';
import 'package:tap_builder/tap_builder.dart';

import '../theme/theme.dart';
import 'base/padding.dart';
import 'base/text.dart';
import 'price_label.dart';

class ProductTile extends StatelessWidget {
  const ProductTile({
    final Key? key,
    required this.name,
    required this.image,
    required this.price,
    required this.onTap,
    this.aspectRatio = 1.0,
  }) : super(key: key);

  final String name;
  final double aspectRatio;
  final ImageProvider image;
  final double price;
  final VoidCallback onTap;

  @override
  Widget build(final BuildContext context) {
    return TapBuilder(
      onTap: onTap,
      builder: (final context, final state, final hasFocus) {
        switch (state) {
          case TapState.pressed:
          case TapState.hover:
            return ProductTileLayout.hovered(
              image: image,
              name: name,
              price: price,
              aspectRatio: aspectRatio,
            );
          default:
            return ProductTileLayout.idle(
              image: image,
              name: name,
              price: price,
              aspectRatio: aspectRatio,
            );
        }
      },
    );
  }
}

enum ProductTileState {
  idle,
  hovered,
}

class ProductTileLayout extends StatelessWidget {
  const ProductTileLayout.idle({
    final Key? key,
    required this.name,
    required this.image,
    required this.price,
    this.aspectRatio = 1.0,
  })  : _state = ProductTileState.idle,
        super(key: key);

  const ProductTileLayout.hovered({
    final Key? key,
    required this.name,
    required this.image,
    required this.price,
    this.aspectRatio = 1.0,
  })  : _state = ProductTileState.hovered,
        super(key: key);

  final String name;
  final double aspectRatio;
  final ImageProvider image;
  final double price;
  final ProductTileState _state;

  @override
  Widget build(final BuildContext context) {
    final theme = AppTheme.of(context);
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: ClipRRect(
        borderRadius: theme.radius.asBorderRadius().big,
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedContainer(
                duration: theme.durations.regular,
                curve: Curves.easeIn,
                transform: Matrix4.identity()
                  ..scale(
                    _state == ProductTileState.hovered ? 1.05 : 1.0,
                  ),
                transformAlignment: Alignment.center,
                child: Image(
                  image: image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned.fill(
              child: AnimatedContainer(
                duration: theme.durations.quick,
                color: theme.colors.accent.withOpacity(
                  _state == ProductTileState.hovered ? 0.4 : 0.0,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          theme.colors.foreground.withOpacity(
                            _state == ProductTileState.hovered ? 0.9 : 0.8,
                          ),
                          theme.colors.foreground.withOpacity(0),
                        ],
                      ),
                    ),
                    child: AppPadding.semiSmall(
                      child: AppText.title3(
                        name,
                        color: theme.colors.accentOpposite,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: AppPadding.semiSmall(
                    child: PriceLabel(price),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
