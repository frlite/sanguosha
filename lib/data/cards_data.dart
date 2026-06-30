import '../models/card.dart';

/// 标准版 108 张牌
List<Card> createDeck() {
  int id = 0;
  final cards = <Card>[];

  void c(String name, Suit suit, int number, CardType type, CardSubtype sub, [String desc = '']) {
    cards.add(Card(id: id++, name: name, suit: suit, number: number,
        type: type, subtype: sub, description: desc));
  }

  // ===== 基本牌 =====
  // 杀 30张
  c('杀', Suit.spade, 7, CardType.basic, CardSubtype.slash);
  c('杀', Suit.spade, 8, CardType.basic, CardSubtype.slash);
  c('杀', Suit.spade, 8, CardType.basic, CardSubtype.slash);
  c('杀', Suit.spade, 9, CardType.basic, CardSubtype.slash);
  c('杀', Suit.spade, 9, CardType.basic, CardSubtype.slash);
  c('杀', Suit.spade, 10, CardType.basic, CardSubtype.slash);
  c('杀', Suit.spade, 10, CardType.basic, CardSubtype.slash);
  c('杀', Suit.spade, 11, CardType.basic, CardSubtype.slash);
  c('杀', Suit.spade, 11, CardType.basic, CardSubtype.slash);
  c('杀', Suit.spade, 12, CardType.basic, CardSubtype.slash);
  c('杀', Suit.spade, 12, CardType.basic, CardSubtype.slash);
  c('杀', Suit.club, 2, CardType.basic, CardSubtype.slash);
  c('杀', Suit.club, 3, CardType.basic, CardSubtype.slash);
  c('杀', Suit.club, 4, CardType.basic, CardSubtype.slash);
  c('杀', Suit.club, 5, CardType.basic, CardSubtype.slash);
  c('杀', Suit.club, 6, CardType.basic, CardSubtype.slash);
  c('杀', Suit.club, 7, CardType.basic, CardSubtype.slash);
  c('杀', Suit.club, 8, CardType.basic, CardSubtype.slash);
  c('杀', Suit.club, 9, CardType.basic, CardSubtype.slash);
  c('杀', Suit.club, 10, CardType.basic, CardSubtype.slash);
  c('杀', Suit.club, 11, CardType.basic, CardSubtype.slash);
  c('杀', Suit.club, 11, CardType.basic, CardSubtype.slash);
  c('杀', Suit.club, 12, CardType.basic, CardSubtype.slash);
  c('杀', Suit.club, 12, CardType.basic, CardSubtype.slash);
  c('杀', Suit.heart, 10, CardType.basic, CardSubtype.slash);
  c('杀', Suit.heart, 11, CardType.basic, CardSubtype.slash);
  c('杀', Suit.diamond, 6, CardType.basic, CardSubtype.slash);
  c('杀', Suit.diamond, 7, CardType.basic, CardSubtype.slash);
  c('杀', Suit.diamond, 8, CardType.basic, CardSubtype.slash);
  c('杀', Suit.diamond, 9, CardType.basic, CardSubtype.slash);

  // 闪 15张
  c('闪', Suit.heart, 2, CardType.basic, CardSubtype.dodge);
  c('闪', Suit.heart, 2, CardType.basic, CardSubtype.dodge);
  c('闪', Suit.heart, 3, CardType.basic, CardSubtype.dodge);
  c('闪', Suit.heart, 4, CardType.basic, CardSubtype.dodge);
  c('闪', Suit.heart, 5, CardType.basic, CardSubtype.dodge);
  c('闪', Suit.heart, 6, CardType.basic, CardSubtype.dodge);
  c('闪', Suit.heart, 7, CardType.basic, CardSubtype.dodge);
  c('闪', Suit.heart, 8, CardType.basic, CardSubtype.dodge);
  c('闪', Suit.heart, 9, CardType.basic, CardSubtype.dodge);
  c('闪', Suit.heart, 10, CardType.basic, CardSubtype.dodge);
  c('闪', Suit.heart, 11, CardType.basic, CardSubtype.dodge);
  c('闪', Suit.heart, 12, CardType.basic, CardSubtype.dodge);
  c('闪', Suit.diamond, 2, CardType.basic, CardSubtype.dodge);
  c('闪', Suit.diamond, 3, CardType.basic, CardSubtype.dodge);
  c('闪', Suit.diamond, 4, CardType.basic, CardSubtype.dodge);
  c('闪', Suit.diamond, 5, CardType.basic, CardSubtype.dodge);
  c('闪', Suit.diamond, 6, CardType.basic, CardSubtype.dodge);
  c('闪', Suit.diamond, 7, CardType.basic, CardSubtype.dodge);

  // 桃 8张
  c('桃', Suit.heart, 3, CardType.basic, CardSubtype.peach);
  c('桃', Suit.heart, 4, CardType.basic, CardSubtype.peach);
  c('桃', Suit.heart, 6, CardType.basic, CardSubtype.peach);
  c('桃', Suit.heart, 7, CardType.basic, CardSubtype.peach);
  c('桃', Suit.heart, 8, CardType.basic, CardSubtype.peach);
  c('桃', Suit.heart, 9, CardType.basic, CardSubtype.peach);
  c('桃', Suit.heart, 12, CardType.basic, CardSubtype.peach);
  c('桃', Suit.diamond, 12, CardType.basic, CardSubtype.peach);

  // ===== 锦囊 =====
  // 过河拆桥 6张
  c('过河拆桥', Suit.spade, 3, CardType.trick, CardSubtype.dismantle);
  c('过河拆桥', Suit.spade, 4, CardType.trick, CardSubtype.dismantle);
  c('过河拆桥', Suit.spade, 12, CardType.trick, CardSubtype.dismantle);
  c('过河拆桥', Suit.club, 3, CardType.trick, CardSubtype.dismantle);
  c('过河拆桥', Suit.club, 4, CardType.trick, CardSubtype.dismantle);
  c('过河拆桥', Suit.heart, 12, CardType.trick, CardSubtype.dismantle);

  // 顺手牵羊 5张
  c('顺手牵羊', Suit.spade, 3, CardType.trick, CardSubtype.steal);
  c('顺手牵羊', Suit.spade, 4, CardType.trick, CardSubtype.steal);
  c('顺手牵羊', Suit.spade, 11, CardType.trick, CardSubtype.steal);
  c('顺手牵羊', Suit.diamond, 3, CardType.trick, CardSubtype.steal);
  c('顺手牵羊', Suit.diamond, 4, CardType.trick, CardSubtype.steal);

  // 无中生有 4张
  c('无中生有', Suit.heart, 7, CardType.trick, CardSubtype.create);
  c('无中生有', Suit.heart, 8, CardType.trick, CardSubtype.create);
  c('无中生有', Suit.heart, 9, CardType.trick, CardSubtype.create);
  c('无中生有', Suit.heart, 11, CardType.trick, CardSubtype.create);

  // 决斗 3张
  c('决斗', Suit.spade, 1, CardType.trick, CardSubtype.duel);
  c('决斗', Suit.club, 1, CardType.trick, CardSubtype.duel);
  c('决斗', Suit.diamond, 1, CardType.trick, CardSubtype.duel);

  // 南蛮入侵 3张
  c('南蛮入侵', Suit.spade, 7, CardType.trick, CardSubtype.savage);
  c('南蛮入侵', Suit.spade, 13, CardType.trick, CardSubtype.savage);
  c('南蛮入侵', Suit.club, 7, CardType.trick, CardSubtype.savage);

  // 万箭齐发 1张
  c('万箭齐发', Suit.heart, 1, CardType.trick, CardSubtype.volley);

  // 桃园结义 1张
  c('桃园结义', Suit.heart, 1, CardType.trick, CardSubtype.peachGarden);

  // 五谷丰登 2张
  c('五谷丰登', Suit.heart, 3, CardType.trick, CardSubtype.abundant);
  c('五谷丰登', Suit.club, 3, CardType.trick, CardSubtype.abundant);

  // 无懈可击 3张
  c('无懈可击', Suit.club, 13, CardType.trick, CardSubtype.counter);
  c('无懈可击', Suit.club, 1, CardType.trick, CardSubtype.counter);
  c('无懈可击', Suit.diamond, 13, CardType.trick, CardSubtype.counter);

  // 乐不思蜀 3张
  c('乐不思蜀', Suit.spade, 6, CardType.trick, CardSubtype.happy);
  c('乐不思蜀', Suit.club, 6, CardType.trick, CardSubtype.happy);
  c('乐不思蜀', Suit.heart, 6, CardType.trick, CardSubtype.happy);

  // 闪电 1张
  c('闪电', Suit.spade, 1, CardType.trick, CardSubtype.lightning);

  // ===== 装备 =====
  // 诸葛连弩 2张
  c('诸葛连弩', Suit.spade, 1, CardType.equipment, CardSubtype.crossbow, '攻击范围1，出牌阶段可出任意张【杀】');
  c('诸葛连弩', Suit.club, 1, CardType.equipment, CardSubtype.crossbow, '攻击范围1，出牌阶段可出任意张【杀】');

  // 青龙偃月刀 2张
  c('青龙偃月刀', Suit.spade, 5, CardType.equipment, CardSubtype.blade, '攻击范围3');
  c('青龙偃月刀', Suit.club, 5, CardType.equipment, CardSubtype.blade, '攻击范围3');

  // 丈八蛇矛 1张
  c('丈八蛇矛', Suit.spade, 12, CardType.equipment, CardSubtype.spear, '攻击范围3');

  // 青釭剑 1张
  c('青釭剑', Suit.spade, 6, CardType.equipment, CardSubtype.sword, '攻击范围2，无视防具');

  // 八卦阵 2张
  c('八卦阵', Suit.spade, 2, CardType.equipment, CardSubtype.eightTrigram, '当你需要出【闪】时，可判定，红色视为出【闪】');
  c('八卦阵', Suit.club, 2, CardType.equipment, CardSubtype.eightTrigram, '');

  // 仁王盾 1张
  c('仁王盾', Suit.club, 2, CardType.equipment, CardSubtype.renShield, '黑色【杀】对你无效');

  // +1马 3张
  c('骅骝', Suit.spade, 5, CardType.equipment, CardSubtype.plusHorse, '其他角色距你距离+1');
  c('骅骝', Suit.club, 5, CardType.equipment, CardSubtype.plusHorse, '');
  c('骅骝', Suit.heart, 13, CardType.equipment, CardSubtype.plusHorse, '');

  // -1马 3张
  c('赤兔', Suit.heart, 5, CardType.equipment, CardSubtype.minusHorse, '你距其他角色距离-1');
  c('赤兔', Suit.diamond, 13, CardType.equipment, CardSubtype.minusHorse, '');
  c('赤兔', Suit.club, 5, CardType.equipment, CardSubtype.minusHorse, '');

  return cards;
}
