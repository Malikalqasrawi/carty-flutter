import 'package:flutter/material.dart';

class CartyLogo extends StatelessWidget {
  const CartyLogo({super.key, this.size = 28});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CartyLogoPainter(),
      ),
    );
  }
}

class _CartyLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final scale = size.width / 85;
    canvas.scale(scale);

    final path = Path();
    path.moveTo(84.48, 80.448);
    path.cubicTo(84.48, 84.736, 83.648, 87.84, 81.984, 89.76);
    path.cubicTo(80.384, 91.744, 77.408, 92.736, 73.056, 92.736);
    path.lineTo(12.384, 92.736);
    path.cubicTo(8.096, 92.736, 4.96, 91.744, 2.976, 89.76);
    path.cubicTo(0.992, 87.84, 0, 84.736, 0, 80.448);
    path.lineTo(0, 12.384);
    path.cubicTo(0, 8.416, 1.088, 5.376, 3.264, 3.264);
    path.cubicTo(5.44, 1.088, 8.48, 0, 12.384, 0);
    path.lineTo(70.176, 0);
    path.cubicTo(74.528, 0, 77.984, 0.992, 80.544, 2.976);
    path.cubicTo(83.168, 4.896, 84.48, 8.032, 84.48, 12.384);
    path.lineTo(84.48, 80.448);
    path.close();

    path.moveTo(12.384, 3.456);
    path.cubicTo(9.504, 3.456, 7.296, 4.224, 5.76, 5.76);
    path.cubicTo(4.224, 7.296, 3.456, 9.504, 3.456, 12.384);
    path.lineTo(3.456, 77.472);
    path.cubicTo(3.456, 80.352, 4.224, 82.4, 5.76, 83.616);
    path.cubicTo(7.296, 84.832, 9.504, 85.44, 12.384, 85.44);
    path.lineTo(67.296, 85.44);
    path.cubicTo(70.176, 85.44, 72.224, 84.832, 73.44, 83.616);
    path.cubicTo(74.656, 82.4, 75.264, 80.352, 75.264, 77.472);
    path.lineTo(75.264, 12.384);
    path.cubicTo(75.264, 9.504, 74.656, 7.296, 73.44, 5.76);
    path.cubicTo(72.224, 4.224, 70.176, 3.456, 67.296, 3.456);
    path.lineTo(12.384, 3.456);
    path.close();

    path.moveTo(44.16, 48);
    path.cubicTo(44.224, 50.368, 44.256, 52.96, 44.256, 55.776);
    path.cubicTo(44.32, 58.528, 44.384, 61.088, 44.448, 63.456);
    path.cubicTo(44.512, 65.824, 44.608, 67.584, 44.736, 68.736);
    path.cubicTo(44.16, 68.608, 43.264, 68.544, 42.048, 68.544);
    path.cubicTo(40.832, 68.48, 39.968, 68.448, 39.456, 68.448);
    path.cubicTo(38.944, 68.448, 38.08, 68.48, 36.864, 68.544);
    path.cubicTo(35.712, 68.544, 34.848, 68.608, 34.272, 68.736);
    path.cubicTo(34.4, 67.392, 34.496, 65.6, 34.56, 63.36);
    path.cubicTo(34.624, 61.12, 34.656, 58.688, 34.656, 56.064);
    path.cubicTo(34.72, 53.44, 34.752, 50.976, 34.752, 48.672);
    path.cubicTo(34.24, 47.712, 33.408, 46.336, 32.256, 44.544);
    path.cubicTo(31.168, 42.688, 29.952, 40.64, 28.608, 38.4);
    path.cubicTo(27.264, 36.16, 25.888, 33.952, 24.48, 31.776);
    path.cubicTo(23.136, 29.536, 21.888, 27.52, 20.736, 25.728);
    path.cubicTo(19.648, 23.936, 18.816, 22.624, 18.24, 21.792);
    path.cubicTo(18.816, 21.92, 19.744, 22.016, 21.024, 22.08);
    path.cubicTo(22.304, 22.08, 23.232, 22.08, 23.808, 22.08);
    path.cubicTo(24.448, 22.08, 25.376, 22.08, 26.592, 22.08);
    path.cubicTo(27.872, 22.016, 28.832, 21.92, 29.472, 21.792);
    path.cubicTo(31.264, 25.376, 33.152, 28.864, 35.136, 32.256);
    path.cubicTo(37.12, 35.584, 39.2, 39.04, 41.376, 42.624);
    path.cubicTo(43.36, 39.552, 45.376, 36.192, 47.424, 32.544);
    path.cubicTo(49.536, 28.896, 51.456, 25.312, 53.184, 21.792);
    path.cubicTo(53.568, 21.92, 54.304, 22.016, 55.392, 22.08);
    path.cubicTo(56.48, 22.08, 57.248, 22.08, 57.696, 22.08);
    path.cubicTo(58.144, 22.08, 58.624, 22.08, 59.136, 22.08);
    path.cubicTo(59.712, 22.016, 60.224, 21.92, 60.672, 21.792);
    path.cubicTo(56.384, 28.448, 52.928, 33.76, 50.304, 37.728);
    path.cubicTo(47.68, 41.696, 45.632, 45.12, 44.16, 48);
    path.close();

    path.moveTo(23.775, 58.069);
    path.cubicTo(23.069, 57.835, 22.305, 58.214, 22.07, 58.916);
    path.cubicTo(21.834, 59.618, 22.216, 60.376, 22.922, 60.61);
    path.lineTo(23.399, 60.768);
    path.cubicTo(24.615, 61.171, 25.419, 61.439, 26.011, 61.713);
    path.cubicTo(26.572, 61.972, 26.814, 62.18, 26.97, 62.394);
    path.cubicTo(27.125, 62.608, 27.248, 62.903, 27.318, 63.513);
    path.cubicTo(27.392, 64.158, 27.394, 65.0, 27.394, 66.274);
    path.lineTo(27.394, 71.045);
    path.cubicTo(27.394, 73.487, 27.394, 75.455, 27.603, 77.003);
    path.cubicTo(27.821, 78.61, 28.287, 79.964, 29.369, 81.039);
    path.cubicTo(30.451, 82.113, 31.813, 82.576, 33.432, 82.792);
    path.cubicTo(34.99, 83.0, 36.972, 83.0, 39.431, 83.0);
    path.lineTo(52.115, 83.0);
    path.cubicTo(52.859, 83.0, 53.463, 82.4, 53.463, 81.661);
    path.cubicTo(53.463, 80.921, 52.859, 80.321, 52.115, 80.321);
    path.lineTo(39.53, 80.321);
    path.cubicTo(36.949, 80.321, 35.149, 80.319, 33.791, 80.137);
    path.cubicTo(32.472, 79.961, 31.773, 79.639, 31.276, 79.145);
    path.cubicTo(30.853, 78.725, 30.555, 78.16, 30.366, 77.196);
    path.lineTo(48.558, 77.196);
    path.cubicTo(50.283, 77.196, 51.146, 77.196, 51.821, 76.754);
    path.cubicTo(52.497, 76.312, 52.836, 75.524, 53.516, 73.95);
    path.lineTo(54.286, 72.164);
    path.cubicTo(55.742, 68.791, 56.47, 67.105, 55.67, 65.901);
    path.cubicTo(54.871, 64.697, 53.024, 64.697, 49.329, 64.697);
    path.lineTo(30.082, 64.697);
    path.cubicTo(30.071, 64.147, 30.048, 63.651, 29.997, 63.209);
    path.cubicTo(29.898, 62.344, 29.681, 61.549, 29.158, 60.828);
    path.cubicTo(28.634, 60.107, 27.944, 59.651, 27.149, 59.284);
    path.cubicTo(26.4, 58.938, 25.449, 58.623, 24.322, 58.25);
    path.lineTo(23.775, 58.069);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}