import 'card.dart';

/// 势力
enum Kingdom { wei, shu, wu, other }

String kingdomName(Kingdom k) {
  switch (k) {
    case Kingdom.wei: return '魏';
    case Kingdom.shu: return '蜀';
    case Kingdom.wu: return '吴';
    case Kingdom.other: return '群';
  }
}

/// 身份
enum Role { lord, loyalist, rebel, traitor }

String roleName(Role r) {
  switch (r) {
    case Role.lord: return '主公';
    case Role.loyalist: return '忠臣';
    case Role.rebel: return '反贼';
    case Role.traitor: return '内奸';
  }
}

/// 技能
class Skill {
  final String name;
  final String description;
  final SkillTrigger trigger;
  final SkillType type;

  const Skill({
    required this.name,
    required this.description,
    required this.trigger,
    this.type = SkillType.active,
  });
}

enum SkillTrigger {
  passive, // 锁定技，自动触发
  active, // 主动技能，出牌阶段使用
  triggered, // 触发技，条件触发
  onDamage, // 受到伤害时
  onDealDamage, // 造成伤害时
  onDeath, // 有人死亡时
  onJudge, // 判定时
  onDiscard, // 弃牌时
  onDraw, // 摸牌时
}

enum SkillType { active, passive, triggered }

/// 武将
class General {
  final String name;
  final String title; // 称号
  final Kingdom kingdom;
  final int maxHp;
  final List<Skill> skills;

  const General({
    required this.name,
    required this.title,
    required this.kingdom,
    required this.maxHp,
    required this.skills,
  });
}

/// 装备区
class EquipmentSet {
  Card? weapon;
  Card? armor;
  Card? minusHorse;
  Card? plusHorse;

  bool get hasWeapon => weapon != null;
  bool get hasArmor => armor != null;

  /// 攻击范围（默认1，有武器则取武器范围）
  int get attackRange {
    if (weapon != null) return weapon!.attackRange;
    return 1;
  }

  /// 距离修正
  int get distanceModifier {
    int mod = 0;
    if (minusHorse != null) mod--;
    if (plusHorse != null) mod++;
    return mod;
  }

  void equip(Card card) {
    switch (card.equipSlot) {
      case EquipSlot.weapon:
        weapon = card;
        break;
      case EquipSlot.armor:
        armor = card;
        break;
      case EquipSlot.minusHorse:
        minusHorse = card;
        break;
      case EquipSlot.plusHorse:
        plusHorse = card;
        break;
      default:
        break;
    }
  }

  Card? remove(EquipSlot slot) {
    Card? old;
    switch (slot) {
      case EquipSlot.weapon:
        old = weapon;
        weapon = null;
        break;
      case EquipSlot.armor:
        old = armor;
        armor = null;
        break;
      case EquipSlot.minusHorse:
        old = minusHorse;
        minusHorse = null;
        break;
      case EquipSlot.plusHorse:
        old = plusHorse;
        plusHorse = null;
        break;
    }
    return old;
  }

  List<Card> getAll() {
    return [weapon, armor, minusHorse, plusHorse]
        .where((c) => c != null)
        .cast<Card>()
        .toList();
  }
}
