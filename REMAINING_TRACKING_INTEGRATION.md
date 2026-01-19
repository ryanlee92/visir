# Remaining Tracking Integration Points

This guide shows where to add the remaining funnel tracking calls in your app.

## ✅ Already Implemented

1. **App Install Tracking** - Added to `lib/bootstrap.dart:168-207`
   - Tracks first launch with UTM params and GA4 client ID
   - Uses `FirstTimeTracker.trackAppInstallIfFirst()`

2. **Signup Tracking** - Added to authentication flows
   - Apple: `lib/features/auth/presentation/screens/auth_screen.dart:224-230`
   - Google: `lib/features/auth/presentation/screens/auth_screen.dart:267-273`
   - Email: `lib/features/auth/presentation/screens/email_confirm_screen.dart:41-44`
   - Uses `logSignupCompleted()` with signup method

3. **First Task Created** - Added to `lib/features/task/application/calendar_task_list_controller.dart:279-288`
   - Tracks when user creates their first task
   - Uses `FirstTimeTracker.trackFeatureIfFirst('task_created')`

## 📝 TODO: Integration Tracking

You need to add tracking for first-time email, calendar, and Slack connections. Use the helper function:

```dart
import 'package:Visir/features/common/presentation/utils/first_time_tracker.dart';

await FirstTimeTracker.trackFeatureIfFirst(
  'feature_name',
  additionalProperties: {'key': 'value'},
);
```

### 1. Email Integration Tracking

**Where to add:** After successful Gmail/Outlook OAuth connection

**Likely files to check:**
- `lib/features/inbox/application/inbox_source_mails_controller.dart`
- `lib/features/preference/presentation/widgets/integration/mail_integration_widget.dart`
- Look for OAuth success callbacks or mail account connection success handlers

**Code to add:**
```dart
// After successful email OAuth connection
await FirstTimeTracker.trackFeatureIfFirst(
  'email_connected',
  additionalProperties: {
    'provider': provider, // 'gmail' or 'outlook'
  },
);
```

**How to find the right place:**
1. Search for "OAuth" or "mail" connection logic in inbox feature
2. Look for Supabase auth signInWithOAuth for Google/Microsoft
3. Find the success callback after OAuth completes
4. Add tracking there

**Example pattern to look for:**
```dart
// Somewhere in your code after OAuth success:
if (authResult.success) {
  // Add tracking here
  await FirstTimeTracker.trackFeatureIfFirst('email_connected',
    additionalProperties: {'provider': 'gmail'});
}
```

### 2. Calendar Integration Tracking

**Where to add:** After successful Google Calendar/Outlook Calendar sync

**Likely files to check:**
- `lib/features/calendar/application/calendar_list_controller.dart`
- `lib/features/calendar/application/calendar_event_list_controller.dart`
- `lib/features/preference/presentation/widgets/integration/calendar_integration_widget.dart`

**Code to add:**
```dart
// After successful calendar sync
await FirstTimeTracker.trackFeatureIfFirst(
  'calendar_synced',
  additionalProperties: {
    'provider': provider, // 'google', 'outlook', 'apple'
  },
);
```

**How to find the right place:**
1. Search for calendar sync or calendar OAuth in calendar feature
2. Look for initial calendar data fetch after OAuth
3. Add tracking when first calendar events are successfully loaded

### 3. Slack Integration Tracking

**Where to add:** After successful Slack workspace connection

**Likely files to check:**
- `lib/features/inbox/application/inbox_source_chats_controller.dart`
- `lib/features/preference/presentation/widgets/integration/chat_integration_widget.dart`
- Look for Slack OAuth or channel connection logic

**Code to add:**
```dart
// After successful Slack connection
await FirstTimeTracker.trackFeatureIfFirst(
  'slack_connected',
  additionalProperties: {
    'workspace_name': workspaceName, // optional
  },
);
```

**How to find the right place:**
1. Search for "Slack" or "chat" integration in inbox feature
2. Find where Slack OAuth completes or workspace is connected
3. Add tracking after successful connection

## 📝 TODO: Subscription Tracking

### Subscription Started

**Where to add:** After successful subscription purchase

**Likely files to check:**
- `lib/features/auth/presentation/screens/subscription_screen.dart`
- `lib/features/auth/application/auth_controller.dart`
- Look for Lemon Squeezy checkout or webhook handlers

**Code to add:**
```dart
import 'package:Visir/features/common/presentation/utils/log_event.dart';

// After successful subscription purchase
await logSubscriptionStarted(
  userId: user.id,
  plan: variantId, // e.g., 'pro', 'team'
  amount: price,
  currency: 'USD',
  billingInterval: interval, // 'monthly' or 'yearly'
);
```

**Where to find:**
1. **Lemon Squeezy Checkout:** Look for checkout URL creation or redirect
2. **Webhook Handler:** Check if there's a webhook endpoint that receives subscription events
3. **Subscription Status Update:** Find where user subscription status is updated after purchase

**Possible locations:**
```dart
// In auth_controller.dart or subscription screen:
// After checkout completes or webhook confirms subscription
if (subscriptionActive) {
  await logSubscriptionStarted(
    userId: userId,
    plan: variant.name,
    amount: variant.price / 100.0,
    currency: 'USD',
    billingInterval: variant.isMonthly ? 'monthly' : 'yearly',
  );
}
```

### Subscription Cancelled

**Where to add:** When user cancels subscription

**In `auth_controller.dart`**, find the `cancelSubscription` method around line 268:

```dart
Future<bool?> cancelSubscription({required String subscriptionId, String? reason}) async {
  // existing cancel logic...
  final result = await repository.cancelSubscription(...);

  // Add tracking after successful cancellation
  if (result != null && result == true) {
    final userId = state.requireValue.id;
    final currentSubscription = state.requireValue.subscription;

    await logSubscriptionCancelled(
      userId: userId,
      plan: currentSubscription?.plan ?? 'unknown',
      reason: reason,
    );
  }

  return result;
}
```

### Subscription Renewed

**Where to add:** This should be handled by Lemon Squeezy webhooks

**Create a webhook endpoint** (if not exists) that receives subscription renewal events from Lemon Squeezy.

**Typical webhook handler:**
```dart
// In your webhook handler (backend or edge function)
Future<void> handleLemonSqueezyWebhook(Map<String, dynamic> payload) async {
  final eventType = payload['meta']['event_name'];

  if (eventType == 'subscription_payment_success') {
    final subscription = payload['data'];
    final userId = subscription['user_id']; // however you store user mapping

    await logSubscriptionRenewed(
      userId: userId,
      plan: subscription['product_name'],
      amount: double.parse(subscription['total']) / 100.0,
    );
  }
}
```

## Quick Search Commands

Use these to find integration points:

```bash
# Find email integration
grep -r "Gmail\|Outlook\|mail.*OAuth" lib/features/inbox/

# Find calendar integration
grep -r "Calendar.*OAuth\|sync.*calendar" lib/features/calendar/

# Find Slack integration
grep -r "Slack\|workspace" lib/features/inbox/

# Find subscription logic
grep -r "checkout\|purchase\|subscribe" lib/features/auth/
```

## Testing Your Implementation

After adding tracking, test each flow:

### 1. Test Email Connection
```dart
// Clear first-time flag for testing
await FirstTimeTracker.reset();

// Connect an email account
// Check Mixpanel Live View for: first_email_connected_usage
```

### 2. Test Calendar Sync
```dart
// Clear first-time flag
await FirstTimeTracker.reset();

// Sync a calendar
// Check Mixpanel Live View for: first_calendar_synced_usage
```

### 3. Test Slack Connection
```dart
// Clear first-time flag
await FirstTimeTracker.reset();

// Connect Slack workspace
// Check Mixpanel Live View for: first_slack_connected_usage
```

### 4. Test Subscription Purchase
```dart
// Use Lemon Squeezy test mode
// Complete a test subscription purchase
// Check Mixpanel Live View for: subscription_started
```

## Verification Checklist

After implementing all tracking:

- [ ] Email connection tracked in Mixpanel
- [ ] Calendar sync tracked in Mixpanel
- [ ] Slack connection tracked in Mixpanel
- [ ] Subscription started tracked in Mixpanel
- [ ] Subscription cancelled tracked in Mixpanel
- [ ] Subscription renewed tracked in Mixpanel (via webhook)
- [ ] All events include correct properties
- [ ] User ID is correctly attached to all events

## Example: Complete Integration Pattern

Here's a complete example of how to add tracking to any OAuth integration:

```dart
// Example: Adding tracking to email integration
class EmailIntegrationController {

  Future<void> connectGmail() async {
    try {
      // Existing OAuth logic
      final result = await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        scopes: ['email', 'https://www.googleapis.com/auth/gmail.readonly'],
      );

      if (result) {
        // Fetch emails to confirm connection works
        await _fetchEmails();

        // ✅ ADD TRACKING HERE - After successful connection
        await FirstTimeTracker.trackFeatureIfFirst(
          'email_connected',
          additionalProperties: {
            'provider': 'gmail',
            'scopes': 'readonly',
          },
        );

        // Show success message
        _showSuccessMessage();
      }
    } catch (e) {
      // Handle error
    }
  }
}
```

## Next Steps

1. Search for OAuth integration points using the commands above
2. Add tracking calls after successful OAuth connections
3. Find subscription purchase completion point
4. Add subscription tracking
5. Test each integration in development
6. Verify events appear in Mixpanel Live View
7. Deploy to production

## Need Help?

- Check `FUNNEL_INTEGRATION_GUIDE.md` for detailed examples
- Review `lib/features/common/presentation/utils/first_time_tracker.dart` for API
- Review `lib/features/common/presentation/utils/log_event.dart` for all tracking functions
