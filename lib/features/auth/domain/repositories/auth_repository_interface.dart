import 'package:Visir/features/auth/domain/entities/subscription/lemon_squeezy/lemon_squeezy_customer_entity.dart';
import 'package:Visir/features/auth/domain/entities/subscription/lemon_squeezy/lemon_squeezy_discount_entity.dart';
import 'package:Visir/features/auth/domain/entities/subscription/lemon_squeezy/lemon_squeezy_product_entity.dart';
import 'package:Visir/features/auth/domain/entities/subscription/lemon_squeezy/lemon_squeezy_variant_entity.dart';
import 'package:Visir/features/auth/domain/entities/subscription/user_subscription_update_attributes_entity.dart';
import 'package:Visir/features/auth/domain/entities/user_entity.dart';
import 'package:Visir/features/common/domain/failures/failure.dart';
import 'package:fpdart/fpdart.dart';

///
abstract class AuthRepositoryInterface {
  Future<Either<Failure, UserEntity?>> onSignInSuccess();

  Future<Either<Failure, UserEntity?>> onSignInFailed(Object error);

  Future<Either<Failure, UserEntity?>> signOut();

  Future<Either<Failure, UserEntity?>> deleteUser(String userId);

  Future<Either<Failure, UserEntity?>> updateUser({required UserEntity user});

  void authStateChange(void Function(String? userId) callback);

  Future<Either<Failure, String?>> getSubscriptionCheckoutUrl({
    required bool isTestMode,
    required String productId,
    required String variantId,
    String? discountCode,
  });

  Future<Either<Failure, bool?>> restoreSubscription({required bool isTestMode, required int lemonSqueezyCustomerId});

  Future<Either<Failure, bool?>> updateSubscription({
    required bool isTestMode,
    required String subscriptionId,
    required UserSubscriptionUpdateAttributesEntity attributes,
  });

  Future<Either<Failure, List<LemonSqueezyProductEntity>>> getLemonSqueezyProducts({required bool isTestMode});

  Future<Either<Failure, List<LemonSqueezyVariantEntity>>> getLemonSqueezyVariants({required bool isTestMode, required String productId});

  Future<Either<Failure, LemonSqueezyCustomerEntity>> getLemonSqueezyCustomer({required bool isTestMode, required String customerId});

  Future<Either<Failure, List<LemonSqueezyDiscountEntity>>> getLemonSqueezyDiscounts({required bool isTestMode, required String storeId});

  /// 사용자 정보 조회
  Future<Either<Failure, UserEntity>> getUser({required String userId});

  /// 크레딧 조회
  Future<Either<Failure, double>> getAiCredits({required String userId});

  /// 크레딧 업데이트 (추가 또는 차감)
  Future<Either<Failure, double>> updateAiCredits({
    required String userId,
    required double amount, // 양수면 추가, 음수면 차감
  });
}
