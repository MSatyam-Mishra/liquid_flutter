import 'package:flutter/material.dart';
import 'package:liquidx/liquidx.dart' as liquid;

import '../domain/feature_demo.dart';

class FeatureCatalogModule {
  FeatureCatalogModule()
      : tub = liquid.Tub(label: 'feature_catalog'),
        themeMode = liquid.Drop<ThemeMode>(ThemeMode.light, label: 'theme_mode'),
        nestedParentCount = liquid.Drop<int>(0, label: 'nested_parent_count'),
        nestedChildCount = liquid.Drop<int>(0, label: 'nested_child_count'),
        searchQuery = liquid.Drop<String>('', label: 'search_query'),
        folderDepthCount = liquid.Drop<int>(1, label: 'folder_depth_count'),
        editorCharacterCount = liquid.Drop<int>(0, label: 'editor_char_count'),
        streamCounter = liquid.Flow<int>(label: 'stream_counter'),
        rippleCount = liquid.Drop<int>(0, label: 'ripple_count'),
        baseCount = liquid.Drop<int>(0, label: 'base_count') {
    ripple = liquid.Ripple(
      source: baseCount,
      label: 'base_count_ripple',
      effect: () => rippleCount.value = rippleCount.value + 1,
    );
  }

  final liquid.Tub tub;
  final liquid.Drop<ThemeMode> themeMode;
  final liquid.Drop<int> baseCount;
  final liquid.Drop<int> nestedParentCount;
  final liquid.Drop<int> nestedChildCount;
  final liquid.Drop<String> searchQuery;
  final liquid.Drop<int> folderDepthCount;
  final liquid.Drop<int> editorCharacterCount;
  final liquid.Flow<int> streamCounter;
  final liquid.Drop<int> rippleCount;
  late final liquid.Ripple ripple;

  final List<FeatureDefinition> features = const <FeatureDefinition>[
    FeatureDefinition(
      feature: LiquidFeature.drop,
      title: 'Drop',
      description: 'Smallest reactive state unit using a simple counter.',
      whereToUse: 'Use for any single mutable value like count, toggle, selected id, or input text.',
    ),
    FeatureDefinition(
      feature: LiquidFeature.flow,
      title: 'Flow',
      description: 'Async counter loading state (idle/loading/data/error).',
      whereToUse: 'Use for API calls, async initialization, and stream/listener-driven state.',
    ),
    FeatureDefinition(
      feature: LiquidFeature.tub,
      title: 'Tub',
      description: 'Scoped state container for counter lifecycle ownership.',
      whereToUse: 'Use per feature/page/module to create and dispose a local state graph cleanly.',
    ),
    FeatureDefinition(
      feature: LiquidFeature.ripple,
      title: 'Ripple',
      description: 'Counter side-effects that react to count changes.',
      whereToUse: 'Use for side effects: navigation, analytics, logs, snackbars, and command triggers.',
    ),
    FeatureDefinition(
      feature: LiquidFeature.streamDrop,
      title: 'Pool',
      description: 'Derived counter state (double + triple) with memoized recompute.',
      whereToUse: 'Use when one value must be computed from other states without manual syncing.',
    ),
    FeatureDefinition(
      feature: LiquidFeature.nestedState,
      title: 'Nested State',
      description: 'Parent counter + child counter composition.',
      whereToUse: 'Use when child/section state contributes to a parent/aggregate total.',
    ),
    FeatureDefinition(
      feature: LiquidFeature.searchState,
      title: 'Search State',
      description: 'Counter filtering through query state.',
      whereToUse: 'Use in searchable lists, filters, and query-driven views.',
    ),
    FeatureDefinition(
      feature: LiquidFeature.editorState,
      title: 'Editor State',
      description: 'Counter reflected as editable text/character state.',
      whereToUse: 'Use in forms, note editors, and draft/editing experiences.',
    ),
    FeatureDefinition(
      feature: LiquidFeature.folderHierarchyState,
      title: 'Folder Hierarchy State',
      description: 'Hierarchical counters by folder depth.',
      whereToUse: 'Use for nested trees like folders, categories, and menu hierarchies.',
    ),
    FeatureDefinition(
      feature: LiquidFeature.themeState,
      title: 'Theme State',
      description: 'Counter app theme switching using Liquid state.',
      whereToUse: 'Use for app-wide preferences such as theme, locale, and accessibility options.',
    ),
  ];

  late final liquid.Pool<int> doubled = liquid.Pool<int>(
    () => baseCount.value * 2,
    label: 'doubled_count',
  );

  late final liquid.Pool<int> tripled = liquid.Pool<int>(
    () => baseCount.value * 3,
    label: 'tripled_count',
  );

  late final liquid.Pool<List<int>> searchResults = liquid.Pool<List<int>>(() {
    final String query = searchQuery.value.trim();
    final List<int> source = List<int>.generate(baseCount.value + 1, (int index) => index);
    if (query.isEmpty) {
      return source;
    }
    return source.where((int value) => value.toString().contains(query)).toList(growable: false);
  }, label: 'search_results');

  late final liquid.Pool<int> nestedTotal = liquid.Pool<int>(
    () => nestedParentCount.value + nestedChildCount.value,
    label: 'nested_total',
  );

  late final liquid.Pool<int> hierarchyTotal = liquid.Pool<int>(
    () => baseCount.value * folderDepthCount.value,
    label: 'hierarchy_total',
  );

  void increment() {
    baseCount.value = baseCount.value + 1;
  }

  void decrement() {
    if (baseCount.value == 0) {
      return;
    }
    baseCount.value = baseCount.value - 1;
  }

  void incrementNestedParent() {
    nestedParentCount.value = nestedParentCount.value + 1;
  }

  void incrementNestedChild() {
    nestedChildCount.value = nestedChildCount.value + 1;
  }

  void setSearchQuery(String value) {
    searchQuery.value = value;
  }

  void setFolderDepth(int depth) {
    folderDepthCount.value = depth;
  }

  void setEditorText(String text) {
    editorCharacterCount.value = text.length;
  }

  void toggleTheme() {
    themeMode.value = themeMode.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> loadAsyncCounter() async {
    await streamCounter.run(() async {
      await Future<void>.delayed(const Duration(milliseconds: 450));
      return baseCount.value;
    });
  }

  void dispose() {
    ripple.dispose();
    tub.dispose();
  }
}
