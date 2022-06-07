import 'package:la_design_core/la_design_core.dart';
import 'package:la_test_utils/la_test_utils.dart';

import '../base/widget.dart';

void main() async {
  testAppWidgets(
    'tile_grid',
    {
      'products': const CustomScrollView(
        slivers: [
          AppTileSliverGrid(
            children: [
              ProductTileLayout.idle(
                name: 'Dog 1',
                price: 300,
                image: kDogImage,
                aspectRatio: 1 / 1.5,
              ),
              ProductTileLayout.idle(
                name: 'Dog 2',
                price: 400,
                image: kDogImage,
              ),
              ProductTileLayout.idle(
                name: 'Dog 3',
                price: 200,
                image: kDogImage,
                aspectRatio: 1 / 2,
              ),
              ProductTileLayout.idle(
                name: 'Dog 4',
                price: 120,
                image: kDogImage,
                aspectRatio: 1 / 1.8,
              ),
            ],
          ),
        ],
      ),
    },
    baseSize: const Size(1024, 1600),
  );
}
