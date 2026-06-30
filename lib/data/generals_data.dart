import '../models/general.dart';

/// 标准版 25 武将
final List<General> allGenerals = [
  // ===== 魏 =====
  General(
    name: '曹操',
    title: '魏武帝',
    kingdom: Kingdom.wei,
    maxHp: 4,
    skills: [
      Skill(name: '奸雄', description: '当你受到伤害后，你可以获得造成此伤害的牌。',
          trigger: SkillTrigger.onDamage, type: SkillType.triggered),
      Skill(name: '护驾', description: '当你受到【杀】时，你可令其他魏势力角色打出一张【闪】。',
          trigger: SkillTrigger.onDamage, type: SkillType.active),
    ],
  ),
  General(
    name: '司马懿',
    title: '狼顾之鬼',
    kingdom: Kingdom.wei,
    maxHp: 3,
    skills: [
      Skill(name: '反馈', description: '当你受到伤害后，你可以获得伤害来源的一张牌。',
          trigger: SkillTrigger.onDamage, type: SkillType.triggered),
      Skill(name: '鬼才', description: '当一名角色的判定牌生效前，你可以打出一张手牌代替之。',
          trigger: SkillTrigger.onJudge, type: SkillType.active),
    ],
  ),
  General(
    name: '夏侯惇',
    title: '独眼的罗刹',
    kingdom: Kingdom.wei,
    maxHp: 4,
    skills: [
      Skill(name: '刚烈', description: '当你受到伤害后，你可以令伤害来源进行判定，若结果不为♥，其受到1点伤害。',
          trigger: SkillTrigger.onDamage, type: SkillType.triggered),
    ],
  ),
  General(
    name: '张辽',
    title: '前将军',
    kingdom: Kingdom.wei,
    maxHp: 4,
    skills: [
      Skill(name: '突袭', description: '摸牌阶段，你可以少摸牌并改为获得最多两名其他角色各一张手牌。',
          trigger: SkillTrigger.active, type: SkillType.active),
    ],
  ),
  General(
    name: '许褚',
    title: '虎痴',
    kingdom: Kingdom.wei,
    maxHp: 4,
    skills: [
      Skill(name: '裸衣', description: '出牌阶段，你可以令本回合使用【杀】伤害+1。',
          trigger: SkillTrigger.active, type: SkillType.active),
    ],
  ),
  General(
    name: '郭嘉',
    title: '早夭的天才',
    kingdom: Kingdom.wei,
    maxHp: 3,
    skills: [
      Skill(name: '天妒', description: '当你的判定牌生效后，你可以获得此牌。',
          trigger: SkillTrigger.onJudge, type: SkillType.triggered),
      Skill(name: '遗计', description: '当你受到1点伤害后，你可以摸两张牌。',
          trigger: SkillTrigger.onDamage, type: SkillType.triggered),
    ],
  ),
  General(
    name: '甄姬',
    title: '薄幸的美人',
    kingdom: Kingdom.wei,
    maxHp: 3,
    skills: [
      Skill(name: '倾国', description: '你可以将一张黑色手牌当【闪】使用或打出。',
          trigger: SkillTrigger.active, type: SkillType.active),
      Skill(name: '洛神', description: '准备阶段，你可以进行判定，若结果为黑色，你可以获得此牌并重复此流程。',
          trigger: SkillTrigger.active, type: SkillType.active),
    ],
  ),

  // ===== 蜀 =====
  General(
    name: '刘备',
    title: '仁德圣君',
    kingdom: Kingdom.shu,
    maxHp: 4,
    skills: [
      Skill(name: '仁德', description: '出牌阶段，你可以将任意张手牌交给其他角色，然后你于此阶段不能再如此做。',
          trigger: SkillTrigger.active, type: SkillType.active),
    ],
  ),
  General(
    name: '关羽',
    title: '美髯公',
    kingdom: Kingdom.shu,
    maxHp: 4,
    skills: [
      Skill(name: '武圣', description: '你可以将一张红色牌当【杀】使用或打出。',
          trigger: SkillTrigger.active, type: SkillType.active),
    ],
  ),
  General(
    name: '张飞',
    title: '万夫不当',
    kingdom: Kingdom.shu,
    maxHp: 4,
    skills: [
      Skill(name: '咆哮', description: '你于出牌阶段内使用【杀】无次数限制。',
          trigger: SkillTrigger.passive, type: SkillType.passive),
    ],
  ),
  General(
    name: '诸葛亮',
    title: '迟暮的军师',
    kingdom: Kingdom.shu,
    maxHp: 3,
    skills: [
      Skill(name: '观星', description: '准备阶段，你可以观看牌堆顶五张牌并任意调整顺序。',
          trigger: SkillTrigger.active, type: SkillType.active),
      Skill(name: '空城', description: '锁定技，若你没有手牌，则你不能成为【杀】或【决斗】的目标。',
          trigger: SkillTrigger.passive, type: SkillType.passive),
    ],
  ),
  General(
    name: '赵云',
    title: '少年将军',
    kingdom: Kingdom.shu,
    maxHp: 4,
    skills: [
      Skill(name: '龙胆', description: '你可以将【杀】当【闪】、【闪】当【杀】使用或打出。',
          trigger: SkillTrigger.active, type: SkillType.active),
    ],
  ),
  General(
    name: '马超',
    title: '一骑当千',
    kingdom: Kingdom.shu,
    maxHp: 4,
    skills: [
      Skill(name: '铁骑', description: '当你使用【杀】指定一名目标后，你可令其进行判定，若结果为红色，此【杀】不可被【闪】响应。',
          trigger: SkillTrigger.active, type: SkillType.active),
    ],
  ),
  General(
    name: '黄月英',
    title: '不详',
    kingdom: Kingdom.shu,
    maxHp: 3,
    skills: [
      Skill(name: '集智', description: '当你使用一张非延时锦囊时，你可以摸一张牌。',
          trigger: SkillTrigger.triggered, type: SkillType.triggered),
    ],
  ),

  // ===== 吴 =====
  General(
    name: '孙权',
    title: '年轻的贤君',
    kingdom: Kingdom.wu,
    maxHp: 4,
    skills: [
      Skill(name: '制衡', description: '出牌阶段，你可以弃置任意张牌并摸等量的牌。',
          trigger: SkillTrigger.active, type: SkillType.active),
    ],
  ),
  General(
    name: '甘宁',
    title: '锦帆游侠',
    kingdom: Kingdom.wu,
    maxHp: 4,
    skills: [
      Skill(name: '奇袭', description: '你可以将一张黑色牌当【过河拆桥】使用。',
          trigger: SkillTrigger.active, type: SkillType.active),
    ],
  ),
  General(
    name: '吕蒙',
    title: '白衣渡江',
    kingdom: Kingdom.wu,
    maxHp: 4,
    skills: [
      Skill(name: '克己', description: '若你于出牌阶段未使用或打出【杀】，则你可以跳过弃牌阶段。',
          trigger: SkillTrigger.passive, type: SkillType.passive),
    ],
  ),
  General(
    name: '黄盖',
    title: '轻身为国',
    kingdom: Kingdom.wu,
    maxHp: 4,
    skills: [
      Skill(name: '苦肉', description: '出牌阶段，你可以失去1点体力，然后摸两张牌。',
          trigger: SkillTrigger.active, type: SkillType.active),
    ],
  ),
  General(
    name: '周瑜',
    title: '大都督',
    kingdom: Kingdom.wu,
    maxHp: 3,
    skills: [
      Skill(name: '英姿', description: '摸牌阶段，你可以多摸一张牌。',
          trigger: SkillTrigger.passive, type: SkillType.passive),
      Skill(name: '反间', description: '出牌阶段，你可以令一名其他角色选择一种花色后获得你一张手牌并展示之，若此牌与所选花色不同，其受到1点伤害。',
          trigger: SkillTrigger.active, type: SkillType.active),
    ],
  ),
  General(
    name: '大乔',
    title: '矜持之花',
    kingdom: Kingdom.wu,
    maxHp: 3,
    skills: [
      Skill(name: '国色', description: '你可以将一张方块牌当【乐不思蜀】使用。',
          trigger: SkillTrigger.active, type: SkillType.active),
      Skill(name: '流离', description: '当你成为【杀】的目标时，你可以将此【杀】转移给另一名其他角色。',
          trigger: SkillTrigger.active, type: SkillType.active),
    ],
  ),
  General(
    name: '陆逊',
    title: '儒生雄才',
    kingdom: Kingdom.wu,
    maxHp: 3,
    skills: [
      Skill(name: '谦逊', description: '你不能成为【乐不思蜀】和【顺手牵羊】的目标。',
          trigger: SkillTrigger.passive, type: SkillType.passive),
      Skill(name: '连营', description: '当你失去最后一张手牌时，你可以摸一张牌。',
          trigger: SkillTrigger.triggered, type: SkillType.triggered),
    ],
  ),
  General(
    name: '孙尚香',
    title: '弓腰姬',
    kingdom: Kingdom.wu,
    maxHp: 3,
    skills: [
      Skill(name: '结姻', description: '出牌阶段，你可以弃置两张手牌并选择一名已受伤的男性角色，你与其各回复1点体力。',
          trigger: SkillTrigger.active, type: SkillType.active),
      Skill(name: '枭姬', description: '当你失去装备区一张牌时，你可以摸两张牌。',
          trigger: SkillTrigger.triggered, type: SkillType.triggered),
    ],
  ),

  // ===== 群 =====
  General(
    name: '华佗',
    title: '神医',
    kingdom: Kingdom.other,
    maxHp: 3,
    skills: [
      Skill(name: '青囊', description: '出牌阶段，你可以弃置一张手牌并令一名角色回复1点体力。',
          trigger: SkillTrigger.active, type: SkillType.active),
      Skill(name: '急救', description: '你的回合外，你可以将一张红色牌当【桃】使用。',
          trigger: SkillTrigger.active, type: SkillType.active),
    ],
  ),
  General(
    name: '吕布',
    title: '武的化身',
    kingdom: Kingdom.other,
    maxHp: 4,
    skills: [
      Skill(name: '无双', description: '锁定技，你使用【杀】时，目标角色需连续使用两张【闪】才能抵消。',
          trigger: SkillTrigger.passive, type: SkillType.passive),
    ],
  ),
  General(
    name: '貂蝉',
    title: '绝世的舞姬',
    kingdom: Kingdom.other,
    maxHp: 3,
    skills: [
      Skill(name: '离间', description: '出牌阶段，你可以弃置一张牌并令两名男性角色决斗。',
          trigger: SkillTrigger.active, type: SkillType.active),
      Skill(name: '闭月', description: '结束阶段，你可以摸一张牌。',
          trigger: SkillTrigger.active, type: SkillType.active),
    ],
  ),
];
