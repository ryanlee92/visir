# Funnel Tracking Integration Guide

This guide shows exactly where to add funnel tracking calls in your Flutter app.

## Quick Reference

All tracking functions are in: `lib/features/common/presentation/utils/log_event.dart`

## 1. App Install Tracking

### Where: App Initialization / First Launch

**File:** `lib/main.dart` or your app initialization logic

```dart
import 'package:Visir/features/common/presentation/utils/log_event.dart';
import 'package:shared_preferences/shared_preferences.dart';

// In your app initialization
Future<void> initializeApp() async {
  final prefs = await SharedPreferences.getInstance();
  final hasLaunched = prefs.getBool('has_launched') ?? false;

  if (!hasLaunched) {
    // First launch - log app install
    final Uri? launchUri = await getInitialUri(); // Or however you get launch URI
    final params = launchUri?.queryParameters ?? {};

    await logAppInstall(
      gaClientId: params['ga_client_id'],
      utmSource: params['utm_source'],
      utmMedium: params['utm_medium'],
      utmCampaign: params['utm_campaign'],
      utmTerm: params['utm_term'],
      utmContent: params['utm_content'],
    );

    // Store UTM params for later attribution
    if (params['ga_client_id'] != null) {
      await prefs.setString('ga_client_id', params['ga_client_id']!);
    }
    if (params['utm_source'] != null) {
      await prefs.setString('utm_source', params['utm_source']!);
    }

    // Mark app as launched
    await prefs.setBool('has_launched', true);
  }
}
```

### Deep Link Handler Setup

**File:** Your deep link configuration (e.g., `AndroidManifest.xml`, `Info.plist`)

**Android - AndroidManifest.xml:**
```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <!-- Accept URLs with tracking parameters -->
    <data android:scheme="visir" android:host="install" />
</intent-filter>
```

**iOS - Info.plist:**
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>visir</string>
        </array>
    </dict>
</array>
```

## 2. Signup Tracking

### Where: After Successful Authentication

**File:** Your authentication logic (e.g., `lib/features/auth/...`)

```dart
import 'package:Visir/features/common/presentation/utils/log_event.dart';
import 'package:shared_preferences/shared_preferences.dart';

// After successful signup
Future<void> onSignupSuccess(User user, String authMethod) async {
  final prefs = await SharedPreferences.getInstance();
  final gaClientId = prefs.getString('ga_client_id');
  final utmSource = prefs.getString('utm_source');

  // Log signup event
  await logSignupCompleted(
    userId: user.id,
    signupMethod: authMethod, // 'email', 'google', 'apple', 'microsoft', 'slack'
    gaClientId: gaClientId,
    utmSource: utmSource,
  );

  // Set user profile
  await setAnalyticsUserProfile(
    user: UserEntity(
      id: user.id,
      email: user.email ?? '',
      name: user.name,
      // ... other user fields
    ),
    moneySaved: 0,
  );
}

// Example: Email/Password Signup
Future<void> handleEmailSignup(String email, String password) async {
  final user = await supabase.auth.signUp(email: email, password: password);
  if (user.user != null) {
    await onSignupSuccess(user.user!, 'email');
  }
}

// Example: Google OAuth
Future<void> handleGoogleSignup() async {
  final user = await supabase.auth.signInWithOAuth(Provider.google);
  if (user != null) {
    await onSignupSuccess(user, 'google');
  }
}
```

## 3. First Feature Usage Tracking

### A. First Task Created

**File:** Task creation logic (e.g., `lib/features/calendar/...`)

```dart
import 'package:Visir/features/common/presentation/utils/log_event.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> onTaskCreated(CalendarTask task) async {
  final prefs = await SharedPreferences.getInstance();
  final userId = Supabase.instance.client.auth.currentUser?.id;

  // Check if this is the first task
  final hasCreatedTask = prefs.getBool('has_created_task') ?? false;

  if (!hasCreatedTask && userId != null) {
    await logFirstTimeFeature(
      featureName: 'task_created',
      userId: userId,
      additionalProperties: {
        'task_type': task.isEvent ? 'event' : 'task',
      },
    );

    await prefs.setBool('has_created_task', true);
  }

  // Continue with existing task creation logic...
}
```

### B. First Email Connected

**File:** Email integration logic (e.g., `lib/features/integrations/gmail/...`)

```dart
import 'package:Visir/features/common/presentation/utils/log_event.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> onEmailConnected(String provider) async {
  final prefs = await SharedPreferences.getInstance();
  final userId = Supabase.instance.client.auth.currentUser?.id;

  // Check if this is the first email connection
  final hasConnectedEmail = prefs.getBool('has_connected_email') ?? false;

  if (!hasConnectedEmail && userId != null) {
    await logFirstTimeFeature(
      featureName: 'email_connected',
      userId: userId,
      additionalProperties: {
        'provider': provider, // 'gmail', 'outlook'
      },
    );

    await prefs.setBool('has_connected_email', true);
  }

  // Continue with existing email connection logic...
}
```

### C. First Calendar Synced

**File:** Calendar sync logic (e.g., `lib/features/calendar/...`)

```dart
import 'package:Visir/features/common/presentation/utils/log_event.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> onCalendarSynced(String calendarProvider) async {
  final prefs = await SharedPreferences.getInstance();
  final userId = Supabase.instance.client.auth.currentUser?.id;

  // Check if this is the first calendar sync
  final hasSyncedCalendar = prefs.getBool('has_synced_calendar') ?? false;

  if (!hasSyncedCalendar && userId != null) {
    await logFirstTimeFeature(
      featureName: 'calendar_synced',
      userId: userId,
      additionalProperties: {
        'provider': calendarProvider, // 'google', 'outlook', 'apple'
      },
    );

    await prefs.setBool('has_synced_calendar', true);
  }

  // Continue with existing calendar sync logic...
}
```

### D. First Slack Connected

**File:** Slack integration logic (e.g., `lib/features/integrations/slack/...`)

```dart
import 'package:Visir/features/common/presentation/utils/log_event.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> onSlackConnected(String workspaceName) async {
  final prefs = await SharedPreferences.getInstance();
  final userId = Supabase.instance.client.auth.currentUser?.id;

  // Check if this is the first Slack connection
  final hasConnectedSlack = prefs.getBool('has_connected_slack') ?? false;

  if (!hasConnectedSlack && userId != null) {
    await logFirstTimeFeature(
      featureName: 'slack_connected',
      userId: userId,
      additionalProperties: {
        'workspace_name': workspaceName,
      },
    );

    await prefs.setBool('has_connected_slack', true);
  }

  // Continue with existing Slack connection logic...
}
```

### E. First AI Assistant Usage

**File:** AI assistant logic (e.g., `lib/features/ai/...`)

```dart
import 'package:Visir/features/common/presentation/utils/log_event.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> onAIAssistantUsed(String feature) async {
  final prefs = await SharedPreferences.getInstance();
  final userId = Supabase.instance.client.auth.currentUser?.id;

  // Check if this is the first AI usage
  final hasUsedAI = prefs.getBool('has_used_ai') ?? false;

  if (!hasUsedAI && userId != null) {
    await logFirstTimeFeature(
      featureName: 'ai_assistant_used',
      userId: userId,
      additionalProperties: {
        'feature': feature, // 'task_generation', 'email_draft', etc.
      },
    );

    await prefs.setBool('has_used_ai', true);
  }

  // Continue with existing AI logic...
}
```

## 4. Subscription Tracking

### A. Subscription Started

**File:** Payment/subscription logic (e.g., `lib/features/subscription/...`)

```dart
import 'package:Visir/features/common/presentation/utils/log_event.dart';

Future<void> onSubscriptionPurchased({
  required String userId,
  required String planId,
  required double price,
  required String billingPeriod,
}) async {
  await logSubscriptionStarted(
    userId: userId,
    plan: planId, // 'pro', 'team', 'enterprise'
    amount: price,
    currency: 'USD', // or get from payment provider
    billingInterval: billingPeriod, // 'monthly', 'yearly'
  );

  // Continue with existing subscription logic...
}

// Example: In-App Purchase (iOS/Android)
Future<void> handlePurchase(PurchaseDetails purchase) async {
  if (purchase.status == PurchaseStatus.purchased) {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    await onSubscriptionPurchased(
      userId: userId!,
      planId: purchase.productID,
      price: getPriceFromProductId(purchase.productID),
      billingPeriod: getBillingPeriodFromProductId(purchase.productID),
    );
  }
}

// Example: Stripe Webhook
Future<void> handleStripeWebhook(Map<String, dynamic> event) async {
  if (event['type'] == 'checkout.session.completed') {
    final userId = event['data']['object']['client_reference_id'];
    final amount = event['data']['object']['amount_total'] / 100;
    final subscription = event['data']['object']['subscription'];

    await logSubscriptionStarted(
      userId: userId,
      plan: subscription['plan']['id'],
      amount: amount,
      currency: subscription['plan']['currency'].toUpperCase(),
      billingInterval: subscription['plan']['interval'],
    );
  }
}
```

### B. Subscription Cancelled

**File:** Cancellation logic

```dart
import 'package:Visir/features/common/presentation/utils/log_event.dart';

Future<void> onSubscriptionCancelled({
  required String userId,
  required String planId,
  String? cancellationReason,
}) async {
  await logSubscriptionCancelled(
    userId: userId,
    plan: planId,
    reason: cancellationReason,
  );

  // Continue with existing cancellation logic...
}

// Example: User cancels from settings
Future<void> handleUserCancellation(String reason) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  final currentPlan = await getCurrentPlan(userId!);

  await onSubscriptionCancelled(
    userId: userId,
    planId: currentPlan.id,
    cancellationReason: reason, // 'too_expensive', 'not_using', 'missing_features', 'other'
  );

  // Cancel subscription with payment provider
  await cancelSubscriptionWithProvider();
}
```

### C. Subscription Renewed

**File:** Webhook handler or subscription check logic

```dart
import 'package:Visir/features/common/presentation/utils/log_event.dart';

// Example: Stripe Webhook for renewal
Future<void> handleSubscriptionRenewed(Map<String, dynamic> event) async {
  if (event['type'] == 'invoice.paid') {
    final invoice = event['data']['object'];
    final userId = invoice['customer_metadata']['user_id'];
    final amount = invoice['amount_paid'] / 100;

    await logSubscriptionRenewed(
      userId: userId,
      plan: invoice['lines']['data'][0]['plan']['id'],
      amount: amount,
    );
  }
}

// Example: In-App Purchase renewal detection
Future<void> checkSubscriptionRenewal() async {
  // Called periodically or on app launch
  final userId = Supabase.instance.client.auth.currentUser?.id;
  final lastRenewalDate = await getLastRenewalDate(userId!);
  final currentSubscription = await getCurrentSubscription(userId);

  if (currentSubscription != null &&
      currentSubscription.renewalDate.isAfter(lastRenewalDate)) {
    await logSubscriptionRenewed(
      userId: userId,
      plan: currentSubscription.planId,
      amount: currentSubscription.price,
    );

    await saveLastRenewalDate(userId, currentSubscription.renewalDate);
  }
}
```

## 5. Helper Functions

### Storing First-Time Flags

Create a helper service to manage first-time feature flags:

**File:** `lib/features/common/services/first_time_tracker.dart`

```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Visir/features/common/presentation/utils/log_event.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FirstTimeTracker {
  static const String _prefixKey = 'first_time_';

  static Future<void> trackFeatureIfFirst(
    String featureName, {
    Map<String, dynamic>? additionalProperties,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefixKey$featureName';
    final hasUsedFeature = prefs.getBool(key) ?? false;

    if (!hasUsedFeature) {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        await logFirstTimeFeature(
          featureName: featureName,
          userId: userId,
          additionalProperties: additionalProperties,
        );

        await prefs.setBool(key, true);
      }
    }
  }

  static Future<void> reset() async {
    // For testing only - reset all first-time flags
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_prefixKey));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}
```

**Usage:**
```dart
// Anywhere in your app
await FirstTimeTracker.trackFeatureIfFirst(
  'email_connected',
  additionalProperties: {'provider': 'gmail'},
);
```

### Retrieving Stored Attribution Data

**File:** `lib/features/common/services/attribution_service.dart`

```dart
import 'package:shared_preferences/shared_preferences.dart';

class AttributionService {
  static Future<Map<String, String?>> getAttributionData() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'ga_client_id': prefs.getString('ga_client_id'),
      'utm_source': prefs.getString('utm_source'),
      'utm_medium': prefs.getString('utm_medium'),
      'utm_campaign': prefs.getString('utm_campaign'),
      'utm_term': prefs.getString('utm_term'),
      'utm_content': prefs.getString('utm_content'),
    };
  }

  static Future<void> storeAttributionData(Map<String, String> data) async {
    final prefs = await SharedPreferences.getInstance();

    for (final entry in data.entries) {
      await prefs.setString(entry.key, entry.value);
    }
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = [
      'ga_client_id',
      'utm_source',
      'utm_medium',
      'utm_campaign',
      'utm_term',
      'utm_content',
    ];

    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}
```

## Testing

### Test App Install Event

```dart
// For testing, clear first launch flag and trigger install event
import 'package:shared_preferences/shared_preferences.dart';

Future<void> testAppInstall() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('has_launched');

  // Simulate app launch with tracking params
  await logAppInstall(
    gaClientId: 'test_ga_client_id_12345',
    utmSource: 'twitter',
    utmMedium: 'social',
    utmCampaign: 'launch',
    userId: 'test_user_123',
  );

  print('✅ App install event sent');
}
```

### Test First Feature Events

```dart
Future<void> testFirstFeatures() async {
  await FirstTimeTracker.reset(); // Clear all first-time flags

  final userId = Supabase.instance.client.auth.currentUser?.id ?? 'test_user';

  // Test each first-time feature
  await FirstTimeTracker.trackFeatureIfFirst('task_created');
  await FirstTimeTracker.trackFeatureIfFirst('email_connected',
    additionalProperties: {'provider': 'gmail'});
  await FirstTimeTracker.trackFeatureIfFirst('calendar_synced',
    additionalProperties: {'provider': 'google'});

  print('✅ All first-time features logged');
}
```

### Test Subscription Events

```dart
Future<void> testSubscriptionFlow() async {
  final userId = Supabase.instance.client.auth.currentUser?.id ?? 'test_user';

  // Test subscription started
  await logSubscriptionStarted(
    userId: userId,
    plan: 'pro',
    amount: 9.99,
    currency: 'USD',
    billingInterval: 'monthly',
  );
  print('✅ Subscription started event sent');

  // Wait a bit
  await Future.delayed(Duration(seconds: 2));

  // Test subscription cancelled
  await logSubscriptionCancelled(
    userId: userId,
    plan: 'pro',
    reason: 'testing',
  );
  print('✅ Subscription cancelled event sent');
}
```

## Verification Checklist

After implementing, verify:

- [ ] App install event fires on first launch
- [ ] Deep link parameters are captured correctly
- [ ] Signup event fires after auth
- [ ] First feature events fire only once
- [ ] Subscription events fire correctly
- [ ] Events appear in Mixpanel Live View
- [ ] User properties are set correctly
- [ ] Attribution data persists across sessions

## Common Issues

### Issue: Events not appearing in Mixpanel

**Check:**
1. Mixpanel token is valid
2. Network requests are successful (check logs)
3. Event name is in snake_case
4. User ID is valid

### Issue: First-time events firing multiple times

**Fix:**
```dart
// Always check the flag first
final prefs = await SharedPreferences.getInstance();
final hasUsedFeature = prefs.getBool('has_created_task') ?? false;

if (!hasUsedFeature) {
  // Log event
  await prefs.setBool('has_created_task', true);
}
```

### Issue: Attribution data lost

**Fix:**
- Store attribution in SharedPreferences immediately on app launch
- Don't rely on URL parameters after navigation
- Persist data before any async operations

## Next Steps

1. **Review existing code** - Find where these events should be added
2. **Add tracking calls** - Implement tracking at the right places
3. **Test thoroughly** - Use Mixpanel Live View to verify
4. **Monitor in production** - Check GA4 and Mixpanel reports weekly
5. **Optimize funnel** - Use data to improve conversion rates

## Additional Resources

- [Main Funnel Tracking Setup Guide](/branding/docs/FUNNEL_TRACKING_SETUP.md)
- [GA4 Analytics Setup](/branding/docs/ANALYTICS_SETUP.md)
- [Mixpanel Dart SDK](https://pub.dev/packages/mixpanel_analytics)
