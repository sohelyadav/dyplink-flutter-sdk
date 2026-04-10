// Dyplink Flutter SDK — example app.
//
// Demonstrates:
//   * Dyplink.init() with a DyplinkConfig
//   * identify() with user traits
//   * track() custom events
//   * trackConversion() attribution
//   * matchDeferredDeepLink() for first-launch attribution
//   * Stream<DeepLinkResult> subscription
//   * DyplinkBannerCarousel PlatformView widget
//   * DyplinkPush token registration
//   * DyplinkMessages trigger points and event stream

import 'dart:async';
import 'dart:io' show Platform;

import 'package:dyplink/dyplink.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const DyplinkExampleApp());
}

class DyplinkExampleApp extends StatelessWidget {
  const DyplinkExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dyplink Example',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver {
  final _logs = <String>[];
  StreamSubscription<DeepLinkResult>? _deepLinkSub;
  StreamSubscription<MessageEvent>? _messageSub;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initDyplink();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _deepLinkSub?.cancel();
    _messageSub?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _initialized) {
      // Poll for "on_app_open" messages whenever the app foregrounds.
      DyplinkMessages.instance.onAppOpen().ignore();
    }
  }

  Future<void> _initDyplink() async {
    if (!Platform.isAndroid) {
      _log('iOS support is not yet available — Dyplink stubs all calls.');
      return;
    }

    // Replace with your real credentials from the Dyplink dashboard.
    final config = DyplinkConfig.builder(
      baseUrl: 'https://api.dyplink.com',
      apiKey: 'YOUR_API_KEY',
      projectId: 'YOUR_PROJECT_ID',
    )
        .logLevel(DyplinkLogLevel.debug)
        .flushInterval(const Duration(seconds: 30))
        .deepLinkHosts(const ['example.dyplink.com', 'links.example.com'])
        .customScheme('dyplinkexample')
        .build();

    try {
      await Dyplink.instance.init(config);
      _log('Dyplink initialized');

      // Listen for deep links (both direct and deferred). The native listener
      // is attached here and detached when this widget disposes.
      _deepLinkSub = Dyplink.instance.deepLinks.listen(
        (link) => _log('deep link: ${link.url} deferred=${link.isDeferred}'),
        onError: (Object e) => _log('deep link error: $e'),
      );

      // Push (optional)
      await DyplinkPush.instance.init();
      _log('Push initialized, registered=${await DyplinkPush.instance.isRegistered}');

      // In-app messages — subscribe to interaction events.
      _messageSub = DyplinkMessages.instance.events.listen(
        (event) => _log('message event: ${event.runtimeType}'),
      );

      // Attempt a deferred deep link match (only meaningful on first launch
      // after a fresh install).
      final deferred = await Dyplink.instance.matchDeferredDeepLink();
      _log('deferred match: matched=${deferred.matched} code=${deferred.shortCode ?? "-"}');

      if (mounted) setState(() => _initialized = true);
    } on DyplinkError catch (e) {
      _log('init failed: $e');
    } catch (e) {
      _log('init exception: $e');
    }
  }

  Future<void> _identify() async {
    try {
      final params = IdentifyParams.builder()
          .externalUserId('user-123')
          .firstName('Jane')
          .lastName('Doe')
          .phone('+15551234567')
          .emailOptIn(true)
          .traits(const {'plan': 'pro', 'age': 34})
          .build();
      final result = await Dyplink.instance.identify(params);
      _log('identified: ${result.id} fp=${result.deviceFingerprint}');
    } on DyplinkError catch (e) {
      _log('identify failed: $e');
    }
  }

  Future<void> _trackEvent() async {
    await Dyplink.instance.track(
      'button_click',
      properties: const {'button_id': 'hello', 'screen': 'home'},
    );
    _log('tracked event: button_click');
  }

  Future<void> _trackRevenue() async {
    await Dyplink.instance.trackRevenue(9.99);
    _log('tracked revenue: 9.99 USD');
  }

  Future<void> _resetIdentity() async {
    await Dyplink.instance.reset();
    _log('identity reset');
  }

  Future<void> _flushNow() async {
    try {
      await Dyplink.instance.flush();
      _log('flushed');
    } on DyplinkError catch (e) {
      _log('flush failed: $e');
    }
  }

  void _log(String message) {
    if (!mounted) return;
    setState(() {
      _logs.insert(0, message);
      if (_logs.length > 100) _logs.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dyplink Example')),
      body: Column(
        children: [
          // Banner carousel — embeds the native BannerCarouselView.
          if (_initialized)
            const SizedBox(
              height: 160,
              child: DyplinkBannerCarousel(categoryId: 'home-top'),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(onPressed: _identify, child: const Text('Identify')),
                FilledButton(onPressed: _trackEvent, child: const Text('Track event')),
                FilledButton(onPressed: _trackRevenue, child: const Text('Track revenue')),
                FilledButton(onPressed: _flushNow, child: const Text('Flush')),
                FilledButton(onPressed: _resetIdentity, child: const Text('Reset')),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _logs.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(_logs[i], style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
