// DISTINCT ROLLOUT V2 — wobblewheelie: "Top-left grid"
// Layout template from distinct-samples/laserlimbo.
import 'package:flutter/material.dart';
import '../theme/arcade_config.dart';
import '../engine/arcade_engine.dart';
import '../services/settings_service.dart';
import '../services/sound_service.dart';
import 'game_screen.dart';
import 'settings_screen.dart';
import 'support_screen.dart';

const List<String> _emojiFb = ['Noto Color Emoji'];

class MenuScreen extends StatefulWidget {
  final ArcadeConfig config;
  const MenuScreen({super.key, required this.config});
  @override State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int highScore = 0;
  String playerName = 'Player 1';

  @override void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final svc = SettingsService('${widget.config.slug}_');
    final h = await svc.getHighScore();
    final n = await svc.getPlayerName();
    if (mounted) setState(() { highScore = h; playerName = n; });
  }

  void _play() async {
    final svc = SettingsService('${widget.config.slug}_');
    final diff = await svc.getDifficulty();
    final shape = await svc.getShape();
    final mul = [0.8, 1.0, 1.3][diff.clamp(0, 2)];
    final sound = SoundService('${widget.config.slug}_');
    await sound.load();
    await sound.click();
    if (!mounted) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => GameScreen(
      config: widget.config,
      engine: ArcadeEngine(cfg: widget.config, diffMul: mul),
      sound: sound,
      shape: shape,
    ))).then((_) => _load());
  }

  @override Widget build(BuildContext context) {
    final c = widget.config;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [c.darkColor, c.primaryColor.withOpacity(0.45)])),
        child: SafeArea(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(c.playerEmoji,
                style: const TextStyle(fontSize: 48, fontFamilyFallback: _emojiFb)),
            const SizedBox(height: 12),
            Text(c.displayName.toUpperCase(), textAlign: TextAlign.left,
              style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: 0.5, fontFamilyFallback: _emojiFb)),
            const SizedBox(height: 6),
            Text(c.tagline, textAlign: TextAlign.left,
              style: const TextStyle(color: Colors.white70, fontSize: 14, fontFamilyFallback: _emojiFb)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white10,
                border: Border(left: BorderSide(color: c.accentColor, width: 4)),
              ),
              child: Text('🏆 $playerName — Best: $highScore',
                  style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontFamilyFallback: _emojiFb)),
            ),
            const SizedBox(height: 28),
            Row(children: [
              Expanded(child: _gridBtn('▶  PLAY', c.accentColor, Colors.black, _play)),
              const SizedBox(width: 12),
              Expanded(child: _gridBtn('❓  HOW TO PLAY', Colors.white12, Colors.white,
                  () => _howTo(context, c))),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _gridBtn('⚙️  SETTINGS', Colors.white12, Colors.white, () {
                Navigator.push(context, MaterialPageRoute(
                    builder: (_) => SettingsScreen(config: c))).then((_) => _load());
              })),
              const SizedBox(width: 12),
              Expanded(child: _gridBtn('💛  SUPPORT', Colors.white12, Colors.white, () {
                Navigator.push(context, MaterialPageRoute(
                    builder: (_) => SupportScreen(config: c)));
              })),
            ]),
            const SizedBox(height: 36),
            const Text('Credits: WAJIHA', style: TextStyle(color: Colors.white38, fontSize: 12, fontFamilyFallback: _emojiFb)),
          ])))),
      );
  }

  void _howTo(BuildContext ctx, ArcadeConfig c) {
    showDialog(context: ctx, builder: (_) => AlertDialog(
      backgroundColor: c.darkColor,
      title: Text(c.displayName, style: const TextStyle(color: Colors.white, fontFamilyFallback: _emojiFb)),
      content: Text(c.howTo, style: const TextStyle(color: Colors.white70, fontFamilyFallback: _emojiFb)),
      actions: [TextButton(
        onPressed: () => Navigator.pop(ctx),
        child: Text('GOT IT', style: TextStyle(color: c.accentColor, fontFamilyFallback: _emojiFb)))],
    ));
  }

  Widget _gridBtn(String label, Color bg, Color fg, VoidCallback onTap) =>
    SizedBox(height: 118, child: ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: bg, foregroundColor: fg,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        side: BorderSide(color: widget.config.accentColor.withOpacity(0.6), width: 1),
        shape: const BeveledRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
      onPressed: onTap,
      child: Text(label, textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamilyFallback: _emojiFb))));
}
