import 'dart:math';
import '../models/card.dart';
import '../models/general.dart';
import '../models/game_state.dart';
import 'game_engine.dart';

/// 卡牌效果处理器
class CardEffects {
  final GameEngine engine;
  final Random _random = Random();

  CardEffects(this.engine);

  GameState get state => engine.state;

  /// 回合开始阶段处理
  void onTurnStart(Player player) {
    // 洛神
    if (player.general.skills.any((s) => s.name == '洛神')) {
      _luoShen(player);
    }
    // 观星
    if (player.general.skills.any((s) => s.name == '观星')) {
      _guanXing(player);
    }
  }

  void _luoShen(Player player) {
    state.addLog('${player.name} 发动【洛神】');
    while (true) {
      final card = engine.judge(player);
      if (card.suit == Suit.spade || card.suit == Suit.club) {
        player.handCards.add(card);
        state.discardPile.removeLast();
        state.addLog('${player.name} 获得判定牌');
      } else {
        break;
      }
    }
  }

  void _guanXing(Player player) {
    // 简版：看牌堆顶5张并重排（AI直接跳过）
    state.addLog('${player.name} 发动【观星】');
  }

  /// 判定阶段
  void onJudge(Player player) {
    // 闪电判定
    if (player.hasLightning) {
      final card = engine.judge(player);
      if (card.suit == Suit.spade && (card.number >= 2 && card.number <= 9)) {
        engine.dealDamage(player, player, 6);
        player.statusEffects.remove(StatusEffect.lightning);
      } else {
        state.addLog('闪电未生效');
      }
    }
  }

  /// 摸牌阶段
  void onDrawPhase(Player player) {
    int count = 2;
    // 英姿
    if (player.general.skills.any((s) => s.name == '英姿')) {
      count++;
      state.addLog('${player.name} 发动【英姿】，多摸一张牌');
    }
    // 突袭
    if (player.general.skills.any((s) => s.name == '突袭') &&
        player.id == state.currentPlayer.id) {
      // AI简化：不发动突袭
    }
    engine.drawCards(player, count);
  }

  /// 回合结束处理
  void onTurnEnd(Player player) {
    // 闭月
    if (player.general.skills.any((s) => s.name == '闭月') && player.id == state.currentPlayer.id) {
      engine.drawCard(player);
      state.addLog('${player.name} 发动【闭月】，摸一张牌');
    }
  }

  /// 使用卡牌
  bool playCard(Player player, Card card, {List<Player>? targets, Card? extraCard}) {
    switch (card.type) {
      case CardType.basic:
        return _playBasic(player, card, targets: targets);
      case CardType.trick:
        return _playTrick(player, card, targets: targets);
      case CardType.equipment:
        return _playEquipment(player, card);
    }
  }

  bool _playBasic(Player player, Card card, {List<Player>? targets}) {
    switch (card.subtype) {
      case CardSubtype.slash:
        return _playSlash(player, card, targets: targets);
      case CardSubtype.peach:
        return _playPeach(player, card, target: targets?.isNotEmpty == true ? targets!.first : player);
      default:
        return false;
    }
  }

  bool _playSlash(Player player, Card card, {List<Player>? targets}) {
    if (targets == null || targets.isEmpty) return false;
    final target = targets.first;
    if (!state.inAttackRange(player, target)) return false;
    if (!player.canUseKill && !_hasZhangFei(player)) return false;

    player.killsUsedThisTurn++;

    // 弃掉杀的牌（如果是转换的，弃掉转换用的牌）
    if (player.handCards.contains(card)) {
      engine.discardCard(player, card);
    }

    state.addLog('${player.name} 对 ${target.name} 使用【杀】');

    // 空城判定
    if (target.handCards.isEmpty && target.general.skills.any((s) => s.name == '空城')) {
      state.addLog('${target.name} 【空城】不能被指定为【杀】目标');
      return false;
    }

    // 铁骑判定
    bool forcedHit = false;
    if (player.general.skills.any((s) => s.name == '铁骑')) {
      final judgeCard = engine.judge(target);
      if (judgeCard.isRed) {
        forcedHit = true;
        state.addLog('${player.name} 发动【铁骑】，此杀不可闪避');
      }
    }

    // 吕布无双 - 需要2张闪
    int dodgeNeeded = 1;
    if (player.general.skills.any((s) => s.name == '无双')) {
      dodgeNeeded = 2;
      state.addLog('${player.name} 发动【无双】，需要2张【闪】');
    }

    // 对方出闪
    if (forcedHit) {
      engine.dealDamage(player, target, 1, card: card);
    } else if (_hasDodge(target)) {
      int dodged = 0;
      for (final c in target.handCards.toList()) {
        if (c.subtype == CardSubtype.dodge && dodged < dodgeNeeded) {
          engine.playDodge(target, c);
          dodged++;
        }
      }
      if (dodged < dodgeNeeded) {
        engine.dealDamage(player, target, 1, card: card);
      } else {
        state.addLog('${target.name} 使用【闪】');
      }
    } else {
      engine.dealDamage(player, target, 1, card: card);
    }

    // 反馈
    if (!target.isAlive) {
      _checkSkillsOnKill(player, target);
    }
    return true;
  }

  bool _hasZhangFei(Player player) {
    return player.general.skills.any((s) => s.name == '咆哮');
  }

  bool _hasDodge(Player player) {
    // 手牌有闪
    if (player.handCards.any((c) => c.subtype == CardSubtype.dodge)) return true;
    // 倾国
    if (player.general.skills.any((s) => s.name == '倾国') &&
        player.handCards.any((c) => !c.isRed)) return true;
    // 龙胆
    if (player.general.skills.any((s) => s.name == '龙胆') &&
        player.handCards.any((c) => c.subtype == CardSubtype.slash)) return true;
    // 八卦阵
    if (player.equipment.armor?.subtype == CardSubtype.eightTrigram) {
      final judgeCard = engine.judge(player);
      if (judgeCard.isRed) {
        state.addLog('${player.name} 八卦阵生效');
        return true;
      }
    }
    // 仁王盾 - 黑杀无效
    // (简化)
    return false;
  }

  bool _playPeach(Player player, Card card, {required Player target}) {
    if (target.currentHp == target.maxHp && target.isAlive) {
      state.addLog('${target.name} 不需要回血');
      return false;
    }
    engine.discardCard(player, card);
    engine.heal(target, 1);
    return true;
  }

  bool _playTrick(Player player, Card card, {List<Player>? targets}) {
    engine.discardCard(player, card);
    state.addLog('${player.name} 使用【${card.name}】');

    switch (card.subtype) {
      case CardSubtype.dismantle:
        return _dismantle(player, targets);
      case CardSubtype.steal:
        return _steal(player, targets);
      case CardSubtype.create:
        engine.drawCards(player, 2);
        return true;
      case CardSubtype.duel:
        return _duel(player, targets);
      case CardSubtype.savage:
        return _savage(player);
      case CardSubtype.volley:
        return _volley(player);
      case CardSubtype.peachGarden:
        for (final p in state.alivePlayers) {
          engine.heal(p, 1);
        }
        return true;
      case CardSubtype.abundant:
        return _abundant(player);
      case CardSubtype.happy:
        return _happy(player, targets);
      case CardSubtype.lightning:
        player.statusEffects.add(StatusEffect.lightning);
        state.addLog('${player.name} 挂上了闪电');
        return true;
      default:
        return false;
    }
  }

  bool _dismantle(Player player, List<Player>? targets) {
    if (targets == null || targets.isEmpty) return false;
    final target = targets.first;
    final choices = <Card>[];
    choices.addAll(target.handCards);
    choices.addAll(target.equipment.getAll());
    if (choices.isEmpty) {
      state.addLog('${target.name} 没有牌可拆');
      return false;
    }
    choices.shuffle();
    final removed = choices.first;
    if (target.handCards.contains(removed)) {
      target.handCards.remove(removed);
    } else {
      target.equipment.getAll().contains(removed);
      // 找到并移除
      for (final eq in [target.equipment.weapon, target.equipment.armor,
          target.equipment.minusHorse, target.equipment.plusHorse]) {
        if (eq == removed) {
          target.equipment.remove(eq!.equipSlot!);
          break;
        }
      }
    }
    state.discardPile.add(removed);
    state.addLog('${player.name} 拆掉了 ${target.name} 的一张牌');
    return true;
  }

  bool _steal(Player player, List<Player>? targets) {
    if (targets == null || targets.isEmpty) return false;
    final target = targets.first;
    // 陆逊谦逊
    if (target.general.skills.any((s) => s.name == '谦逊')) {
      state.addLog('${target.name} 【谦逊】不能被顺手牵羊');
      return false;
    }
    final choices = <Card>[];
    choices.addAll(target.handCards);
    choices.addAll(target.equipment.getAll());
    if (choices.isEmpty) return false;
    choices.shuffle();
    final stolen = choices.first;
    if (target.handCards.contains(stolen)) {
      target.handCards.remove(stolen);
    } else {
      for (final eq in [target.equipment.weapon, target.equipment.armor,
          target.equipment.minusHorse, target.equipment.plusHorse]) {
        if (eq == stolen) {
          target.equipment.remove(eq!.equipSlot!);
          break;
        }
      }
    }
    player.handCards.add(stolen);
    state.addLog('${player.name} 顺走了 ${target.name} 的一张牌');
    return true;
  }

  bool _duel(Player player, List<Player>? targets) {
    if (targets == null || targets.isEmpty) return false;
    final target = targets.first;
    // 空城
    if (target.handCards.isEmpty && target.general.skills.any((s) => s.name == '空城')) {
      state.addLog('${target.name} 【空城】不能被【决斗】');
      return false;
    }
    // 决斗流程
    Player attacker = player;
    Player defender = target;
    while (true) {
      final hasSlash = defender.handCards.any((c) => c.subtype == CardSubtype.slash);
      if (!hasSlash) {
        engine.dealDamage(attacker, defender, 1);
        return true;
      }
      final slash = defender.handCards.firstWhere((c) => c.subtype == CardSubtype.slash);
      engine.discardCard(defender, slash);
      // 交换
      final tmp = attacker;
      attacker = defender;
      defender = tmp;
    }
  }

  bool _savage(Player player) {
    // 南蛮入侵：所有其他玩家需打出杀
    for (final p in state.alivePlayers) {
      if (p.id == player.id) continue;
      final hasSlash = p.handCards.any((c) => c.subtype == CardSubtype.slash);
      if (hasSlash) {
        final slash = p.handCards.firstWhere((c) => c.subtype == CardSubtype.slash);
        engine.discardCard(p, slash);
        state.addLog('${p.name} 出【杀】响应南蛮入侵');
      } else {
        engine.dealDamage(player, p, 1);
      }
    }
    return true;
  }

  bool _volley(Player player) {
    // 万箭齐发：所有其他玩家需出闪
    for (final p in state.alivePlayers) {
      if (p.id == player.id) continue;
      if (_hasDodge(p)) {
        final dodge = p.handCards.firstWhere((c) => c.subtype == CardSubtype.dodge,
            orElse: () => p.handCards.first);
        if (dodge.subtype == CardSubtype.dodge) {
          engine.discardCard(p, dodge);
          state.addLog('${p.name} 出【闪】响应万箭齐发');
          continue;
        }
      }
      engine.dealDamage(player, p, 1);
    }
    return true;
  }

  bool _abundant(Player player) {
    // 五谷丰登：展示牌堆顶存活人数张牌，每人选一张
    final alive = state.alivePlayers;
    final revealed = <Card>[];
    for (int i = 0; i < alive.length; i++) {
      if (state.deck.isEmpty) break;
      revealed.add(state.deck.removeLast());
    }
    // 从当前玩家开始轮流选
    int startIdx = alive.indexOf(player);
    for (int i = 0; i < alive.length; i++) {
      final idx = (startIdx + i) % alive.length;
      final p = alive[idx];
      if (revealed.isEmpty) break;
      revealed.shuffle();
      final chosen = revealed.removeLast();
      p.handCards.add(chosen);
      state.addLog('${p.name} 获得 ${chosen.name}');
    }
    // 剩余的弃掉
    for (final c in revealed) {
      state.discardPile.add(c);
    }
    return true;
  }

  bool _happy(Player player, List<Player>? targets) {
    if (targets == null || targets.isEmpty) return false;
    final target = targets.first;
    if (target.general.skills.any((s) => s.name == '谦逊')) {
      state.addLog('${target.name} 【谦逊】不能被乐不思蜀');
      return false;
    }
    if (!target.statusEffects.contains(StatusEffect.happy)) {
      target.statusEffects.add(StatusEffect.happy);
      state.addLog('${target.name} 被乐不思蜀');
    }
    return true;
  }

  bool _playEquipment(Player player, Card card) {
    if (card.equipSlot == null) return false;
    // 替换装备
    final old = player.equipment.remove(card.equipSlot!);
    if (old != null) {
      state.discardPile.add(old);
    }
    player.equipment.equip(card);
    player.handCards.remove(card);
    state.addLog('${player.name} 装备了【${card.name}】');
    return true;
  }

  void _checkSkillsOnKill(Player killer, Player target) {
    // 反馈
    if (target.general.skills.any((s) => s.name == '反馈')) {
      // AI简化
    }
    // 刚烈
    if (target.general.skills.any((s) => s.name == '刚烈')) {
      final card = engine.judge(killer);
      if (!card.isRed) {
        engine.dealDamage(target, killer, 1);
      }
    }
  }
}
