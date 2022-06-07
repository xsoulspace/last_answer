import 'package:equatable/equatable.dart';
import 'package:flutter/rendering.dart';

import '../../utils/named.dart';

class AppShadowsData extends Equatable {
  const AppShadowsData({required this.big});

  factory AppShadowsData.regular() => const AppShadowsData(
        big: BoxShadow(
          blurRadius: 32,
          color: Color(0x44000000),
        ),
      );

  final BoxShadow big;

  @override
  List<Object?> get props => [
        big.named('big'),
      ];
}
