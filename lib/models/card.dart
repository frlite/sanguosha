/// 花色
enum Suit { spade, heart, club, diamond }

/// 卡牌大类
enum CardType { basic, trick, equipment }

/// 卡牌子类
enum CardSubtype {
  // 基本牌
  slash, // 杀
  dodge, // 闪
  peach, // 桃
  // 锦囊
  dismantle, // 过河拆桥
  steal, // 顺手牵羊
  create, // 无中生有
  duel, // 决斗
  savage, // 南蛮入侵
  volley, // 万箭齐发
  peachGarden, // 桃园结义
  abundant, // 五谷丰登
  counter, // 无懈可击
  happy, // 乐不思蜀
  lightning, // 闪电
  // 装备
  crossbow, // 诸葛连弩 (武器)
  blade, // 青龙偃月刀
  spear, // 丈八蛇矛
  sword, // 青釭剑
  eightTrigram, // 八卦阵 (防具)
  renShield, // 仁王盾
  minusHorse, // -1马
  plusHorse, // +1马
}

/// 装备类型
enum EquipSlot { weapon, armor, minusHorse, plusHorse }

/// 卡牌
class Card {
  final int id;
  final String name;
  final Suit suit;
  final int number; // 1-13 (A-K)
  final CardType type;
  final CardSubtype subtype;
  final String description;

  const Card({
    required this.id,
    required this.name,
    required this.suit,
    required this.number,
    required this.type,
    required this.subtype,
    this.description = '',
  });

  String get displayNumber {
    switch (number) {
      case 1: return 'A';
      case 11: return 'J';
      case 12: return 'Q';
      case 13: return 'K';
      default: return '$number';
    }
  }

  String get suitName {
    switch (suit) {
      case Suit.spade: return '♠';
      case Suit.heart: return '♥';
      case Suit.club: return '♣';
      case Suit.diamond: return '♦';
    }
  }

  bool get isRed => suit == Suit.heart || suit == Suit.diamond;

  /// 是否延时类锦囊
  bool get isDelayTrick =>
      subtype == CardSubtype.happy || subtype == CardSubtype.lightning;

  /// 是否可装备
  EquipSlot? get equipSlot {
    switch (subtype) {
      case CardSubtype.crossbow:
      case CardSubtype.blade:
      case CardSubtype.spear:
      case CardSubtype.sword:
        return EquipSlot.weapon;
      case CardSubtype.eightTrigram:
      case CardSubtype.renShield:
        return EquipSlot.armor;
      case CardSubtype.minusHorse:
        return EquipSlot.minusHorse;
      case CardSubtype.plusHorse:
        return EquipSlot.plusHorse;
      default:
        return null;
    }
  }

  /// 攻击范围（武器）
  int get attackRange {
    switch (subtype) {
      case CardSubtype.crossbow: return 1;
      case CardSubtype.blade: return 3;
      case CardSubtype.spear: return 3;
      case CardSubtype.sword: return 2;
      default: return 1;
    }
  }

  /// 是否武器
  bool get isWeapon => equipSlot == EquipSlot.weapon;
}
