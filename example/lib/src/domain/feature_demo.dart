enum LiquidFeature {
  drop,
  flow,
  tub,
  ripple,
  streamDrop,
  nestedState,
  searchState,
  editorState,
  folderHierarchyState,
  themeState,
}

class FeatureDefinition {
  const FeatureDefinition({
    required this.feature,
    required this.title,
    required this.description,
    required this.whereToUse,
  });

  final LiquidFeature feature;
  final String title;
  final String description;
  final String whereToUse;
}
