import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/selection.dart';
import '../../models/news_source_model.dart';

abstract class PreferencesDataSource {
  Future<void> persistAppLocale(String languageCode);

  Future<void> persistAppThemeMode(int themeMode);

  String? get locale;

  int? get themeMode;

  bool get isSourcesSelected;

  Future<void> persistSourcesSelection(
    covariant List<Selection<NewsSourceModel>> sources,
  );

  List<Selection<NewsSourceModel>> getSourcesPreferences();
}

class PreferencesDataSourceImpl implements PreferencesDataSource {
  PreferencesDataSourceImpl(this.preferences);

  final SharedPreferences preferences;

  @override
  Future<void> persistAppLocale(String languageCode) =>
      preferences.setString('locale', languageCode);

  @override
  String? get locale => preferences.getString('locale');

  @override
  Future<void> persistAppThemeMode(int themeMode) =>
      preferences.setInt('themeMode', themeMode);

  @override
  int? get themeMode => preferences.getInt('themeMode');

  @override
  bool get isSourcesSelected => preferences.containsKey('sources');

  @override
  List<Selection<NewsSourceModel>> getSourcesPreferences() {
    if (!isSourcesSelected) return [];

    final Map<String, dynamic> sourcesMap = jsonDecode(
      preferences.getString('sources')!,
    );

    final sourcesList = <Selection<NewsSourceModel>>[];

    for (Map<String, dynamic> sourceValue in sourcesMap.values) {
      sourcesList.add(
        Selection(
          selected: sourceValue['selected'],
          value: NewsSourceModel.fromJson(
            sourceValue['value'],
          ),
        ),
      );
    }

    return sourcesList;
  }

  @override
  Future<void> persistSourcesSelection(
    List<Selection<NewsSourceModel>> sources,
  ) async {
    final sourcesMap = <String, Map<String, dynamic>>{};

    for (var source in sources) {
      sourcesMap[source.value.title] = source.toJson(source.value.toJson());
    }

    await preferences.setString('sources', jsonEncode(sourcesMap));
  }
}
