import 'card.dart';
import 'general.dart';

/// 游戏阶段
enum GamePhase {
  prepare, // 准备阶段
  judge, // 判定阶段
  draw, // 摸牌阶段
  play, // 出牌阶段
  discard, // 弃牌阶段
  end, // 结束阶段
}

/// 状态效果
enum StatusEffect {
  happy, // 乐不思蜀
  lightning, // 闪电
}

/// 目标选择
class TargetSelection {
  final int count; // 需要选几个目标
  final String reason; // 选择原因
  final bool allowSelf; // 能否选自己
  final List<int> candidates; // 可选玩家ID
  final Card? sourceCard; // 触发选择的卡牌
  final String? skillName; // 触发选择的技能
  final void Function(List<int> targets)? onSelected;

  TargetSelection({
    required this.count,
    required this.reason,
    this.allowSelf = false,
    required this.candidates,
    this.sourceCard,
    this.skillName,
    this.onSelected,
  });
}

/// 玩家
class Player {
  final int id;
  final String name;
  General general;
  Role role;
  int maxHp;
  int currentHp;
  List<Card> handCards;
  EquipmentSet equipment;
  bool isAlive;
  bool isCurrentTurn;
  bool roleRevealed;
  List<StatusEffect> statusEffects;
  int killsUsedThisTurn; // 本回合使用杀的次数
  int cardsDrawnThisTurn;
  int totalDamageDealt;

  Player({
    required this.id,
    required this.name,
    required this.general,
    required this.role,
    this.isAlive = true,
    this.isCurrentTurn = false,
    this.roleRevealed = false,
  })  : maxHp = general.maxHp,
        currentHp = general.maxHp,
        handCards = [],
        equipment = EquipmentSet(),
        statusEffects = [],
        killsUsedThisTurn = 0,
        cardsDrawnThisTurn = 0,
        totalDamageDealt = 0;

  int get distanceModifier => equipment.distanceModifier;

  /// 手牌上限（当前血量）
  int get handLimit => currentHp > 0 ? currentHp : 0;

  /// 是否能使用杀（默认1次，有诸葛连弩则不限）
  bool get canUseKill {
    if (equipment.weapon?.subtype == CardSubtype.crossbow) return true;
    return killsUsedThisTurn < 1;
  }

  /// 是否被乐不思蜀
  bool get isHappy => statusEffects.contains(StatusEffect.happy);

  /// 是否有闪电
  bool get hasLightning => statusEffects.contains(StatusEffect.lightning);
}

/// 游戏结果
class GameResult {
  final Role winnerRole;
  final int winnerPlayerId;
  final String message;

  GameResult({
    required this.winnerRole,
    required this.winnerPlayerId,
    required this.message,
  });
}

/// 游戏状态
class GameState {
  List<Player> players;
  int currentPlayerIndex;
  GamePhase phase;
  List<Card> deck;
  List<Card> discardPile;
  int turnCount;
  bool gameOver;
  GameResult? result;
  String? logMessage;
  List<String> gameLog;
  TargetSelection? pendingTargetSelection;
  bool waitingForPlayerResponse;
  int? respondingPlayerId;
  String? requiredResponseType; // 'dodge', 'counter', etc.
  Card? pendingCard; // 当前正在结算的卡牌
  String? pendingSkill; // 当前正在结算的技能

  GameState({
    required this.players,
    required this.deck,
  })  : currentPlayerIndex = 0,
        phase = GamePhase.prepare,
        discardPile = [],
        turnCount = 0,
        gameOver = false,
        logMessage = '',
        gameLog = [],
        waitingForPlayerResponse = false,
        pendingTargetSelection = null;

  Player get currentPlayer => players[currentPlayerIndex];

  /// 获取存活玩家
  List<Player> get alivePlayers => players.where((p) => p.isAlive).toList();

  /// 计算两名玩家之间的距离
  int distanceBetween(Player a, Player b) {
    final alive = alivePlayers;
    final aIdx = alive.indexOf(a);
    final bIdx = alive.indexOf(b);
    if (aIdx == -1 || bIdx == -1) return 999;

    // 座次距离（环形）
    final n = alive.length;
    final dist = (aIdx - bIdx).abs();
    final roundDist = dist < n - dist ? dist : n - dist;

    // 修正距离
    int mod = roundDist;
    mod += a.distanceModifier; // +1马
    return mod > 0 ? mod : 1;
  }

  /// 是否在攻击范围内
  bool inAttackRange(Player attacker, Player target) {
    final dist = distanceBetween(attacker, target);
    if (dist <= attacker.equipment.attackRange) return true;
    return false;
  }

  void addLog(String msg) {
    logMessage = msg;
    gameLog.add(msg);
  }
}
