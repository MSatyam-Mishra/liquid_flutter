import 'package:flutter/material.dart';
import 'package:liquidx/liquidx.dart' as liquid;

import '../application/feature_catalog_module.dart';
import '../domain/feature_demo.dart';

class LiquidFeatureCatalogApp extends StatefulWidget {
  const LiquidFeatureCatalogApp({super.key});

  @override
  State<LiquidFeatureCatalogApp> createState() => _LiquidFeatureCatalogAppState();
}

class _LiquidFeatureCatalogAppState extends State<LiquidFeatureCatalogApp> {
  late final FeatureCatalogModule module;

  @override
  void initState() {
    super.initState();
    module = FeatureCatalogModule();
  }

  @override
  void dispose() {
    module.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return liquid.LiquidScope(
      tub: module.tub,
      child: liquid.WatchDrop<ThemeMode, ThemeMode>(
        source: module.themeMode,
        select: (ThemeMode mode) => mode,
        builder: (BuildContext context, ThemeMode mode, Widget? child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            themeMode: mode,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
            ),
            darkTheme: ThemeData.dark(useMaterial3: true),
            home: FeatureCatalogScreen(module: module),
          );
        },
      ),
    );
  }
}

class FeatureCatalogScreen extends StatelessWidget {
  const FeatureCatalogScreen({required this.module, super.key});

  final FeatureCatalogModule module;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liquid Feature Catalog'),
        actions: <Widget>[
          IconButton(
            onPressed: module.toggleTheme,
            icon: const Icon(Icons.brightness_6_outlined),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: module.features.length,
        separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 10),
        itemBuilder: (BuildContext context, int index) {
          final FeatureDefinition item = module.features[index];
          return Card(
            child: ListTile(
              title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(item.description),
                  const SizedBox(height: 4),
                  Text(
                    'Where to use: ${item.whereToUse}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => FeatureCounterDemoScreen(module: module, feature: item),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class FeatureCounterDemoScreen extends StatefulWidget {
  const FeatureCounterDemoScreen({
    required this.module,
    required this.feature,
    super.key,
  });

  final FeatureCatalogModule module;
  final FeatureDefinition feature;

  @override
  State<FeatureCounterDemoScreen> createState() => _FeatureCounterDemoScreenState();
}

class _FeatureCounterDemoScreenState extends State<FeatureCounterDemoScreen> {
  late final TextEditingController _searchController;
  late final TextEditingController _editorController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _editorController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _editorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final FeatureCatalogModule module = widget.module;
    final LiquidFeature feature = widget.feature.feature;

    return Scaffold(
      appBar: AppBar(title: Text(widget.feature.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(widget.feature.description),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Where to use: ${widget.feature.whereToUse}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 16),
            _counterHeader(module),
            const SizedBox(height: 20),
            Expanded(child: _featureBody(feature, module)),
          ],
        ),
      ),
    );
  }

  Widget _counterHeader(FeatureCatalogModule module) {
    return liquid.WatchDrop<int, int>(
      source: module.baseCount,
      select: (int value) => value,
      builder: (BuildContext context, int value, Widget? child) {
        return Row(
          children: <Widget>[
            FilledButton.tonal(onPressed: module.decrement, child: const Text('-')),
            const SizedBox(width: 12),
            Text('Counter: $value', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(width: 12),
            FilledButton(onPressed: module.increment, child: const Text('+')),
          ],
        );
      },
    );
  }

  Widget _featureBody(LiquidFeature feature, FeatureCatalogModule module) {
    switch (feature) {
      case LiquidFeature.drop:
      case LiquidFeature.tub:
        return const Text('Use + and - above. This demo is powered by a Drop inside a Tub scope.');
      case LiquidFeature.flow:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            FilledButton.tonal(
              onPressed: module.loadAsyncCounter,
              child: const Text('Load Counter Async'),
            ),
            const SizedBox(height: 12),
            liquid.WatchDrop<liquid.AsyncDropState<int>, liquid.AsyncDropState<int>>(
              source: module.streamCounter,
              select: (liquid.AsyncDropState<int> state) => state,
              builder: (BuildContext context, liquid.AsyncDropState<int> state, Widget? child) {
                if (state is liquid.AsyncLoading<int>) {
                  return const Text('State: loading');
                }
                if (state is liquid.AsyncData<int>) {
                  return Text('State: data -> ${state.value}');
                }
                if (state is liquid.AsyncError<int>) {
                  return Text('State: error -> ${state.error}');
                }
                return const Text('State: idle');
              },
            ),
          ],
        );
      case LiquidFeature.streamDrop:
        return liquid.WatchDrop<int, int>(
          source: module.doubled,
          select: (int value) => value,
          builder: (BuildContext context, int doubled, Widget? child) {
            return liquid.WatchDrop<int, int>(
              source: module.tripled,
              select: (int value) => value,
              builder: (BuildContext context, int tripled, Widget? child) {
                return Text('Flow values -> doubled: $doubled, tripled: $tripled');
              },
            );
          },
        );
      case LiquidFeature.ripple:
        return liquid.WatchDrop<int, int>(
          source: module.rippleCount,
          select: (int value) => value,
          builder: (BuildContext context, int fired, Widget? child) {
            return Text('Ripple fired $fired times from counter changes.');
          },
        );
      case LiquidFeature.nestedState:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                FilledButton.tonal(onPressed: module.incrementNestedParent, child: const Text('Parent +')),
                const SizedBox(width: 10),
                FilledButton.tonal(onPressed: module.incrementNestedChild, child: const Text('Child +')),
              ],
            ),
            const SizedBox(height: 12),
            liquid.WatchDrop<int, int>(
              source: module.nestedTotal,
              select: (int value) => value,
              builder: (BuildContext context, int total, Widget? child) {
                return Text('Nested total counter: $total');
              },
            ),
          ],
        );
      case LiquidFeature.searchState:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _searchController,
              onChanged: module.setSearchQuery,
              decoration: const InputDecoration(
                labelText: 'Search counter values',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            liquid.WatchDrop<List<int>, List<int>>(
              source: module.searchResults,
              select: (List<int> values) => values,
              builder: (BuildContext context, List<int> values, Widget? child) {
                return Text('Matching values: ${values.join(', ')}');
              },
            ),
          ],
        );
      case LiquidFeature.editorState:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _editorController,
              onChanged: module.setEditorText,
              decoration: const InputDecoration(
                labelText: 'Type something',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            liquid.WatchDrop<int, int>(
              source: module.editorCharacterCount,
              select: (int value) => value,
              builder: (BuildContext context, int count, Widget? child) {
                return Text('Editor characters: $count');
              },
            ),
          ],
        );
      case LiquidFeature.folderHierarchyState:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Folder depth'),
            liquid.WatchDrop<int, int>(
              source: module.folderDepthCount,
              select: (int value) => value,
              builder: (BuildContext context, int depth, Widget? child) {
                return Slider(
                  value: depth.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: depth.toString(),
                  onChanged: (double value) => module.setFolderDepth(value.toInt()),
                );
              },
            ),
            liquid.WatchDrop<int, int>(
              source: module.hierarchyTotal,
              select: (int value) => value,
              builder: (BuildContext context, int total, Widget? child) {
                return Text('Hierarchy weighted counter: $total');
              },
            ),
          ],
        );
      case LiquidFeature.themeState:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Theme is state managed by Liquid.'),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: module.toggleTheme,
              child: const Text('Toggle Theme'),
            ),
          ],
        );
    }
  }
}
