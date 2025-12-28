import 'dart:async';
import 'dart:convert';

import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/searchfield/src/searchfield.dart';
import 'package:Visir/features/common/infrastructure/entities/environment.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class LocationSearchField extends ConsumerStatefulWidget {
  final String? initialValue;
  final String? hint;
  final InputDecorationTheme? decoration;
  final void Function(String location) onSearchTextChanged;
  final void Function(String location)? onFieldSubmitted;
  final Offset? offset;
  final FocusNode? focusNode;
  final TextStyle? searchStyle;
  final TextStyle? suggestionStyle;
  final bool? enabled;

  const LocationSearchField({
    super.key,
    this.onFieldSubmitted,
    required this.onSearchTextChanged,
    this.initialValue,
    this.decoration,
    this.hint,
    this.offset,
    this.focusNode,
    this.searchStyle,
    this.suggestionStyle,
    this.enabled,
  });

  @override
  ConsumerState<LocationSearchField> createState() => LocationSearchFieldState();
}

class LocationSearchFieldState extends ConsumerState<LocationSearchField> {
  String query = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    query = widget.initialValue ?? '';
  }

  Future<List<SearchFieldListItem<String>>?> onSearchTextChanged(String item) async {
    widget.onSearchTextChanged(item);
    query = item;

    if (item.isEmpty) {
      setState(() {});
      return null;
    }

    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }
    setState(() {});

    try {
      final configFile = await rootBundle.loadString('assets/config/config.json');
      final env = Environment.fromJson(json.decode(configFile) as Map<String, dynamic>);
      // Edge Function에서 가져온 키 사용, 없으면 config.json에서 가져오기 (fallback)
      final finalApiKey = googleAPiWeb.isNotEmpty ? googleAPiWeb : env.googleAPiWeb;

      String url = "https://places.googleapis.com/v1/places:searchText";
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json', 'X-Goog-Api-Key': finalApiKey, 'X-Goog-FieldMask': 'places.displayName,places.formattedAddress'},
        body: jsonEncode({'textQuery': item, 'maxResultCount': 3, 'languageCode': Localizations.localeOf(context).languageCode}),
      );
      final result = jsonDecode(response.body)['places'] as List<dynamic>;
      final filter = result.map((e) => e['displayName']['text']).whereType<String>().toList();
      return filter
          .map(
            (e) => SearchFieldListItem<String>(
              e,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(e, style: context.bodyLarge?.copyWith(color: context.outlineVariant)),
              ),
            ),
          )
          .toList();
    } catch (e) {}

    return null;
  }

  GlobalKey<SearchFieldState> searchKey = GlobalKey();

  Future<bool> isSuggestionExists() async {
    return (await searchKey.currentState?.isSuggestionExists()) ?? false;
  }

  void closeSuggestion() {
    searchKey.currentState?.closeSuggestion();
  }

  @override
  Widget build(BuildContext context) {
    final borderRaidus = 6.0;
    return Theme(
      data: context.theme.copyWith(
        inputDecorationTheme:
            widget.decoration ??
            InputDecorationTheme(
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRaidus),
                borderSide: BorderSide(color: context.surface, width: 1),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRaidus),
                borderSide: BorderSide(color: context.surface, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRaidus),
                borderSide: BorderSide(color: context.surface, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRaidus),
                borderSide: BorderSide(color: context.surface, width: 1),
              ),
              fillColor: query.isEmpty ? Colors.transparent : context.surface,
              filled: true,
              isDense: true,
              hintStyle: context.bodyMedium?.copyWith(color: context.surfaceTint),
              hoverColor: Colors.transparent,
            ),
      ),
      child: SearchField<String>(
        key: searchKey,
        enabled: widget.enabled ?? true,
        initialValue: widget.initialValue != null ? SearchFieldListItem<String>(widget.initialValue!) : null,
        suggestions: [],
        hint: widget.hint ?? context.tr.type_location,
        suggestionState: Suggestion.expand,
        textInputAction: TextInputAction.go,
        searchStyle: widget.searchStyle ?? context.bodyMedium?.copyWith(color: context.outlineVariant),
        suggestionStyle: context.bodyMedium!.textColor(context.shadow),
        suggestionAction: SuggestionAction.unfocus,
        onSubmit: widget.onFieldSubmitted,
        suggestionsDecoration: SuggestionDecoration(
          borderRadius: BorderRadius.circular(6),
          color: (context.context.surfaceVariant),
          boxShadow: PopupMenu.popupShadow,
          padding: EdgeInsets.symmetric(vertical: 0),
        ),
        validator: (x) => null,
        offset: widget.offset ?? Offset(0, 40),
        itemHeight: 36,
        maxSuggestionsInViewPort: 5,
        onSearchTextChanged: onSearchTextChanged,
        onSuggestionTap: (x) {
          onSearchTextChanged(x.searchKey);
        },
        focusNode: widget.focusNode,
      ),
    );
  }
}
