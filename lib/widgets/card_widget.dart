import 'package:flutter/material.dart';
import '../models/card.dart';

/// 卡牌组件
class CardWidget extends StatelessWidget {
  final Card card;
  final bool faceDown;
  final bool selected;
  final bool highlighted;
  final double width;
  final VoidCallback? onTap;

  const CardWidget({
    super.key,
    required this.card,
    this.faceDown = false,
    this.selected = false,
    this.highlighted = false,
    this.width = 72,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final height = width * 1.4;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: faceDown ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected ? Colors.orange[400]! : Colors.grey[400]!,
            width: selected ? 3 : 1,
          ),
          boxShadow: [
            if (highlighted)
              BoxShadow(color: Colors.yellow[200]!, blurRadius: 8, spreadRadius: 2),
            BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(1, 2)),
          ],
        ),
        child: faceDown
            ? Center(
                child: Icon(Icons.star, color: Colors.grey[400], size: width * 0.3),
              )
            : _buildFace(context),
      ),
    );
  }

  Widget _buildFace(BuildContext context) {
    final color = card.isRed ? Colors.red[700]! : Colors.black;

    return Padding(
      padding: EdgeInsets.all(width * 0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 花色 + 数字
          Text(
            '${card.suitName}${card.displayNumber}',
            style: TextStyle(
              fontSize: width * 0.18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Spacer(),
          // 卡名
          Center(
            child: Text(
              card.name,
              style: TextStyle(
                fontSize: width * 0.19,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Spacer(),
          // 类型标识
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              card.suitName,
              style: TextStyle(fontSize: width * 0.14, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

/// 小卡牌（用于展示区域）
class MiniCard extends StatelessWidget {
  final Card card;
  final double size;

  const MiniCard({super.key, required this.card, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 1.3,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: Center(
        child: Text(
          card.name,
          style: TextStyle(
            fontSize: size * 0.18,
            fontWeight: FontWeight.bold,
            color: card.isRed ? Colors.red[700] : Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
