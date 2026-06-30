import 'package:flutter/material.dart';
import 'engine/game_engine.dart';
import 'widgets/game_board.dart';

void main() {
  runApp(const SanguoshaApp());
}

class SanguoshaApp extends StatelessWidget {
  const SanguoshaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '三国杀',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: Colors.orange[700]!,
          secondary: Colors.red[700]!,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

/// 主菜单
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _nameController = TextEditingController();
  String _playerName = '玩家';

  @override
  void initState() {
    super.initState();
    _nameController.text = _playerName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _startGame() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请输入你的名字')),
      );
      return;
    }
    _playerName = name;

    final engine = GameEngine.create([name, '电脑1', '电脑2', '电脑3']);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameBoard(engine: engine),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1a3a1a),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题
              Icon(Icons.circle, size: 64, color: Colors.orange[700]),
              SizedBox(height: 16),
              Text(
                '三 国 杀',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.yellow[200],
                  letterSpacing: 8,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '标准版 - 离线游戏',
                style: TextStyle(fontSize: 16, color: Colors.grey[400]),
              ),
              SizedBox(height: 48),

              // 模式选择
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      '经典身份局',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '4人局 · 1主1忠1反1内',
                      style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '共25位武将，108张卡牌',
                      style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                    ),
                    SizedBox(height: 24),

                    // 名字输入
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: '你的名字',
                        labelStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(Icons.person, color: Colors.grey[400]),
                      ),
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _startGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[700],
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          '开始游戏',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
