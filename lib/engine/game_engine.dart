import 'dart:math';
import '../models/card.dart';
import '../models/general.dart';
import '../models/game_state.dart';
import '../data/cards_data.dart';
import '../data/generals_data.dart';
import 'card_effects.dart';
import 'ai_engine.dart';

/// 游戏引擎 - 控制游戏流程
class GameEngine {
  GameState state;
  final Random _random = Random();
  late final CardEffects _effects;

  GameEngine(this.state) {
    _effects = CardEffects(this);
  }

  /// 创建新游戏（4人局）
  static GameEngine create(List<String> playerNames) {
    final deck = createDeck()..shuffle();
    // 选4个武将
    final generals = List<General>.from(allGenerals)..shuffle();
    final selected = generals.take(4).toList();

    // 分配角色
    final roles = [Role.lord, Role.loyalist, Role.rebel, Role.traitor]..shuffle();

    final players = List.generate(4, (i) {
      return Player(
        id: i,
        name: playerNames[i],
        general: selected[i],
        role: roles[i],
      );
    });

    // 主公明身份
    players.firstWhere((p) => p.role == Role.lord).roleRevealed = true;

    final state = GameState(players: players, deck: deck);
    return GameEngine(state);
  }

  /// 开始游戏
  void start() {
    state.addLog('========== 三国杀 ==========');
    state.addLog('游戏开始！');
    for (final p in state.players) {
      state.addLog('${p.name} 身份: ${roleName(p.role)} 武将: ${p.general.name}');
    }
    // 每人摸4张牌
    for (final p in state.players) {
      for (int i = 0; i < 4; i++) {
        drawCard(p);
      }
    }
    // 开始第一个回合
    nextTurn();
  }

  /// 摸牌
  Card? drawCard(Player player) {
    if (state.deck.isEmpty) {
      // 洗弃牌堆
      state.deck = List.from(state.discardPile)..shuffle();
      state.discardPile.clear();
      state.addLog('牌堆已重新洗混');
    }
    if (state.deck.isEmpty) return null;
    final card = state.deck.removeLast();
    player.handCards.add(card);
    return card;
  }

  /// 摸多张牌
  void drawCards(Player player, int count) {
    for (int i = 0; i < count; i++) drawCard(player);
  }

  /// 弃牌
  void discardCard(Player player, Card card) {
    player.handCards.remove(card);
    state.discardPile.add(card);
  }

  /// 判定
  Card judge(Player player) {
    final card = state.deck.removeLast();
    state.discardPile.add(card);
    state.addLog('${player.name} 判定: ${card.suitName}${card.displayNumber} ${card.name}');
    return card;
  }

  /// 造成伤害
  void dealDamage(Player source, Player target, int amount, {Card? card}) {
    target.currentHp -= amount;
    target.totalDamageDealt++;
    state.addLog('${source.name} 对 ${target.name} 造成 $amount 点伤害');
    if (target.currentHp <= 0) {
      target.currentHp = 0;
      _checkDeath(target, source);
    }
  }

  /// 回复体力
  void heal(Player target, int amount) {
    target.currentHp = (target.currentHp + amount).clamp(0, target.maxHp);
    state.addLog('${target.name} 回复 $amount 点体力');
  }

  /// 查验死亡
  void _checkDeath(Player player, Player killer) {
    if (player.currentHp <= 0) {
      player.isAlive = false;
      // 弃掉所有手牌
      for (final card in player.handCards) {
        state.discardPile.add(card);
      }
      player.handCards.clear();
      state.addLog('${player.name} 阵亡！');

      // 判断游戏结束
      _checkGameOver(player, killer);
    }
  }

  /// 判断游戏结束
  void _checkGameOver(Player dead, Player killer) {
    // 反贼死亡：摸三张牌
    if (dead.role == Role.rebel && killer.isAlive) {
      drawCards(killer, 3);
    }

    final alive = state.alivePlayers;
    final roles = alive.map((p) => p.role).toSet();

    // 主公死亡 → 反贼赢（内奸要主公最后死才能赢）
    if (!alive.any((p) => p.role == Role.lord)) {
      final killers = alive.where((p) => p.role == Role.rebel).toList();
      if (killers.isNotEmpty) {
        state.result = GameResult(
          winnerRole: Role.rebel,
          winnerPlayerId: killers.first.id,
          message: '反贼获胜！',
        );
      } else {
        // 内奸单挑主公赢了
        final traitors = alive.where((p) => p.role == Role.traitor).toList();
        if (traitors.isNotEmpty) {
          state.result = GameResult(
            winnerRole: Role.traitor,
            winnerPlayerId: traitors.first.id,
            message: '内奸获胜！',
          );
        }
      }
      state.gameOver = true;
      return;
    }

    // 仅剩主公和忠臣 → 主公忠臣获胜
    if (roles.length == 1 && roles.contains(Role.lord)) {
      state.result = GameResult(
        winnerRole: Role.lord,
        winnerPlayerId: alive.first.id,
        message: '主公与忠臣获胜！',
      );
      state.gameOver = true;
      return;
    }

    // 反贼和内奸全灭 → 主公忠臣获胜
    if (!roles.contains(Role.rebel) && !roles.contains(Role.traitor)) {
      state.result = GameResult(
        winnerRole: Role.lord,
        winnerPlayerId: alive.firstWhere((p) => p.role == Role.lord).id,
        message: '主公与忠臣获胜！',
      );
      state.gameOver = true;
      return;
    }
  }

  /// 下一个回合
  void nextTurn() {
    if (state.gameOver) return;
    state.turnCount++;

    // 找到下一个存活的玩家
    do {
      state.currentPlayerIndex = (state.currentPlayerIndex + 1) % state.players.length;
    } while (!state.currentPlayer.isAlive);

    final p = state.currentPlayer;
    p.isCurrentTurn = true;
    p.killsUsedThisTurn = 0;
    p.cardsDrawnThisTurn = 0;

    state.addLog('\n--- 第 ${state.turnCount} 回合: ${p.name} (${p.general.name}) ---');
    state.phase = GamePhase.prepare;
    _effects.onTurnStart(p);
    state.phase = GamePhase.judge;
    _effects.onJudge(p);

    // 如果被乐不思蜀则跳过摸牌
    if (p.isHappy) {
      state.phase = GamePhase.draw;
      state.addLog('${p.name} 被乐不思蜀，跳过摸牌阶段');
      p.statusEffects.remove(StatusEffect.happy);
      state.phase = GamePhase.play;
      state.phase = GamePhase.discard;
      _doDiscardPhase(p);
      state.phase = GamePhase.end;
      _effects.onTurnEnd(p);
      p.isCurrentTurn = false;
      nextTurn();
      return;
    }

    // 摸牌
    state.phase = GamePhase.draw;
    _effects.onDrawPhase(p);

    // 出牌
    state.phase = GamePhase.play;
  }

  /// 弃牌阶段
  void _doDiscardPhase(Player p) {
    int limit = p.handLimit;
    if (p.handCards.length > limit) {
      state.addLog('${p.name} 需要弃牌至 $limit 张（当前 ${p.handCards.length} 张）');
      // AI 自动弃牌
      if (p.id != 0) {
        final ai = AIEngine(this);
        ai.autoDiscard(p);
      }
      // 玩家手动弃牌（由UI处理）
    }
  }

  /// 玩家使用牌
  bool playCard(Player player, Card card, {List<Player>? targets, Card? extraCard}) {
    if (state.phase != GamePhase.play) return false;
    if (!player.isCurrentTurn) return false;

    // 处理卡牌效果
    return _effects.playCard(player, card, targets: targets, extraCard: extraCard);
  }

  /// 玩家结束出牌阶段
  void endPlayPhase(Player player) {
    if (state.gameOver) return;
    state.phase = GamePhase.discard;
    _doDiscardPhase(player);
    state.phase = GamePhase.end;
    _effects.onTurnEnd(player);
    player.isCurrentTurn = false;
    nextTurn();
  }

  /// 玩家出闪响应
  void playDodge(Player player, Card card) {
    discardCard(player, card);
  }

  /// 是否可以使用杀
  bool canUseSlash(Player player, Player target) {
    if (!player.canUseKill) return false;
    if (player.handCards.any((c) => c.subtype == CardSubtype.slash)) return false;
    // 武圣
    if (player.general.skills.any((s) => s.name == '武圣') &&
        player.handCards.any((c) => c.isRed)) return false;
    // 龙胆
    if (player.general.skills.any((s) => s.name == '龙胆') &&
        player.handCards.any((c) => c.subtype == CardSubtype.dodge)) return false;
    return true;
  }
}
