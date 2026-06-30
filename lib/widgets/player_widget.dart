import 'package:flutter/material.dart';
import '../models/card.dart';
import '../models/general.dart';
import '../models/game_state.dart';
import 'card_widget.dart';

/// 玩家面板
class PlayerWidget extends StatelessWidget {
  final Player player;
  final bool isCurrent;
  final bool isSelected;
  final double width;
  final VoidCallback? onTap;
  final VoidCallback? onEquipTap;

  const PlayerWidget({
    super.key,
    required this.player,
    this.isCurrent = false,
    this.isSelected = false,
    this.width = 160,
    this.onTap,
    this.onEquipTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color borderColor;
    if (isSelected) {
      borderColor = Colors.yellow;
    } else if (isCurrent) {
      borderColor = Colors.orange;
    } else {
      borderColor = Colors.grey[300]!;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: player.isAlive ? Colors.white.withOpacity(0.95) : Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: isSelected ? 3 : 1),
          boxShadow: [
            if (isCurrent)
              BoxShadow(color: Colors.orange[200]!, blurRadius: 8),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 名称行
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  player.general.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: player.isAlive ? null : Colors.grey,
                  ),
                ),
                if (player.roleRevealed) ...[
                  SizedBox(width: 4),
                  _roleBadge(player.role),
                ],
              ],
            ),
            SizedBox(height: 4),
            // 血量
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < player.maxHp; i++)
                  Icon(
                    i < player.currentHp ? Icons.favorite : Icons.favorite_border,
                    color: i < player.currentHp ? Colors.red : Colors.grey,
                    size: 16,
                  ),
              ],
            ),
            SizedBox(height: 4),
            // 手牌数
            Text(
              '手牌: ${player.handCards.length}',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
            // 装备
            if (player.equipment.getAll().isNotEmpty) ...[
              SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: player.equipment.getAll().map((e) => MiniCard(card: e, size: 24)).toList().cast<Widget>(),
              ),
            ],
            // 状态
            if (player.statusEffects.isNotEmpty) ...[
              SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: player.statusEffects.map((e) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: _statusColor(e),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _statusName(e),
                      style: TextStyle(fontSize: 9, color: Colors.white),
                    ),
                  );
                }).toList(),
              ),
            ],
            // 阵亡
            if (!player.isAlive)
              Text('阵亡', style: TextStyle(fontSize: 12, color: Colors.red[700], fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _roleBadge(Role r) {
    final colors = {
      Role.lord: Colors.red,
      Role.loyalist: Colors.yellow[700],
      Role.rebel: Colors.blue[400],
      Role.traitor: Colors.green,
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: colors[r],
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        roleName(r),
        style: TextStyle(fontSize: 8, color: Colors.white),
      ),
    );
  }

  Color? _statusColor(StatusEffect e) {
    switch (e) {
      case StatusEffect.happy: return Colors.purple;
      case StatusEffect.lightning: return Colors.amber;
    }
  }

  String _statusName(StatusEffect e) {
    switch (e) {
      case StatusEffect.happy: return '乐';
      case StatusEffect.lightning: return '⚡';
    }
  }
}
