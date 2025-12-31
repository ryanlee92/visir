// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inbox_conversation_summary_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(InboxConversationSummary)
const inboxConversationSummaryProvider = InboxConversationSummaryFamily._();

final class InboxConversationSummaryProvider
    extends $AsyncNotifierProvider<InboxConversationSummary, String?> {
  const InboxConversationSummaryProvider._({
    required InboxConversationSummaryFamily super.from,
    required (String?, String?) super.argument,
  }) : super(
         retry: null,
         name: r'inboxConversationSummaryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$inboxConversationSummaryHash();

  @override
  String toString() {
    return r'inboxConversationSummaryProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  InboxConversationSummary create() => InboxConversationSummary();

  @override
  bool operator ==(Object other) {
    return other is InboxConversationSummaryProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$inboxConversationSummaryHash() =>
    r'c4a99fe1d68198bcec00eb94a46099aa4ad62c6b';

final class InboxConversationSummaryFamily extends $Family
    with
        $ClassFamilyOverride<
          InboxConversationSummary,
          AsyncValue<String?>,
          String?,
          FutureOr<String?>,
          (String?, String?)
        > {
  const InboxConversationSummaryFamily._()
    : super(
        retry: null,
        name: r'inboxConversationSummaryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  InboxConversationSummaryProvider call(String? taskId, String? eventId) =>
      InboxConversationSummaryProvider._(
        argument: (taskId, eventId),
        from: this,
      );

  @override
  String toString() => r'inboxConversationSummaryProvider';
}

abstract class _$InboxConversationSummary extends $AsyncNotifier<String?> {
  late final _$args = ref.$arg as (String?, String?);
  String? get taskId => _$args.$1;
  String? get eventId => _$args.$2;

  FutureOr<String?> build(String? taskId, String? eventId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args.$1, _$args.$2);
    final ref = this.ref as $Ref<AsyncValue<String?>, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<String?>, String?>,
              AsyncValue<String?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(_inboxConversationSummary)
const _inboxConversationSummaryProvider = _InboxConversationSummaryFamily._();

final class _InboxConversationSummaryProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  const _InboxConversationSummaryProvider._({
    required _InboxConversationSummaryFamily super.from,
    required (String?, String?) super.argument,
  }) : super(
         retry: null,
         name: r'_inboxConversationSummaryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$_inboxConversationSummaryHash();

  @override
  String toString() {
    return r'_inboxConversationSummaryProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    final argument = this.argument as (String?, String?);
    return _inboxConversationSummary(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is _InboxConversationSummaryProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$_inboxConversationSummaryHash() =>
    r'2e3c20c9f21242d1329639659472011999ee0584';

final class _InboxConversationSummaryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String?>, (String?, String?)> {
  const _InboxConversationSummaryFamily._()
    : super(
        retry: null,
        name: r'_inboxConversationSummaryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  _InboxConversationSummaryProvider call(String? taskId, String? eventId) =>
      _InboxConversationSummaryProvider._(
        argument: (taskId, eventId),
        from: this,
      );

  @override
  String toString() => r'_inboxConversationSummaryProvider';
}
