# ✅ Funnel Tracking Implementation - COMPLETE

All funnel tracking has been successfully implemented across your Visir app!

## 📊 Complete Funnel Flow

```
Twitter/X (UTM params)
    ↓ [GA4: page_view]
Branding Page (visir.app)
    ↓ [GA4: download with ga_client_id + UTM]
Download
    ↓ [Mixpanel: app_install]
App Launch
    ↓ [Mixpanel: signup_completed]
Sign Up (Google/Apple/Email)
    ↓ [Mixpanel: first_task_created_usage]
Create First Task
    ↓ [Mixpanel: first_email_connected_usage]
Connect Email (Gmail/Outlook)
    ↓ [Mixpanel: first_calendar_synced_usage]
Sync Calendar (Google/Outlook)
    ↓ [Mixpanel: first_slack_connected_usage]
Connect Slack
    ↓ [Mixpanel: subscription_started]
Subscribe (Lemon Squeezy)
```

## ✅ Implementation Summary

### 1. Branding Page (Web)

**Files Modified:**
- `branding/lib/analytics.ts` - Added client ID & UTM tracking functions
- `branding/App.svelte` - Store UTM params on load
- `branding/pages/DownloadPage.svelte` - Enhanced downloads with attribution

**Features:**
- ✅ Captures UTM parameters from URL
- ✅ Gets GA4 client ID for cross-platform tracking
- ✅ Attaches both to download URLs
- ✅ Tracks download events by platform

### 2. Flutter App - Core Tracking

#### a. Helper Service
**File:** `lib/features/common/presentation/utils/first_time_tracker.dart` (NEW)

**Features:**
- Tracks first-time feature usage
- Stores attribution data
- Prevents duplicate tracking

#### b. App Install Tracking
**File:** `lib/bootstrap.dart:168-207`

**Features:**
- ✅ Tracks first app launch
- ✅ Captures GA4 client ID from deep links
- ✅ Captures UTM params from deep links
- ✅ Stores attribution for later use

#### c. Signup Tracking
**Files Modified:**
- `lib/features/auth/application/auth_controller.dart:102-123`
- `lib/features/auth/presentation/screens/auth_screen.dart:224-230, 267-273`
- `lib/features/auth/presentation/screens/email_confirm_screen.dart:41-44`

**Features:**
- ✅ Tracks Google OAuth signup
- ✅ Tracks Apple OAuth signup
- ✅ Tracks Email signup
- ✅ Includes attribution data (GA4 client ID, UTM source)
- ✅ Distinguishes signups from logins

#### d. First Task Created
**File:** `lib/features/task/application/calendar_task_list_controller.dart:279-288`

**Features:**
- ✅ Tracks when user creates first task
- ✅ Includes task type (event vs task)
- ✅ Includes recurring status
- ✅ Only fires once per user

#### e. First Email Connected
**File:** `lib/features/preference/presentation/widgets/integration/mail_integration_widget.dart:114-121`

**Features:**
- ✅ Tracks Gmail connection
- ✅ Tracks Outlook connection
- ✅ Includes provider name
- ✅ Only fires once per user

#### f. First Calendar Synced
**File:** `lib/features/preference/presentation/widgets/integration/calendar_integration_widget.dart:68-74`

**Features:**
- ✅ Tracks Google Calendar sync
- ✅ Tracks Outlook Calendar sync
- ✅ Includes provider name
- ✅ Only fires once per user

#### g. First Slack Connected
**File:** `lib/features/preference/presentation/widgets/integration/chat_integration_widget.dart:75-82`

**Features:**
- ✅ Tracks Slack workspace connection
- ✅ Tracks Discord connection (if used)
- ✅ Includes team count
- ✅ Only fires once per user

#### h. Subscription Started
**File:** `lib/features/auth/application/auth_controller.dart:180-205`

**Features:**
- ✅ Automatically detects new active subscriptions
- ✅ Tracks plan name
- ✅ Tracks price
- ✅ Tracks billing interval (monthly/yearly)
- ✅ Works with Lemon Squeezy webhooks

#### i. Subscription Cancelled
**File:** `lib/features/auth/application/auth_controller.dart:297-323`

**Features:**
- ✅ Tracks subscription cancellation
- ✅ Includes plan name
- ✅ Supports optional cancellation reason

## 📝 Tracking Functions Reference

### Branding Page (GA4)
```typescript
// Track downloads
trackDownload(platform: string)

// Get GA4 client ID
await getClientId()

// Get UTM params
getUTMParams()

// Store UTM params
storeUTMParams()
```

### Flutter App (Mixpanel)
```dart
// App install
await logAppInstall(
  gaClientId: gaClientId,
  utmSource: utmSource,
  utmMedium: utmMedium,
  utmCampaign: utmCampaign,
);

// Signup
await logSignupCompleted(
  userId: userId,
  signupMethod: 'google', // or 'apple', 'email'
  gaClientId: gaClientId,
  utmSource: utmSource,
);

// First feature usage
await FirstTimeTracker.trackFeatureIfFirst(
  'feature_name',
  additionalProperties: {'key': 'value'},
);

// Subscription started
await logSubscriptionStarted(
  userId: userId,
  plan: 'pro',
  amount: 9.99,
  currency: 'USD',
  billingInterval: 'monthly',
);

// Subscription cancelled
await logSubscriptionCancelled(
  userId: userId,
  plan: 'pro',
  reason: 'too_expensive',
);
```

## 🧪 Testing Your Implementation

### 1. Test Branding Page
```bash
cd branding
npm run dev

# Visit with UTM params
# http://localhost:5173?utm_source=test&utm_campaign=dev_test

# Check:
# - sessionStorage has 'visir_utm_params'
# - Download URLs include ga_client_id and UTM params
# - GA4 events appear in Network tab
```

### 2. Test Flutter App Install
```dart
// In your test file or debug mode:
import 'package:Visir/features/common/presentation/utils/first_time_tracker.dart';

// Reset for testing
await FirstTimeTracker.reset();

// Simulate app install with tracking params
final prefs = await SharedPreferences.getInstance();
await prefs.setString('launch_ga_client_id', 'test_client_123');
await prefs.setString('launch_utm_source', 'twitter');

// Restart app - should log app_install event
```

### 3. Test Signup Flow
```dart
// Sign up with any method (Google/Apple/Email)
// Check Mixpanel Live View for 'signup_completed' event
// Should include:
// - signup_method: 'google'/'apple'/'email'
// - ga_client_id (if available)
// - utm_source (if available)
```

### 4. Test First Features
```dart
// For each feature, first reset:
await FirstTimeTracker.reset();

// Then perform action:
// - Create a task
// - Connect Gmail
// - Sync Google Calendar
// - Connect Slack

// Check Mixpanel Live View for events:
// - first_task_created_usage
// - first_email_connected_usage
// - first_calendar_synced_usage
// - first_slack_connected_usage
```

### 5. Test Subscriptions
```dart
// Use Lemon Squeezy test mode
// Purchase a subscription
// Check Mixpanel Live View for 'subscription_started'

// Cancel subscription
// Check Mixpanel Live View for 'subscription_cancelled'
```

## 📊 Setting Up Analytics Dashboards

### Google Analytics 4 Funnel

1. Go to GA4 → Explore → Funnel exploration
2. Add these steps:
   - Step 1: `page_view` (Landing page)
   - Step 2: `download` (Download clicked)
   - Step 3: Custom event from Mixpanel import (if connected)

3. Add breakdowns:
   - `utm_source`
   - `utm_campaign`
   - `platform`

### Mixpanel Funnel

1. Go to Mixpanel → Funnels → New Funnel
2. Add these steps:
   - Step 1: `app_install`
   - Step 2: `signup_completed`
   - Step 3: `first_task_created_usage` OR `first_email_connected_usage` OR `first_calendar_synced_usage` OR `first_slack_connected_usage`
   - Step 4: `subscription_started`

3. Set conversion window: 30 days
4. Add breakdowns:
   - `utm_source`
   - `utm_campaign`
   - `platform`
   - `signup_method`

## 📈 Key Metrics to Monitor

### Conversion Rates (Targets)
- Landing → Download: **15-25%**
- Download → Install: **60-80%**
- Install → Signup: **40-60%**
- Signup → First Feature: **70-90%**
- First Feature → Subscribe: **5-15%**

### Time to Convert (Targets)
- Download → Install: **< 1 hour**
- Install → Signup: **< 5 minutes**
- Signup → First Feature: **< 10 minutes**
- First Feature → Subscribe: **7-14 days**

## 🎯 Using UTM Parameters

Always use UTM parameters in your marketing links:

```
# Twitter
https://visir.app?utm_source=twitter&utm_medium=social&utm_campaign=launch

# Product Hunt
https://visir.app?utm_source=producthunt&utm_medium=referral&utm_campaign=launch

# Email Newsletter
https://visir.app?utm_source=newsletter&utm_medium=email&utm_campaign=weekly

# Reddit
https://visir.app?utm_source=reddit&utm_medium=social&utm_campaign=post

# Hacker News
https://visir.app?utm_source=hackernews&utm_medium=social&utm_campaign=show_hn
```

## 🔍 Debugging

### Check if events are firing

**Browser (Branding Page):**
```javascript
// Open console
console.log(sessionStorage.getItem('visir_utm_params'))
console.log(window.dataLayer) // Should show GA4 events
```

**Flutter App:**
```dart
// Check Mixpanel Live View
// https://mixpanel.com/report/<your-project>/live

// Or check SharedPreferences
final prefs = await SharedPreferences.getInstance();
print(prefs.getBool('app_installed'));
print(prefs.getBool('first_time_task_created'));
```

### Common Issues

1. **Events not appearing in Mixpanel**
   - Check Mixpanel token in config.json
   - Verify network requests to api.mixpanel.com
   - Check that user is logged in (userId is set)

2. **GA4 client ID not passing**
   - Ensure GA4 loads before download
   - Check download URL includes `ga_client_id` parameter
   - Verify getClientId() returns a value

3. **First-time events firing multiple times**
   - Check SharedPreferences isn't being cleared
   - Verify flag is set after event fires
   - Test with FirstTimeTracker.reset() only in development

## 📚 Documentation

- [Main Setup Guide](branding/docs/FUNNEL_TRACKING_SETUP.md)
- [Integration Guide](FUNNEL_INTEGRATION_GUIDE.md)
- [Analytics Setup](branding/docs/ANALYTICS_SETUP.md)

## ✅ Final Checklist

- [x] Branding page UTM tracking
- [x] Branding page GA4 client ID bridge
- [x] Download tracking with attribution
- [x] App install event
- [x] Signup tracking (Google/Apple/Email)
- [x] First task created
- [x] First email connected
- [x] First calendar synced
- [x] First Slack connected
- [x] Subscription started (auto-detected)
- [x] Subscription cancelled
- [x] Helper service for first-time tracking
- [x] Documentation created

## 🚀 You're Ready!

Your complete funnel tracking is now live. Start monitoring your metrics and optimize your conversion funnel!

**Next Steps:**
1. Deploy to production
2. Create GA4 and Mixpanel funnels
3. Add UTM params to all marketing links
4. Monitor weekly conversion rates
5. A/B test landing page variations
6. Optimize drop-off points

Good luck! 🎉
