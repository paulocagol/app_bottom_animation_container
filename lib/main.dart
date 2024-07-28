import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app_bottom_container.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: !kReleaseMode, // Ativar o DevicePreview apenas no modo debug
      builder: (context) => const _SafariApp(),
    ),
  );
}

class _SafariApp extends StatelessWidget {
  const _SafariApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: DevicePreview.appBuilder, // Adiciona o DevicePreview.appBuilder
      useInheritedMediaQuery: true, // Garante que o DevicePreview use a mídia herdada
      locale: DevicePreview.locale(context), // Adiciona suporte à localidade
      debugShowCheckedModeBanner: false,
      home: const AppBottomContainer(
        child: Home(),
      ),
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bottom Sheet Example'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                AppBottomContainer.of(context).max();
              },
              child: const Text('Max Bottom Sheet'),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: () {
                AppBottomContainer.of(context).show();
              },
              child: const Text('Show Bottom Sheet'),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: () {
                AppBottomContainer.of(context).hide();
              },
              child: const Text('Hide Bottom Sheet'),
            ),
          ),
        ],
      ),
    );
  }
}
