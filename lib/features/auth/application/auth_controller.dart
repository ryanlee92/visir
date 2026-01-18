import 'dart:convert';

import 'package:Visir/config/providers.dart';
import 'package:Visir/features/auth/domain/entities/subscription/lemon_squeezy/lemon_squeezy_customer_entity.dart';
import 'package:Visir/features/auth/domain/entities/subscription/lemon_squeezy/lemon_squeezy_discount_entity.dart';
import 'package:Visir/features/auth/domain/entities/subscription/lemon_squeezy/lemon_squeezy_product_entity.dart';
import 'package:Visir/features/auth/domain/entities/subscription/lemon_squeezy/lemon_squeezy_variant_entity.dart';
import 'package:Visir/features/auth/domain/entities/subscription/user_subscription_update_attributes_entity.dart';
import 'package:Visir/features/auth/domain/entities/user_entity.dart';
import 'package:Visir/features/auth/infrastructure/repositories/auth_repository.dart';
import 'package:Visir/features/auth/providers.dart';
import 'package:Visir/features/chat/domain/entities/message_event_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_unread_entity.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/log_event.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_config_entity.dart';
import 'package:Visir/features/task/domain/entities/task_entity.dart';
import 'package:riverpod_annotation/experimental/persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_controller.g.dart';

@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  late AuthRepository repository;

  List<LemonSqueezyProductEntity> _subscriptionProducts = [];
  List<LemonSqueezyVariantEntity> _subscriptionVariants = [];
  LemonSqueezyCustomerEntity? _subscriptionCustomer;
  List<LemonSqueezyDiscountEntity> _subscriptionDiscounts = [];

  List<LemonSqueezyProductEntity> get subscriptionProducts => _subscriptionProducts;
  List<LemonSqueezyVariantEntity> get subscriptionVariants => _subscriptionVariants;
  LemonSqueezyCustomerEntity? get subscriptionCustomer => _subscriptionCustomer;
  List<LemonSqueezyDiscountEntity> get subscriptionDiscounts => _subscriptionDiscounts;

  bool get isSubscriptionTestMode => onToggleTestMode;

  @override
  Future<UserEntity> build() async {
    // Supabase가 초기화될 때까지 대기
    await ref.watch(supabaseProvider.future);

    repository = ref.watch(authRepositoryProvider);
    repository.authStateChange((userId) async {
      if (userId == null) {
        ref.read(isSignedInProvider.notifier).updateIsSignedIn(false);
        return;
      }

      await _getUser();
      ref.read(isSignedInProvider.notifier).updateIsSignedIn(true);
    });

    if (ref.watch(shouldUseMockDataProvider)) {
      return fakeUser;
    }

    await persist(
      ref.watch(storageProvider.future),
      key: 'auth',
      encode: (UserEntity state) => jsonEncode(state.toJson()),
      decode: (String encoded) => UserEntity.fromJson(jsonDecode(encoded) as Map<String, dynamic>),
      options: Utils.storageOptions,
    ).future;

    // persist 데이터가 있으면 즉시 반환 (로딩 완료)
    if (state.value != null) {
      _getUser();
      return state.value!;
    }

    // persist 데이터가 없으면 getUser를 호출
    final user = await _getUser();
    return user;
  }

  Future<UserEntity> _getUser() async {
    if (repository.currentUserId == null) return fakeUser;

    ref.read(isSignedInProvider.notifier).updateIsSignedIn(true);
    final result = await repository.getUser(userId: repository.currentUserId!);
    return result.fold((l) => state.requireValue, (r) {
      updateUser(user: r);
      switchSubscriptionTestMode(isTestMode: false);
      if (r.lemonSqueezyCustomerId != null) {
        restoreSubscription(lemonSqueezyCustomerId: r.lemonSqueezyCustomerId!);
      }
      return r;
    });
  }

  Future<bool> checkUserExistByEmail({required String email}) async {
    final result = await repository.checkUserExistByEmail(email: email);
    return result.fold((l) => false, (r) {
      return r;
    });
  }

  Future<void> onSignInSuccess() async {
    tabNotifier.value = TabType.home;
    // 로그인 시 사용자별 설정 초기화
    // await clearUserSpecificSharedPreferences();
    await _getUser();
    await setAnalyticsUserProfile(user: state.requireValue);
  }

  Future<void> onSignInFailed(Object error) async {
    final user = await repository.onSignInFailed(error);
    _updateState(user: user.getRight().toNullable());
  }

  Future<void> signOut() async {
    ref.read(isSignedInProvider.notifier).updateIsSignedIn(false);
    // 로그아웃 시 사용자별 설정 초기화
    final user = await repository.signOut();
    await clearUserSpecificSharedPreferences();
    Utils.clearWidgetData();
    _updateState(user: user.getRight().toNullable());
  }

  Future<void> deleteUser() async {
    final isSignedIn = state.requireValue.isSignedIn;
    if (!isSignedIn) return;
    logAnalyticsEvent(eventName: 'delete_account', userId: state.requireValue.id);
    Utils.clearWidgetData();
    String? subscriptionId = state.requireValue.subscription?.id;
    if (subscriptionId != null) {
      await cancelSubscription(subscriptionId: subscriptionId);
    }
    await repository.deleteUser(state.requireValue.id);
    await clearUserSpecificSharedPreferences();
    _updateState(user: null);
  }

  Future<void> updateUser({required UserEntity user}) async {
    if (repository.currentUserId == null) return;
    if (ref.read(shouldUseMockDataProvider)) return;
    final prevUser = state.value;
    if (prevUser == user) return;
    _updateState(user: user);
    await repository.updateUser(user: user);
  }

  Future<void> clearBadge() async {
    final user = state.requireValue;
    if (!user.isSignedIn) return;
    if (repository.currentUserId == null) return null;
    await updateUser(user: user.copyWith(badge: 0));
  }

  void _updateState({required UserEntity? user}) {
    if (state.value != null && user?.copyWith(badge: 0) == state.requireValue.copyWith(badge: 0)) return;
    if (user?.subscription == null) {
      state = AsyncData(user?.copyWith(subscription: state.requireValue.subscription) ?? fakeUser);
    } else {
      state = AsyncData(user ?? fakeUser);
    }
  }

  Future<void> updateGmailHistoryId(Map<String, String> lastGmailHistoryIds) async {
    final user = state.requireValue;
    if (!user.isSignedIn) return;
    if (repository.currentUserId == null) return null;

    final result = await repository.updateUser(user: user.copyWith(lastGmailHistoryIds: {...(user.lastGmailHistoryIds ?? {}), ...lastGmailHistoryIds}));

    return result.fold((l) => null, (r) {
      _updateState(user: r);
      return r;
    });
  }

  Future<String> uploadUserImage({required String path}) async {
    final user = state.requireValue;
    if (!user.isSignedIn) return '';
    if (repository.currentUserId == null) return '';
    final result = await repository.uploadUserImage(userId: user.id, path: path);
    return result.fold((l) => '', (r) => r);
  }

  Future<void> refreshSession() async {
    if (repository.currentUserId == null) return null;
    await repository.refreshSession();
  }

  bool get isUserListenerConnected => repository.isUserListenerConnected;

  bool get isNotiListenerConnected => repository.isNotiListenerConnected;

  void attachUserChannelListener({
    required void Function(String calendarId) onGcalChanged,
    required void Function(String eventId) onOutlookCalChanged,
    required void Function(String historyId, String email) onGmailChanged,
    required void Function(String messageId, String email, String changeType) onOutlookMailChanged,
    required void Function(MessageEventEntity event) onSlackChanged,
    required void Function(TaskEntity task) onUpdateTask,
    required void Function(String taskId) onDeleteTask,
    required void Function(InboxConfigEntity config) onUpdateInboxConfig,
    required void Function(String configId) onDeleteInboxConfig,
    required void Function(MessageUnreadEntity unread) onUpdateMessageUnread,
  }) {
    if (repository.currentUserId == null) return;
    repository.attachUserChannelListener(
      onGcalChanged: onGcalChanged,
      onOutlookCalChanged: onOutlookCalChanged,
      onGmailChanged: onGmailChanged,
      onOutlookMailChanged: onOutlookMailChanged,
      onSlackChanged: onSlackChanged,
      onDeleteTask: onDeleteTask,
      onUpdateTask: onUpdateTask,
      onUpdateInboxConfig: onUpdateInboxConfig,
      onDeleteInboxConfig: onDeleteInboxConfig,
      onUpdateMessageUnread: onUpdateMessageUnread,
      onUpdate: (user) {
        _updateState(user: user);
      },
    );
  }

  void attachNotiChannelListener({required String deviceId}) {
    if (repository.currentUserId == null) return;
    repository.attachNotiChannelListener(deviceId: deviceId);
  }

  Future<String?> getSubscriptionCheckoutUrl({required String productId, required String variantId, String? discountCode}) async {
    if (repository.currentUserId == null) return null;
    final result = await repository.getSubscriptionCheckoutUrl(isTestMode: isSubscriptionTestMode, productId: productId, variantId: variantId, discountCode: discountCode);

    return result.fold((l) => null, (r) {
      return r;
    });
  }

  Future<bool?> restoreSubscription({required int lemonSqueezyCustomerId}) async {
    if (repository.currentUserId == null) return null;
    final result = await repository.restoreSubscription(isTestMode: isSubscriptionTestMode, lemonSqueezyCustomerId: lemonSqueezyCustomerId);
    return result.fold((l) => null, (r) {
      return r;
    });
  }

  Future<bool?> cancelSubscription({required String subscriptionId}) async {
    if (repository.currentUserId == null) return null;
    final result = await repository.updateSubscription(
      isTestMode: isSubscriptionTestMode,
      subscriptionId: subscriptionId,
      attributes: UserSubscriptionUpdateAttributesEntity(cancelled: true),
    );
    return result.fold((l) => null, (r) {
      return r;
    });
  }

  Future<bool?> resumeSubscription({required String subscriptionId}) async {
    if (repository.currentUserId == null) return null;
    final result = await repository.updateSubscription(
      isTestMode: isSubscriptionTestMode,
      subscriptionId: subscriptionId,
      attributes: UserSubscriptionUpdateAttributesEntity(cancelled: false),
    );
    return result.fold((l) => null, (r) {
      return r;
    });
  }

  Future<bool?> extendSubscriptionTrial({required Duration duration}) async {
    if (repository.currentUserId == null) return null;
    DateTime? trialEndAt = state.requireValue.subscription?.subscriptionTrialEndsAt;
    final subscriptionId = state.requireValue.subscription?.id;
    if (subscriptionId == null || trialEndAt == null) return false;

    DateTime newTrialEndAt = trialEndAt.add(duration);

    final result = await repository.updateSubscription(
      isTestMode: isSubscriptionTestMode,
      subscriptionId: subscriptionId,
      attributes: UserSubscriptionUpdateAttributesEntity(trialEndsAt: newTrialEndAt, cancelled: false),
    );

    return result.fold((l) => null, (r) {
      return r;
    });
  }

  Future<List<LemonSqueezyProductEntity>> getLemonSqueezyProducts() async {
    final result = await repository.getLemonSqueezyProducts(isTestMode: isSubscriptionTestMode);
    return result.fold((l) => [], (r) async {
      _subscriptionProducts = r;

      getLemonSqueezyDiscounts();

      List<Future<List<LemonSqueezyVariantEntity>>> futures = [];
      for (var product in r) {
        futures.add(repository.getLemonSqueezyVariants(isTestMode: isSubscriptionTestMode, productId: product.id).then((value) => value.getRight().toNullable() ?? []));
      }
      final variants = await Future.wait(futures);
      _subscriptionVariants = variants.expand((e) => e).toList();
      return r;
    });
  }

  Future<LemonSqueezyCustomerEntity?> getLemonSqueezyCustomer() async {
    if (repository.currentUserId == null) return null;
    String lemonSqueezyCustomerId = state.requireValue.lemonSqueezyCustomerId?.toString() ?? '';
    if (lemonSqueezyCustomerId.isEmpty) return null;
    final result = await repository.getLemonSqueezyCustomer(isTestMode: isSubscriptionTestMode, customerId: lemonSqueezyCustomerId);
    return result.fold((l) => null, (r) {
      _subscriptionCustomer = r;
      return r;
    });
  }

  Future<List<LemonSqueezyDiscountEntity>> getLemonSqueezyDiscounts() async {
    if (subscriptionProducts.isEmpty) return [];
    final result = await repository.getLemonSqueezyDiscounts(isTestMode: isSubscriptionTestMode, storeId: subscriptionProducts.first.storeId.toString());
    return result.fold((l) => [], (r) {
      _subscriptionDiscounts = r;
      return r;
    });
  }

  Future<void> switchSubscriptionTestMode({required bool isTestMode}) async {
    ref.read(subscriptionTestModeProvider.notifier).setTestMode(isTestMode);
    await getLemonSqueezyProducts();
  }
}

@Riverpod(keepAlive: true)
class IsSignedIn extends _$IsSignedIn {
  @override
  bool build() {
    return false;
  }

  void updateIsSignedIn(bool isSignedIn) {
    if (state == isSignedIn) return;
    state = isSignedIn;
  }
}
