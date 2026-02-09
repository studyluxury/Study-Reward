import 'package:flutter/material.dart';
import 'models/app_state.dart';
import 'pages/home_page.dart';
import 'pages/analytics_page.dart';
import 'pages/rewards_page.dart';
import 'services/storage.dart';

class StudyRewardApp extends StatefulWidget {
  const StudyRewardApp({super.key});

  @override
  State<StudyRewardApp> createState() => _StudyRewardAppState();
}

class _StudyRewardAppState extends State<StudyRewardApp> {
  int _index = 0;
  late AppState state;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await Storage.load();
    setState(() {
      state = s ?? AppState.defaults();
      _loaded = true;
    });
  }

  Future<void> _persist() async {
    await Storage.save(state);
  }

  void _setStateAndSave(VoidCallback fn) {
    setState(() {
      fn();
    });
    _persist();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    final pages = [
      HomePage(
        state: state,
        onChanged: _setStateAndSave,
      ),
      AnalyticsPage(
        state: state,
      ),
      RewardsPage(
        state: state,
        onChanged: _setStateAndSave,
      ),
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Study Reward',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5B7CFA)),
        useMaterial3: true,
        fontFamilyFallback: const ["Hiragino Sans", "Noto Sans JP"],
      ),
      home: Scaffold(
        body: pages[_index],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_rounded), label: "Home"),
            NavigationDestination(icon: Icon(Icons.bar_chart_rounded), label: "Analytics"),
            NavigationDestination(icon: Icon(Icons.card_giftcard_rounded), label: "Rewards"),
          ],
        ),
      ),
    );
  }
}
