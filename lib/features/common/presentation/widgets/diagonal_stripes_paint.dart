import 'package:flutter/material.dart';

class DiagonalStripesPainter extends CustomPainter {
  DiagonalStripesPainter({
    required this.angleRadians,
    required this.stripeWidth,
    required this.gapWidth,
    required this.stripeColor,
    required this.backgroundColor,
  });

  final double angleRadians;
  final double stripeWidth;
  final double gapWidth;
  final Color stripeColor;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paintBg = Paint()..color = backgroundColor;
    canvas.drawRect(Offset.zero & size, paintBg);

    // 대각선 방향으로 좌표계를 회전
    canvas.save();
    final center = Offset(size.width / 2, size.height / 2);
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angleRadians);
    canvas.translate(-center.dx, -center.dy);

    // 회전된 좌표계에서 수평 스트라이프를 반복으로 그림
    final total = stripeWidth + gapWidth;
    final paintStripe = Paint()..color = stripeColor;

    // 충분히 넓은 폭으로 사각형을 그리기 위해, 화면보다 약간 더 넓게
    final stripeRectWidth = size.width * 20;

    // y=0 기준 위아래로 반복
    // 시작점을 음수로 당겨 화면 위부터 꽉 차게
    for (double y = -size.height * 20; y < size.height * 20; y += total) {
      final rect = Rect.fromLTWH(
        -((stripeRectWidth - size.width) / 2), // 좌우 여유분
        y,
        stripeRectWidth,
        stripeWidth,
      );
      canvas.drawRect(rect, paintStripe);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant DiagonalStripesPainter old) {
    return angleRadians != old.angleRadians ||
        stripeWidth != old.stripeWidth ||
        gapWidth != old.gapWidth ||
        stripeColor != old.stripeColor ||
        backgroundColor != old.backgroundColor;
  }
}
