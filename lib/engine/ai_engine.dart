import 'dart:math';
import '../models/card.dart';
import '../models/game_state.dart';
import 'game_engine.dart';

/// AI 决策引擎
class AIEngine {
  final GameEngine engine;
  final Random _random = Random();

  AIEngine(this.engine);

  GameState get state => engine.state;

  /// AI 自动执行一个回合
  void takeTurn(Player player) {
    // 出牌阶段自动出牌
    _playPhase(player);

    // 结束出牌阶段
    engine.endPlayPhase(player);
  }

  /// 出牌阶段 AI 决策
  void _playPhase(Player player) {
    if (state.gameOver) return;
    if (state.phase != GamePhase.play) return;

    int maxActions = 20; // 防止死循环

    while (maxActions-- > 0 && !state.gameOver) {
      bool acted = false;

      // 1. 优先吃桃回血
      if (player.currentHp < player.maxHp) {
        final peach = player.handCards.where((c) => c.subtype == CardSubtype.peach).toList();
        if (peach.isNotEmpty) {
          engine.playCard(player, peach.first, targets: [player]);
          acted = true;
          continue;
        }
      }

      // 2. 装备武器
      final weapons = player.handCards.where((c) => c.isWeapon).toList();
      if (weapons.isNotEmpty && !player.equipment.hasWeapon) {
        engine.playCard(player, weapons.first);
        acted = true;
        continue;
      }

      // 3. 装备防具
      if (player.equipment.armor == null) {
        final armor = player.handCards.where((c) =>
            c.subtype == CardSubtype.eightTrigram ||
            c.subtype == CardSubtype.renShield).toList();
        if (armor.isNotEmpty) {
          engine.playCard(player, armor.first);
          acted = true;
          continue;
        }
      }

      // 4. 装备马
      if (player.equipment.minusHorse == null) {
        final mh = player.handCards.where((c) => c.subtype == CardSubtype.minusHorse).toList();
        if (mh.isNotEmpty) {
          engine.playCard(player, mh.first);
          acted = true;
          continue;
        }
      }
      if (player.equipment.plusHorse == null) {
        final ph = player.handCards.where((c) => c.subtype == CardSubtype.plusHorse).toList();
        if (ph.isNotEmpty) {
          engine.playCard(player, ph.first);
          acted = true;
          continue;
        }
      }

      // 5. 无中生有
      final create = player.handCards.where((c) => c.subtype == CardSubtype.create).toList();
      if (create.isNotEmpty) {
        engine.playCard(player, create.first);
        acted = true;
        continue;
      }

      // 6. 桃园结义（有人受伤时）
      final injured = state.alivePlayers.any((p) => p.currentHp < p.maxHp);
      if (injured) {
        final pg = player.handCards.where((c) => c.subtype == CardSubtype.peachGarden).toList();
        if (pg.isNotEmpty) {
          engine.playCard(player, pg.first);
          acted = true;
          continue;
        }
      }

      // 7. 找敌人放南蛮/万箭
      final targets = _findHostileTargets(player);
      if (targets.isNotEmpty) {
        // 南蛮入侵
        final savage = player.handCards.where((c) => c.subtype == CardSubtype.savage).toList();
        if (savage.isNotEmpty && _random.nextDouble() < 0.7) {
          engine.playCard(player, savage.first);
          acted = true;
          continue;
        }
        // 万箭齐发
        final volley = player.handCards.where((c) => c.subtype == CardSubtype.volley).toList();
        if (volley.isNotEmpty && _random.nextDouble() < 0.7) {
          engine.playCard(player, volley.first);
          acted = true;
          continue;
        }
      }

      // 8. 对敌人出杀
      if (player.canUseKill) {
        final slash = _findSlash(player);
        if (slash != null && targets.isNotEmpty) {
          final bestTarget = _bestSlashTarget(player, targets);
          if (bestTarget != null && state.inAttackRange(player, bestTarget)) {
            engine.playCard(player, slash, targets: [bestTarget]);
            acted = true;
            continue;
          }
        }
      }

      // 9. 决斗敌人
      if (targets.isNotEmpty) {
        final duel = player.handCards.where((c) => c.subtype == CardSubtype.duel).toList();
        if (duel.isNotEmpty) {
          engine.playCard(player, duel.first, targets: [targets.first]);
          acted = true;
          continue;
        }
      }

      // 10. 过河拆桥/顺手牵羊
      if (targets.isNotEmpty) {
        final dismantle = player.handCards.where((c) => c.subtype == CardSubtype.dismantle).toList();
        if (dismantle.isNotEmpty) {
          engine.playCard(player, dismantle.first, targets: [targets.first]);
          acted = true;
          continue;
        }
        final steal = player.handCards.where((c) => c.subtype == CardSubtype.steal).toList();
        if (steal.isNotEmpty) {
          engine.playCard(player, steal.first, targets: [targets.first]);
          acted = true;
          continue;
        }
      }

      // 11. 五谷丰登
      final abundant = player.handCards.where((c) => c.subtype == CardSubtype.abundant).toList();
      if (abundant.isNotEmpty) {
        engine.playCard(player, abundant.first);
        acted = true;
        continue;
      }

      // 12. 闪电（没挂才挂）
      if (!player.hasLightning) {
        final lightning = player.handCards.where((c) => c.subtype == CardSubtype.lightning).toList();
        if (lightning.isNotEmpty && _random.nextDouble() < 0.3) {
          engine.playCard(player, lightning.first);
          acted = true;
          continue;
        }
      }

      // 13. 乐不思蜀（对敌人）
      if (targets.isNotEmpty) {
        final happy = player.handCards.where((c) => c.subtype == CardSubtype.happy).toList();
        if (happy.isNotEmpty && targets.isNotEmpty) {
          engine.playCard(player, happy.first, targets: [targets.first]);
          acted = true;
          continue;
        }
      }

      // 14. 制衡（孙权）
      if (player.general.skills.any((s) => s.name == '制衡') && player.handCards.length > 3) {
        _zhiHeng(player);
        acted = true;
        continue;
      }

      // 15. 苦肉（黄盖）
      if (player.general.skills.any((s) => s.name == '苦肉') && player.currentHp > 1) {
        player.currentHp--;
        engine.drawCards(player, 2);
        state.addLog('${player.name} 发动【苦肉】');
        acted = true;
        continue;
      }

      if (!acted) break;
    }
  }

  /// 找到可以当杀用的牌
  Card? _findSlash(Player player) {
    for (final c in player.handCards) {
      if (c.subtype == CardSubtype.slash) return c;
    }
    // 武圣（红牌当杀）
    if (player.general.skills.any((s) => s.name == '武圣')) {
      for (final c in player.handCards) {
        if (c.isRed) return c;
      }
    }
    // 龙胆（闪当杀）
    if (player.general.skills.any((s) => s.name == '龙胆')) {
      for (final c in player.handCards) {
        if (c.subtype == CardSubtype.dodge) return c;
      }
    }
    return null;
  }

  /// 找敌对目标（反贼杀忠/主，忠臣杀反/内，主公杀反/内，内奸杀所有人）
  List<Player> _findHostileTargets(Player player) {
    final targets = <Player>[];
    for (final p in state.alivePlayers) {
      if (p.id == player.id) continue;
      if (_isHostile(player, p)) {
        targets.add(p);
      }
    }
    // 按血量升序（先打残血）
    targets.sort((a, b) => a.currentHp.compareTo(b.currentHp));
    return targets;
  }

  bool _isHostile(Player self, Player other) {
    switch (self.role) {
      case Role.lord:
      case Role.loyalist:
        return other.role == Role.rebel || other.role == Role.traitor;
      case Role.rebel:
        return other.role == Role.lord || other.role == Role.loyalist;
      case Role.traitor:
        return other.role != Role.traitor;
    }
  }

  /// 最佳杀的目标
  Player? _bestSlashTarget(Player player, List<Player> targets) {
    // 选血量最低 && 在攻击范围内
    for (final t in targets) {
      if (state.inAttackRange(player, t)) return t;
    }
    return null;
  }

  /// 制衡（孙权技能）
  void _zhiHeng(Player player) {
    final discard = player.handCards.sublist(0, player.handCards.length ~/ 2);
    for (final c in discard) {
      engine.discardCard(player, c);
    }
    engine.drawCards(player, discard.length);
    state.addLog('${player.name} 发动【制衡】');
  }

  /// AI 弃牌阶段
  void autoDiscard(Player player) {
    int limit = player.handLimit;
    while (player.handCards.length > limit) {
      // 弃掉优先级最低的牌
      Card? worst;
      int worstScore = 999;
      for (final c in player.handCards) {
        int score = _cardValue(c);
        if (score < worstScore) {
          worstScore = score;
          worst = c;
        }
      }
      if (worst != null) {
        engine.discardCard(player, worst);
      }
    }
  }

  int _cardValue(Card c) {
    switch (c.subtype) {
      case CardSubtype.peach: return 100;
      case CardSubtype.dodge: return 80;
      case CardSubtype.slash: return 60;
      case CardSubtype.create: return 90;
      case CardSubtype.peachGarden: return 85;
      case CardSubtype.abundant: return 70;
      case CardSubtype.counter: return 75;
      case CardSubtype.crossbow: return 88;
      case CardSubtype.eightTrigram: return 78;
      case CardSubtype.blade: return 70;
      case CardSubtype.minusHorse: return 65;
      case CardSubtype.plusHorse: return 65;
      case CardSubtype.savage: return 72;
      case CardSubtype.volley: return 72;
      case CardSubtype.duel: return 68;
      case CardSubtype.dismantle: return 75;
      case CardSubtype.steal: return 77;
      case CardSubtype.happy: return 62;
      default: return 50;
    }
  }
}
