import 'package:flutter/widgets.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, required this.size, this.atEnd = false});

  final double size;
  final bool atEnd;

  @override
  Widget build(BuildContext context) {
    final inset = size * .125;
    return Transform.translate(
      offset: Offset(atEnd ? inset : -inset, 0),
      child: Image.asset('assets/academe/raster/academe_cube.png', width: size),
    );
  }
}
