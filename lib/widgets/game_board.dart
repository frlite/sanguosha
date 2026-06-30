import 'dart:async';
import 'package:flutter/material.dart';
import '../models/card.dart' as card_model;
import '../models/game_state.dart';
import '../engine/game_engine.dart';
import '../engine/ai_engine.dart';
import 'card_widget.dart';
import 'player_widget.dart';

/// 主游戏界面
class GameBoard extends StatefulWidget {
  final GameEngine engine;

  const GameBoard({super.key, required this.engine});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  late AIEngine _ai;
  int? _selectedHandIndex;
  List<Player> _selectedTargets = [];
  String? _actionMessage;

  @override
  void initState() {
    super.initState();
    _ai = AIEngine(widget.engine);
    widget.engine.start();
    // 如果当前不是玩家回合，启动 AI 回合
    _checkAITurn();
  }

  void _checkAITurn() {
    final current = widget.engine.state.currentPlayer;
    if (current.id != 0) {
      Future.delayed(Duration(milliseconds: 800), () {
        _runAITurn();
      });
    }
  }

  void _runAITurn() {
    if (widget.engine.state.gameOver) {
      setState(() {});
      return;
    }
    final current = widget.engine.state.currentPlayer;
    if (current.id != 0) {
      _ai.takeTurn(current);
      setState(() {});
      if (!widget.engine.state.gameOver) {
        // 检查下一个是否还是AI
        final next = widget.engine.state.currentPlayer;
        if (next.id != 0) {
          Future.delayed(Duration(milliseconds: 600), () => _runAITurn());
        }
      } else {
        setState(() {});
      }
    }
    setState(() {});
  }

  void _endTurn() {
    if (widget.engine.state.phase != GamePhase.play) return;
    final player = widget.engine.state.players[0];
    widget.engine.endPlayPhase(player);
    setState(() {});
    _checkAITurn();
  }

  void _playSelectedCard() {
    if (_selectedHandIndex == null) return;
    final player = widget.engine.state.players[0];
    if (_selectedHandIndex! >= player.handCards.length) {
      _selectedHandIndex = null;
      setState(() {});
      return;
    }
    final card = player.handCards[_selectedHandIndex!];

    // 桃 - 对自己使用
    if (card.subtype == card_model.CardSubtype.peach && player.currentHp < player.maxHp) {
      widget.engine.playCard(player, card, targets: [player]);
      _selectedHandIndex = null;
      setState(() {});
      return;
    }

    // 装备
    if (card.type == card_model.CardType.equipment) {
      widget.engine.playCard(player, card);
      _selectedHandIndex = null;
      setState(() {});
      return;
    }

    // 无中生有, 桃园结义, 五谷丰登, 闪电(无目标)
    if (card.subtype == card_model.CardSubtype.create ||
        card.subtype == card_model.CardSubtype.peachGarden ||
        card.subtype == card_model.CardSubtype.lightning) {
      widget.engine.playCard(player, card);
      _selectedHandIndex = null;
      setState(() {});
      return;
    }

    // 南蛮入侵, 万箭齐发 (不需要选目标)
    if (card.subtype == card_model.CardSubtype.savage ||
        card.subtype == card_model.CardSubtype.volley) {
      widget.engine.playCard(player, card);
      _selectedHandIndex = null;
      setState(() {});
      return;
    }

    // 清空目标选择
    _selectedTargets.clear();
    _actionMessage = '选择目标...';
    setState(() {});
  }

  void _onPlayerTap(Player target) {
    if (_selectedHandIndex == null) return;

    final player = widget.engine.state.players[0];
    if (target.id == player.id) return;
    if (!target.isAlive) return;

    final card = player.handCards[_selectedHandIndex!];

    // 顺手牵羊 / 过河拆桥
    if (card.subtype == card_model.CardSubtype.steal ||
        card.subtype == card_model.CardSubtype.dismantle) {
      widget.engine.playCard(player, card, targets: [target]);
      _selectedHandIndex = null;
      _actionMessage = null;
      setState(() {});
      return;
    }

    // 决斗
    if (card.subtype == card_model.CardSubtype.duel) {
      widget.engine.playCard(player, card, targets: [target]);
      _selectedHandIndex = null;
      _actionMessage = null;
      setState(() {});
      return;
    }

    // 杀
    if (card.subtype == card_model.CardSubtype.slash) {
      if (!widget.engine.state.inAttackRange(player, target)) {
        _actionMessage = '距离不够！';
        setState(() {});
        return;
      }
      // 武圣转换
      widget.engine.playCard(player, card, targets: [target]);
      _selectedHandIndex = null;
      _actionMessage = null;
      setState(() {});
      return;
    }

    // 乐不思蜀
    if (card.subtype == card_model.CardSubtype.happy) {
      widget.engine.playCard(player, card, targets: [target]);
      _selectedHandIndex = null;
      _actionMessage = null;
      setState(() {});
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.engine.state;
    if (state.gameOver) return _buildGameOver(context);

    final player = state.players[0];
    final isMyTurn = state.currentPlayer.id == 0 && state.phase == GamePhase.play;

    return Scaffold(
      backgroundColor: Color(0xFF1a3a1a),
      appBar: AppBar(
        backgroundColor: Color(0xFF0d260d),
        title: Text(
          '三国杀 - 第 ${state.turnCount} 回合',
          style: TextStyle(fontSize: 16),
        ),
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 游戏状态栏
          _buildStatusBar(context, state, isMyTurn),

          // 对手区域
          Expanded(
            child: _buildOpponents(context, state),
          ),

          // 日志
          _buildLog(state),

          // 手牌
          _buildHandCards(context, player, isMyTurn),

          // 操作按钮
          if (isMyTurn) _buildActions(context, player),
        ],
      ),
    );
  }

  Widget _buildStatusBar(BuildContext context, GameState state, bool isMyTurn) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.black26,
      child: Row(
        children: [
          Text(
            isMyTurn ? '⚔️ 你的回合 - 出牌阶段' : '👀 对方思考中...',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          Spacer(),
          if (_actionMessage != null)
            Text(
              _actionMessage!,
              style: TextStyle(color: Colors.yellow[200], fontSize: 13),
            ),
        ],
      ),
    );
  }

  Widget _buildOpponents(BuildContext context, GameState state) {
    final alive = state.alivePlayers.where((p) => p.id != 0).toList();
    // 重新排序让玩家视角自然
    if (alive.length >= 2) {
      // 换个顺序：上家左，下家右
      final myIdx = state.players.indexOf(state.players[0]);
      alive.sort((a, b) {
        final aDist = (a.id - myIdx).abs();
        final bDist = (b.id - myIdx).abs();
        return aDist.compareTo(bDist);
      });
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: alive.map((p) {
          return PlayerWidget(
            player: p,
            isCurrent: state.currentPlayer.id == p.id,
            isSelected: _selectedTargets.contains(p),
            onTap: () => _onPlayerTap(p),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLog(GameState state) {
    return Container(
      height: 80,
      margin: EdgeInsets.symmetric(horizontal: 8),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView(
        reverse: true,
        children: state.gameLog.reversed.take(5).map((msg) {
          return Text(
            msg,
            style: TextStyle(color: Colors.grey[300], fontSize: 11),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHandCards(BuildContext context, player, bool isMyTurn) {
    return Container(
      height: 140,
      padding: EdgeInsets.symmetric(vertical: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 8),
        itemCount: player.handCards.length,
        itemBuilder: (context, i) {
          final card = player.handCards[i];
          return Padding(
            padding: EdgeInsets.only(right: 4),
            child: CardWidget(
              card: card,
              selected: _selectedHandIndex == i,
              highlighted: isMyTurn && _selectedHandIndex == i,
              onTap: isMyTurn
                  ? () {
                      setState(() {
                        _selectedHandIndex = _selectedHandIndex == i ? null : i;
                        _selectedTargets.clear();
                        _actionMessage = null;
                      });
                    }
                  : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildActions(BuildContext context, player) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: _selectedHandIndex != null ? _playSelectedCard : null,
            icon: Icon(Icons.play_arrow),
            label: Text('使用牌'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[700],
              foregroundColor: Colors.white,
            ),
          ),
          SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: _endTurn,
            icon: Icon(Icons.skip_next),
            label: Text('结束回合'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[700],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameOver(BuildContext context) {
    final result = widget.engine.state.result!;
    return Scaffold(
      backgroundColor: Color(0xFF1a3a1a),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '🏆 游戏结束',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.yellow[200],
              ),
            ),
            SizedBox(height: 24),
            Text(
              result.message,
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
            SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[700],
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text('返回主菜单', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
