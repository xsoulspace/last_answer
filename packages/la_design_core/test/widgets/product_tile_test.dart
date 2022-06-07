import 'package:la_design_core/la_design_core.dart';
import 'package:la_test_utils/la_test_utils.dart';

import '../base/widget.dart';

void main() async {
  const name = 'Dog';
  const price = 300.0;

  testAppWidgets(
    'product_tile_test',
    {
      'idle': const ProductTileLayout.idle(
        name: name,
        price: price,
        image: kDogImage,
      ),
      'hovered': const ProductTileLayout.hovered(
        name: name,
        price: price,
        image: kDogImage,
      ),
    },
  );
}
