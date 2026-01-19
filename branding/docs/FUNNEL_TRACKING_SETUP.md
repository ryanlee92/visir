# Funnel Tracking Setup Guide

This guide covers the complete funnel tracking implementation for Visir: from Twitter/X to subscription.

## Funnel Overview

```
Twitter/X → Branding Page → Download → Sign Up → Core Features → Subscribe
```

## Implementation Details

### 1. Traffic Source Tracking (X → Branding Page)

#### UTM Parameters

Use UTM parameters in all marketing links to track traffic sources:

```
https://visir.app?utm_source=twitter&utm_medium=social&utm_campaign=launch
```

**Standard UTM Parameters:**
- `utm_source`: Traffic source (e.g., `twitter`, `linkedin`, `producthunt`)
- `utm_medium`: Medium type (e.g., `social`, `email`, `paid`)
- `utm_campaign`: Campaign name (e.g., `launch`, `feature_announcement`)
- `utm_term`: Paid keyword (optional)
- `utm_content`: Ad variation (optional)

**Implementation:**
- UTM params are automatically captured on page load (`branding/App.svelte:273`)
- Stored in sessionStorage for persistence across navigation
- Attached to download links and tracked in Mixpanel

### 2. Branding Page → Download

#### Tracking Downloads

Downloads are tracked with:
- **Platform** (macos, windows, ios, android)
- **UTM parameters** from session storage
- **GA4 client ID** for cross-platform tracking

**Code Location:** `branding/pages/DownloadPage.svelte:7-38`

**Example Usage:**
```typescript
await handleDownload('macos', 'https://visir.pro/release/visir-setup.zip');
```

**What Gets Tracked:**
```javascript
{
  event: 'download',
  platform: 'macos',
  ga_client_id: 'GA1.1.xxxxx',
  utm_source: 'twitter',
  utm_medium: 'social',
  utm_campaign: 'launch'
}
```

### 3. Download → App Install

#### App Install Tracking (Flutter)

When the app is first launched, track the install event with UTM params:

**Code Location:** `lib/features/common/presentation/utils/log_event.dart:101-123`

**Usage Example:**
```dart
// Parse URL parameters from app launch
final Uri? launchUri = // Get from app initialization
final params = launchUri?.queryParameters ?? {};

await logAppInstall(
  gaClientId: params['ga_client_id'],
  utmSource: params['utm_source'],
  utmMedium: params['utm_medium'],
  utmCampaign: params['utm_campaign'],
  userId: currentUser?.id,
);
```

**Integration Points:**

1. **Deep Links**: Handle `visir://install?ga_client_id=xxx&utm_source=twitter`
2. **App Initialization**: Check for first launch and log install event
3. **Store UTM Data**: Save to local storage for later attribution

### 4. Sign Up Tracking

#### Signup Event

Track when user completes signup:

**Code Location:** `lib/features/common/presentation/utils/log_event.dart:126-141`

**Usage Example:**
```dart
// After successful signup
await logSignupCompleted(
  userId: user.id,
  signupMethod: 'email', // or 'google', 'apple', 'microsoft'
  gaClientId: getStoredGaClientId(),
  utmSource: getStoredUtmSource(),
);

// Set user profile in Mixpanel
await setAnalyticsUserProfile(
  user: user,
  moneySaved: 0,
);
```

**Signup Methods:**
- `email` - Email/password signup
- `google` - Google OAuth
- `apple` - Apple Sign In
- `microsoft` - Microsoft OAuth
- `slack` - Slack OAuth

### 5. First-Time Feature Usage

Track when users first use core features to understand activation:

**Code Location:** `lib/features/common/presentation/utils/log_event.dart:144-157`

**Key Features to Track:**

```dart
// First task created
await logFirstTimeFeature(
  featureName: 'task_created',
  userId: userId,
);

// First email connected
await logFirstTimeFeature(
  featureName: 'email_connected',
  userId: userId,
  additionalProperties: {'provider': 'gmail'},
);

// First calendar synced
await logFirstTimeFeature(
  featureName: 'calendar_synced',
  userId: userId,
);

// First Slack workspace connected
await logFirstTimeFeature(
  featureName: 'slack_connected',
  userId: userId,
);

// First AI assistant usage
await logFirstTimeFeature(
  featureName: 'ai_assistant_used',
  userId: userId,
);
```

**Recommended Activation Metrics:**
- Created first task
- Connected at least one integration (email/calendar/Slack)
- Used calendar view
- Completed onboarding

### 6. Subscription Tracking

Track subscription lifecycle events:

**Code Location:** `lib/features/common/presentation/utils/log_event.dart:160-209`

**Subscription Started:**
```dart
await logSubscriptionStarted(
  userId: user.id,
  plan: 'pro', // or 'team', 'enterprise'
  amount: 9.99,
  currency: 'USD',
  billingInterval: 'monthly', // or 'yearly'
);
```

**Subscription Cancelled:**
```dart
await logSubscriptionCancelled(
  userId: user.id,
  plan: 'pro',
  reason: 'too_expensive', // optional
);
```

**Subscription Renewed:**
```dart
await logSubscriptionRenewed(
  userId: user.id,
  plan: 'pro',
  amount: 9.99,
);
```

## Google Analytics 4 (GA4) Funnel Setup

### Creating a Funnel Exploration

1. **Navigate to GA4 Explorations**
   - Go to Google Analytics 4
   - Click "Explore" in the left sidebar
   - Click "Blank" to create new exploration

2. **Select Funnel Exploration**
   - Click on "Technique" dropdown
   - Select "Funnel exploration"

3. **Define Funnel Steps**

   Configure the following steps:

   **Step 1: Page View (Branding)**
   - Event name: `page_view`
   - Add condition: `page_path` contains `/`
   - Name: "Landing Page Visit"

   **Step 2: Download Click**
   - Event name: `download`
   - Any `platform` value
   - Name: "Download Started"

   **Step 3: App Install**
   - Event name: `app_install`
   - Name: "App Installed"

   **Step 4: Signup Completed**
   - Event name: `signup_completed`
   - Name: "Signup Completed"

   **Step 5: First Feature Usage**
   - Event name: matches regex `first_.*_usage`
   - Name: "First Feature Used"

   **Step 6: Subscription Started**
   - Event name: `subscription_started`
   - Name: "Subscription Started"

4. **Configure Breakdown Dimensions**

   Add these dimensions for deeper insights:
   - `utm_source` - Traffic source
   - `utm_campaign` - Campaign name
   - `platform` - Device platform
   - `signup_method` - How user signed up

5. **Set Funnel Settings**
   - **Funnel type**: Open funnel (users can skip steps)
   - **Elapsed time**: 30 days (or your preferred window)

### Key Metrics to Monitor

#### Conversion Rates
- Landing Page → Download: **Target: 15-25%**
- Download → Install: **Target: 60-80%**
- Install → Signup: **Target: 40-60%**
- Signup → First Feature: **Target: 70-90%**
- First Feature → Subscribe: **Target: 5-15%**

#### Time to Convert
- Download to Install: **Target: < 1 hour**
- Install to Signup: **Target: < 5 minutes**
- Signup to First Feature: **Target: < 10 minutes**
- First Feature to Subscribe: **Target: 7-14 days**

## Mixpanel Funnel Setup

### Creating a Funnel Report

1. **Navigate to Funnels**
   - Go to Mixpanel dashboard
   - Click "Funnels" in the left sidebar
   - Click "+ New Funnel"

2. **Define Funnel Steps**

   ```
   Step 1: app_install
   Step 2: signup_completed
   Step 3: first_*_usage (any first feature)
   Step 4: subscription_started
   ```

3. **Add Breakdown Properties**
   - `utm_source`
   - `utm_campaign`
   - `platform`
   - `signup_method`

4. **Set Conversion Window**
   - Recommended: 30 days
   - Adjust based on your sales cycle

### User Cohort Analysis

Create cohorts for different user segments:

**High Intent Users:**
```
- utm_source = 'twitter' OR 'producthunt'
- completed signup within 24h of install
- used 2+ features in first week
```

**Low Intent Users:**
```
- completed signup after 7+ days
- used only 1 feature
```

## Testing the Funnel

### Local Testing

1. **Test Branding Page Tracking**
   ```bash
   cd branding
   npm run dev

   # Visit with UTM params
   # http://localhost:5173?utm_source=test&utm_campaign=dev_test
   ```

   Check browser console for:
   - UTM params stored in sessionStorage
   - GA4 page view events

2. **Test Download Tracking**
   - Click download button
   - Verify GA4 event with `download` event name
   - Check download URL includes `ga_client_id` and UTM params

3. **Test Flutter App Events**
   ```dart
   // In your Flutter test
   await logAppInstall(
     gaClientId: 'test_ga_client_id',
     utmSource: 'test',
     userId: 'test_user_123',
   );
   ```

   Verify in Mixpanel's Live View:
   - Event appears with correct properties
   - `ga_client_id` matches from download

### Production Validation

1. **Check GA4 Realtime Reports**
   - Go to Realtime → Events
   - Perform test conversion flow
   - Verify all events appear

2. **Check Mixpanel Live View**
   - Go to "Live View"
   - Watch for events in real-time
   - Verify properties are correct

3. **End-to-End Test**
   - Click Twitter link with UTM params
   - Download app
   - Install and launch
   - Complete signup
   - Use first feature
   - Check both GA4 and Mixpanel

## Troubleshooting

### GA4 Events Not Appearing

**Issue:** Events not showing in GA4

**Solutions:**
1. Check GA4 Measurement ID is correct in `.env`
2. Verify gtag script loaded (check Network tab)
3. Wait 24-48 hours for historical data to appear
4. Use GA4 DebugView for real-time debugging

### Mixpanel Events Missing

**Issue:** Events not appearing in Mixpanel

**Solutions:**
1. Check Mixpanel token in `assets/config/config.json`
2. Verify network request to `api.mixpanel.com/track`
3. Check base64 encoding is correct
4. Look for errors in Dart console

### GA4 Client ID Not Passing

**Issue:** `ga_client_id` is null in Mixpanel events

**Solutions:**
1. Ensure GA4 loads before download click
2. Check `getClientId()` returns valid value
3. Verify download URL includes parameter
4. Check deep link parsing in Flutter app

### UTM Params Not Persisting

**Issue:** UTM params lost between pages

**Solutions:**
1. Check sessionStorage is enabled
2. Verify `storeUTMParams()` called on mount
3. Ensure `getStoredUTMParams()` reads correctly
4. Test with browser dev tools → Application → Session Storage

## Best Practices

### 1. UTM Naming Conventions

Use consistent, descriptive names:

```
utm_source:
  - twitter
  - linkedin
  - producthunt
  - email
  - organic

utm_medium:
  - social
  - email
  - paid
  - referral
  - organic

utm_campaign:
  - launch
  - feature_announcement
  - pricing_update
  - holiday_promo
```

### 2. Event Naming

Follow consistent patterns:
- Use snake_case for event names
- Use descriptive, action-based names
- Group related events with prefixes

```
✅ Good:
- signup_completed
- subscription_started
- first_email_connected

❌ Bad:
- signup
- sub
- email
```

### 3. Property Naming

Be consistent and descriptive:

```
✅ Good:
- signup_method: 'google'
- billing_interval: 'monthly'
- feature_name: 'email_connected'

❌ Bad:
- method: 'g'
- interval: 'm'
- feature: 'email'
```

### 4. Data Quality

- **Validate user_id**: Always pass valid user ID after auth
- **Handle nulls**: Use optional parameters properly
- **Test thoroughly**: Test each event in dev before production
- **Monitor regularly**: Set up weekly reports to catch issues

### 5. Privacy & Compliance

- **GDPR**: Get consent before tracking in EU
- **CCPA**: Allow opt-out for California users
- **Data Minimization**: Only track necessary properties
- **Anonymization**: Don't pass PII in event properties

## Integration Checklist

Use this checklist when implementing funnel tracking:

### Branding Page
- [ ] GA4 initialized on page load
- [ ] UTM params captured and stored
- [ ] Download events fire with correct platform
- [ ] GA4 client ID passed in download URLs
- [ ] UTM params included in download URLs

### Flutter App
- [ ] App install event fires on first launch
- [ ] Deep link params parsed correctly
- [ ] GA4 client ID stored and attributed
- [ ] UTM params stored for later attribution
- [ ] Signup event fires with correct method
- [ ] First feature usage events implemented
- [ ] Subscription events fire for all states

### Analytics Platforms
- [ ] GA4 funnel configured with all steps
- [ ] Mixpanel funnel created
- [ ] Key properties available for breakdown
- [ ] Real-time events validated
- [ ] Reports scheduled for weekly review

### Testing
- [ ] Tested complete flow end-to-end
- [ ] Verified events in GA4 DebugView
- [ ] Checked events in Mixpanel Live View
- [ ] Validated cross-platform attribution
- [ ] Tested with multiple traffic sources

## Support

For issues or questions:
- Check GA4 DebugView for real-time event debugging
- Use Mixpanel Live View to verify events
- Review browser console for JavaScript errors
- Check Flutter logs for Dart errors

## Related Documentation

- [GA4 Analytics Setup](./ANALYTICS_SETUP.md) - Basic GA4 configuration
- [Mixpanel Best Practices](https://docs.mixpanel.com/docs/tracking/how-tos/effective-event-tracking)
- [UTM Parameter Guide](https://ga-dev-tools.google/campaign-url-builder/)
