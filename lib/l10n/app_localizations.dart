import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @sign_in.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get sign_in;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @going_question.
  ///
  /// In en, this message translates to:
  /// **'Going?'**
  String get going_question;

  /// No description provided for @add_organization.
  ///
  /// In en, this message translates to:
  /// **'Add Organization'**
  String get add_organization;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @window.
  ///
  /// In en, this message translates to:
  /// **'Window'**
  String get window;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @yesterday_short.
  ///
  /// In en, this message translates to:
  /// **'Yest.'**
  String get yesterday_short;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @tab_calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get tab_calendar;

  /// No description provided for @tab_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tab_home;

  /// No description provided for @tab_board.
  ///
  /// In en, this message translates to:
  /// **'Board'**
  String get tab_board;

  /// No description provided for @tab_chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get tab_chat;

  /// No description provided for @tab_mail.
  ///
  /// In en, this message translates to:
  /// **'Mail'**
  String get tab_mail;

  /// No description provided for @tab_settings.
  ///
  /// In en, this message translates to:
  /// **'Pref'**
  String get tab_settings;

  /// No description provided for @tab_inbox.
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get tab_inbox;

  /// No description provided for @tab_task.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get tab_task;

  /// No description provided for @general_title.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general_title;

  /// No description provided for @agent_pref_title.
  ///
  /// In en, this message translates to:
  /// **'Agent'**
  String get agent_pref_title;

  /// No description provided for @agent_pref_api_key.
  ///
  /// In en, this message translates to:
  /// **'API Key'**
  String get agent_pref_api_key;

  /// No description provided for @agent_pref_openai_api_key.
  ///
  /// In en, this message translates to:
  /// **'OpenAI API Key'**
  String get agent_pref_openai_api_key;

  /// No description provided for @agent_pref_api_key_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your OpenAI API key'**
  String get agent_pref_api_key_hint;

  /// No description provided for @agent_pref_provider_openai.
  ///
  /// In en, this message translates to:
  /// **'OpenAI'**
  String get agent_pref_provider_openai;

  /// No description provided for @agent_pref_provider_anthropic.
  ///
  /// In en, this message translates to:
  /// **'Anthropic'**
  String get agent_pref_provider_anthropic;

  /// No description provided for @agent_pref_provider_google.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get agent_pref_provider_google;

  /// No description provided for @agent_pref_api_key_hint_anthropic.
  ///
  /// In en, this message translates to:
  /// **'Enter your Anthropic API key'**
  String get agent_pref_api_key_hint_anthropic;

  /// No description provided for @agent_pref_api_key_hint_google.
  ///
  /// In en, this message translates to:
  /// **'Enter your Google AI API key'**
  String get agent_pref_api_key_hint_google;

  /// No description provided for @agent_pref_description.
  ///
  /// In en, this message translates to:
  /// **'We never log your data or engage in any activity that could threaten your privacy. However, if you want to use your own AI provider API directly, you can enter your API key here. With an API key, you can directly command or chat with AI even with a Pro subscription.'**
  String get agent_pref_description;

  /// No description provided for @agent_pref_default_ai_provider.
  ///
  /// In en, this message translates to:
  /// **'Default Agent AI Provider'**
  String get agent_pref_default_ai_provider;

  /// No description provided for @agent_pref_default_ai_provider_description.
  ///
  /// In en, this message translates to:
  /// **'Default inbox suggestions and next schedule summary features will use the API key you\'ve entered.'**
  String get agent_pref_default_ai_provider_description;

  /// No description provided for @agent_pref_no_api_keys.
  ///
  /// In en, this message translates to:
  /// **'No API keys configured. Please add an API key above.'**
  String get agent_pref_no_api_keys;

  /// No description provided for @agent_pref_none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get agent_pref_none;

  /// No description provided for @agent_pref_additional_tokens.
  ///
  /// In en, this message translates to:
  /// **'Additional Tokens'**
  String get agent_pref_additional_tokens;

  /// No description provided for @agent_pref_current_tokens.
  ///
  /// In en, this message translates to:
  /// **'Current: {credits}'**
  String agent_pref_current_tokens(String credits);

  /// No description provided for @agent_pref_additional_tokens_description.
  ///
  /// In en, this message translates to:
  /// **'Purchase additional AI tokens for AI-based orders and summaries. Tokens are used when you don\'t provide your own API key.'**
  String get agent_pref_additional_tokens_description;

  /// No description provided for @agent_pref_system_prompt.
  ///
  /// In en, this message translates to:
  /// **'System Prompt'**
  String get agent_pref_system_prompt;

  /// No description provided for @agent_pref_system_prompt_description.
  ///
  /// In en, this message translates to:
  /// **'Customize the system prompt that will be used for all agent actions. This prompt will be prepended to the default system message.'**
  String get agent_pref_system_prompt_description;

  /// No description provided for @agent_pref_system_prompt_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your custom system prompt (optional)'**
  String get agent_pref_system_prompt_hint;

  /// No description provided for @general_theme_title.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get general_theme_title;

  /// No description provided for @general_text_size.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get general_text_size;

  /// No description provided for @general_theme_system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get general_theme_system;

  /// No description provided for @general_theme_light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get general_theme_light;

  /// No description provided for @general_theme_dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get general_theme_dark;

  /// No description provided for @general_pref_appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get general_pref_appearance;

  /// No description provided for @general_pref_tab_bar_display.
  ///
  /// In en, this message translates to:
  /// **'Tab bar display'**
  String get general_pref_tab_bar_display;

  /// No description provided for @general_pref_tab_bar_standard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get general_pref_tab_bar_standard;

  /// No description provided for @general_pref_tab_bar_always_collapsed.
  ///
  /// In en, this message translates to:
  /// **'Always collapsed'**
  String get general_pref_tab_bar_always_collapsed;

  /// No description provided for @general_pref_hide_unread_indicator.
  ///
  /// In en, this message translates to:
  /// **'Tab icon badge'**
  String get general_pref_hide_unread_indicator;

  /// No description provided for @account_title.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account_title;

  /// No description provided for @account_sign_out.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get account_sign_out;

  /// No description provided for @account_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get account_delete;

  /// No description provided for @version_title.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version_title;

  /// No description provided for @version_check_for_updates.
  ///
  /// In en, this message translates to:
  /// **'Check for Updates'**
  String get version_check_for_updates;

  /// No description provided for @version_update_version.
  ///
  /// In en, this message translates to:
  /// **'Get latest version'**
  String get version_update_version;

  /// No description provided for @version_up_to_date_title.
  ///
  /// In en, this message translates to:
  /// **'Up to date'**
  String get version_up_to_date_title;

  /// No description provided for @version_up_to_date_description.
  ///
  /// In en, this message translates to:
  /// **'You’re running the latest version. No action needed.'**
  String get version_up_to_date_description;

  /// No description provided for @version_up_to_date_confirm.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get version_up_to_date_confirm;

  /// No description provided for @version_new_version_ready_title.
  ///
  /// In en, this message translates to:
  /// **'New version ready'**
  String get version_new_version_ready_title;

  /// No description provided for @version_new_version_ready_description.
  ///
  /// In en, this message translates to:
  /// **'A newer version is available. Update now for the best Visir experience.'**
  String get version_new_version_ready_description;

  /// No description provided for @version_new_version_ready_confirm.
  ///
  /// In en, this message translates to:
  /// **'Update in Store'**
  String get version_new_version_ready_confirm;

  /// No description provided for @calendar_pref_title.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar_pref_title;

  /// No description provided for @calendar_pref_start_title.
  ///
  /// In en, this message translates to:
  /// **'Start week on'**
  String get calendar_pref_start_title;

  /// No description provided for @calendar_pref_week_title.
  ///
  /// In en, this message translates to:
  /// **'Week view start day'**
  String get calendar_pref_week_title;

  /// No description provided for @calendar_pref_default.
  ///
  /// In en, this message translates to:
  /// **'Default calendar'**
  String get calendar_pref_default;

  /// No description provided for @calendar_pref_duration.
  ///
  /// In en, this message translates to:
  /// **'Default event duration'**
  String get calendar_pref_duration;

  /// No description provided for @calendar_pref_last_used.
  ///
  /// In en, this message translates to:
  /// **'Last used'**
  String get calendar_pref_last_used;

  /// No description provided for @calendar_pref_event_reminder.
  ///
  /// In en, this message translates to:
  /// **'Default event reminders'**
  String get calendar_pref_event_reminder;

  /// No description provided for @calendar_pref_event_reminder_body.
  ///
  /// In en, this message translates to:
  /// **'To update your preferences, access “Settings for my calendars” → “Event notifications” as you would in '**
  String get calendar_pref_event_reminder_body;

  /// No description provided for @calendar_pref_event_reminder_link.
  ///
  /// In en, this message translates to:
  /// **'Google Calendar'**
  String get calendar_pref_event_reminder_link;

  /// No description provided for @calendar_pref_include_conference_link.
  ///
  /// In en, this message translates to:
  /// **'Add conference'**
  String get calendar_pref_include_conference_link;

  /// No description provided for @calendar_list_title.
  ///
  /// In en, this message translates to:
  /// **'Calendar Lists'**
  String get calendar_list_title;

  /// No description provided for @calendar_simple_add_location.
  ///
  /// In en, this message translates to:
  /// **'Add Location'**
  String get calendar_simple_add_location;

  /// No description provided for @calendar_connect_to_create.
  ///
  /// In en, this message translates to:
  /// **'Connect Calendar to create events'**
  String get calendar_connect_to_create;

  /// No description provided for @integrate.
  ///
  /// In en, this message translates to:
  /// **'Integrate'**
  String get integrate;

  /// No description provided for @chat_pref_title.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat_pref_title;

  /// No description provided for @chat_display_preferences.
  ///
  /// In en, this message translates to:
  /// **'Display Preferences'**
  String get chat_display_preferences;

  /// No description provided for @chat_chat_lists.
  ///
  /// In en, this message translates to:
  /// **'Chat Lists'**
  String get chat_chat_lists;

  /// No description provided for @chat_show_channels.
  ///
  /// In en, this message translates to:
  /// **'Show channels'**
  String get chat_show_channels;

  /// No description provided for @chat_show_dms.
  ///
  /// In en, this message translates to:
  /// **'Show DMs'**
  String get chat_show_dms;

  /// No description provided for @chat_sort_channels.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get chat_sort_channels;

  /// No description provided for @chat_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get chat_all;

  /// No description provided for @chat_unread_only.
  ///
  /// In en, this message translates to:
  /// **'Unread only'**
  String get chat_unread_only;

  /// No description provided for @chat_alphabetically.
  ///
  /// In en, this message translates to:
  /// **'Alphabetically'**
  String get chat_alphabetically;

  /// No description provided for @chat_most_recent.
  ///
  /// In en, this message translates to:
  /// **'Most recent'**
  String get chat_most_recent;

  /// No description provided for @channel_list_search.
  ///
  /// In en, this message translates to:
  /// **'Search channels'**
  String get channel_list_search;

  /// No description provided for @channel_list_channels.
  ///
  /// In en, this message translates to:
  /// **'Channels'**
  String get channel_list_channels;

  /// No description provided for @channel_list_unlisted_channels.
  ///
  /// In en, this message translates to:
  /// **'Hidden channels'**
  String get channel_list_unlisted_channels;

  /// No description provided for @channel_list_all_channels.
  ///
  /// In en, this message translates to:
  /// **'All channels'**
  String get channel_list_all_channels;

  /// No description provided for @channel_list_hide_channel.
  ///
  /// In en, this message translates to:
  /// **'Hide channel'**
  String get channel_list_hide_channel;

  /// No description provided for @chat_search_emoji.
  ///
  /// In en, this message translates to:
  /// **'Search emoji'**
  String get chat_search_emoji;

  /// No description provided for @chat_chats.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get chat_chats;

  /// No description provided for @chat_message.
  ///
  /// In en, this message translates to:
  /// **'Add message'**
  String get chat_message;

  /// No description provided for @chat_focus_last_message.
  ///
  /// In en, this message translates to:
  /// **'(Press {shortcut} to focus the last message)'**
  String chat_focus_last_message(Object shortcut);

  /// No description provided for @chat_replies.
  ///
  /// In en, this message translates to:
  /// **'replies'**
  String get chat_replies;

  /// No description provided for @chat_thread.
  ///
  /// In en, this message translates to:
  /// **'Thread'**
  String get chat_thread;

  /// No description provided for @chat_reply_thread.
  ///
  /// In en, this message translates to:
  /// **'Reply thread'**
  String get chat_reply_thread;

  /// No description provided for @chat_control_edit_channel_list_of.
  ///
  /// In en, this message translates to:
  /// **'Edit channel list of'**
  String get chat_control_edit_channel_list_of;

  /// No description provided for @chat_control_edit_channel_lists.
  ///
  /// In en, this message translates to:
  /// **'Edit channel lists'**
  String get chat_control_edit_channel_lists;

  /// No description provided for @chat_control_manage_integrations.
  ///
  /// In en, this message translates to:
  /// **'Manage Integrations'**
  String get chat_control_manage_integrations;

  /// No description provided for @chat_control_unread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get chat_control_unread;

  /// No description provided for @chat_toast_downloaded.
  ///
  /// In en, this message translates to:
  /// **'Downloaded'**
  String get chat_toast_downloaded;

  /// No description provided for @chat_toast_download_failed.
  ///
  /// In en, this message translates to:
  /// **'Download failed'**
  String get chat_toast_download_failed;

  /// No description provided for @chat_toast_show_in_folder.
  ///
  /// In en, this message translates to:
  /// **'Show in folder'**
  String get chat_toast_show_in_folder;

  /// No description provided for @chat_toast_open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get chat_toast_open;

  /// No description provided for @chat_toast_download_from_link.
  ///
  /// In en, this message translates to:
  /// **'Download from link'**
  String get chat_toast_download_from_link;

  /// No description provided for @chat_integrate_empty_title.
  ///
  /// In en, this message translates to:
  /// **'Access and manage your Slack'**
  String get chat_integrate_empty_title;

  /// No description provided for @chat_integrate_empty_description.
  ///
  /// In en, this message translates to:
  /// **'Read, reply, and track important conversations in one place.'**
  String get chat_integrate_empty_description;

  /// No description provided for @chat_integrate_chat_button.
  ///
  /// In en, this message translates to:
  /// **'Connect chat providers'**
  String get chat_integrate_chat_button;

  /// No description provided for @chat_edit_channel_list_of.
  ///
  /// In en, this message translates to:
  /// **'Edit channel list of'**
  String get chat_edit_channel_list_of;

  /// No description provided for @chat_edit_channel_list.
  ///
  /// In en, this message translates to:
  /// **'Edit channel list'**
  String get chat_edit_channel_list;

  /// No description provided for @chat_emoji_category_frequently_used.
  ///
  /// In en, this message translates to:
  /// **'Frequently Used'**
  String get chat_emoji_category_frequently_used;

  /// No description provided for @chat_emoji_category_smiley_and_people.
  ///
  /// In en, this message translates to:
  /// **'Smiley & People'**
  String get chat_emoji_category_smiley_and_people;

  /// No description provided for @chat_emoji_category_animals_and_nature.
  ///
  /// In en, this message translates to:
  /// **'Animals & Nature'**
  String get chat_emoji_category_animals_and_nature;

  /// No description provided for @chat_emoji_category_food_and_drink.
  ///
  /// In en, this message translates to:
  /// **'Food & Drink'**
  String get chat_emoji_category_food_and_drink;

  /// No description provided for @chat_emoji_category_travel_and_places.
  ///
  /// In en, this message translates to:
  /// **'Travel & Places'**
  String get chat_emoji_category_travel_and_places;

  /// No description provided for @chat_emoji_category_activities.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get chat_emoji_category_activities;

  /// No description provided for @chat_emoji_category_objects.
  ///
  /// In en, this message translates to:
  /// **'Objects'**
  String get chat_emoji_category_objects;

  /// No description provided for @chat_emoji_category_symbols.
  ///
  /// In en, this message translates to:
  /// **'Symbols'**
  String get chat_emoji_category_symbols;

  /// No description provided for @chat_emoji_category_flags.
  ///
  /// In en, this message translates to:
  /// **'Flags'**
  String get chat_emoji_category_flags;

  /// No description provided for @chat_emoji_category_custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get chat_emoji_category_custom;

  /// No description provided for @chat_emoji_search_result.
  ///
  /// In en, this message translates to:
  /// **'Search result'**
  String get chat_emoji_search_result;

  /// No description provided for @chat_formatted_message_user_joines.
  ///
  /// In en, this message translates to:
  /// **'joined'**
  String get chat_formatted_message_user_joines;

  /// No description provided for @chat_formatted_message_user_archived.
  ///
  /// In en, this message translates to:
  /// **'archived'**
  String get chat_formatted_message_user_archived;

  /// No description provided for @chat_formatted_message_user_archived_description.
  ///
  /// In en, this message translates to:
  /// **'The contents will still be browsable and available in search.'**
  String get chat_formatted_message_user_archived_description;

  /// No description provided for @chat_formatted_message_user_unarchived.
  ///
  /// In en, this message translates to:
  /// **'unarchived'**
  String get chat_formatted_message_user_unarchived;

  /// No description provided for @chat_formatted_message_user_left.
  ///
  /// In en, this message translates to:
  /// **'left'**
  String get chat_formatted_message_user_left;

  /// No description provided for @chat_message_edited.
  ///
  /// In en, this message translates to:
  /// **'edited'**
  String get chat_message_edited;

  /// No description provided for @chat_channel_you_are_viewing.
  ///
  /// In en, this message translates to:
  /// **'You are viewing'**
  String get chat_channel_you_are_viewing;

  /// No description provided for @chat_channel_archived.
  ///
  /// In en, this message translates to:
  /// **', an archived channel'**
  String get chat_channel_archived;

  /// No description provided for @chat_channel_viewing_dm_with_deactivated_account.
  ///
  /// In en, this message translates to:
  /// **'You are viewing the archives of a deactivated account'**
  String get chat_channel_viewing_dm_with_deactivated_account;

  /// No description provided for @chat_block_check_this_message_on_slack.
  ///
  /// In en, this message translates to:
  /// **'Check this message on Slack'**
  String get chat_block_check_this_message_on_slack;

  /// No description provided for @chat_block_go_to_slack.
  ///
  /// In en, this message translates to:
  /// **'Go to Slack'**
  String get chat_block_go_to_slack;

  /// No description provided for @chat_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get chat_settings;

  /// No description provided for @chat_upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get chat_upload;

  /// No description provided for @chat_photo_or_video.
  ///
  /// In en, this message translates to:
  /// **'Photo or Video'**
  String get chat_photo_or_video;

  /// No description provided for @chat_file.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get chat_file;

  /// No description provided for @chat_this_is_the_very_beginning.
  ///
  /// In en, this message translates to:
  /// **'This is the very beginning of the'**
  String get chat_this_is_the_very_beginning;

  /// No description provided for @chat_channel.
  ///
  /// In en, this message translates to:
  /// **'Channel'**
  String get chat_channel;

  /// No description provided for @chat_this_is_the_very_beginning_of_dm_with.
  ///
  /// In en, this message translates to:
  /// **'This is the very beginning of your direct message history with'**
  String get chat_this_is_the_very_beginning_of_dm_with;

  /// No description provided for @chat_channels.
  ///
  /// In en, this message translates to:
  /// **'Channel'**
  String get chat_channels;

  /// No description provided for @chat_dms.
  ///
  /// In en, this message translates to:
  /// **'DM'**
  String get chat_dms;

  /// No description provided for @chat_reaction_you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get chat_reaction_you;

  /// No description provided for @chat_new.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get chat_new;

  /// No description provided for @chat_read_all.
  ///
  /// In en, this message translates to:
  /// **'Read All'**
  String get chat_read_all;

  /// No description provided for @chat_app.
  ///
  /// In en, this message translates to:
  /// **'Bot'**
  String get chat_app;

  /// No description provided for @file_options.
  ///
  /// In en, this message translates to:
  /// **'File Options'**
  String get file_options;

  /// No description provided for @file_options_download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get file_options_download;

  /// No description provided for @file_options_share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get file_options_share;

  /// No description provided for @add_reaction.
  ///
  /// In en, this message translates to:
  /// **'Add reaction'**
  String get add_reaction;

  /// No description provided for @create_task.
  ///
  /// In en, this message translates to:
  /// **'Create task'**
  String get create_task;

  /// No description provided for @integration_pref_title.
  ///
  /// In en, this message translates to:
  /// **'Integrations'**
  String get integration_pref_title;

  /// No description provided for @integration_calendars.
  ///
  /// In en, this message translates to:
  /// **'Calendars'**
  String get integration_calendars;

  /// No description provided for @integration_emails.
  ///
  /// In en, this message translates to:
  /// **'Mails'**
  String get integration_emails;

  /// No description provided for @integration_messengers.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get integration_messengers;

  /// No description provided for @integration_others.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get integration_others;

  /// No description provided for @notification_pref_title.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notification_pref_title;

  /// No description provided for @notification_pref_description.
  ///
  /// In en, this message translates to:
  /// **'Notification preferences are applied separately for each device.'**
  String get notification_pref_description;

  /// No description provided for @notification_tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get notification_tasks;

  /// No description provided for @notification_calendars.
  ///
  /// In en, this message translates to:
  /// **'Calendars'**
  String get notification_calendars;

  /// No description provided for @notification_mails.
  ///
  /// In en, this message translates to:
  /// **'Mails'**
  String get notification_mails;

  /// No description provided for @notification_messengers.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get notification_messengers;

  /// No description provided for @notification_task_reminders.
  ///
  /// In en, this message translates to:
  /// **'Task reminders'**
  String get notification_task_reminders;

  /// No description provided for @notification_mails_notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notification_mails_notifications;

  /// No description provided for @notification_message_notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notification_message_notifications;

  /// No description provided for @notification_mail_description.
  ///
  /// In en, this message translates to:
  /// **'Only receive notifications based on your preferences.'**
  String get notification_mail_description;

  /// No description provided for @notification_message_description.
  ///
  /// In en, this message translates to:
  /// **'Only receive notifications based on your preferences.'**
  String get notification_message_description;

  /// No description provided for @home_pref_title.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get home_pref_title;

  /// No description provided for @home_pref_task_preference.
  ///
  /// In en, this message translates to:
  /// **'Task Preference'**
  String get home_pref_task_preference;

  /// No description provided for @home_pref_default_task_color.
  ///
  /// In en, this message translates to:
  /// **'Default color'**
  String get home_pref_default_task_color;

  /// No description provided for @home_pref_default_task_duration.
  ///
  /// In en, this message translates to:
  /// **'Default duration'**
  String get home_pref_default_task_duration;

  /// No description provided for @home_pref_double_click_action.
  ///
  /// In en, this message translates to:
  /// **'Double click action'**
  String get home_pref_double_click_action;

  /// No description provided for @home_pref_drag_action.
  ///
  /// In en, this message translates to:
  /// **'Drag action'**
  String get home_pref_drag_action;

  /// No description provided for @home_pref_floating_button_action.
  ///
  /// In en, this message translates to:
  /// **'Floating button action'**
  String get home_pref_floating_button_action;

  /// No description provided for @home_pref_default_task_reminder.
  ///
  /// In en, this message translates to:
  /// **'Default reminder'**
  String get home_pref_default_task_reminder;

  /// No description provided for @home_pref_default_all_day_task_reminder.
  ///
  /// In en, this message translates to:
  /// **'Default all-day reminder'**
  String get home_pref_default_all_day_task_reminder;

  /// No description provided for @home_pref_home_calendar.
  ///
  /// In en, this message translates to:
  /// **'Home Calendar'**
  String get home_pref_home_calendar;

  /// No description provided for @inbox_double_click_action_calendar_event.
  ///
  /// In en, this message translates to:
  /// **'Calendar Event'**
  String get inbox_double_click_action_calendar_event;

  /// No description provided for @inbox_double_click_action_task.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get inbox_double_click_action_task;

  /// No description provided for @inbox_double_click_action_last_created.
  ///
  /// In en, this message translates to:
  /// **'Last Created'**
  String get inbox_double_click_action_last_created;

  /// No description provided for @preferences_title.
  ///
  /// In en, this message translates to:
  /// **'Preference'**
  String get preferences_title;

  /// No description provided for @preference_integration.
  ///
  /// In en, this message translates to:
  /// **'Integration'**
  String get preference_integration;

  /// No description provided for @preference_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get preference_home;

  /// No description provided for @preference_chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get preference_chat;

  /// No description provided for @preference_mail.
  ///
  /// In en, this message translates to:
  /// **'Mail'**
  String get preference_mail;

  /// No description provided for @preference_calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get preference_calendar;

  /// No description provided for @preference_customize_tabs.
  ///
  /// In en, this message translates to:
  /// **'Tabs'**
  String get preference_customize_tabs;

  /// No description provided for @preference_terms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get preference_terms;

  /// No description provided for @preference_privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get preference_privacy;

  /// No description provided for @task_no_task_selected.
  ///
  /// In en, this message translates to:
  /// **'No task selected'**
  String get task_no_task_selected;

  /// No description provided for @integration_connect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get integration_connect;

  /// No description provided for @integration_gmail.
  ///
  /// In en, this message translates to:
  /// **'Gmail'**
  String get integration_gmail;

  /// No description provided for @integration_outlook.
  ///
  /// In en, this message translates to:
  /// **'Outlook'**
  String get integration_outlook;

  /// No description provided for @integration_gcal.
  ///
  /// In en, this message translates to:
  /// **'Google Calendar'**
  String get integration_gcal;

  /// No description provided for @integration_outlook_cal.
  ///
  /// In en, this message translates to:
  /// **'Outlook Calendar'**
  String get integration_outlook_cal;

  /// No description provided for @integration_slack.
  ///
  /// In en, this message translates to:
  /// **'Slack'**
  String get integration_slack;

  /// No description provided for @integration_discord.
  ///
  /// In en, this message translates to:
  /// **'Discord'**
  String get integration_discord;

  /// No description provided for @calendar_title.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar_title;

  /// No description provided for @sign_out.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get sign_out;

  /// No description provided for @calendar_configuration_day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get calendar_configuration_day;

  /// No description provided for @calendar_configuration_2_days.
  ///
  /// In en, this message translates to:
  /// **'2 Days'**
  String get calendar_configuration_2_days;

  /// No description provided for @calendar_configuration_3_days.
  ///
  /// In en, this message translates to:
  /// **'3 Days'**
  String get calendar_configuration_3_days;

  /// No description provided for @calendar_configuration_4_days.
  ///
  /// In en, this message translates to:
  /// **'4 Days'**
  String get calendar_configuration_4_days;

  /// No description provided for @calendar_configuration_5_days.
  ///
  /// In en, this message translates to:
  /// **'5 Days'**
  String get calendar_configuration_5_days;

  /// No description provided for @calendar_configuration_6_days.
  ///
  /// In en, this message translates to:
  /// **'6 Days'**
  String get calendar_configuration_6_days;

  /// No description provided for @calendar_configuration_week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get calendar_configuration_week;

  /// No description provided for @calendar_configuration_month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get calendar_configuration_month;

  /// No description provided for @calendar_configuration_list.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get calendar_configuration_list;

  /// No description provided for @calendar_event_edit_title.
  ///
  /// In en, this message translates to:
  /// **'Edit Event'**
  String get calendar_event_edit_title;

  /// No description provided for @calendar_event_create_title.
  ///
  /// In en, this message translates to:
  /// **'Create Event'**
  String get calendar_event_create_title;

  /// No description provided for @calendar_event_edit_repeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get calendar_event_edit_repeat;

  /// No description provided for @calendar_event_edit_datetime.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get calendar_event_edit_datetime;

  /// No description provided for @select_all.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get select_all;

  /// No description provided for @deselect_all.
  ///
  /// In en, this message translates to:
  /// **'Deselect all'**
  String get deselect_all;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @all_day.
  ///
  /// In en, this message translates to:
  /// **'All day'**
  String get all_day;

  /// No description provided for @repeat_never.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get repeat_never;

  /// No description provided for @select_date.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get select_date;

  /// No description provided for @type_description.
  ///
  /// In en, this message translates to:
  /// **'+ Add description'**
  String get type_description;

  /// No description provided for @type_title.
  ///
  /// In en, this message translates to:
  /// **'Enter title'**
  String get type_title;

  /// No description provided for @type_location.
  ///
  /// In en, this message translates to:
  /// **'+ Add location'**
  String get type_location;

  /// No description provided for @type_attendee.
  ///
  /// In en, this message translates to:
  /// **'+ Add guests'**
  String get type_attendee;

  /// No description provided for @add_reminder.
  ///
  /// In en, this message translates to:
  /// **'Add reminder'**
  String get add_reminder;

  /// No description provided for @event_title.
  ///
  /// In en, this message translates to:
  /// **'Event title'**
  String get event_title;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'to'**
  String get to;

  /// No description provided for @add_guest.
  ///
  /// In en, this message translates to:
  /// **'Add guest'**
  String get add_guest;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get minutes;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hours;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get days;

  /// No description provided for @weeks.
  ///
  /// In en, this message translates to:
  /// **'Weeks'**
  String get weeks;

  /// No description provided for @mail.
  ///
  /// In en, this message translates to:
  /// **'Mail'**
  String get mail;

  /// No description provided for @push_notification.
  ///
  /// In en, this message translates to:
  /// **'Push Notification'**
  String get push_notification;

  /// No description provided for @before.
  ///
  /// In en, this message translates to:
  /// **'before'**
  String get before;

  /// No description provided for @on_day_of_event_at.
  ///
  /// In en, this message translates to:
  /// **'On day of event at {time}'**
  String on_day_of_event_at(Object time);

  /// No description provided for @week_before_at.
  ///
  /// In en, this message translates to:
  /// **'{week} week before at {time}'**
  String week_before_at(Object time, Object week);

  /// No description provided for @day_before_at.
  ///
  /// In en, this message translates to:
  /// **'{day} day before at {time}'**
  String day_before_at(Object day, Object time);

  /// No description provided for @reminder_minute.
  ///
  /// In en, this message translates to:
  /// **'1 minute'**
  String get reminder_minute;

  /// No description provided for @reminder_minutes.
  ///
  /// In en, this message translates to:
  /// **'{minute} minutes'**
  String reminder_minutes(Object minute);

  /// No description provided for @reminder_hour.
  ///
  /// In en, this message translates to:
  /// **'1 hour'**
  String get reminder_hour;

  /// No description provided for @reminder_hours.
  ///
  /// In en, this message translates to:
  /// **'{hour} hour'**
  String reminder_hours(Object hour);

  /// No description provided for @at_start_event.
  ///
  /// In en, this message translates to:
  /// **'At the start of event'**
  String get at_start_event;

  /// No description provided for @does_not_repeat.
  ///
  /// In en, this message translates to:
  /// **'Does not repeat'**
  String get does_not_repeat;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @annualy_on.
  ///
  /// In en, this message translates to:
  /// **'Annualy on'**
  String get annualy_on;

  /// No description provided for @every_weekday_monday_to_friday.
  ///
  /// In en, this message translates to:
  /// **'Every weekday (Monday to Friday)'**
  String get every_weekday_monday_to_friday;

  /// No description provided for @every_weekend_saturday_to_sunday.
  ///
  /// In en, this message translates to:
  /// **'Every weekend (Saturday to Sunday)'**
  String get every_weekend_saturday_to_sunday;

  /// No description provided for @custom_reminder.
  ///
  /// In en, this message translates to:
  /// **'Custom...'**
  String get custom_reminder;

  /// No description provided for @custom_reminder_title.
  ///
  /// In en, this message translates to:
  /// **'Custom reminder'**
  String get custom_reminder_title;

  /// No description provided for @custom_recurrence_title.
  ///
  /// In en, this message translates to:
  /// **'Custom recurrence'**
  String get custom_recurrence_title;

  /// No description provided for @add_conference.
  ///
  /// In en, this message translates to:
  /// **'Add conference link'**
  String get add_conference;

  /// No description provided for @add_attachment.
  ///
  /// In en, this message translates to:
  /// **'Add attachment'**
  String get add_attachment;

  /// No description provided for @edit_recurring_event.
  ///
  /// In en, this message translates to:
  /// **'Edit recurring event'**
  String get edit_recurring_event;

  /// No description provided for @delete_recurring_event.
  ///
  /// In en, this message translates to:
  /// **'Delete recurring event'**
  String get delete_recurring_event;

  /// No description provided for @edit_recurring_task.
  ///
  /// In en, this message translates to:
  /// **'Edit recurring task'**
  String get edit_recurring_task;

  /// No description provided for @delete_recurring_task.
  ///
  /// In en, this message translates to:
  /// **'Delete recurring task'**
  String get delete_recurring_task;

  /// No description provided for @this_event_only.
  ///
  /// In en, this message translates to:
  /// **'This event only'**
  String get this_event_only;

  /// No description provided for @all_events.
  ///
  /// In en, this message translates to:
  /// **'All events'**
  String get all_events;

  /// No description provided for @this_and_following_events.
  ///
  /// In en, this message translates to:
  /// **'This and following events'**
  String get this_and_following_events;

  /// No description provided for @this_task_only.
  ///
  /// In en, this message translates to:
  /// **'This task only'**
  String get this_task_only;

  /// No description provided for @this_and_following_tasks.
  ///
  /// In en, this message translates to:
  /// **'This and following tasks'**
  String get this_and_following_tasks;

  /// No description provided for @all_tasks.
  ///
  /// In en, this message translates to:
  /// **'All tasks'**
  String get all_tasks;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @awaiting.
  ///
  /// In en, this message translates to:
  /// **'Awaiting'**
  String get awaiting;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @maybe.
  ///
  /// In en, this message translates to:
  /// **'Maybe'**
  String get maybe;

  /// No description provided for @are_you_sure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get are_you_sure;

  /// No description provided for @are_you_sure_body.
  ///
  /// In en, this message translates to:
  /// **'By pressing ok button, your action will be applied and you will not be able to revert it.'**
  String get are_you_sure_body;

  /// No description provided for @email_address_copied_to_clipboard.
  ///
  /// In en, this message translates to:
  /// **'Email address copied to clipboard'**
  String get email_address_copied_to_clipboard;

  /// No description provided for @calendar_reminder_before.
  ///
  /// In en, this message translates to:
  /// **'Before'**
  String get calendar_reminder_before;

  /// No description provided for @calendar_reminder_at.
  ///
  /// In en, this message translates to:
  /// **'At'**
  String get calendar_reminder_at;

  /// No description provided for @calendar_reminder_by.
  ///
  /// In en, this message translates to:
  /// **'By'**
  String get calendar_reminder_by;

  /// No description provided for @calendar_recurrence_every.
  ///
  /// In en, this message translates to:
  /// **'Every'**
  String get calendar_recurrence_every;

  /// No description provided for @calendar_recurrence_ends.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get calendar_recurrence_ends;

  /// No description provided for @calendar_recurrence_on.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get calendar_recurrence_on;

  /// No description provided for @calendar_recurrence_daily.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get calendar_recurrence_daily;

  /// No description provided for @calendar_recurrence_weekly.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get calendar_recurrence_weekly;

  /// No description provided for @calendar_recurrence_monthly.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get calendar_recurrence_monthly;

  /// No description provided for @calendar_recurrence_yearly.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get calendar_recurrence_yearly;

  /// No description provided for @calendar_recurrence_ends_never.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get calendar_recurrence_ends_never;

  /// No description provided for @calendar_recurrence_ends_after.
  ///
  /// In en, this message translates to:
  /// **'Ends after'**
  String get calendar_recurrence_ends_after;

  /// No description provided for @calendar_recurrence_ends_on_date.
  ///
  /// In en, this message translates to:
  /// **'Ends on date'**
  String get calendar_recurrence_ends_on_date;

  /// No description provided for @calendar_recurrence_count_times.
  ///
  /// In en, this message translates to:
  /// **'{number} times'**
  String calendar_recurrence_count_times(Object number);

  /// No description provided for @link_copied_to_clipboard.
  ///
  /// In en, this message translates to:
  /// **'Link copied to clipboard'**
  String get link_copied_to_clipboard;

  /// No description provided for @image_copied_to_clipboard.
  ///
  /// In en, this message translates to:
  /// **'Image copied to clipboard'**
  String get image_copied_to_clipboard;

  /// No description provided for @first.
  ///
  /// In en, this message translates to:
  /// **'1st'**
  String get first;

  /// No description provided for @second.
  ///
  /// In en, this message translates to:
  /// **'2nd'**
  String get second;

  /// No description provided for @third.
  ///
  /// In en, this message translates to:
  /// **'3rd'**
  String get third;

  /// No description provided for @number.
  ///
  /// In en, this message translates to:
  /// **'{number}th'**
  String number(Object number);

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @hour.
  ///
  /// In en, this message translates to:
  /// **'Hour'**
  String get hour;

  /// No description provided for @minute.
  ///
  /// In en, this message translates to:
  /// **'Minute'**
  String get minute;

  /// No description provided for @more_options.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get more_options;

  /// No description provided for @go_to_day_view.
  ///
  /// In en, this message translates to:
  /// **'Go to Day View'**
  String get go_to_day_view;

  /// No description provided for @new_event.
  ///
  /// In en, this message translates to:
  /// **'New Event'**
  String get new_event;

  /// No description provided for @new_task.
  ///
  /// In en, this message translates to:
  /// **'New Task'**
  String get new_task;

  /// No description provided for @mail_compose.
  ///
  /// In en, this message translates to:
  /// **'Compose'**
  String get mail_compose;

  /// No description provided for @mail_reply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get mail_reply;

  /// No description provided for @mail_reply_all.
  ///
  /// In en, this message translates to:
  /// **'Reply All'**
  String get mail_reply_all;

  /// No description provided for @mail_forward.
  ///
  /// In en, this message translates to:
  /// **'Forward'**
  String get mail_forward;

  /// No description provided for @mail_attachments.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get mail_attachments;

  /// No description provided for @mail_download_all.
  ///
  /// In en, this message translates to:
  /// **'Download all'**
  String get mail_download_all;

  /// No description provided for @mail_detail_tooltip_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get mail_detail_tooltip_close;

  /// No description provided for @mail_detail_tooltip_mark_as_read.
  ///
  /// In en, this message translates to:
  /// **'Mark as read'**
  String get mail_detail_tooltip_mark_as_read;

  /// No description provided for @mail_detail_tooltip_mark_as_unread.
  ///
  /// In en, this message translates to:
  /// **'Mark as unread'**
  String get mail_detail_tooltip_mark_as_unread;

  /// No description provided for @mail_detail_tooltip_pin.
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get mail_detail_tooltip_pin;

  /// No description provided for @mail_detail_tooltip_unpin.
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get mail_detail_tooltip_unpin;

  /// No description provided for @mail_detail_tooltip_task.
  ///
  /// In en, this message translates to:
  /// **'Create task'**
  String get mail_detail_tooltip_task;

  /// No description provided for @mail_detail_tooltip_archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get mail_detail_tooltip_archive;

  /// No description provided for @mail_detail_tooltip_unarchive.
  ///
  /// In en, this message translates to:
  /// **'Unarchive'**
  String get mail_detail_tooltip_unarchive;

  /// No description provided for @mail_detail_tooltip_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get mail_detail_tooltip_delete;

  /// No description provided for @mail_detail_tooltip_delete_forever.
  ///
  /// In en, this message translates to:
  /// **'Delete forever'**
  String get mail_detail_tooltip_delete_forever;

  /// No description provided for @mail_detail_tooltip_undelete.
  ///
  /// In en, this message translates to:
  /// **'Move back to inbox'**
  String get mail_detail_tooltip_undelete;

  /// No description provided for @mail_detail_tooltip_report_spam.
  ///
  /// In en, this message translates to:
  /// **'Report spam'**
  String get mail_detail_tooltip_report_spam;

  /// No description provided for @mail_detail_tooltip_not_spam.
  ///
  /// In en, this message translates to:
  /// **'Not spam'**
  String get mail_detail_tooltip_not_spam;

  /// No description provided for @mail_detail_tooltip_report_unspam.
  ///
  /// In en, this message translates to:
  /// **'Remove from spam'**
  String get mail_detail_tooltip_report_unspam;

  /// No description provided for @mail_detail_tooltip_move_to_inbox.
  ///
  /// In en, this message translates to:
  /// **'Move to Inbox'**
  String get mail_detail_tooltip_move_to_inbox;

  /// No description provided for @mail_label_inbox.
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get mail_label_inbox;

  /// No description provided for @mail_label_pinned.
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get mail_label_pinned;

  /// No description provided for @mail_label_unread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get mail_label_unread;

  /// No description provided for @mail_label_draft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get mail_label_draft;

  /// No description provided for @mail_label_sent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get mail_label_sent;

  /// No description provided for @mail_label_spam.
  ///
  /// In en, this message translates to:
  /// **'Spam'**
  String get mail_label_spam;

  /// No description provided for @mail_label_trash.
  ///
  /// In en, this message translates to:
  /// **'Trash'**
  String get mail_label_trash;

  /// No description provided for @mail_label_archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get mail_label_archive;

  /// No description provided for @mail_label_more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get mail_label_more;

  /// No description provided for @mail_label_less.
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get mail_label_less;

  /// No description provided for @mail_label_all.
  ///
  /// In en, this message translates to:
  /// **'All Mail'**
  String get mail_label_all;

  /// No description provided for @mail_new_message.
  ///
  /// In en, this message translates to:
  /// **'New Message'**
  String get mail_new_message;

  /// No description provided for @mail_to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get mail_to;

  /// No description provided for @mail_from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get mail_from;

  /// No description provided for @mail_cc.
  ///
  /// In en, this message translates to:
  /// **'Cc'**
  String get mail_cc;

  /// No description provided for @mail_bcc.
  ///
  /// In en, this message translates to:
  /// **'Bcc'**
  String get mail_bcc;

  /// No description provided for @mail_subject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get mail_subject;

  /// No description provided for @mail_body_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Write your message here...'**
  String get mail_body_placeholder;

  /// No description provided for @mail_send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get mail_send;

  /// No description provided for @mail_toolbar_font_size_small.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get mail_toolbar_font_size_small;

  /// No description provided for @mail_toolbar_font_size_normal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get mail_toolbar_font_size_normal;

  /// No description provided for @mail_toolbar_font_size_large.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get mail_toolbar_font_size_large;

  /// No description provided for @mail_toolbar_font_size_huge.
  ///
  /// In en, this message translates to:
  /// **'Huge'**
  String get mail_toolbar_font_size_huge;

  /// No description provided for @mail_toolbar_color_picker_reset_to_default.
  ///
  /// In en, this message translates to:
  /// **'Reset to default'**
  String get mail_toolbar_color_picker_reset_to_default;

  /// No description provided for @mail_toolbar_color_picker_font_color.
  ///
  /// In en, this message translates to:
  /// **'Font color'**
  String get mail_toolbar_color_picker_font_color;

  /// No description provided for @mail_toolbar_color_picker_background_color.
  ///
  /// In en, this message translates to:
  /// **'Background color'**
  String get mail_toolbar_color_picker_background_color;

  /// No description provided for @mail_toolbar_align_tooltips.
  ///
  /// In en, this message translates to:
  /// **'Align'**
  String get mail_toolbar_align_tooltips;

  /// No description provided for @mail_toolbar_align_justify.
  ///
  /// In en, this message translates to:
  /// **'Justify'**
  String get mail_toolbar_align_justify;

  /// No description provided for @mail_toolbar_align_left.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get mail_toolbar_align_left;

  /// No description provided for @mail_toolbar_align_center.
  ///
  /// In en, this message translates to:
  /// **'Center'**
  String get mail_toolbar_align_center;

  /// No description provided for @mail_toolbar_align_right.
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get mail_toolbar_align_right;

  /// No description provided for @mail_color_picker_background.
  ///
  /// In en, this message translates to:
  /// **'Background color'**
  String get mail_color_picker_background;

  /// No description provided for @mail_color_picker_text.
  ///
  /// In en, this message translates to:
  /// **'Text color'**
  String get mail_color_picker_text;

  /// No description provided for @mail_toolbar_tooltip_attachments.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get mail_toolbar_tooltip_attachments;

  /// No description provided for @mail_toolbar_tooltip_signatures.
  ///
  /// In en, this message translates to:
  /// **'Signatures'**
  String get mail_toolbar_tooltip_signatures;

  /// No description provided for @mail_pref_title.
  ///
  /// In en, this message translates to:
  /// **'Mail'**
  String get mail_pref_title;

  /// No description provided for @mail_pref_account_color.
  ///
  /// In en, this message translates to:
  /// **'Account color'**
  String get mail_pref_account_color;

  /// No description provided for @mail_pref_account_color_red.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get mail_pref_account_color_red;

  /// No description provided for @mail_pref_account_color_deep_orange.
  ///
  /// In en, this message translates to:
  /// **'Deep Orange'**
  String get mail_pref_account_color_deep_orange;

  /// No description provided for @mail_pref_account_color_orange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get mail_pref_account_color_orange;

  /// No description provided for @mail_pref_account_color_yellow.
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get mail_pref_account_color_yellow;

  /// No description provided for @mail_pref_account_color_light_green.
  ///
  /// In en, this message translates to:
  /// **'Light Green'**
  String get mail_pref_account_color_light_green;

  /// No description provided for @mail_pref_account_color_green.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get mail_pref_account_color_green;

  /// No description provided for @mail_pref_account_color_teal.
  ///
  /// In en, this message translates to:
  /// **'Teal'**
  String get mail_pref_account_color_teal;

  /// No description provided for @mail_pref_account_color_light_blue.
  ///
  /// In en, this message translates to:
  /// **'Light Blue'**
  String get mail_pref_account_color_light_blue;

  /// No description provided for @mail_pref_account_color_indigo.
  ///
  /// In en, this message translates to:
  /// **'Indigo'**
  String get mail_pref_account_color_indigo;

  /// No description provided for @mail_pref_account_color_deep_purple.
  ///
  /// In en, this message translates to:
  /// **'Deep Purple'**
  String get mail_pref_account_color_deep_purple;

  /// No description provided for @mail_pref_account_color_purple.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get mail_pref_account_color_purple;

  /// No description provided for @mail_pref_account_color_brown.
  ///
  /// In en, this message translates to:
  /// **'Brown'**
  String get mail_pref_account_color_brown;

  /// No description provided for @mail_pref_signature_list.
  ///
  /// In en, this message translates to:
  /// **'Signatures'**
  String get mail_pref_signature_list;

  /// No description provided for @mail_pref_default_signature.
  ///
  /// In en, this message translates to:
  /// **'Default signature'**
  String get mail_pref_default_signature;

  /// No description provided for @mail_pref_signature_list_select.
  ///
  /// In en, this message translates to:
  /// **'Select signature'**
  String get mail_pref_signature_list_select;

  /// No description provided for @mail_pref_signature_create_new.
  ///
  /// In en, this message translates to:
  /// **'+ Create new'**
  String get mail_pref_signature_create_new;

  /// No description provided for @mail_pref_signature_number.
  ///
  /// In en, this message translates to:
  /// **'Signature {number}'**
  String mail_pref_signature_number(Object number);

  /// No description provided for @mail_pref_signature_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Write signature...'**
  String get mail_pref_signature_placeholder;

  /// No description provided for @mail_pref_signature_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete Signature'**
  String get mail_pref_signature_delete;

  /// No description provided for @mail_pref_signature_none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get mail_pref_signature_none;

  /// No description provided for @mail_pref_swipe_actions.
  ///
  /// In en, this message translates to:
  /// **'Swipe Actions'**
  String get mail_pref_swipe_actions;

  /// No description provided for @mail_pref_swipe_right.
  ///
  /// In en, this message translates to:
  /// **'Swipe right'**
  String get mail_pref_swipe_right;

  /// No description provided for @mail_pref_swipe_left.
  ///
  /// In en, this message translates to:
  /// **'Swipe left'**
  String get mail_pref_swipe_left;

  /// No description provided for @mail_pref_swipe_none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get mail_pref_swipe_none;

  /// No description provided for @mail_pref_swipe_read_unread.
  ///
  /// In en, this message translates to:
  /// **'Read / Unread'**
  String get mail_pref_swipe_read_unread;

  /// No description provided for @mail_pref_swipe_read.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get mail_pref_swipe_read;

  /// No description provided for @mail_pref_swipe_unread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get mail_pref_swipe_unread;

  /// No description provided for @mail_pref_swipe_pin_unpin.
  ///
  /// In en, this message translates to:
  /// **'Pin / Unpin'**
  String get mail_pref_swipe_pin_unpin;

  /// No description provided for @mail_pref_swipe_pin.
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get mail_pref_swipe_pin;

  /// No description provided for @mail_pref_swipe_unpin.
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get mail_pref_swipe_unpin;

  /// No description provided for @mail_pref_swipe_create_task.
  ///
  /// In en, this message translates to:
  /// **'Create task'**
  String get mail_pref_swipe_create_task;

  /// No description provided for @mail_pref_swipe_archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get mail_pref_swipe_archive;

  /// No description provided for @mail_pref_swipe_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get mail_pref_swipe_delete;

  /// No description provided for @mail_pref_swipe_report_spam.
  ///
  /// In en, this message translates to:
  /// **'Report spam'**
  String get mail_pref_swipe_report_spam;

  /// No description provided for @mail_pref_appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get mail_pref_appearance;

  /// No description provided for @mail_pref_email_content_theme.
  ///
  /// In en, this message translates to:
  /// **'Email content theme'**
  String get mail_pref_email_content_theme;

  /// No description provided for @mail_pref_email_theme_follow_taskey_theme.
  ///
  /// In en, this message translates to:
  /// **'Follow app'**
  String get mail_pref_email_theme_follow_taskey_theme;

  /// No description provided for @mail_pref_email_theme_light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get mail_pref_email_theme_light;

  /// No description provided for @mail_pref_email_theme_dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get mail_pref_email_theme_dark;

  /// No description provided for @mail_write_signature.
  ///
  /// In en, this message translates to:
  /// **'Signature'**
  String get mail_write_signature;

  /// No description provided for @mail_write_message.
  ///
  /// In en, this message translates to:
  /// **'Write your message here...'**
  String get mail_write_message;

  /// No description provided for @mail_sent.
  ///
  /// In en, this message translates to:
  /// **'Mail sent'**
  String get mail_sent;

  /// No description provided for @mail_toast_undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get mail_toast_undo;

  /// No description provided for @mail_reply_to.
  ///
  /// In en, this message translates to:
  /// **'Reply to {name}'**
  String mail_reply_to(Object name);

  /// No description provided for @mail_empty_trash.
  ///
  /// In en, this message translates to:
  /// **'Empty Trash'**
  String get mail_empty_trash;

  /// No description provided for @mail_empty_spam.
  ///
  /// In en, this message translates to:
  /// **'Empty Spam'**
  String get mail_empty_spam;

  /// No description provided for @mail_toast_archive.
  ///
  /// In en, this message translates to:
  /// **'Mail archived'**
  String get mail_toast_archive;

  /// No description provided for @mail_toast_trash.
  ///
  /// In en, this message translates to:
  /// **'Mail moved to trash'**
  String get mail_toast_trash;

  /// No description provided for @mail_toast_trashs.
  ///
  /// In en, this message translates to:
  /// **'{number} mails moved to trash'**
  String mail_toast_trashs(Object number);

  /// No description provided for @mail_toast_spam.
  ///
  /// In en, this message translates to:
  /// **'Mail marked as spam'**
  String get mail_toast_spam;

  /// No description provided for @mail_search_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get mail_search_placeholder;

  /// No description provided for @mail_empty_description.
  ///
  /// In en, this message translates to:
  /// **'This will remove all messages in the folder, but it won’t delete messages from Outlook permanently.'**
  String get mail_empty_description;

  /// No description provided for @inbox_filter_all.
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get inbox_filter_all;

  /// No description provided for @inbox_filter_unread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get inbox_filter_unread;

  /// No description provided for @inbox_filter_pinned.
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get inbox_filter_pinned;

  /// No description provided for @inbox_filter_chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get inbox_filter_chat;

  /// No description provided for @inbox_filter_mail.
  ///
  /// In en, this message translates to:
  /// **'Mail'**
  String get inbox_filter_mail;

  /// No description provided for @inbox_filter_deleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get inbox_filter_deleted;

  /// No description provided for @inbox_drag_event.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get inbox_drag_event;

  /// No description provided for @inbox_drag_task.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get inbox_drag_task;

  /// No description provided for @inbox_task_title.
  ///
  /// In en, this message translates to:
  /// **'Task title'**
  String get inbox_task_title;

  /// No description provided for @show_next_message.
  ///
  /// In en, this message translates to:
  /// **'Show next message'**
  String get show_next_message;

  /// No description provided for @mail_pref_filter_inbox_filter.
  ///
  /// In en, this message translates to:
  /// **'Inbox Filter'**
  String get mail_pref_filter_inbox_filter;

  /// No description provided for @mail_pref_filter_inbox_filter_description.
  ///
  /// In en, this message translates to:
  /// **'Use Inbox Filter to control which mails appear in your Inbox.'**
  String get mail_pref_filter_inbox_filter_description;

  /// No description provided for @mail_pref_filter_mails.
  ///
  /// In en, this message translates to:
  /// **'Mails'**
  String get mail_pref_filter_mails;

  /// No description provided for @mail_pref_filter_none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get mail_pref_filter_none;

  /// No description provided for @mail_pref_filter_with_specific_labels.
  ///
  /// In en, this message translates to:
  /// **'With specific labels'**
  String get mail_pref_filter_with_specific_labels;

  /// No description provided for @mail_pref_filter_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get mail_pref_filter_all;

  /// No description provided for @mail_pref_filter_labels.
  ///
  /// In en, this message translates to:
  /// **'Labels'**
  String get mail_pref_filter_labels;

  /// No description provided for @mail_pref_filter_with_labels.
  ///
  /// In en, this message translates to:
  /// **'With labels'**
  String get mail_pref_filter_with_labels;

  /// No description provided for @mail_pref_filter_all_mails.
  ///
  /// In en, this message translates to:
  /// **'All mails'**
  String get mail_pref_filter_all_mails;

  /// No description provided for @message_pref_filter_inbox_filter.
  ///
  /// In en, this message translates to:
  /// **'Inbox Filter'**
  String get message_pref_filter_inbox_filter;

  /// No description provided for @message_pref_filter_inbox_filter_description.
  ///
  /// In en, this message translates to:
  /// **'Use Inbox Filter to control which messages appear in your Inbox.'**
  String get message_pref_filter_inbox_filter_description;

  /// No description provided for @message_pref_filter_direct_messages.
  ///
  /// In en, this message translates to:
  /// **'DMs'**
  String get message_pref_filter_direct_messages;

  /// No description provided for @message_pref_filter_mentions_from_direct_messages.
  ///
  /// In en, this message translates to:
  /// **'Mentions from DMs'**
  String get message_pref_filter_mentions_from_direct_messages;

  /// No description provided for @message_pref_filter_channels.
  ///
  /// In en, this message translates to:
  /// **'Channels'**
  String get message_pref_filter_channels;

  /// No description provided for @message_pref_filter_mentions_from_channels.
  ///
  /// In en, this message translates to:
  /// **'Mentions from channels'**
  String get message_pref_filter_mentions_from_channels;

  /// No description provided for @message_pref_filter_none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get message_pref_filter_none;

  /// No description provided for @message_pref_filter_mentions.
  ///
  /// In en, this message translates to:
  /// **'Mentions'**
  String get message_pref_filter_mentions;

  /// No description provided for @message_pref_filter_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get message_pref_filter_all;

  /// No description provided for @message_forwarded_posted_in_channel.
  ///
  /// In en, this message translates to:
  /// **'Posted in # {channelName}'**
  String message_forwarded_posted_in_channel(Object channelName);

  /// No description provided for @message_forwarded_thread_in_channel.
  ///
  /// In en, this message translates to:
  /// **'Thread in # {channelName}'**
  String message_forwarded_thread_in_channel(Object channelName);

  /// No description provided for @message_forwarded_direct_message.
  ///
  /// In en, this message translates to:
  /// **'Direct Message'**
  String get message_forwarded_direct_message;

  /// No description provided for @message_forwarded_view_message.
  ///
  /// In en, this message translates to:
  /// **'View Message'**
  String get message_forwarded_view_message;

  /// No description provided for @message_forwarded_view_conversation.
  ///
  /// In en, this message translates to:
  /// **'View Conversation'**
  String get message_forwarded_view_conversation;

  /// No description provided for @task_action_duplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get task_action_duplicate;

  /// No description provided for @task_action_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get task_action_delete;

  /// No description provided for @task_action_copy_link.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get task_action_copy_link;

  /// No description provided for @task_action_delete_link.
  ///
  /// In en, this message translates to:
  /// **'Delete link'**
  String get task_action_delete_link;

  /// No description provided for @delete_message.
  ///
  /// In en, this message translates to:
  /// **'Delete message'**
  String get delete_message;

  /// No description provided for @edit_message.
  ///
  /// In en, this message translates to:
  /// **'Edit message'**
  String get edit_message;

  /// No description provided for @show_tasks.
  ///
  /// In en, this message translates to:
  /// **'Show tasks'**
  String get show_tasks;

  /// No description provided for @set_different_end_date.
  ///
  /// In en, this message translates to:
  /// **'Set Different End Date'**
  String get set_different_end_date;

  /// No description provided for @guests.
  ///
  /// In en, this message translates to:
  /// **'Guests'**
  String get guests;

  /// No description provided for @reminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get reminder;

  /// No description provided for @conference.
  ///
  /// In en, this message translates to:
  /// **'Conference'**
  String get conference;

  /// No description provided for @mobile_task_edit_create_task.
  ///
  /// In en, this message translates to:
  /// **'Create Task'**
  String get mobile_task_edit_create_task;

  /// No description provided for @mobile_task_edit_edit_task.
  ///
  /// In en, this message translates to:
  /// **'Edit Task'**
  String get mobile_task_edit_edit_task;

  /// No description provided for @delete_event_confirm_popup_title.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get delete_event_confirm_popup_title;

  /// No description provided for @delete_event_confirm_popup_description.
  ///
  /// In en, this message translates to:
  /// **'This will delete the event and cannot be undone.'**
  String get delete_event_confirm_popup_description;

  /// No description provided for @delete_event_confirm_popup_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get delete_event_confirm_popup_cancel;

  /// No description provided for @delete_event_confirm_popup_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete_event_confirm_popup_delete;

  /// No description provided for @message_loaded_until.
  ///
  /// In en, this message translates to:
  /// **'loaded until {date}'**
  String message_loaded_until(Object date);

  /// No description provided for @message_load_more.
  ///
  /// In en, this message translates to:
  /// **'load more'**
  String get message_load_more;

  /// No description provided for @mail_integration_empty_title.
  ///
  /// In en, this message translates to:
  /// **'Access and manage your emails'**
  String get mail_integration_empty_title;

  /// No description provided for @mail_integration_empty_description.
  ///
  /// In en, this message translates to:
  /// **'Read, reply, forward, compose, search, and archive your emails.'**
  String get mail_integration_empty_description;

  /// No description provided for @mail_integration_empty_button.
  ///
  /// In en, this message translates to:
  /// **'Connect Mail'**
  String get mail_integration_empty_button;

  /// No description provided for @calendar_integration_empty_title.
  ///
  /// In en, this message translates to:
  /// **'Connect your Calendar to begin'**
  String get calendar_integration_empty_title;

  /// No description provided for @calendar_integration_empty_description.
  ///
  /// In en, this message translates to:
  /// **'Sync with Calendar to bring in your schedule and stay organized.'**
  String get calendar_integration_empty_description;

  /// No description provided for @calendar_integration_empty_button.
  ///
  /// In en, this message translates to:
  /// **'Connect Calendar'**
  String get calendar_integration_empty_button;

  /// No description provided for @mail_actions.
  ///
  /// In en, this message translates to:
  /// **'Mail actions'**
  String get mail_actions;

  /// No description provided for @mark_done.
  ///
  /// In en, this message translates to:
  /// **'Mark done'**
  String get mark_done;

  /// No description provided for @mark_undone.
  ///
  /// In en, this message translates to:
  /// **'Mark undone'**
  String get mark_undone;

  /// No description provided for @mail_no_recepients.
  ///
  /// In en, this message translates to:
  /// **'No Recipients'**
  String get mail_no_recepients;

  /// No description provided for @mail_no_subject.
  ///
  /// In en, this message translates to:
  /// **'No Subject'**
  String get mail_no_subject;

  /// No description provided for @mail_no_content.
  ///
  /// In en, this message translates to:
  /// **'No Content'**
  String get mail_no_content;

  /// No description provided for @home_pref_task_completion_sound.
  ///
  /// In en, this message translates to:
  /// **'Task completion sound'**
  String get home_pref_task_completion_sound;

  /// No description provided for @home_pref_completed_tasks.
  ///
  /// In en, this message translates to:
  /// **'Completed tasks'**
  String get home_pref_completed_tasks;

  /// No description provided for @home_pref_completed_tasks_show.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get home_pref_completed_tasks_show;

  /// No description provided for @home_pref_completed_tasks_hide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get home_pref_completed_tasks_hide;

  /// No description provided for @home_pref_completed_tasks_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get home_pref_completed_tasks_delete;

  /// No description provided for @mail_google_api_limit_reached.
  ///
  /// In en, this message translates to:
  /// **'Gmail API limit reached. Try again later'**
  String get mail_google_api_limit_reached;

  /// No description provided for @calendar_google_api_limit_reached.
  ///
  /// In en, this message translates to:
  /// **'Google Calendar API limit reached. Try again later'**
  String get calendar_google_api_limit_reached;

  /// No description provided for @message_slack_api_limit_reached.
  ///
  /// In en, this message translates to:
  /// **'Slack API limit reached. Try again later'**
  String get message_slack_api_limit_reached;

  /// No description provided for @inbox_drop_to_cancel.
  ///
  /// In en, this message translates to:
  /// **'Drop to cancel'**
  String get inbox_drop_to_cancel;

  /// No description provided for @inbox_drop_to_edit_details.
  ///
  /// In en, this message translates to:
  /// **'Drop to edit details'**
  String get inbox_drop_to_edit_details;

  /// No description provided for @inbox_you_are_all_set.
  ///
  /// In en, this message translates to:
  /// **'You\'re all set!'**
  String get inbox_you_are_all_set;

  /// No description provided for @inbox_no_issues_for_this_day.
  ///
  /// In en, this message translates to:
  /// **'No issues for this day.'**
  String get inbox_no_issues_for_this_day;

  /// No description provided for @inbox_no_search_results.
  ///
  /// In en, this message translates to:
  /// **'No search results'**
  String get inbox_no_search_results;

  /// No description provided for @task_created.
  ///
  /// In en, this message translates to:
  /// **'Task created'**
  String get task_created;

  /// No description provided for @task_edited.
  ///
  /// In en, this message translates to:
  /// **'Task edited'**
  String get task_edited;

  /// No description provided for @task_created_undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get task_created_undo;

  /// No description provided for @event_created.
  ///
  /// In en, this message translates to:
  /// **'Event created'**
  String get event_created;

  /// No description provided for @event_created_undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get event_created_undo;

  /// No description provided for @mail_empty_subject.
  ///
  /// In en, this message translates to:
  /// **'(No Subject)'**
  String get mail_empty_subject;

  /// No description provided for @mail_no_email_selected.
  ///
  /// In en, this message translates to:
  /// **'No email selected.'**
  String get mail_no_email_selected;

  /// No description provided for @mail_no_search_results.
  ///
  /// In en, this message translates to:
  /// **'No search results'**
  String get mail_no_search_results;

  /// No description provided for @mail_no_email_inbox.
  ///
  /// In en, this message translates to:
  /// **'No emails in your inbox.'**
  String get mail_no_email_inbox;

  /// No description provided for @mail_no_email_unread.
  ///
  /// In en, this message translates to:
  /// **'No unread emails.'**
  String get mail_no_email_unread;

  /// No description provided for @mail_no_email_pinned.
  ///
  /// In en, this message translates to:
  /// **'No pinned emails.'**
  String get mail_no_email_pinned;

  /// No description provided for @mail_no_email_draft.
  ///
  /// In en, this message translates to:
  /// **'No draft emails.'**
  String get mail_no_email_draft;

  /// No description provided for @mail_no_email_sent.
  ///
  /// In en, this message translates to:
  /// **'No sent emails.'**
  String get mail_no_email_sent;

  /// No description provided for @mail_no_email_spam.
  ///
  /// In en, this message translates to:
  /// **'No spam emails.'**
  String get mail_no_email_spam;

  /// No description provided for @mail_no_email_trash.
  ///
  /// In en, this message translates to:
  /// **'No emails in trash.'**
  String get mail_no_email_trash;

  /// No description provided for @mail_me.
  ///
  /// In en, this message translates to:
  /// **'me'**
  String get mail_me;

  /// No description provided for @mail_drop_to_attach.
  ///
  /// In en, this message translates to:
  /// **'Drop to Attach'**
  String get mail_drop_to_attach;

  /// No description provided for @file_uploading_message_error.
  ///
  /// In en, this message translates to:
  /// **'File uploading. Please wait to send your message.'**
  String get file_uploading_message_error;

  /// No description provided for @mail_discard_drafts.
  ///
  /// In en, this message translates to:
  /// **'Discard Drafts'**
  String get mail_discard_drafts;

  /// No description provided for @mail_discard_draft.
  ///
  /// In en, this message translates to:
  /// **'Discard Draft'**
  String get mail_discard_draft;

  /// No description provided for @mail_discard_drafts_description.
  ///
  /// In en, this message translates to:
  /// **'This will discard all drafts and cannot be undone.'**
  String get mail_discard_drafts_description;

  /// No description provided for @mail_organizer.
  ///
  /// In en, this message translates to:
  /// **'Organizer'**
  String get mail_organizer;

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// No description provided for @feedback_send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get feedback_send;

  /// No description provided for @feedback_sent_successfully.
  ///
  /// In en, this message translates to:
  /// **'Feedback sent successfully'**
  String get feedback_sent_successfully;

  /// No description provided for @feedback_sent_wrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again later'**
  String get feedback_sent_wrong;

  /// No description provided for @feedback_write_your_feedback.
  ///
  /// In en, this message translates to:
  /// **'Write your feedback...'**
  String get feedback_write_your_feedback;

  /// No description provided for @feedback_can_not_open_slack_app.
  ///
  /// In en, this message translates to:
  /// **'Can\'t open Slack app'**
  String get feedback_can_not_open_slack_app;

  /// No description provided for @signup_warning.
  ///
  /// In en, this message translates to:
  /// **'By signing in, I accept to the terms of service and privacy policy of Visir'**
  String get signup_warning;

  /// No description provided for @pref_privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get pref_privacy;

  /// No description provided for @pref_terms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get pref_terms;

  /// No description provided for @pref_subscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get pref_subscription;

  /// No description provided for @pref_download.
  ///
  /// In en, this message translates to:
  /// **'Download App'**
  String get pref_download;

  /// No description provided for @task_unscheduled.
  ///
  /// In en, this message translates to:
  /// **'Unscheduled'**
  String get task_unscheduled;

  /// No description provided for @task_overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get task_overdue;

  /// No description provided for @task_add_task.
  ///
  /// In en, this message translates to:
  /// **'Add task'**
  String get task_add_task;

  /// No description provided for @task_to.
  ///
  /// In en, this message translates to:
  /// **'to'**
  String get task_to;

  /// No description provided for @task_color.
  ///
  /// In en, this message translates to:
  /// **'Task color'**
  String get task_color;

  /// No description provided for @task_set_date.
  ///
  /// In en, this message translates to:
  /// **'Set date'**
  String get task_set_date;

  /// No description provided for @task_set_time.
  ///
  /// In en, this message translates to:
  /// **'Set time'**
  String get task_set_time;

  /// No description provided for @task_label_all.
  ///
  /// In en, this message translates to:
  /// **'All Tasks'**
  String get task_label_all;

  /// No description provided for @task_label_scheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get task_label_scheduled;

  /// No description provided for @task_label_completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get task_label_completed;

  /// No description provided for @task_label_overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get task_label_overdue;

  /// No description provided for @task_label_unscheduled.
  ///
  /// In en, this message translates to:
  /// **'Unscheduled'**
  String get task_label_unscheduled;

  /// No description provided for @task_label_this_week.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get task_label_this_week;

  /// No description provided for @task_label_this_month.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get task_label_this_month;

  /// No description provided for @task_label_more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get task_label_more;

  /// No description provided for @task_label_less.
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get task_label_less;

  /// No description provided for @task_no_tasks_today.
  ///
  /// In en, this message translates to:
  /// **'No tasks today'**
  String get task_no_tasks_today;

  /// No description provided for @task_no_scheduled_tasks.
  ///
  /// In en, this message translates to:
  /// **'No scheduled tasks'**
  String get task_no_scheduled_tasks;

  /// No description provided for @task_no_completed_tasks.
  ///
  /// In en, this message translates to:
  /// **'No completed tasks'**
  String get task_no_completed_tasks;

  /// No description provided for @task_no_overdue_tasks.
  ///
  /// In en, this message translates to:
  /// **'No overdue tasks'**
  String get task_no_overdue_tasks;

  /// No description provided for @task_no_unscheduled_tasks.
  ///
  /// In en, this message translates to:
  /// **'No unscheduled tasks'**
  String get task_no_unscheduled_tasks;

  /// No description provided for @task_no_title.
  ///
  /// In en, this message translates to:
  /// **'No title'**
  String get task_no_title;

  /// No description provided for @task_save_recurring_changes.
  ///
  /// In en, this message translates to:
  /// **'Save recurring changes'**
  String get task_save_recurring_changes;

  /// No description provided for @onboarding_description.
  ///
  /// In en, this message translates to:
  /// **'Manage all your emails, tasks, calendars, and chats in one place.\nSimplify your workflow and save time.'**
  String get onboarding_description;

  /// No description provided for @onboarding_continue_with_google.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get onboarding_continue_with_google;

  /// No description provided for @onboarding_continue_with_apple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get onboarding_continue_with_apple;

  /// No description provided for @onboarding_continue_with_email.
  ///
  /// In en, this message translates to:
  /// **'Continue with email'**
  String get onboarding_continue_with_email;

  /// No description provided for @onboarding_signin_with_google.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get onboarding_signin_with_google;

  /// No description provided for @onboarding_signin_with_apple.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get onboarding_signin_with_apple;

  /// No description provided for @onboarding_signin_with_email.
  ///
  /// In en, this message translates to:
  /// **'Sign in with email'**
  String get onboarding_signin_with_email;

  /// No description provided for @onboarding_by_registering.
  ///
  /// In en, this message translates to:
  /// **'By registering, you agree to the '**
  String get onboarding_by_registering;

  /// No description provided for @onboarding_terms_of_service.
  ///
  /// In en, this message translates to:
  /// **'terms of service'**
  String get onboarding_terms_of_service;

  /// No description provided for @onboarding_and.
  ///
  /// In en, this message translates to:
  /// **' and'**
  String get onboarding_and;

  /// No description provided for @onboarding_privacy_policy.
  ///
  /// In en, this message translates to:
  /// **' privacy policy'**
  String get onboarding_privacy_policy;

  /// No description provided for @onboarding_of_taskey.
  ///
  /// In en, this message translates to:
  /// **' of Visir.'**
  String get onboarding_of_taskey;

  /// No description provided for @onboarding_enter_your_email.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get onboarding_enter_your_email;

  /// No description provided for @onboarding_enter_your_password.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get onboarding_enter_your_password;

  /// No description provided for @onboarding_log_in.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get onboarding_log_in;

  /// No description provided for @onboarding_sign_up.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get onboarding_sign_up;

  /// No description provided for @onboarding_send_password_reset_email.
  ///
  /// In en, this message translates to:
  /// **'Send password reset email'**
  String get onboarding_send_password_reset_email;

  /// No description provided for @onboarding_return_to_login_options.
  ///
  /// In en, this message translates to:
  /// **'Return to login options'**
  String get onboarding_return_to_login_options;

  /// No description provided for @onboarding_forgot_your_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get onboarding_forgot_your_password;

  /// No description provided for @onboarding_do_not_have_an_account.
  ///
  /// In en, this message translates to:
  /// **'Don’t have an account? Sign up.'**
  String get onboarding_do_not_have_an_account;

  /// No description provided for @onboarding_already_have_an_account.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in.'**
  String get onboarding_already_have_an_account;

  /// No description provided for @onboarding_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get onboarding_email;

  /// No description provided for @onboarding_password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get onboarding_password;

  /// No description provided for @onboarding_username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get onboarding_username;

  /// No description provided for @onboarding_password_reset_email_sent.
  ///
  /// In en, this message translates to:
  /// **'A password reset email has been sent.'**
  String get onboarding_password_reset_email_sent;

  /// No description provided for @onboarding_password_reset_email_failed.
  ///
  /// In en, this message translates to:
  /// **'The email address is not registered. Please try again with a valid address.'**
  String get onboarding_password_reset_email_failed;

  /// No description provided for @onboarding_back_to_sign_in.
  ///
  /// In en, this message translates to:
  /// **'Back to Sign in'**
  String get onboarding_back_to_sign_in;

  /// No description provided for @onboarding_please_enter_a_username.
  ///
  /// In en, this message translates to:
  /// **'Please enter a username.'**
  String get onboarding_please_enter_a_username;

  /// No description provided for @onboarding_please_enter_a_valid_email_address.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get onboarding_please_enter_a_valid_email_address;

  /// No description provided for @onboarding_please_enter_a_long_password.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password that is at least 6 characters long.'**
  String get onboarding_please_enter_a_long_password;

  /// No description provided for @onboarding_invalid_username_or_password.
  ///
  /// In en, this message translates to:
  /// **'Invalid username or password. Please try again.'**
  String get onboarding_invalid_username_or_password;

  /// No description provided for @onboarding_email_sign_up_failed.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get onboarding_email_sign_up_failed;

  /// No description provided for @onboarding_email_sign_up_failed_email_address_invalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get onboarding_email_sign_up_failed_email_address_invalid;

  /// No description provided for @onboarding_email_sign_up_failed_email_exists.
  ///
  /// In en, this message translates to:
  /// **'This email address is already in use. Please log in.'**
  String get onboarding_email_sign_up_failed_email_exists;

  /// No description provided for @onboarding_email_sign_up_failed_email_not_confirmed.
  ///
  /// In en, this message translates to:
  /// **'This email address is pending confirmation. Please check your inbox or resend the confirmation email.'**
  String get onboarding_email_sign_up_failed_email_not_confirmed;

  /// No description provided for @onboarding_email_sign_up_failed_over_email_send_rate_limit.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please wait a moment and try again.'**
  String get onboarding_email_sign_up_failed_over_email_send_rate_limit;

  /// No description provided for @onboarding_email_not_registered.
  ///
  /// In en, this message translates to:
  /// **'The email address is not registered. Please try again with a valid address.'**
  String get onboarding_email_not_registered;

  /// No description provided for @onboarding_email_sending_error.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while sending the email. Please try again later.'**
  String get onboarding_email_sending_error;

  /// No description provided for @onboarding_waiting_for_confirm_email.
  ///
  /// In en, this message translates to:
  /// **'Waiting for confirmation email'**
  String get onboarding_waiting_for_confirm_email;

  /// No description provided for @time_saved_todo.
  ///
  /// In en, this message translates to:
  /// **'Todo'**
  String get time_saved_todo;

  /// No description provided for @time_saved_load_more.
  ///
  /// In en, this message translates to:
  /// **'load more'**
  String get time_saved_load_more;

  /// No description provided for @time_saved_most_frequent_transitions.
  ///
  /// In en, this message translates to:
  /// **'Most Frequent Transitions'**
  String get time_saved_most_frequent_transitions;

  /// No description provided for @time_saved_according_to_research.
  ///
  /// In en, this message translates to:
  /// **'According to research conducted by Qatalog in collaboration with Cornell University’s Ellis Idea Lab'**
  String get time_saved_according_to_research;

  /// No description provided for @time_saved_based_on_our.
  ///
  /// In en, this message translates to:
  /// **'Based on our internal experiments'**
  String get time_saved_based_on_our;

  /// No description provided for @time_saved_calendars_are_not_separated.
  ///
  /// In en, this message translates to:
  /// **'Calendars are not separated by account because they can be used without switching apps through subscription or sharing features.'**
  String get time_saved_calendars_are_not_separated;

  /// No description provided for @time_saved_hourly_wage_only_device.
  ///
  /// In en, this message translates to:
  /// **'The hourly wage is stored only on this device and is not saved anywhere else, ensuring your data remains secure.'**
  String get time_saved_hourly_wage_only_device;

  /// No description provided for @time_saved_button_title.
  ///
  /// In en, this message translates to:
  /// **'Saved \${number}'**
  String time_saved_button_title(Object number);

  /// No description provided for @time_saved_button_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Saved in {month}'**
  String time_saved_button_tooltip(Object month);

  /// No description provided for @time_saved_screen_title.
  ///
  /// In en, this message translates to:
  /// **'Time Saved'**
  String get time_saved_screen_title;

  /// No description provided for @time_saved_your_savings.
  ///
  /// In en, this message translates to:
  /// **'Your Savings'**
  String get time_saved_your_savings;

  /// No description provided for @time_saved_time_saved.
  ///
  /// In en, this message translates to:
  /// **'Time Saved'**
  String get time_saved_time_saved;

  /// No description provided for @time_saved_money_saved.
  ///
  /// In en, this message translates to:
  /// **'Money Saved'**
  String get time_saved_money_saved;

  /// No description provided for @time_saved_hour_per_week.
  ///
  /// In en, this message translates to:
  /// **'h / week'**
  String get time_saved_hour_per_week;

  /// No description provided for @time_saved_based_on_your_last_week_data.
  ///
  /// In en, this message translates to:
  /// **'*based on the last 7 days of data'**
  String get time_saved_based_on_your_last_week_data;

  /// No description provided for @time_saved_based_on_your_hourly_wage.
  ///
  /// In en, this message translates to:
  /// **'*based on your hourly wage'**
  String get time_saved_based_on_your_hourly_wage;

  /// No description provided for @time_saved_hourly_wage.
  ///
  /// In en, this message translates to:
  /// **'Hourly Wage'**
  String get time_saved_hourly_wage;

  /// No description provided for @time_saved_per_hour.
  ///
  /// In en, this message translates to:
  /// **'/ hr'**
  String get time_saved_per_hour;

  /// No description provided for @time_saved_time_spent_on_app_switching.
  ///
  /// In en, this message translates to:
  /// **'Time Spent on App Switching (Direct)'**
  String get time_saved_time_spent_on_app_switching;

  /// No description provided for @time_saved_focus_lost_from_app_switching.
  ///
  /// In en, this message translates to:
  /// **'Focus Lost from App Switching (Indirect)'**
  String get time_saved_focus_lost_from_app_switching;

  /// No description provided for @time_saved_seconds.
  ///
  /// In en, this message translates to:
  /// **'seconds'**
  String get time_saved_seconds;

  /// No description provided for @time_saved_app_switches.
  ///
  /// In en, this message translates to:
  /// **'App Switches'**
  String get time_saved_app_switches;

  /// No description provided for @time_saved_time_per_switch.
  ///
  /// In en, this message translates to:
  /// **'Time Per Switch'**
  String get time_saved_time_per_switch;

  /// No description provided for @time_saved_time_wasted.
  ///
  /// In en, this message translates to:
  /// **'Time Wasted'**
  String get time_saved_time_wasted;

  /// No description provided for @time_saved_hours_in_low_focus.
  ///
  /// In en, this message translates to:
  /// **'Hours in Low Focus'**
  String get time_saved_hours_in_low_focus;

  /// No description provided for @time_saved_productivity_loss.
  ///
  /// In en, this message translates to:
  /// **'Productivity Loss'**
  String get time_saved_productivity_loss;

  /// No description provided for @time_saved_calculation_method.
  ///
  /// In en, this message translates to:
  /// **'Calculation Method'**
  String get time_saved_calculation_method;

  /// No description provided for @time_saved_hidden_coast.
  ///
  /// In en, this message translates to:
  /// **'The Hidden Cost of App Switching'**
  String get time_saved_hidden_coast;

  /// No description provided for @time_saved_opening_apps_title.
  ///
  /// In en, this message translates to:
  /// **'Time Wasted Searching for and Opening Apps'**
  String get time_saved_opening_apps_title;

  /// No description provided for @time_saved_opening_apps_description.
  ///
  /// In en, this message translates to:
  /// **'Switching between apps takes time to locate and open each tool, with every transition taking an average of 9 seconds. These small delays accumulate, creating unnecessary interruptions and slowing down your workflow.'**
  String get time_saved_opening_apps_description;

  /// No description provided for @time_saved_ease_switch_title.
  ///
  /// In en, this message translates to:
  /// **'Productivity Loss After Each Switch'**
  String get time_saved_ease_switch_title;

  /// No description provided for @time_saved_ease_switch_description.
  ///
  /// In en, this message translates to:
  /// **'After switching apps, it takes an average of 9.5 minutes to regain focus and return to a productive state. This repeated loss of focus leads to significant wasted time each week, impacting your overall efficiency.'**
  String get time_saved_ease_switch_description;

  /// No description provided for @time_saved_how_solved_title.
  ///
  /// In en, this message translates to:
  /// **'How Visir Solves This'**
  String get time_saved_how_solved_title;

  /// No description provided for @time_saved_how_solved_description.
  ///
  /// In en, this message translates to:
  /// **'With Visir, all your apps are accessible and manageable in one place. By eliminating app switching, Visir saves you time and helps you maintain focus, ensuring your productivity remains uninterrupted.'**
  String get time_saved_how_solved_description;

  /// No description provided for @time_saved_projection_description_first.
  ///
  /// In en, this message translates to:
  /// **'You\'ve been using Visir for '**
  String get time_saved_projection_description_first;

  /// No description provided for @time_saved_projection_days.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String time_saved_projection_days(Object count);

  /// No description provided for @time_saved_projection_description_second.
  ///
  /// In en, this message translates to:
  /// **' and have reduced '**
  String get time_saved_projection_description_second;

  /// No description provided for @time_saved_projection_app_switches.
  ///
  /// In en, this message translates to:
  /// **'{count} app switches'**
  String time_saved_projection_app_switches(Object count);

  /// No description provided for @time_saved_projection_description_third.
  ///
  /// In en, this message translates to:
  /// **' so far. This saved you a total of '**
  String get time_saved_projection_description_third;

  /// No description provided for @time_saved_projection_hours.
  ///
  /// In en, this message translates to:
  /// **'{count} hours'**
  String time_saved_projection_hours(Object count);

  /// No description provided for @time_saved_projection_description_fourth.
  ///
  /// In en, this message translates to:
  /// **', which equals '**
  String get time_saved_projection_description_fourth;

  /// No description provided for @time_saved_projection_description_fifth.
  ///
  /// In en, this message translates to:
  /// **' based on your hourly wage. If this pace continues, your projected annual savings are '**
  String get time_saved_projection_description_fifth;

  /// No description provided for @time_saved_productive_hours_reclaimed.
  ///
  /// In en, this message translates to:
  /// **'Productive Hours Reclaimed'**
  String get time_saved_productive_hours_reclaimed;

  /// No description provided for @time_saved_most_frequent_switch.
  ///
  /// In en, this message translates to:
  /// **'Most Frequent Switch'**
  String get time_saved_most_frequent_switch;

  /// No description provided for @time_saved_wasted_switching.
  ///
  /// In en, this message translates to:
  /// **'Wasted Switching'**
  String get time_saved_wasted_switching;

  /// No description provided for @time_saved_wasted_regaining_focus.
  ///
  /// In en, this message translates to:
  /// **'Wasted Regaining Focus'**
  String get time_saved_wasted_regaining_focus;

  /// No description provided for @time_saved_last_7_days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get time_saved_last_7_days;

  /// No description provided for @time_saved_last_14_days.
  ///
  /// In en, this message translates to:
  /// **'Last 14 days'**
  String get time_saved_last_14_days;

  /// No description provided for @time_saved_last_28_days.
  ///
  /// In en, this message translates to:
  /// **'Last 28 days'**
  String get time_saved_last_28_days;

  /// No description provided for @time_saved_last_12_weeks.
  ///
  /// In en, this message translates to:
  /// **'Last 12 weeks'**
  String get time_saved_last_12_weeks;

  /// No description provided for @time_saved_last_12_months.
  ///
  /// In en, this message translates to:
  /// **'Last 12 months'**
  String get time_saved_last_12_months;

  /// No description provided for @time_saved_this_week.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get time_saved_this_week;

  /// No description provided for @time_saved_this_month.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get time_saved_this_month;

  /// No description provided for @time_saved_this_year.
  ///
  /// In en, this message translates to:
  /// **'This Year'**
  String get time_saved_this_year;

  /// No description provided for @time_saved_total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get time_saved_total;

  /// No description provided for @time_saved_trend.
  ///
  /// In en, this message translates to:
  /// **'Savings Trend'**
  String get time_saved_trend;

  /// No description provided for @time_saved_times.
  ///
  /// In en, this message translates to:
  /// **'times'**
  String get time_saved_times;

  /// No description provided for @time_saved_savings_with.
  ///
  /// In en, this message translates to:
  /// **'Savings with'**
  String get time_saved_savings_with;

  /// No description provided for @time_saved_switches_avoided.
  ///
  /// In en, this message translates to:
  /// **'Switches Avoided'**
  String get time_saved_switches_avoided;

  /// No description provided for @time_saved_that_is_equivalent_to.
  ///
  /// In en, this message translates to:
  /// **'That\'s equivalent to'**
  String get time_saved_that_is_equivalent_to;

  /// No description provided for @time_saved_how_i_did_it.
  ///
  /// In en, this message translates to:
  /// **'How I did it'**
  String get time_saved_how_i_did_it;

  /// No description provided for @time_saved_watching.
  ///
  /// In en, this message translates to:
  /// **'Watching'**
  String get time_saved_watching;

  /// No description provided for @time_saved_episodes.
  ///
  /// In en, this message translates to:
  /// **'episodes'**
  String get time_saved_episodes;

  /// No description provided for @time_saved_buy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get time_saved_buy;

  /// No description provided for @time_saved_burgers.
  ///
  /// In en, this message translates to:
  /// **'burgers'**
  String get time_saved_burgers;

  /// No description provided for @time_saved_start_using_taskey.
  ///
  /// In en, this message translates to:
  /// **'Start using Visir to see your savings'**
  String get time_saved_start_using_taskey;

  /// No description provided for @time_saved_share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get time_saved_share;

  /// No description provided for @time_saved_download_image.
  ///
  /// In en, this message translates to:
  /// **'Download Image'**
  String get time_saved_download_image;

  /// No description provided for @time_saved_share_tutorial_title.
  ///
  /// In en, this message translates to:
  /// **'Image copied to clipboard'**
  String get time_saved_share_tutorial_title;

  /// No description provided for @time_saved_share_tutorial_description.
  ///
  /// In en, this message translates to:
  /// **'Click Continue to open {platform}, then paste the image'**
  String time_saved_share_tutorial_description(Object platform);

  /// No description provided for @time_saved_share_tutorial_button.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get time_saved_share_tutorial_button;

  /// No description provided for @time_saved_saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get time_saved_saved;

  /// No description provided for @time_saved_saved_in.
  ///
  /// In en, this message translates to:
  /// **'Saved in'**
  String get time_saved_saved_in;

  /// No description provided for @time_saved_saved_in_the.
  ///
  /// In en, this message translates to:
  /// **'Saved in the'**
  String get time_saved_saved_in_the;

  /// No description provided for @time_saved_taskey_helped_you_save.
  ///
  /// In en, this message translates to:
  /// **'Visir helped you save {hours} hours and \${money}'**
  String time_saved_taskey_helped_you_save(Object hours, Object money);

  /// No description provided for @time_saved_in.
  ///
  /// In en, this message translates to:
  /// **'in {viewType}'**
  String time_saved_in(Object viewType);

  /// No description provided for @time_saved_in_the.
  ///
  /// In en, this message translates to:
  /// **'in the {viewType}'**
  String time_saved_in_the(Object viewType);

  /// No description provided for @time_saved_taskey_helped_you_save_total.
  ///
  /// In en, this message translates to:
  /// **'Congrats 🎉🎉 \${money} saved so far.'**
  String time_saved_taskey_helped_you_save_total(Object money);

  /// No description provided for @time_saved_total_share_text.
  ///
  /// In en, this message translates to:
  /// **'🙌 Only {days} days with Visir and I\'ve already saved {hours} hours and \${money}! Give it a try!'**
  String time_saved_total_share_text(Object days, Object hours, Object money);

  /// No description provided for @time_saved_check_out_taskey_here.
  ///
  /// In en, this message translates to:
  /// **'✨ Check out Visir here : {url}'**
  String time_saved_check_out_taskey_here(Object url);

  /// No description provided for @subscription_visir_pro.
  ///
  /// In en, this message translates to:
  /// **'Pro Plan'**
  String get subscription_visir_pro;

  /// No description provided for @subscription_unlimited_integrations.
  ///
  /// In en, this message translates to:
  /// **'Unlimited integrations'**
  String get subscription_unlimited_integrations;

  /// No description provided for @subscription_ai_suggestion.
  ///
  /// In en, this message translates to:
  /// **'AI Suggestions and more AI features'**
  String get subscription_ai_suggestion;

  /// No description provided for @subscription_pro_ai_based_inbox_summary.
  ///
  /// In en, this message translates to:
  /// **'AI based inbox suggestions'**
  String get subscription_pro_ai_based_inbox_summary;

  /// No description provided for @subscription_pro_next_schedule_summary.
  ///
  /// In en, this message translates to:
  /// **'Next schedule summary'**
  String get subscription_pro_next_schedule_summary;

  /// No description provided for @subscription_pro_100k_ai_tokens.
  ///
  /// In en, this message translates to:
  /// **'100K AI tokens monthly for AI-powered summaries and insights'**
  String get subscription_pro_100k_ai_tokens;

  /// No description provided for @subscription_all_features.
  ///
  /// In en, this message translates to:
  /// **'All features'**
  String get subscription_all_features;

  /// No description provided for @subscription_priority_support.
  ///
  /// In en, this message translates to:
  /// **'Priority support'**
  String get subscription_priority_support;

  /// No description provided for @subscription_continuous_update.
  ///
  /// In en, this message translates to:
  /// **'Continuous updates, no price increase'**
  String get subscription_continuous_update;

  /// No description provided for @subscription_visir_ultra.
  ///
  /// In en, this message translates to:
  /// **'Ultra Plan'**
  String get subscription_visir_ultra;

  /// No description provided for @subscription_ultra.
  ///
  /// In en, this message translates to:
  /// **'Ultra'**
  String get subscription_ultra;

  /// No description provided for @subscription_ultra_best_value.
  ///
  /// In en, this message translates to:
  /// **'Best Value'**
  String get subscription_ultra_best_value;

  /// No description provided for @subscription_ultra_all_pro_features.
  ///
  /// In en, this message translates to:
  /// **'All features in Pro'**
  String get subscription_ultra_all_pro_features;

  /// No description provided for @subscription_ultra_500k_ai_tokens.
  ///
  /// In en, this message translates to:
  /// **'500K additional AI tokens monthly'**
  String get subscription_ultra_500k_ai_tokens;

  /// No description provided for @subscription_ultra_advanced_ai_features.
  ///
  /// In en, this message translates to:
  /// **'Advanced AI features and unlimited AI requests'**
  String get subscription_ultra_advanced_ai_features;

  /// No description provided for @subscription_ultra_priority_support.
  ///
  /// In en, this message translates to:
  /// **'Priority support'**
  String get subscription_ultra_priority_support;

  /// No description provided for @subscription_ultra_continuous_update.
  ///
  /// In en, this message translates to:
  /// **'Continuous updates, no price increase'**
  String get subscription_ultra_continuous_update;

  /// No description provided for @subscription_monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get subscription_monthly;

  /// No description provided for @subscription_yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get subscription_yearly;

  /// No description provided for @subscription_early_access_discout.
  ///
  /// In en, this message translates to:
  /// **'Early Access Discount'**
  String get subscription_early_access_discout;

  /// No description provided for @subscription_active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get subscription_active;

  /// No description provided for @subscription_manage_billing.
  ///
  /// In en, this message translates to:
  /// **'Manage billing'**
  String get subscription_manage_billing;

  /// No description provided for @subscription_switch_subscription.
  ///
  /// In en, this message translates to:
  /// **'Switch plan'**
  String get subscription_switch_subscription;

  /// No description provided for @subscription_per_month.
  ///
  /// In en, this message translates to:
  /// **' /mo'**
  String get subscription_per_month;

  /// No description provided for @subscription_next_billing_date.
  ///
  /// In en, this message translates to:
  /// **'Next bill on'**
  String get subscription_next_billing_date;

  /// No description provided for @subscription_subscription_ends.
  ///
  /// In en, this message translates to:
  /// **'Subscription ends on'**
  String get subscription_subscription_ends;

  /// No description provided for @subscription_free_trial_ends.
  ///
  /// In en, this message translates to:
  /// **'Free trial ends on'**
  String get subscription_free_trial_ends;

  /// No description provided for @subscription_upgrade_to_pro.
  ///
  /// In en, this message translates to:
  /// **'Choose this plan'**
  String get subscription_upgrade_to_pro;

  /// No description provided for @subscription_save_two_months_more.
  ///
  /// In en, this message translates to:
  /// **'Save 2-months more'**
  String get subscription_save_two_months_more;

  /// No description provided for @subscription_billed_annualy.
  ///
  /// In en, this message translates to:
  /// **'Billed annually'**
  String get subscription_billed_annualy;

  /// No description provided for @subscription_restore_subscription.
  ///
  /// In en, this message translates to:
  /// **'Restore subscription'**
  String get subscription_restore_subscription;

  /// No description provided for @subscription_contact_billing_support.
  ///
  /// In en, this message translates to:
  /// **'Contact billing support'**
  String get subscription_contact_billing_support;

  /// No description provided for @subscription_your_savings_tooptip_desktop.
  ///
  /// In en, this message translates to:
  /// **'The range you choose here also updates the Saved amount in the app’s top right corner.'**
  String get subscription_your_savings_tooptip_desktop;

  /// No description provided for @subscription_your_savings_tooptip_mobile.
  ///
  /// In en, this message translates to:
  /// **'The range you choose here also updates the Saved amount below the settings icon in the bottom-right corner.'**
  String get subscription_your_savings_tooptip_mobile;

  /// No description provided for @update_required_title.
  ///
  /// In en, this message translates to:
  /// **'Update Required'**
  String get update_required_title;

  /// No description provided for @update_required_body.
  ///
  /// In en, this message translates to:
  /// **'This version is no longer supported. Please update to continue.'**
  String get update_required_body;

  /// No description provided for @update_required_button.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update_required_button;

  /// No description provided for @delete_confirm_text.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to proceed? Deleting your account will permanently remove all your task data and account information from our system. This action is irreversible.'**
  String get delete_confirm_text;

  /// No description provided for @delete_confirm_title.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete_confirm_title;

  /// No description provided for @join_community.
  ///
  /// In en, this message translates to:
  /// **'Join community'**
  String get join_community;

  /// No description provided for @join_slack_community.
  ///
  /// In en, this message translates to:
  /// **'Join Slack community'**
  String get join_slack_community;

  /// No description provided for @download_for_mobile.
  ///
  /// In en, this message translates to:
  /// **'Download for mobile'**
  String get download_for_mobile;

  /// No description provided for @webview2_required_title.
  ///
  /// In en, this message translates to:
  /// **'Need WebView2 Runtime'**
  String get webview2_required_title;

  /// No description provided for @webview2_required_body.
  ///
  /// In en, this message translates to:
  /// **'To view and edit emails in Visir, you need the WebView2 Runtime. You can get it from the official Microsoft website.'**
  String get webview2_required_body;

  /// No description provided for @webview2_required_button.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get webview2_required_button;

  /// No description provided for @error_message_dont_have_permission.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permissions to do this action'**
  String get error_message_dont_have_permission;

  /// No description provided for @n_selected.
  ///
  /// In en, this message translates to:
  /// **'{count} Selected'**
  String n_selected(Object count);

  /// No description provided for @mail_options.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get mail_options;

  /// No description provided for @mail_options_title.
  ///
  /// In en, this message translates to:
  /// **'Reply & More'**
  String get mail_options_title;

  /// No description provided for @download_button.
  ///
  /// In en, this message translates to:
  /// **'Download native Visir app'**
  String get download_button;

  /// No description provided for @search_inbox.
  ///
  /// In en, this message translates to:
  /// **'Search inbox'**
  String get search_inbox;

  /// No description provided for @tooltip_prev_day.
  ///
  /// In en, this message translates to:
  /// **'Previous day'**
  String get tooltip_prev_day;

  /// No description provided for @tooltip_next_day.
  ///
  /// In en, this message translates to:
  /// **'Next day'**
  String get tooltip_next_day;

  /// No description provided for @tooltip_prev_n_day.
  ///
  /// In en, this message translates to:
  /// **'Previous {count} days'**
  String tooltip_prev_n_day(Object count);

  /// No description provided for @tooltip_next_n_day.
  ///
  /// In en, this message translates to:
  /// **'Next {count} days'**
  String tooltip_next_n_day(Object count);

  /// No description provided for @tooltip_prev_week.
  ///
  /// In en, this message translates to:
  /// **'Previous week'**
  String get tooltip_prev_week;

  /// No description provided for @tooltip_next_week.
  ///
  /// In en, this message translates to:
  /// **'Next week'**
  String get tooltip_next_week;

  /// No description provided for @tooltip_prev_month.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get tooltip_prev_month;

  /// No description provided for @tooltip_next_month.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get tooltip_next_month;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @show_hide_calendars.
  ///
  /// In en, this message translates to:
  /// **'Show / Hide calendars'**
  String get show_hide_calendars;

  /// No description provided for @tooltip_view_range.
  ///
  /// In en, this message translates to:
  /// **'View range'**
  String get tooltip_view_range;

  /// No description provided for @tooltip_view_range_shortcut_to_week.
  ///
  /// In en, this message translates to:
  /// **'1~7, W'**
  String get tooltip_view_range_shortcut_to_week;

  /// No description provided for @tooltip_view_range_shortcut_to_month.
  ///
  /// In en, this message translates to:
  /// **'1~7, W, M'**
  String get tooltip_view_range_shortcut_to_month;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @quick_view.
  ///
  /// In en, this message translates to:
  /// **'Quick view'**
  String get quick_view;

  /// No description provided for @open_in.
  ///
  /// In en, this message translates to:
  /// **'Open in {provider}'**
  String open_in(Object provider);

  /// No description provided for @remove_from_inbox.
  ///
  /// In en, this message translates to:
  /// **'Remove from inbox'**
  String get remove_from_inbox;

  /// No description provided for @open_in_chat_tab.
  ///
  /// In en, this message translates to:
  /// **'Open in chat tab'**
  String get open_in_chat_tab;

  /// No description provided for @open_in_mail_tab.
  ///
  /// In en, this message translates to:
  /// **'Open in mail tab'**
  String get open_in_mail_tab;

  /// No description provided for @disconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// No description provided for @inbox_filter.
  ///
  /// In en, this message translates to:
  /// **'Inbox filter'**
  String get inbox_filter;

  /// No description provided for @notification_preference.
  ///
  /// In en, this message translates to:
  /// **'Notification perferences'**
  String get notification_preference;

  /// No description provided for @chat_preference.
  ///
  /// In en, this message translates to:
  /// **'Chat perferences'**
  String get chat_preference;

  /// No description provided for @join_conference.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get join_conference;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @mute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get mute;

  /// No description provided for @unmute.
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get unmute;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @go_back.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get go_back;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @duplicate.
  ///
  /// In en, this message translates to:
  /// **'Dupliacte'**
  String get duplicate;

  /// No description provided for @search_mail.
  ///
  /// In en, this message translates to:
  /// **'Search mail'**
  String get search_mail;

  /// No description provided for @search_channels.
  ///
  /// In en, this message translates to:
  /// **'Search channels'**
  String get search_channels;

  /// No description provided for @collapse.
  ///
  /// In en, this message translates to:
  /// **'Collapse'**
  String get collapse;

  /// No description provided for @expand.
  ///
  /// In en, this message translates to:
  /// **'Expand'**
  String get expand;

  /// No description provided for @cancel_search.
  ///
  /// In en, this message translates to:
  /// **'Cancel search'**
  String get cancel_search;

  /// No description provided for @reaction.
  ///
  /// In en, this message translates to:
  /// **'Reaction'**
  String get reaction;

  /// No description provided for @reply_in_thread.
  ///
  /// In en, this message translates to:
  /// **'Reply in thread'**
  String get reply_in_thread;

  /// No description provided for @more_actions.
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get more_actions;

  /// No description provided for @attach.
  ///
  /// In en, this message translates to:
  /// **'Attach'**
  String get attach;

  /// No description provided for @drag_and_drop.
  ///
  /// In en, this message translates to:
  /// **'Drag & drop'**
  String get drag_and_drop;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @quick_link_hint_link.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get quick_link_hint_link;

  /// No description provided for @quick_link_hint_title.
  ///
  /// In en, this message translates to:
  /// **'Title (Optional)'**
  String get quick_link_hint_title;

  /// No description provided for @quick_link_add.
  ///
  /// In en, this message translates to:
  /// **'Add quick link'**
  String get quick_link_add;

  /// No description provided for @quick_link_more.
  ///
  /// In en, this message translates to:
  /// **'More quick links'**
  String get quick_link_more;

  /// No description provided for @copy_message.
  ///
  /// In en, this message translates to:
  /// **'Copy message'**
  String get copy_message;

  /// No description provided for @text_copied_to_clipboard.
  ///
  /// In en, this message translates to:
  /// **'Message copied to clipboard'**
  String get text_copied_to_clipboard;

  /// No description provided for @tutorial_welcome_to_taskey.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Visir!'**
  String get tutorial_welcome_to_taskey;

  /// No description provided for @tutorial_connect_apps.
  ///
  /// In en, this message translates to:
  /// **'Connect Mail, Calendar, and Slack.'**
  String get tutorial_connect_apps;

  /// No description provided for @tutorial_keep_everything_organized.
  ///
  /// In en, this message translates to:
  /// **'Keep everything organized and reclaim your time.'**
  String get tutorial_keep_everything_organized;

  /// No description provided for @tutorial_get_started.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get tutorial_get_started;

  /// No description provided for @feature_tutorial_inbox_integration_title.
  ///
  /// In en, this message translates to:
  /// **'This is your Inbox'**
  String get feature_tutorial_inbox_integration_title;

  /// No description provided for @feature_tutorial_inbox_integration_description.
  ///
  /// In en, this message translates to:
  /// **'This is where all your messages from Mail and Chats come together.'**
  String get feature_tutorial_inbox_integration_description;

  /// No description provided for @feature_tutorial_inbox_integration_button.
  ///
  /// In en, this message translates to:
  /// **'Set up integrations'**
  String get feature_tutorial_inbox_integration_button;

  /// No description provided for @feature_tutorial_inbox_drag_and_drop_title.
  ///
  /// In en, this message translates to:
  /// **'Drag and drop task creation'**
  String get feature_tutorial_inbox_drag_and_drop_title;

  /// No description provided for @feature_tutorial_inbox_drag_and_drop_description.
  ///
  /// In en, this message translates to:
  /// **'Drag an issue from your Inbox to create a task or event instantly.'**
  String get feature_tutorial_inbox_drag_and_drop_description;

  /// No description provided for @feature_tutorial_inbox_drag_and_drop_button.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get feature_tutorial_inbox_drag_and_drop_button;

  /// No description provided for @feature_tutorial_mobile_inbox_drag_and_drop_title.
  ///
  /// In en, this message translates to:
  /// **'Long press task creation'**
  String get feature_tutorial_mobile_inbox_drag_and_drop_title;

  /// No description provided for @feature_tutorial_mobile_inbox_drag_and_drop_description.
  ///
  /// In en, this message translates to:
  /// **'Tap and hold an item in your Inbox to create a task or event.'**
  String get feature_tutorial_mobile_inbox_drag_and_drop_description;

  /// No description provided for @feature_tutorial_time_saved_title.
  ///
  /// In en, this message translates to:
  /// **'Switch less. Save more.'**
  String get feature_tutorial_time_saved_title;

  /// No description provided for @feature_tutorial_time_saved_description.
  ///
  /// In en, this message translates to:
  /// **'Every context switch drains focus and costs about 9.5 minutes and real dollars. Stay inside Visir and watch minutes and money stack up in Time Saved.'**
  String get feature_tutorial_time_saved_description;

  /// No description provided for @feature_tutorial_time_saved_button.
  ///
  /// In en, this message translates to:
  /// **'Show my savings'**
  String get feature_tutorial_time_saved_button;

  /// No description provided for @feature_tutorial_create_task_from_mail_title.
  ///
  /// In en, this message translates to:
  /// **'Turn mails into tasks'**
  String get feature_tutorial_create_task_from_mail_title;

  /// No description provided for @feature_tutorial_create_task_from_mail_description.
  ///
  /// In en, this message translates to:
  /// **'Use the Create task button to directly create a task from Mail.'**
  String get feature_tutorial_create_task_from_mail_description;

  /// No description provided for @feature_tutorial_create_task_from_mail_button.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get feature_tutorial_create_task_from_mail_button;

  /// No description provided for @google_calendar_permission_title.
  ///
  /// In en, this message translates to:
  /// **'Grant full access to sync your calendar'**
  String get google_calendar_permission_title;

  /// No description provided for @google_calendar_permission_description.
  ///
  /// In en, this message translates to:
  /// **'On the next screen, make sure to check all permission boxes. These permissions are required to manage your calendar events in Visir.'**
  String get google_calendar_permission_description;

  /// No description provided for @google_calendar_permission_button.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get google_calendar_permission_button;

  /// No description provided for @google_mail_permission_title.
  ///
  /// In en, this message translates to:
  /// **'Grant full access to connect your Gmail'**
  String get google_mail_permission_title;

  /// No description provided for @google_mail_permission_description.
  ///
  /// In en, this message translates to:
  /// **'On the next screen, make sure to check all permission boxes. These permissions are required to manage your emails in Visir.'**
  String get google_mail_permission_description;

  /// No description provided for @google_mail_permission_button.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get google_mail_permission_button;

  /// No description provided for @inbox_filter_tutorial_title.
  ///
  /// In en, this message translates to:
  /// **'Control what appears in your Inbox'**
  String get inbox_filter_tutorial_title;

  /// No description provided for @inbox_filter_tutorial_description.
  ///
  /// In en, this message translates to:
  /// **'Use inbox filter to choose which messages show up.'**
  String get inbox_filter_tutorial_description;

  /// No description provided for @inbox_filter_tutorial_button.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get inbox_filter_tutorial_button;

  /// No description provided for @download_mobile_app_popup_title.
  ///
  /// In en, this message translates to:
  /// **'Get Visir on mobile'**
  String get download_mobile_app_popup_title;

  /// No description provided for @download_mobile_app_popup_description.
  ///
  /// In en, this message translates to:
  /// **'Scan this QR code to download the app for iOS or Android. Visir on mobile offers the same full functionality as desktop.'**
  String get download_mobile_app_popup_description;

  /// No description provided for @download_mobile_app_popup_button.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get download_mobile_app_popup_button;

  /// No description provided for @download_for_desktop.
  ///
  /// In en, this message translates to:
  /// **'Download for desktop'**
  String get download_for_desktop;

  /// No description provided for @reacting_members.
  ///
  /// In en, this message translates to:
  /// **'Reacting members'**
  String get reacting_members;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @launch_at_startup.
  ///
  /// In en, this message translates to:
  /// **'Launch at startup'**
  String get launch_at_startup;

  /// No description provided for @ai_suggestion_section.
  ///
  /// In en, this message translates to:
  /// **'Suggestion'**
  String get ai_suggestion_section;

  /// No description provided for @ai_suggestion.
  ///
  /// In en, this message translates to:
  /// **'Suggested'**
  String get ai_suggestion;

  /// No description provided for @ai_suggestion_urgency_urgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get ai_suggestion_urgency_urgent;

  /// No description provided for @ai_suggestion_urgency_important.
  ///
  /// In en, this message translates to:
  /// **'Important'**
  String get ai_suggestion_urgency_important;

  /// No description provided for @ai_suggestion_urgency_action_required.
  ///
  /// In en, this message translates to:
  /// **'Action Required'**
  String get ai_suggestion_urgency_action_required;

  /// No description provided for @ai_suggestion_urgency_need_review.
  ///
  /// In en, this message translates to:
  /// **'Need Review'**
  String get ai_suggestion_urgency_need_review;

  /// No description provided for @ai_suggestion_reason_meeting_invitation.
  ///
  /// In en, this message translates to:
  /// **'Meeting Invitation'**
  String get ai_suggestion_reason_meeting_invitation;

  /// No description provided for @ai_suggestion_reason_meeting_followup.
  ///
  /// In en, this message translates to:
  /// **'Meeting Follow-up'**
  String get ai_suggestion_reason_meeting_followup;

  /// No description provided for @ai_suggestion_reason_meeting_notes.
  ///
  /// In en, this message translates to:
  /// **'Meeting Notes'**
  String get ai_suggestion_reason_meeting_notes;

  /// No description provided for @ai_suggestion_reason_task_assignment.
  ///
  /// In en, this message translates to:
  /// **'Task Assignment'**
  String get ai_suggestion_reason_task_assignment;

  /// No description provided for @ai_suggestion_reason_task_status_update.
  ///
  /// In en, this message translates to:
  /// **'Task Update'**
  String get ai_suggestion_reason_task_status_update;

  /// No description provided for @ai_suggestion_reason_scheduling_request.
  ///
  /// In en, this message translates to:
  /// **'Scheduling Request'**
  String get ai_suggestion_reason_scheduling_request;

  /// No description provided for @ai_suggestion_reason_scheduling_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Scheduling Confirmation'**
  String get ai_suggestion_reason_scheduling_confirmation;

  /// No description provided for @ai_suggestion_reason_document_review.
  ///
  /// In en, this message translates to:
  /// **'Document Review'**
  String get ai_suggestion_reason_document_review;

  /// No description provided for @ai_suggestion_reason_code_review.
  ///
  /// In en, this message translates to:
  /// **'Code Review'**
  String get ai_suggestion_reason_code_review;

  /// No description provided for @ai_suggestion_reason_approval_request.
  ///
  /// In en, this message translates to:
  /// **'Approval Request'**
  String get ai_suggestion_reason_approval_request;

  /// No description provided for @ai_suggestion_reason_question.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get ai_suggestion_reason_question;

  /// No description provided for @ai_suggestion_reason_information_sharing.
  ///
  /// In en, this message translates to:
  /// **'Info Sharing'**
  String get ai_suggestion_reason_information_sharing;

  /// No description provided for @ai_suggestion_reason_announcement.
  ///
  /// In en, this message translates to:
  /// **'Announcement'**
  String get ai_suggestion_reason_announcement;

  /// No description provided for @ai_suggestion_reason_system_notification.
  ///
  /// In en, this message translates to:
  /// **'System Notification'**
  String get ai_suggestion_reason_system_notification;

  /// No description provided for @ai_suggestion_reason_cold_contact.
  ///
  /// In en, this message translates to:
  /// **'Cold Contact'**
  String get ai_suggestion_reason_cold_contact;

  /// No description provided for @ai_suggestion_reason_customer_contact.
  ///
  /// In en, this message translates to:
  /// **'Customer Contact'**
  String get ai_suggestion_reason_customer_contact;

  /// No description provided for @ai_suggestion_reason_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get ai_suggestion_reason_other;

  /// No description provided for @ai_suggestion_due.
  ///
  /// In en, this message translates to:
  /// **'Due: {due}'**
  String ai_suggestion_due(Object due);

  /// No description provided for @ai_suggestion_due_asap.
  ///
  /// In en, this message translates to:
  /// **'ASAP'**
  String get ai_suggestion_due_asap;

  /// No description provided for @ai_suggestion_duration.
  ///
  /// In en, this message translates to:
  /// **'{mininutes} min'**
  String ai_suggestion_duration(Object mininutes);

  /// No description provided for @ai_thinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking...'**
  String get ai_thinking;

  /// No description provided for @inbox_sort_and_filter.
  ///
  /// In en, this message translates to:
  /// **'Sort & Filter'**
  String get inbox_sort_and_filter;

  /// No description provided for @inbox_sort_section.
  ///
  /// In en, this message translates to:
  /// **'Sorting'**
  String get inbox_sort_section;

  /// No description provided for @inbox_sort_recent.
  ///
  /// In en, this message translates to:
  /// **'Sort by recent'**
  String get inbox_sort_recent;

  /// No description provided for @inbox_sort_due.
  ///
  /// In en, this message translates to:
  /// **'Sort by due'**
  String get inbox_sort_due;

  /// No description provided for @inbox_sort_importnace.
  ///
  /// In en, this message translates to:
  /// **'Sort by importance'**
  String get inbox_sort_importnace;

  /// No description provided for @inbox_filter_section.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get inbox_filter_section;

  /// No description provided for @inbox_filter_urgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent only'**
  String get inbox_filter_urgent;

  /// No description provided for @inbox_filter_important.
  ///
  /// In en, this message translates to:
  /// **'Important or higher'**
  String get inbox_filter_important;

  /// No description provided for @inbox_filter_action_required.
  ///
  /// In en, this message translates to:
  /// **'Action Required or higher'**
  String get inbox_filter_action_required;

  /// No description provided for @inbox_filter_hide_all.
  ///
  /// In en, this message translates to:
  /// **'Hide all'**
  String get inbox_filter_hide_all;

  /// No description provided for @inbox_right_click_option_read.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get inbox_right_click_option_read;

  /// No description provided for @inbox_right_click_option_unread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get inbox_right_click_option_unread;

  /// No description provided for @inbox_right_click_option_pin.
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get inbox_right_click_option_pin;

  /// No description provided for @inbox_right_click_option_unpin.
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get inbox_right_click_option_unpin;

  /// No description provided for @inbox_right_click_option_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get inbox_right_click_option_delete;

  /// No description provided for @inbox_right_click_option_undelete.
  ///
  /// In en, this message translates to:
  /// **'Move back to inbox'**
  String get inbox_right_click_option_undelete;

  /// No description provided for @failed_to_send_mail.
  ///
  /// In en, this message translates to:
  /// **'Failed to send mail'**
  String get failed_to_send_mail;

  /// No description provided for @retry_to_send_mail.
  ///
  /// In en, this message translates to:
  /// **'Retry sending mail'**
  String get retry_to_send_mail;

  /// No description provided for @select_prev.
  ///
  /// In en, this message translates to:
  /// **'Select previous'**
  String get select_prev;

  /// No description provided for @select_next.
  ///
  /// In en, this message translates to:
  /// **'Select next'**
  String get select_next;

  /// No description provided for @new_message.
  ///
  /// In en, this message translates to:
  /// **'New Message'**
  String get new_message;

  /// No description provided for @new_messages.
  ///
  /// In en, this message translates to:
  /// **'{count} Messages'**
  String new_messages(Object count);

  /// No description provided for @ask_taskey.
  ///
  /// In en, this message translates to:
  /// **'Search anything'**
  String get ask_taskey;

  /// No description provided for @command_bar_hint.
  ///
  /// In en, this message translates to:
  /// **'Search for tasks, events, commands, and more…'**
  String get command_bar_hint;

  /// No description provided for @command_search_in_all.
  ///
  /// In en, this message translates to:
  /// **'Search{query} everywhere'**
  String command_search_in_all(Object query);

  /// No description provided for @command_search_in_mail.
  ///
  /// In en, this message translates to:
  /// **'Search{query} in emails'**
  String command_search_in_mail(Object query);

  /// No description provided for @command_search_in_event.
  ///
  /// In en, this message translates to:
  /// **'Search{query} in calendar events'**
  String command_search_in_event(Object query);

  /// No description provided for @command_search_in_task.
  ///
  /// In en, this message translates to:
  /// **'Search{query} in tasks'**
  String command_search_in_task(Object query);

  /// No description provided for @command_search_in_chat.
  ///
  /// In en, this message translates to:
  /// **'Search{query} in chats'**
  String command_search_in_chat(Object query);

  /// No description provided for @command_create_task.
  ///
  /// In en, this message translates to:
  /// **'Create task {title}'**
  String command_create_task(Object title);

  /// No description provided for @command_edit_task.
  ///
  /// In en, this message translates to:
  /// **'Edit task {title}'**
  String command_edit_task(Object title);

  /// No description provided for @command_delete_task.
  ///
  /// In en, this message translates to:
  /// **'Delete task {title}'**
  String command_delete_task(Object title);

  /// No description provided for @command_mark_as_done_task.
  ///
  /// In en, this message translates to:
  /// **'Mark as done {title}'**
  String command_mark_as_done_task(Object title);

  /// No description provided for @command_mark_as_undone_task.
  ///
  /// In en, this message translates to:
  /// **'Mark as undone {title}'**
  String command_mark_as_undone_task(Object title);

  /// No description provided for @command_create_event.
  ///
  /// In en, this message translates to:
  /// **'Create calendar event {title}'**
  String command_create_event(Object title);

  /// No description provided for @command_edit_event.
  ///
  /// In en, this message translates to:
  /// **'Edit calendar event {title}'**
  String command_edit_event(Object title);

  /// No description provided for @command_delete_event.
  ///
  /// In en, this message translates to:
  /// **'Delete calendar event {title}'**
  String command_delete_event(Object title);

  /// No description provided for @command_chat_open_channel.
  ///
  /// In en, this message translates to:
  /// **'Open channel {title}'**
  String command_chat_open_channel(Object title);

  /// No description provided for @command_chat_send_message.
  ///
  /// In en, this message translates to:
  /// **'Send message {title}'**
  String command_chat_send_message(Object title);

  /// No description provided for @command_chat_show_channel.
  ///
  /// In en, this message translates to:
  /// **'Show channel {title}'**
  String command_chat_show_channel(Object title);

  /// No description provided for @command_chat_hide_channel.
  ///
  /// In en, this message translates to:
  /// **'Hide channel {title}'**
  String command_chat_hide_channel(Object title);

  /// No description provided for @command_argument_title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get command_argument_title;

  /// No description provided for @command_arguemnt_message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get command_arguemnt_message;

  /// No description provided for @command_argument_description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get command_argument_description;

  /// No description provided for @command_argument_rrule.
  ///
  /// In en, this message translates to:
  /// **'Recurrence rule'**
  String get command_argument_rrule;

  /// No description provided for @command_argument_at.
  ///
  /// In en, this message translates to:
  /// **'At'**
  String get command_argument_at;

  /// No description provided for @command_argument_recurring.
  ///
  /// In en, this message translates to:
  /// **'Every'**
  String get command_argument_recurring;

  /// No description provided for @command_argument_reminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get command_argument_reminder;

  /// No description provided for @command_argument_location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get command_argument_location;

  /// No description provided for @command_argument_attendee.
  ///
  /// In en, this message translates to:
  /// **'Attendee'**
  String get command_argument_attendee;

  /// No description provided for @command_argument_calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get command_argument_calendar;

  /// No description provided for @command_argument_color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get command_argument_color;

  /// No description provided for @command_argument_channel.
  ///
  /// In en, this message translates to:
  /// **'Channel'**
  String get command_argument_channel;

  /// No description provided for @command_suggestion.
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get command_suggestion;

  /// No description provided for @command_results.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get command_results;

  /// No description provided for @command_argument_with.
  ///
  /// In en, this message translates to:
  /// **'with '**
  String get command_argument_with;

  /// No description provided for @command_argument_and.
  ///
  /// In en, this message translates to:
  /// **'and '**
  String get command_argument_and;

  /// No description provided for @command_argument_add_flag.
  ///
  /// In en, this message translates to:
  /// **'Add {flag}'**
  String command_argument_add_flag(Object flag);

  /// No description provided for @command_argument_set_flag.
  ///
  /// In en, this message translates to:
  /// **'Set {flag}: {value}'**
  String command_argument_set_flag(Object flag, Object value);

  /// No description provided for @command_argument_marked_done.
  ///
  /// In en, this message translates to:
  /// **'which marked as done'**
  String get command_argument_marked_done;

  /// No description provided for @subscription_done_title.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Visir Pro'**
  String get subscription_done_title;

  /// No description provided for @subscription_done_description.
  ///
  /// In en, this message translates to:
  /// **'Manage all your emails, chats, calendars, and tasks in one place, simplify your workflow, and reclaim time for the work that matters.'**
  String get subscription_done_description;

  /// No description provided for @subscription_done_button.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get subscription_done_button;

  /// No description provided for @early_access_done_title.
  ///
  /// In en, this message translates to:
  /// **'Introducing Visir Pro'**
  String get early_access_done_title;

  /// No description provided for @early_access_done_description.
  ///
  /// In en, this message translates to:
  /// **'Free Early Access ends on August 30, continue with our discounted Early Access pricing after that.'**
  String get early_access_done_description;

  /// No description provided for @early_access_done_button.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get early_access_done_button;

  /// No description provided for @upgrade_to_taskey_pro_title.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Visir Pro'**
  String get upgrade_to_taskey_pro_title;

  /// No description provided for @upgrade_to_taskey_pro_button.
  ///
  /// In en, this message translates to:
  /// **'View plans'**
  String get upgrade_to_taskey_pro_button;

  /// No description provided for @expired_title.
  ///
  /// In en, this message translates to:
  /// **'Your subscription is expired'**
  String get expired_title;

  /// No description provided for @expired_title_ios.
  ///
  /// In en, this message translates to:
  /// **'This account doesn\'t currently have access to Visir'**
  String get expired_title_ios;

  /// No description provided for @expired_title_mobile.
  ///
  /// In en, this message translates to:
  /// **'Visir Pro needed'**
  String get expired_title_mobile;

  /// No description provided for @expired_description.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Visir Pro to access every feature, connect your calendars and inboxes, and keep your day organized from one place.'**
  String get expired_description;

  /// No description provided for @expired_button.
  ///
  /// In en, this message translates to:
  /// **'View plans'**
  String get expired_button;

  /// No description provided for @expired_button_mobile.
  ///
  /// In en, this message translates to:
  /// **'Download for desktop'**
  String get expired_button_mobile;

  /// No description provided for @expired_you_are_logged_in_as.
  ///
  /// In en, this message translates to:
  /// **'You’re logged in as'**
  String get expired_you_are_logged_in_as;

  /// No description provided for @expired_you_are_logged_in_with_apple.
  ///
  /// In en, this message translates to:
  /// **'You’re logged in with Apple'**
  String get expired_you_are_logged_in_with_apple;

  /// No description provided for @expired_log_out.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get expired_log_out;

  /// No description provided for @expired_delete_account.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get expired_delete_account;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @task_deleted.
  ///
  /// In en, this message translates to:
  /// **'Task deleted'**
  String get task_deleted;

  /// No description provided for @task_undone.
  ///
  /// In en, this message translates to:
  /// **'Task marked as undone'**
  String get task_undone;

  /// No description provided for @task_done.
  ///
  /// In en, this message translates to:
  /// **'Task marked as done'**
  String get task_done;

  /// No description provided for @event_deleted.
  ///
  /// In en, this message translates to:
  /// **'Calendar event deleted'**
  String get event_deleted;

  /// No description provided for @event_edited.
  ///
  /// In en, this message translates to:
  /// **'Calendar event edited'**
  String get event_edited;

  /// No description provided for @take_a_tour.
  ///
  /// In en, this message translates to:
  /// **'See how it works'**
  String get take_a_tour;

  /// No description provided for @tour_inbox_list_title.
  ///
  /// In en, this message translates to:
  /// **'Smart Unified Inbox'**
  String get tour_inbox_list_title;

  /// No description provided for @tour_inbox_list_description.
  ///
  /// In en, this message translates to:
  /// **'Integrated emails and chats are organized by date.\nAI Suggestions highlight what matters most, tagging items as Action Required, Need Review, Important, or Urgent.\nThey’re also classified as Tasks or Calendar Events, with time information extracted automatically.'**
  String get tour_inbox_list_description;

  /// No description provided for @tour_inbox_item_title.
  ///
  /// In en, this message translates to:
  /// **'Inbox from Mail & Chat'**
  String get tour_inbox_item_title;

  /// No description provided for @tour_inbox_item_description.
  ///
  /// In en, this message translates to:
  /// **'Your connected emails and chats, all in one place.\nClick to read, Reply to respond, Drag & Drop to turn into tasks or calendar events.'**
  String get tour_inbox_item_description;

  /// No description provided for @tour_inbox_item_description_mobile.
  ///
  /// In en, this message translates to:
  /// **'Your connected emails and chats, all in one place.\nClick to read, Reply to respond, Long press then Drag & Drop to turn into tasks or calendar events.'**
  String get tour_inbox_item_description_mobile;

  /// No description provided for @tour_task_calendar_title.
  ///
  /// In en, this message translates to:
  /// **'Task & Calendar'**
  String get tour_task_calendar_title;

  /// No description provided for @tour_task_calendar_description.
  ///
  /// In en, this message translates to:
  /// **'See all your connected calendars and tasks in one view.\nDouble-click anywhere or drag on the screen to create a new task or calendar event instantly.'**
  String get tour_task_calendar_description;

  /// No description provided for @tour_task_on_calendar_title.
  ///
  /// In en, this message translates to:
  /// **'Inbox Linked Tasks & Events'**
  String get tour_task_on_calendar_title;

  /// No description provided for @tour_task_on_calendar_description.
  ///
  /// In en, this message translates to:
  /// **'Any task or calendar event you create from the inbox stays connected.\nYou can always see which mail or chat it came from.'**
  String get tour_task_on_calendar_description;

  /// No description provided for @tour_task_linked_mail_title.
  ///
  /// In en, this message translates to:
  /// **'Quick Mail Access'**
  String get tour_task_linked_mail_title;

  /// No description provided for @tour_task_linked_mail_description.
  ///
  /// In en, this message translates to:
  /// **'Click the 👁 button to instantly open the linked mail in a popup.'**
  String get tour_task_linked_mail_description;

  /// No description provided for @tour_task_linked_chat_title.
  ///
  /// In en, this message translates to:
  /// **'Quick Chat Access'**
  String get tour_task_linked_chat_title;

  /// No description provided for @tour_task_linked_chat_description.
  ///
  /// In en, this message translates to:
  /// **'Also, click the 👁 button to instantly open the linked chat in a popup.'**
  String get tour_task_linked_chat_description;

  /// No description provided for @tour_task_linked_mail_detail_title.
  ///
  /// In en, this message translates to:
  /// **'Full Mail Experience'**
  String get tour_task_linked_mail_detail_title;

  /// No description provided for @tour_task_linked_mail_detail_description.
  ///
  /// In en, this message translates to:
  /// **'Read, reply, forward, and manage your emails.\nAll right from the Home tab.'**
  String get tour_task_linked_mail_detail_description;

  /// No description provided for @tour_task_linked_chat_detail_title.
  ///
  /// In en, this message translates to:
  /// **'Full Chat Experience'**
  String get tour_task_linked_chat_detail_title;

  /// No description provided for @tour_task_linked_chat_detail_description.
  ///
  /// In en, this message translates to:
  /// **'Read, reply, and keep your conversation context.\nAll without leaving the Home tab.'**
  String get tour_task_linked_chat_detail_description;

  /// No description provided for @tour_task_tab_title.
  ///
  /// In en, this message translates to:
  /// **'Task Tab'**
  String get tour_task_tab_title;

  /// No description provided for @tour_task_tab_description.
  ///
  /// In en, this message translates to:
  /// **'Manage all your tasks created in Visir with a familiar list view. Use filters like Unscheduled and Today to organize your tasks efficiently.'**
  String get tour_task_tab_description;

  /// No description provided for @tour_mail_tab_title.
  ///
  /// In en, this message translates to:
  /// **'Full-Featured Mail Tab'**
  String get tour_mail_tab_title;

  /// No description provided for @tour_mail_tab_description.
  ///
  /// In en, this message translates to:
  /// **'Access all the essential features of a standard mail app—star, unread, trash, spam, and more—right from the Mail tab.'**
  String get tour_mail_tab_description;

  /// No description provided for @tour_chat_tab_title.
  ///
  /// In en, this message translates to:
  /// **'Unified Chat Tab'**
  String get tour_chat_tab_title;

  /// No description provided for @tour_chat_tab_description.
  ///
  /// In en, this message translates to:
  /// **'View and manage channels from multiple workspaces in one place. Stay on top of new messages, reply, and react with ease.'**
  String get tour_chat_tab_description;

  /// No description provided for @tour_calendar_tab_title.
  ///
  /// In en, this message translates to:
  /// **'Comprehensive Calendar Tab'**
  String get tour_calendar_tab_title;

  /// No description provided for @tour_calendar_tab_description.
  ///
  /// In en, this message translates to:
  /// **'Manage your team’s calendars together and focus on your schedule, even without tasks. Enjoy a full-featured calendar experience.'**
  String get tour_calendar_tab_description;

  /// No description provided for @tour_chat_create_task_title.
  ///
  /// In en, this message translates to:
  /// **'Create Tasks or Events from Chat'**
  String get tour_chat_create_task_title;

  /// No description provided for @tour_chat_create_task_description.
  ///
  /// In en, this message translates to:
  /// **'Turn any chat message into a task or calendar event instantly. Just drag and drop or use the quick action button.'**
  String get tour_chat_create_task_description;

  /// No description provided for @tour_mail_create_task_title.
  ///
  /// In en, this message translates to:
  /// **'Create Tasks or Events from Mail'**
  String get tour_mail_create_task_title;

  /// No description provided for @tour_mail_create_task_description.
  ///
  /// In en, this message translates to:
  /// **'Easily convert any email into a task or calendar event. Stay organized by turning important messages into actionable items.'**
  String get tour_mail_create_task_description;

  /// No description provided for @tour_inbox_list_subject.
  ///
  /// In en, this message translates to:
  /// **'See all your emails and chats together, sorted by date with AI highlights.'**
  String get tour_inbox_list_subject;

  /// No description provided for @tour_inbox_item_subject.
  ///
  /// In en, this message translates to:
  /// **'Quickly access and manage your connected emails and chats in one inbox.'**
  String get tour_inbox_item_subject;

  /// No description provided for @tour_task_calendar_subject.
  ///
  /// In en, this message translates to:
  /// **'View all your calendars and tasks together, create new ones with a click or drag.'**
  String get tour_task_calendar_subject;

  /// No description provided for @tour_task_on_calendar_subject.
  ///
  /// In en, this message translates to:
  /// **'Tasks and events from the inbox stay linked to their original mail or chat.'**
  String get tour_task_on_calendar_subject;

  /// No description provided for @tour_task_linked_mail_subject.
  ///
  /// In en, this message translates to:
  /// **'Open linked emails instantly from any task or event.'**
  String get tour_task_linked_mail_subject;

  /// No description provided for @tour_task_linked_chat_subject.
  ///
  /// In en, this message translates to:
  /// **'Open linked chats instantly from any task or event.'**
  String get tour_task_linked_chat_subject;

  /// No description provided for @tour_task_linked_mail_detail_subject.
  ///
  /// In en, this message translates to:
  /// **'Read, reply, and manage emails directly from Home.'**
  String get tour_task_linked_mail_detail_subject;

  /// No description provided for @tour_task_linked_chat_detail_subject.
  ///
  /// In en, this message translates to:
  /// **'Read and reply to chats without leaving Home.'**
  String get tour_task_linked_chat_detail_subject;

  /// No description provided for @tour_task_tab_subject.
  ///
  /// In en, this message translates to:
  /// **'Organize and manage all your Visir tasks with filters and lists.'**
  String get tour_task_tab_subject;

  /// No description provided for @tour_mail_tab_subject.
  ///
  /// In en, this message translates to:
  /// **'Use all standard mail features—star, unread, trash, spam—in the Mail tab.'**
  String get tour_mail_tab_subject;

  /// No description provided for @tour_chat_tab_subject.
  ///
  /// In en, this message translates to:
  /// **'Manage all your chat channels and messages from every workspace in one place.'**
  String get tour_chat_tab_subject;

  /// No description provided for @tour_calendar_tab_subject.
  ///
  /// In en, this message translates to:
  /// **'See and manage your team’s calendars and events in a full-featured calendar view.'**
  String get tour_calendar_tab_subject;

  /// No description provided for @tour_chat_create_task_subject.
  ///
  /// In en, this message translates to:
  /// **'Turn any chat message into a task or event instantly.'**
  String get tour_chat_create_task_subject;

  /// No description provided for @tour_mail_create_task_subject.
  ///
  /// In en, this message translates to:
  /// **'Convert any email into a task or event to stay organized.'**
  String get tour_mail_create_task_subject;

  /// No description provided for @tour_list_title.
  ///
  /// In en, this message translates to:
  /// **'Play Showcase'**
  String get tour_list_title;

  /// No description provided for @default_task_before_signin_tour_title.
  ///
  /// In en, this message translates to:
  /// **'1. Start the Tour 🚀'**
  String get default_task_before_signin_tour_title;

  /// No description provided for @default_task_before_signin_tour_desc.
  ///
  /// In en, this message translates to:
  /// **'Click the \"See how it works\" button to take a quick tour of Visir.'**
  String get default_task_before_signin_tour_desc;

  /// No description provided for @default_task_before_signin_explore_title.
  ///
  /// In en, this message translates to:
  /// **'2. Explore the Tabs 🗂️'**
  String get default_task_before_signin_explore_title;

  /// No description provided for @default_task_before_signin_explore_desc.
  ///
  /// In en, this message translates to:
  /// **'Check out the Home, Calendar, Inbox, and Settings tabs to get familiar with the layout.'**
  String get default_task_before_signin_explore_desc;

  /// No description provided for @default_task_before_signin_inbox_title.
  ///
  /// In en, this message translates to:
  /// **'3. Create a Task from the Inbox ✉️➡️✅'**
  String get default_task_before_signin_inbox_title;

  /// No description provided for @default_task_before_signin_inbox_desc.
  ///
  /// In en, this message translates to:
  /// **'Easily create a task by dragging and dropping directly from the Inbox.'**
  String get default_task_before_signin_inbox_desc;

  /// No description provided for @default_task_before_signin_quickview_title.
  ///
  /// In en, this message translates to:
  /// **'4. Open Quick View 👁️'**
  String get default_task_before_signin_quickview_title;

  /// No description provided for @default_task_before_signin_quickview_desc.
  ///
  /// In en, this message translates to:
  /// **'Open your new task in Quick View to review details and reply.'**
  String get default_task_before_signin_quickview_desc;

  /// No description provided for @default_task_before_signin_signin_title.
  ///
  /// In en, this message translates to:
  /// **'5. Sign In 🔑'**
  String get default_task_before_signin_signin_title;

  /// No description provided for @default_task_before_signin_signin_desc.
  ///
  /// In en, this message translates to:
  /// **'Sign in to start using Visir and unlock all features.'**
  String get default_task_before_signin_signin_desc;

  /// No description provided for @default_task_after_signin_connect_services_title.
  ///
  /// In en, this message translates to:
  /// **'1. Connect Services 🔗'**
  String get default_task_after_signin_connect_services_title;

  /// No description provided for @default_task_after_signin_connect_services_desc.
  ///
  /// In en, this message translates to:
  /// **'Link email, Slack, and more to bring everything into Inbox.'**
  String get default_task_after_signin_connect_services_desc;

  /// No description provided for @default_task_after_signin_revisit_tabs_title.
  ///
  /// In en, this message translates to:
  /// **'2. Revisit Tabs 🗂️'**
  String get default_task_after_signin_revisit_tabs_title;

  /// No description provided for @default_task_after_signin_revisit_tabs_desc.
  ///
  /// In en, this message translates to:
  /// **'If you skipped earlier, check each tab now.'**
  String get default_task_after_signin_revisit_tabs_desc;

  /// No description provided for @default_task_after_signin_schedule_ai_title.
  ///
  /// In en, this message translates to:
  /// **'3. Schedule AI 🤖'**
  String get default_task_after_signin_schedule_ai_title;

  /// No description provided for @default_task_after_signin_schedule_ai_desc.
  ///
  /// In en, this message translates to:
  /// **'Drag an AI suggestion onto your calendar.'**
  String get default_task_after_signin_schedule_ai_desc;

  /// No description provided for @default_task_after_signin_reply_in_quick_view_title.
  ///
  /// In en, this message translates to:
  /// **'4. Reply in Quick View 👁️'**
  String get default_task_after_signin_reply_in_quick_view_title;

  /// No description provided for @default_task_after_signin_reply_in_quick_view_desc.
  ///
  /// In en, this message translates to:
  /// **'Reply and manage checklists right inside Quick View.'**
  String get default_task_after_signin_reply_in_quick_view_desc;

  /// No description provided for @default_task_after_signin_create_from_message_title.
  ///
  /// In en, this message translates to:
  /// **'5. Create from Message ✉️➡️✅'**
  String get default_task_after_signin_create_from_message_title;

  /// No description provided for @default_task_after_signin_create_from_message_desc.
  ///
  /// In en, this message translates to:
  /// **'Use Create Task in email/chat to make a task instantly.'**
  String get default_task_after_signin_create_from_message_desc;

  /// No description provided for @default_task_after_signin_use_free_trial_title.
  ///
  /// In en, this message translates to:
  /// **'6. Use Free Trial 🎁'**
  String get default_task_after_signin_use_free_trial_title;

  /// No description provided for @default_task_after_signin_use_free_trial_desc.
  ///
  /// In en, this message translates to:
  /// **'Enjoy all features free for 7 days.'**
  String get default_task_after_signin_use_free_trial_desc;

  /// No description provided for @default_task_near_trial_end_check_time_saved_title.
  ///
  /// In en, this message translates to:
  /// **'1. Check Time Saved ⏳'**
  String get default_task_near_trial_end_check_time_saved_title;

  /// No description provided for @default_task_near_trial_end_check_time_saved_desc.
  ///
  /// In en, this message translates to:
  /// **'Open Time Saved to see how much time you saved.'**
  String get default_task_near_trial_end_check_time_saved_desc;

  /// No description provided for @default_task_near_trial_end_share_image_title.
  ///
  /// In en, this message translates to:
  /// **'2. Share Image 🖼️'**
  String get default_task_near_trial_end_share_image_title;

  /// No description provided for @default_task_near_trial_end_share_image_desc.
  ///
  /// In en, this message translates to:
  /// **'Generate and share the image on social.'**
  String get default_task_near_trial_end_share_image_desc;

  /// No description provided for @default_task_near_trial_end_start_subscription_title.
  ///
  /// In en, this message translates to:
  /// **'3. Start Subscription 🚀'**
  String get default_task_near_trial_end_start_subscription_title;

  /// No description provided for @default_task_near_trial_end_start_subscription_desc.
  ///
  /// In en, this message translates to:
  /// **'Subscribe if it’s boosting your workflow.'**
  String get default_task_near_trial_end_start_subscription_desc;

  /// No description provided for @oauth_disconnected_title.
  ///
  /// In en, this message translates to:
  /// **'{provider} account disconnected'**
  String oauth_disconnected_title(Object provider);

  /// No description provided for @oauth_disconnected_description.
  ///
  /// In en, this message translates to:
  /// **'Lost access to {provider} account ({email}). Reconnect to continue syncing.'**
  String oauth_disconnected_description(Object email, Object provider);

  /// No description provided for @oauth_disconnected_ignore.
  ///
  /// In en, this message translates to:
  /// **'Ignore'**
  String get oauth_disconnected_ignore;

  /// No description provided for @oauth_disconnected_reconnect.
  ///
  /// In en, this message translates to:
  /// **'Reconnect'**
  String get oauth_disconnected_reconnect;

  /// No description provided for @linked_task_evnet.
  ///
  /// In en, this message translates to:
  /// **'Linked tasks / events'**
  String get linked_task_evnet;

  /// No description provided for @search_timezone.
  ///
  /// In en, this message translates to:
  /// **'Search timezone...'**
  String get search_timezone;

  /// No description provided for @no_selection.
  ///
  /// In en, this message translates to:
  /// **'No item selected yet'**
  String get no_selection;

  /// No description provided for @no_history.
  ///
  /// In en, this message translates to:
  /// **'No history'**
  String get no_history;

  /// No description provided for @no_inbox_matched_with_filter.
  ///
  /// In en, this message translates to:
  /// **'No inboxes match your filter'**
  String get no_inbox_matched_with_filter;

  /// No description provided for @viewtype_section.
  ///
  /// In en, this message translates to:
  /// **'View type'**
  String get viewtype_section;

  /// No description provided for @search_tasks.
  ///
  /// In en, this message translates to:
  /// **'Search tasks'**
  String get search_tasks;

  /// No description provided for @search_events.
  ///
  /// In en, this message translates to:
  /// **'Search calendar events'**
  String get search_events;

  /// No description provided for @no_channel_selected.
  ///
  /// In en, this message translates to:
  /// **'Select a channel to get started'**
  String get no_channel_selected;

  /// No description provided for @muted.
  ///
  /// In en, this message translates to:
  /// **'Muted'**
  String get muted;

  /// No description provided for @emailprovider.
  ///
  /// In en, this message translates to:
  /// **'Email & Provider'**
  String get emailprovider;

  /// No description provided for @manage_account.
  ///
  /// In en, this message translates to:
  /// **'Manage account'**
  String get manage_account;

  /// No description provided for @current_subscription.
  ///
  /// In en, this message translates to:
  /// **'Current subscription'**
  String get current_subscription;

  /// No description provided for @available_plans.
  ///
  /// In en, this message translates to:
  /// **'Available plans'**
  String get available_plans;

  /// No description provided for @per_month_billed_monthly.
  ///
  /// In en, this message translates to:
  /// **'Per month,\nBilled monthly'**
  String get per_month_billed_monthly;

  /// No description provided for @per_month_billed_yearly.
  ///
  /// In en, this message translates to:
  /// **'Per month,\nBilled yearly'**
  String get per_month_billed_yearly;

  /// No description provided for @no_chat_provider_integrated.
  ///
  /// In en, this message translates to:
  /// **'You haven’t connected any chat accounts yet'**
  String get no_chat_provider_integrated;

  /// No description provided for @last_opened_channel.
  ///
  /// In en, this message translates to:
  /// **'Last checked'**
  String get last_opened_channel;

  /// No description provided for @suggested_unread_channels.
  ///
  /// In en, this message translates to:
  /// **'Last updated & unread'**
  String get suggested_unread_channels;

  /// No description provided for @updated_at.
  ///
  /// In en, this message translates to:
  /// **'Updated at {date}'**
  String updated_at(Object date);

  /// No description provided for @last_seen_at.
  ///
  /// In en, this message translates to:
  /// **'Last check at {date}'**
  String last_seen_at(Object date);

  /// No description provided for @project.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get project;

  /// No description provided for @default_pref.
  ///
  /// In en, this message translates to:
  /// **'Defaults'**
  String get default_pref;

  /// No description provided for @pref_actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get pref_actions;

  /// No description provided for @secondary_timezone.
  ///
  /// In en, this message translates to:
  /// **'Secondary timezone'**
  String get secondary_timezone;

  /// No description provided for @no_integration_yet_for_inbox.
  ///
  /// In en, this message translates to:
  /// **'You haven’t integrated any mail or chat accounts yet. Inbox will display important emails and messages once you connect your accounts.'**
  String get no_integration_yet_for_inbox;

  /// No description provided for @integrate_new_accounts.
  ///
  /// In en, this message translates to:
  /// **'Connect new accounts'**
  String get integrate_new_accounts;

  /// No description provided for @no_integration_yet_for_mail.
  ///
  /// In en, this message translates to:
  /// **'You haven’t connected any mail accounts yet'**
  String get no_integration_yet_for_mail;

  /// No description provided for @need_to_integrate_calendar.
  ///
  /// In en, this message translates to:
  /// **'Connect calendars'**
  String get need_to_integrate_calendar;

  /// No description provided for @opened.
  ///
  /// In en, this message translates to:
  /// **'Opened'**
  String get opened;

  /// No description provided for @home_calendar_default_ratio.
  ///
  /// In en, this message translates to:
  /// **'Home calendar split ratio'**
  String get home_calendar_default_ratio;

  /// No description provided for @create_signautre.
  ///
  /// In en, this message translates to:
  /// **'Create new'**
  String get create_signautre;

  /// No description provided for @create_signature_title.
  ///
  /// In en, this message translates to:
  /// **'Create new signature'**
  String get create_signature_title;

  /// No description provided for @edit_signature_title.
  ///
  /// In en, this message translates to:
  /// **'Edit signature'**
  String get edit_signature_title;

  /// No description provided for @project_pref_title.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get project_pref_title;

  /// No description provided for @project_pref_structures.
  ///
  /// In en, this message translates to:
  /// **'Manage projects'**
  String get project_pref_structures;

  /// No description provided for @press_back_button.
  ///
  /// In en, this message translates to:
  /// **'Press back button again to exit'**
  String get press_back_button;

  /// No description provided for @create_new_project.
  ///
  /// In en, this message translates to:
  /// **'New project'**
  String get create_new_project;

  /// No description provided for @create_new_project_description.
  ///
  /// In en, this message translates to:
  /// **'Add description'**
  String get create_new_project_description;

  /// No description provided for @confirm_delete_project.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this project? Items under project will be moved to default project.'**
  String get confirm_delete_project;

  /// No description provided for @default_project.
  ///
  /// In en, this message translates to:
  /// **'Default project'**
  String get default_project;

  /// No description provided for @hide_tab.
  ///
  /// In en, this message translates to:
  /// **'Hide tab'**
  String get hide_tab;

  /// No description provided for @task_section_braindump.
  ///
  /// In en, this message translates to:
  /// **'Braindump'**
  String get task_section_braindump;

  /// No description provided for @task_section_unscheduled.
  ///
  /// In en, this message translates to:
  /// **'Unscheduled'**
  String get task_section_unscheduled;

  /// No description provided for @dump_ideas_from_brain.
  ///
  /// In en, this message translates to:
  /// **'Capture your thoughts'**
  String get dump_ideas_from_brain;

  /// No description provided for @add_unscheduled_task.
  ///
  /// In en, this message translates to:
  /// **'Add unscheduled task'**
  String get add_unscheduled_task;

  /// No description provided for @agentic_home_hi.
  ///
  /// In en, this message translates to:
  /// **'Hello, '**
  String get agentic_home_hi;

  /// No description provided for @agentic_home_summary_action_required.
  ///
  /// In en, this message translates to:
  /// **'You have {count} inboxes that need action in the last 24 hours'**
  String agentic_home_summary_action_required(Object count);

  /// No description provided for @agentic_home_summary_events.
  ///
  /// In en, this message translates to:
  /// **'You have {eventCount} events and {taskCount} tasks in the last 24 hours'**
  String agentic_home_summary_events(Object eventCount, Object taskCount);

  /// No description provided for @agentic_home_summary_only_events.
  ///
  /// In en, this message translates to:
  /// **'You have {eventCount} events in the last 24 hours'**
  String agentic_home_summary_only_events(Object eventCount);

  /// No description provided for @agentic_home_summary_only_tasks.
  ///
  /// In en, this message translates to:
  /// **'You have {taskCount} tasks in the last 24 hours'**
  String agentic_home_summary_only_tasks(Object taskCount);

  /// No description provided for @agentic_home_summary_all_clear.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up!'**
  String get agentic_home_summary_all_clear;

  /// No description provided for @no_suggested_schedule.
  ///
  /// In en, this message translates to:
  /// **'No schedule suggested'**
  String get no_suggested_schedule;

  /// No description provided for @inbox_home_type.
  ///
  /// In en, this message translates to:
  /// **'Home Mode'**
  String get inbox_home_type;

  /// No description provided for @inbox_agent_type.
  ///
  /// In en, this message translates to:
  /// **'Agent'**
  String get inbox_agent_type;

  /// No description provided for @inbox_manual_type.
  ///
  /// In en, this message translates to:
  /// **'Helper'**
  String get inbox_manual_type;

  /// No description provided for @inbox_agent_loading.
  ///
  /// In en, this message translates to:
  /// **'I\'m checking your inboxes from the last 24 hours'**
  String get inbox_agent_loading;

  /// No description provided for @inbox_agent_loading_dynamic.
  ///
  /// In en, this message translates to:
  /// **'I\'m checking your inboxes from the last {duration}'**
  String inbox_agent_loading_dynamic(String duration);

  /// No description provided for @agentic_home_summary_action_required_dynamic.
  ///
  /// In en, this message translates to:
  /// **'You have {count} inboxes that need action in the last {duration}'**
  String agentic_home_summary_action_required_dynamic(
    int count,
    String duration,
  );

  /// No description provided for @agentic_home_summary_events_dynamic.
  ///
  /// In en, this message translates to:
  /// **'You have {eventCount} events and {taskCount} tasks in the last {duration}'**
  String agentic_home_summary_events_dynamic(
    int eventCount,
    int taskCount,
    String duration,
  );

  /// No description provided for @agentic_home_summary_only_events_dynamic.
  ///
  /// In en, this message translates to:
  /// **'You have {eventCount} events in the last {duration}'**
  String agentic_home_summary_only_events_dynamic(
    int eventCount,
    String duration,
  );

  /// No description provided for @agentic_home_summary_only_tasks_dynamic.
  ///
  /// In en, this message translates to:
  /// **'You have {taskCount} tasks in the last {duration}'**
  String agentic_home_summary_only_tasks_dynamic(
    int taskCount,
    String duration,
  );

  /// No description provided for @duration_day.
  ///
  /// In en, this message translates to:
  /// **'{count} day'**
  String duration_day(int count);

  /// No description provided for @duration_days.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String duration_days(int count);

  /// No description provided for @no_project_suggested.
  ///
  /// In en, this message translates to:
  /// **'No Project'**
  String get no_project_suggested;

  /// No description provided for @agent_select_model_hint.
  ///
  /// In en, this message translates to:
  /// **'Change agent model'**
  String get agent_select_model_hint;

  /// No description provided for @agent_suggested_actions_hint.
  ///
  /// In en, this message translates to:
  /// **'Suggested actions'**
  String get agent_suggested_actions_hint;

  /// No description provided for @agent_use_taskey_api_key.
  ///
  /// In en, this message translates to:
  /// **'With Visir API Key'**
  String get agent_use_taskey_api_key;

  /// No description provided for @agent_use_user_api_key.
  ///
  /// In en, this message translates to:
  /// **'With User API Key'**
  String get agent_use_user_api_key;

  /// No description provided for @agent_select_project_hint.
  ///
  /// In en, this message translates to:
  /// **'Add project based context'**
  String get agent_select_project_hint;

  /// No description provided for @agent_select_project_remove.
  ///
  /// In en, this message translates to:
  /// **'Remove project base context'**
  String get agent_select_project_remove;

  /// No description provided for @daily_summary_greeting.
  ///
  /// In en, this message translates to:
  /// **'Good {timeOfDay}. Here is your daily summary'**
  String daily_summary_greeting(String timeOfDay);

  /// No description provided for @daily_summary_project_greeting.
  ///
  /// In en, this message translates to:
  /// **'Here is {projectName} summary for today'**
  String daily_summary_project_greeting(String projectName);

  /// No description provided for @morning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get morning;

  /// No description provided for @afternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get afternoon;

  /// No description provided for @evening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get evening;

  /// No description provided for @night.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get night;

  /// No description provided for @dawn.
  ///
  /// In en, this message translates to:
  /// **'Dawn'**
  String get dawn;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @daily_summary_overdue_tasks.
  ///
  /// In en, this message translates to:
  /// **'I found {count} overdue task{plural} that need your attention right away'**
  String daily_summary_overdue_tasks(int count, String plural);

  /// No description provided for @daily_summary_meeting_invitation.
  ///
  /// In en, this message translates to:
  /// **'You\'ve got {count} meeting invitation{plural} waiting for your response'**
  String daily_summary_meeting_invitation(int count, String plural);

  /// No description provided for @daily_summary_meeting_followup.
  ///
  /// In en, this message translates to:
  /// **'There {isAre} {count} meeting{plural} that need follow-up'**
  String daily_summary_meeting_followup(int count, String plural, String isAre);

  /// No description provided for @daily_summary_meeting_notes.
  ///
  /// In en, this message translates to:
  /// **'You\'ve got {count} meeting note{plural} to check out'**
  String daily_summary_meeting_notes(int count, String plural);

  /// No description provided for @daily_summary_task_assignment.
  ///
  /// In en, this message translates to:
  /// **'There {isAre} {count} task{plural} assigned to you'**
  String daily_summary_task_assignment(int count, String plural, String isAre);

  /// No description provided for @daily_summary_task_status_update.
  ///
  /// In en, this message translates to:
  /// **'You\'ve got {count} task{plural} with status updates to review'**
  String daily_summary_task_status_update(int count, String plural);

  /// No description provided for @daily_summary_scheduling_request.
  ///
  /// In en, this message translates to:
  /// **'There {isAre} {count} scheduling request{plural} waiting for your decision'**
  String daily_summary_scheduling_request(
    int count,
    String plural,
    String isAre,
  );

  /// No description provided for @daily_summary_scheduling_confirmation.
  ///
  /// In en, this message translates to:
  /// **'You\'ve got {count} scheduling confirmation{plural} to confirm'**
  String daily_summary_scheduling_confirmation(int count, String plural);

  /// No description provided for @daily_summary_document_review.
  ///
  /// In en, this message translates to:
  /// **'There {isAre} {count} document{plural} waiting for you to review'**
  String daily_summary_document_review(int count, String plural, String isAre);

  /// No description provided for @daily_summary_code_review.
  ///
  /// In en, this message translates to:
  /// **'You\'ve got {count} code review{plural} waiting'**
  String daily_summary_code_review(int count, String plural);

  /// No description provided for @daily_summary_approval_request.
  ///
  /// In en, this message translates to:
  /// **'There {isAre} {count} approval request{plural} that need your sign-off'**
  String daily_summary_approval_request(int count, String plural, String isAre);

  /// No description provided for @daily_summary_question.
  ///
  /// In en, this message translates to:
  /// **'You\'ve got {count} question{plural} that need{needs} an answer'**
  String daily_summary_question(int count, String plural, String needs);

  /// No description provided for @daily_summary_information_sharing.
  ///
  /// In en, this message translates to:
  /// **'There {isAre} {count} item{plural} with important info to check out'**
  String daily_summary_information_sharing(
    int count,
    String plural,
    String isAre,
  );

  /// No description provided for @daily_summary_announcement.
  ///
  /// In en, this message translates to:
  /// **'You\'ve got {count} announcement{plural} to check out'**
  String daily_summary_announcement(int count, String plural);

  /// No description provided for @daily_summary_system_notification.
  ///
  /// In en, this message translates to:
  /// **'There {isAre} {count} system notification{plural} that might need your attention'**
  String daily_summary_system_notification(
    int count,
    String plural,
    String isAre,
  );

  /// No description provided for @daily_summary_cold_contact.
  ///
  /// In en, this message translates to:
  /// **'You\'ve got {count} message{plural} from new contacts'**
  String daily_summary_cold_contact(int count, String plural);

  /// No description provided for @daily_summary_customer_contact.
  ///
  /// In en, this message translates to:
  /// **'There {isAre} {count} customer inquiry{plural} that need your response'**
  String daily_summary_customer_contact(int count, String plural, String isAre);

  /// No description provided for @daily_summary_other.
  ///
  /// In en, this message translates to:
  /// **'You\'ve got {count} item{plural} to check out'**
  String daily_summary_other(int count, String plural);

  /// No description provided for @daily_summary_action_items.
  ///
  /// In en, this message translates to:
  /// **'You\'ve got {count} action item{plural} waiting'**
  String daily_summary_action_items(int count, String plural);

  /// No description provided for @daily_summary_review_items.
  ///
  /// In en, this message translates to:
  /// **'There {isAre} {count} item{plural} for you to review when you have time'**
  String daily_summary_review_items(int count, String plural, String isAre);

  /// No description provided for @daily_summary_schedule_clear.
  ///
  /// In en, this message translates to:
  /// **'Your schedule is clear for today'**
  String get daily_summary_schedule_clear;

  /// No description provided for @daily_summary_schedule_today.
  ///
  /// In en, this message translates to:
  /// **'Today, you have {eventCount} event{eventPlural} and {taskCount} task{taskPlural} scheduled'**
  String daily_summary_schedule_today(
    int eventCount,
    int taskCount,
    String eventPlural,
    String taskPlural,
  );

  /// No description provided for @daily_summary_cross_inbox_highlights.
  ///
  /// In en, this message translates to:
  /// **'Cross-Inbox Highlights'**
  String get daily_summary_cross_inbox_highlights;

  /// No description provided for @daily_summary_inbox_highlights.
  ///
  /// In en, this message translates to:
  /// **'Inbox Highlights'**
  String get daily_summary_inbox_highlights;

  /// No description provided for @daily_summary_urgent_overdue.
  ///
  /// In en, this message translates to:
  /// **'Urgent & Overdue'**
  String get daily_summary_urgent_overdue;

  /// No description provided for @daily_summary_overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get daily_summary_overdue;

  /// No description provided for @daily_summary_no_urgent_items.
  ///
  /// In en, this message translates to:
  /// **'No urgent items'**
  String get daily_summary_no_urgent_items;

  /// No description provided for @daily_summary_no_actions_pending.
  ///
  /// In en, this message translates to:
  /// **'No actions pending'**
  String get daily_summary_no_actions_pending;

  /// No description provided for @daily_summary_no_inbox_highlights.
  ///
  /// In en, this message translates to:
  /// **'No inbox items need attention yet'**
  String get daily_summary_no_inbox_highlights;

  /// No description provided for @daily_summary_no_inbox_highlights_friendly.
  ///
  /// In en, this message translates to:
  /// **'All clear! Nothing needs your attention right now.'**
  String get daily_summary_no_inbox_highlights_friendly;

  /// No description provided for @daily_summary_reading_previous_conversations.
  ///
  /// In en, this message translates to:
  /// **'Reading previous conversations...'**
  String get daily_summary_reading_previous_conversations;

  /// No description provided for @daily_summary_for_review.
  ///
  /// In en, this message translates to:
  /// **'For Review'**
  String get daily_summary_for_review;

  /// No description provided for @daily_summary_nothing_to_review.
  ///
  /// In en, this message translates to:
  /// **'Nothing to review'**
  String get daily_summary_nothing_to_review;

  /// No description provided for @daily_summary_schedule_overview.
  ///
  /// In en, this message translates to:
  /// **'Schedule Overview'**
  String get daily_summary_schedule_overview;

  /// No description provided for @daily_summary_todays_remaining.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Remaining'**
  String get daily_summary_todays_remaining;

  /// No description provided for @daily_summary_no_more_events_today.
  ///
  /// In en, this message translates to:
  /// **'No more events today'**
  String get daily_summary_no_more_events_today;

  /// No description provided for @daily_summary_check_tomorrow_schedule.
  ///
  /// In en, this message translates to:
  /// **'Check your calendar for tomorrow\'s schedule.'**
  String get daily_summary_check_tomorrow_schedule;

  /// No description provided for @daily_summary_ai_synthesis.
  ///
  /// In en, this message translates to:
  /// **'AI Synthesis'**
  String get daily_summary_ai_synthesis;

  /// No description provided for @daily_summary_synthesis_label.
  ///
  /// In en, this message translates to:
  /// **'Synthesis: '**
  String get daily_summary_synthesis_label;

  /// No description provided for @daily_summary_synthesis_urgent.
  ///
  /// In en, this message translates to:
  /// **'Your primary focus today should be resolving {overdueCount} overdue tasks and addressing {urgentCount} urgent inbox items.'**
  String daily_summary_synthesis_urgent(int overdueCount, int urgentCount);

  /// No description provided for @daily_summary_synthesis_caught_up.
  ///
  /// In en, this message translates to:
  /// **'You are caught up on urgent matters.'**
  String get daily_summary_synthesis_caught_up;

  /// No description provided for @daily_summary_synthesis_events_today.
  ///
  /// In en, this message translates to:
  /// **'You have {eventCount} events scheduled today.'**
  String daily_summary_synthesis_events_today(int eventCount);

  /// No description provided for @daily_summary_synthesis_schedule_clear.
  ///
  /// In en, this message translates to:
  /// **'Your schedule is clear today.'**
  String get daily_summary_synthesis_schedule_clear;

  /// No description provided for @daily_summary_next_schedule.
  ///
  /// In en, this message translates to:
  /// **'Next Schedule'**
  String get daily_summary_next_schedule;

  /// No description provided for @daily_summary_up_next.
  ///
  /// In en, this message translates to:
  /// **'Up Next'**
  String get daily_summary_up_next;

  /// No description provided for @daily_summary_previous_context.
  ///
  /// In en, this message translates to:
  /// **'Previous Context'**
  String get daily_summary_previous_context;

  /// No description provided for @daily_summary_previously_completed_tasks.
  ///
  /// In en, this message translates to:
  /// **'Previously Completed Tasks'**
  String get daily_summary_previously_completed_tasks;

  /// No description provided for @daily_summary_anytime.
  ///
  /// In en, this message translates to:
  /// **'Anytime'**
  String get daily_summary_anytime;

  /// No description provided for @daily_summary_min.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get daily_summary_min;

  /// No description provided for @daily_summary_overdue_task.
  ///
  /// In en, this message translates to:
  /// **'Overdue Task'**
  String get daily_summary_overdue_task;

  /// No description provided for @daily_summary_move_to_today.
  ///
  /// In en, this message translates to:
  /// **'Reschedule'**
  String get daily_summary_move_to_today;

  /// No description provided for @daily_summary_inbox.
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get daily_summary_inbox;

  /// No description provided for @daily_summary_unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get daily_summary_unknown;

  /// No description provided for @agent_action_error_occurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again.'**
  String get agent_action_error_occurred;

  /// No description provided for @agent_action_mail_generation_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate email. Please try again.'**
  String get agent_action_mail_generation_failed;

  /// No description provided for @agent_action_mail_generated.
  ///
  /// In en, this message translates to:
  /// **'Reply email has been generated. Please review and send.'**
  String get agent_action_mail_generated;

  /// No description provided for @agent_action_action_not_supported.
  ///
  /// In en, this message translates to:
  /// **'This action type is not yet supported.'**
  String get agent_action_action_not_supported;

  /// No description provided for @agent_action_starting_action.
  ///
  /// In en, this message translates to:
  /// **'Starting action.'**
  String get agent_action_starting_action;

  /// No description provided for @agent_action_reply_initial_message.
  ///
  /// In en, this message translates to:
  /// **'I\'ll help you write a reply to the following email. Please tell me how you\'d like to respond in natural language.\n\n{contextInfo}\n\nHow would you like to reply? For example:\n- \"Thank them for the email\"\n- \"Let them know I\'m available tomorrow at 2 PM\"\n- \"Provide a detailed explanation about the inquiry\"\nPlease make your request in this format.'**
  String agent_action_reply_initial_message(String contextInfo);

  /// No description provided for @agent_action_reply_suggested_response.
  ///
  /// In en, this message translates to:
  /// **'Here\'s a suggested reply:\n\n{suggestedResponse}\n\nHow would you like to modify it? For example:\n- \"Make it more formal\"\n- \"Add a question about their availability\"\n- \"Shorten it\"\nPlease tell me how you\'d like to adjust the reply.'**
  String agent_action_reply_suggested_response(String suggestedResponse);

  /// No description provided for @agent_action_create_task_initial_message.
  ///
  /// In en, this message translates to:
  /// **'I\'ll help you create a task from the following inbox item. Please tell me how you\'d like to customize it.\n\n{contextInfo}\n\nHow would you like to create the task? For example:\n- \"Set the due date to tomorrow\"\n- \"Add it to the Marketing project\"\n- \"Make the title more specific\"\nPlease make your request in this format.'**
  String agent_action_create_task_initial_message(String contextInfo);

  /// No description provided for @agent_action_create_task_suggested_response.
  ///
  /// In en, this message translates to:
  /// **'<div>Here\'s a suggested task:</div><br>{suggestedTask}<br><div>Would you like to create this task as is, or would you like to make changes? If you\'d like to make changes, please tell me what you\'d like to modify.</div>'**
  String agent_action_create_task_suggested_response(String suggestedTask);

  /// No description provided for @agent_action_task_generation_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate task. Please try again.'**
  String get agent_action_task_generation_failed;

  /// No description provided for @agent_action_task_created.
  ///
  /// In en, this message translates to:
  /// **'Task has been created successfully.'**
  String get agent_action_task_created;

  /// No description provided for @agent_action_loading_thinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking...'**
  String get agent_action_loading_thinking;

  /// No description provided for @agent_action_loading_processing_request.
  ///
  /// In en, this message translates to:
  /// **'Processing your request...'**
  String get agent_action_loading_processing_request;

  /// No description provided for @agent_action_loading_creating_task.
  ///
  /// In en, this message translates to:
  /// **'Creating task...'**
  String get agent_action_loading_creating_task;

  /// No description provided for @agent_action_loading_saving_task_details.
  ///
  /// In en, this message translates to:
  /// **'Saving task details...'**
  String get agent_action_loading_saving_task_details;

  /// No description provided for @agent_action_loading_finalizing_task.
  ///
  /// In en, this message translates to:
  /// **'Finalizing task...'**
  String get agent_action_loading_finalizing_task;

  /// No description provided for @agent_action_loading_updating_task_details.
  ///
  /// In en, this message translates to:
  /// **'Updating task details...'**
  String get agent_action_loading_updating_task_details;

  /// No description provided for @agent_action_loading_modifying_task_info.
  ///
  /// In en, this message translates to:
  /// **'Modifying task information...'**
  String get agent_action_loading_modifying_task_info;

  /// No description provided for @agent_action_loading_adjusting_task_params.
  ///
  /// In en, this message translates to:
  /// **'Adjusting task parameters...'**
  String get agent_action_loading_adjusting_task_params;

  /// No description provided for @agent_action_loading_analyzing_inbox.
  ///
  /// In en, this message translates to:
  /// **'Analyzing inbox item...'**
  String get agent_action_loading_analyzing_inbox;

  /// No description provided for @agent_action_loading_generating_task_details.
  ///
  /// In en, this message translates to:
  /// **'Generating task details...'**
  String get agent_action_loading_generating_task_details;

  /// No description provided for @agent_action_loading_preparing_task_info.
  ///
  /// In en, this message translates to:
  /// **'Preparing task information...'**
  String get agent_action_loading_preparing_task_info;

  /// No description provided for @agent_action_loading_updating_reply_draft.
  ///
  /// In en, this message translates to:
  /// **'Updating reply draft...'**
  String get agent_action_loading_updating_reply_draft;

  /// No description provided for @agent_action_loading_modifying_email_content.
  ///
  /// In en, this message translates to:
  /// **'Modifying email content...'**
  String get agent_action_loading_modifying_email_content;

  /// No description provided for @agent_action_loading_adjusting_response.
  ///
  /// In en, this message translates to:
  /// **'Adjusting response...'**
  String get agent_action_loading_adjusting_response;

  /// No description provided for @agent_action_loading_analyzing_email.
  ///
  /// In en, this message translates to:
  /// **'Analyzing email content...'**
  String get agent_action_loading_analyzing_email;

  /// No description provided for @agent_action_loading_drafting_reply.
  ///
  /// In en, this message translates to:
  /// **'Drafting reply...'**
  String get agent_action_loading_drafting_reply;

  /// No description provided for @agent_action_loading_generating_response.
  ///
  /// In en, this message translates to:
  /// **'Generating response...'**
  String get agent_action_loading_generating_response;

  /// No description provided for @agent_action_loading_creating_event.
  ///
  /// In en, this message translates to:
  /// **'Creating event...'**
  String get agent_action_loading_creating_event;

  /// No description provided for @agent_action_loading_saving_event_details.
  ///
  /// In en, this message translates to:
  /// **'Saving event details...'**
  String get agent_action_loading_saving_event_details;

  /// No description provided for @agent_action_loading_finalizing_event.
  ///
  /// In en, this message translates to:
  /// **'Finalizing event...'**
  String get agent_action_loading_finalizing_event;

  /// No description provided for @agent_action_loading_updating_event_details.
  ///
  /// In en, this message translates to:
  /// **'Updating event details...'**
  String get agent_action_loading_updating_event_details;

  /// No description provided for @agent_action_loading_modifying_event_info.
  ///
  /// In en, this message translates to:
  /// **'Modifying event information...'**
  String get agent_action_loading_modifying_event_info;

  /// No description provided for @agent_action_loading_adjusting_event_params.
  ///
  /// In en, this message translates to:
  /// **'Adjusting event parameters...'**
  String get agent_action_loading_adjusting_event_params;

  /// No description provided for @agent_action_loading_generating_event_details.
  ///
  /// In en, this message translates to:
  /// **'Generating event details...'**
  String get agent_action_loading_generating_event_details;

  /// No description provided for @agent_action_loading_preparing_event_info.
  ///
  /// In en, this message translates to:
  /// **'Preparing event information...'**
  String get agent_action_loading_preparing_event_info;

  /// No description provided for @agent_action_loading_analyzing_info.
  ///
  /// In en, this message translates to:
  /// **'Analyzing information...'**
  String get agent_action_loading_analyzing_info;

  /// No description provided for @ai_credits_title.
  ///
  /// In en, this message translates to:
  /// **'AI Credits'**
  String get ai_credits_title;

  /// No description provided for @ai_credits_purchase.
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get ai_credits_purchase;

  /// No description provided for @ai_credits_history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get ai_credits_history;

  /// No description provided for @ai_credits_current_tokens.
  ///
  /// In en, this message translates to:
  /// **'Current Tokens'**
  String get ai_credits_current_tokens;

  /// No description provided for @ai_credits_purchase_packages.
  ///
  /// In en, this message translates to:
  /// **'Credit Packages'**
  String get ai_credits_purchase_packages;

  /// No description provided for @ai_credits_best_value.
  ///
  /// In en, this message translates to:
  /// **'Best Value'**
  String get ai_credits_best_value;

  /// No description provided for @ai_credits_tokens.
  ///
  /// In en, this message translates to:
  /// **'tokens'**
  String get ai_credits_tokens;

  /// No description provided for @ai_credits_buy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get ai_credits_buy;

  /// No description provided for @ai_credits_history_empty.
  ///
  /// In en, this message translates to:
  /// **'No usage history'**
  String get ai_credits_history_empty;

  /// No description provided for @ai_credits_purchase_coming_soon.
  ///
  /// In en, this message translates to:
  /// **'Credit purchase will be available soon'**
  String get ai_credits_purchase_coming_soon;

  /// No description provided for @ai_credits_insufficient.
  ///
  /// In en, this message translates to:
  /// **'Insufficient credits'**
  String get ai_credits_insufficient;

  /// No description provided for @ai_credits_insufficient_message.
  ///
  /// In en, this message translates to:
  /// **'You need {required} tokens but only have {available} tokens available.'**
  String ai_credits_insufficient_message(String required, String available);

  /// No description provided for @ai_credits_purchase_now.
  ///
  /// In en, this message translates to:
  /// **'Purchase Credits'**
  String get ai_credits_purchase_now;

  /// No description provided for @ai_credits_purchase_on_desktop.
  ///
  /// In en, this message translates to:
  /// **'You can purchase credits on the desktop version'**
  String get ai_credits_purchase_on_desktop;

  /// No description provided for @agent_action_task_proposal_message.
  ///
  /// In en, this message translates to:
  /// **'I can create a task with the following details:\n\n**Title**: {title}\n{description}**Project**: {project}\n{startTime}\n\nPlease confirm if you\'d like me to create this task, or let me know if you\'d like to make any changes.'**
  String agent_action_task_proposal_message(
    String title,
    String description,
    String project,
    String startTime,
  );

  /// No description provided for @agent_action_send_initial_message.
  ///
  /// In en, this message translates to:
  /// **'Please provide the following information to send an email:\n- To recipients (required)\n- CC recipients (optional)\n- BCC recipients (optional)\n- Subject/title (required)\n- Body/content (required)\n\nYou can provide email addresses or names.'**
  String get agent_action_send_initial_message;

  /// No description provided for @agent_action_send_request_message.
  ///
  /// In en, this message translates to:
  /// **'Send an email'**
  String get agent_action_send_request_message;

  /// No description provided for @agent_action_email_thread_summary.
  ///
  /// In en, this message translates to:
  /// **'Here\'s a summary of the email thread:'**
  String get agent_action_email_thread_summary;

  /// No description provided for @agent_action_suggested_reply.
  ///
  /// In en, this message translates to:
  /// **'Here\'s a suggested reply:'**
  String get agent_action_suggested_reply;

  /// No description provided for @agent_action_send_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Would you like to send this as is, or would you like me to modify it?'**
  String get agent_action_send_confirmation;

  /// No description provided for @agent_action_reply_all_suggestion.
  ///
  /// In en, this message translates to:
  /// **'Note: This email has CC recipients. Would you like to use \"Reply All\" instead?'**
  String get agent_action_reply_all_suggestion;

  /// No description provided for @agent_action_suggested_email.
  ///
  /// In en, this message translates to:
  /// **'Here\'s a suggested email:'**
  String get agent_action_suggested_email;

  /// No description provided for @agent_action_see_full_email.
  ///
  /// In en, this message translates to:
  /// **'To see full email rather than snippet, click'**
  String get agent_action_see_full_email;

  /// No description provided for @agent_action_no_email_account_configured.
  ///
  /// In en, this message translates to:
  /// **'No email account configured. Please configure an email account first.'**
  String get agent_action_no_email_account_configured;

  /// No description provided for @agent_action_no_email_account_available.
  ///
  /// In en, this message translates to:
  /// **'No email account available.'**
  String get agent_action_no_email_account_available;

  /// No description provided for @agent_action_forward_preview.
  ///
  /// In en, this message translates to:
  /// **'Here\'s the forward:'**
  String get agent_action_forward_preview;

  /// No description provided for @agent_action_forward_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Would you like to forward this email as is, or would you like to add a message? If you\'d like to add a message, please let me know what you\'d like to include.'**
  String get agent_action_forward_confirmation;

  /// No description provided for @agent_action_forwarding_as_is.
  ///
  /// In en, this message translates to:
  /// **'Forwarding the email as is:'**
  String get agent_action_forwarding_as_is;

  /// No description provided for @agent_action_send_forward_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Would you like to send this forward?'**
  String get agent_action_send_forward_confirmation;

  /// No description provided for @agent_action_suggested_forward.
  ///
  /// In en, this message translates to:
  /// **'Here\'s a suggested forward:'**
  String get agent_action_suggested_forward;

  /// No description provided for @agent_action_task_prepared_for_confirmation.
  ///
  /// In en, this message translates to:
  /// **'A new task has been prepared from the inbox item and is waiting for your confirmation. Once you confirm, it will be created in your tasks.'**
  String get agent_action_task_prepared_for_confirmation;

  /// No description provided for @agent_action_event_prepared_for_confirmation.
  ///
  /// In en, this message translates to:
  /// **'A new event has been prepared from the inbox item and is waiting for your confirmation. Once you confirm, it will be created in your calendar.'**
  String get agent_action_event_prepared_for_confirmation;

  /// No description provided for @agent_action_mail_prepared_for_confirmation.
  ///
  /// In en, this message translates to:
  /// **'A new email has been prepared and is waiting for your confirmation. Once you confirm, it will be sent.'**
  String get agent_action_mail_prepared_for_confirmation;

  /// No description provided for @agent_action_prepared_for_confirmation.
  ///
  /// In en, this message translates to:
  /// **'An action has been prepared and is waiting for your confirmation. Once you confirm, it will be executed.'**
  String get agent_action_prepared_for_confirmation;

  /// No description provided for @agent_action_reply_fallback_message.
  ///
  /// In en, this message translates to:
  /// **'Please write a reply to this email.'**
  String get agent_action_reply_fallback_message;

  /// No description provided for @agent_action_reply_fallback_message_no_inbox.
  ///
  /// In en, this message translates to:
  /// **'Please write a reply to the email.'**
  String get agent_action_reply_fallback_message_no_inbox;

  /// No description provided for @agent_action_reply_request_message.
  ///
  /// In en, this message translates to:
  /// **'Reply to this email'**
  String get agent_action_reply_request_message;

  /// No description provided for @agent_action_reply_request_message_no_inbox.
  ///
  /// In en, this message translates to:
  /// **'Reply to the email'**
  String get agent_action_reply_request_message_no_inbox;

  /// No description provided for @agent_action_forward_fallback_message.
  ///
  /// In en, this message translates to:
  /// **'Please forward this email.'**
  String get agent_action_forward_fallback_message;

  /// No description provided for @agent_action_forward_fallback_message_no_inbox.
  ///
  /// In en, this message translates to:
  /// **'Please forward the email.'**
  String get agent_action_forward_fallback_message_no_inbox;

  /// No description provided for @agent_action_forward_request_message.
  ///
  /// In en, this message translates to:
  /// **'Forward this email'**
  String get agent_action_forward_request_message;

  /// No description provided for @agent_action_forward_request_message_no_inbox.
  ///
  /// In en, this message translates to:
  /// **'Forward the email'**
  String get agent_action_forward_request_message_no_inbox;

  /// No description provided for @agent_action_create_task_fallback_from_mail.
  ///
  /// In en, this message translates to:
  /// **'Please create a task based on this email.'**
  String get agent_action_create_task_fallback_from_mail;

  /// No description provided for @agent_action_create_task_fallback_from_inbox.
  ///
  /// In en, this message translates to:
  /// **'Please create a task based on this inbox item.'**
  String get agent_action_create_task_fallback_from_inbox;

  /// No description provided for @agent_action_create_task_fallback_no_inbox.
  ///
  /// In en, this message translates to:
  /// **'Please create a task.'**
  String get agent_action_create_task_fallback_no_inbox;

  /// No description provided for @agent_action_create_task_request_message.
  ///
  /// In en, this message translates to:
  /// **'Create a task from this inbox item'**
  String get agent_action_create_task_request_message;

  /// No description provided for @agent_action_create_task_request_message_no_inbox.
  ///
  /// In en, this message translates to:
  /// **'Create a task'**
  String get agent_action_create_task_request_message_no_inbox;

  /// No description provided for @agent_action_create_event_fallback_from_mail.
  ///
  /// In en, this message translates to:
  /// **'Please create an event based on this email.'**
  String get agent_action_create_event_fallback_from_mail;

  /// No description provided for @agent_action_create_event_fallback_from_inbox.
  ///
  /// In en, this message translates to:
  /// **'Please create an event based on this inbox item.'**
  String get agent_action_create_event_fallback_from_inbox;

  /// No description provided for @agent_action_create_event_fallback_no_inbox.
  ///
  /// In en, this message translates to:
  /// **'Please create an event.'**
  String get agent_action_create_event_fallback_no_inbox;

  /// No description provided for @agent_action_create_event_request_message.
  ///
  /// In en, this message translates to:
  /// **'Create an event from this inbox item'**
  String get agent_action_create_event_request_message;

  /// No description provided for @agent_action_create_event_request_message_no_inbox.
  ///
  /// In en, this message translates to:
  /// **'Create an event'**
  String get agent_action_create_event_request_message_no_inbox;

  /// No description provided for @agent_action_confirm_send_mail.
  ///
  /// In en, this message translates to:
  /// **'Would you like to send the following email?'**
  String get agent_action_confirm_send_mail;

  /// No description provided for @agent_action_confirm_reply_mail.
  ///
  /// In en, this message translates to:
  /// **'Would you like to send a reply to this email?'**
  String get agent_action_confirm_reply_mail;

  /// No description provided for @agent_action_confirm_forward_mail.
  ///
  /// In en, this message translates to:
  /// **'Would you like to forward this email?'**
  String get agent_action_confirm_forward_mail;

  /// No description provided for @agent_action_confirm_delete_task.
  ///
  /// In en, this message translates to:
  /// **'Would you like to delete this task?'**
  String get agent_action_confirm_delete_task;

  /// No description provided for @agent_action_confirm_delete_event.
  ///
  /// In en, this message translates to:
  /// **'Would you like to delete this event?'**
  String get agent_action_confirm_delete_event;

  /// No description provided for @agent_action_confirm_delete_mail.
  ///
  /// In en, this message translates to:
  /// **'Would you like to delete this email?'**
  String get agent_action_confirm_delete_mail;

  /// No description provided for @agent_action_confirm_update_task.
  ///
  /// In en, this message translates to:
  /// **'Would you like to update this task?'**
  String get agent_action_confirm_update_task;

  /// No description provided for @agent_action_confirm_update_event.
  ///
  /// In en, this message translates to:
  /// **'Would you like to update this event?'**
  String get agent_action_confirm_update_event;

  /// No description provided for @agent_action_confirm_mark_mail_read.
  ///
  /// In en, this message translates to:
  /// **'Would you like to mark this email as read?'**
  String get agent_action_confirm_mark_mail_read;

  /// No description provided for @agent_action_confirm_mark_mail_unread.
  ///
  /// In en, this message translates to:
  /// **'Would you like to mark this email as unread?'**
  String get agent_action_confirm_mark_mail_unread;

  /// No description provided for @agent_action_confirm_archive_mail.
  ///
  /// In en, this message translates to:
  /// **'Would you like to archive this email?'**
  String get agent_action_confirm_archive_mail;

  /// No description provided for @agent_action_confirm_response_calendar_invitation.
  ///
  /// In en, this message translates to:
  /// **'Would you like to respond to the calendar invitation with \"{response}\"?'**
  String agent_action_confirm_response_calendar_invitation(String response);

  /// No description provided for @agent_action_confirm_create_task.
  ///
  /// In en, this message translates to:
  /// **'Would you like to create the following task?'**
  String get agent_action_confirm_create_task;

  /// No description provided for @agent_action_confirm_create_event.
  ///
  /// In en, this message translates to:
  /// **'Would you like to create the following event?'**
  String get agent_action_confirm_create_event;

  /// No description provided for @agent_action_confirm_execute_action.
  ///
  /// In en, this message translates to:
  /// **'Would you like to execute this action?'**
  String get agent_action_confirm_execute_action;

  /// No description provided for @agent_action_confirm_title.
  ///
  /// In en, this message translates to:
  /// **'Title: {title}'**
  String agent_action_confirm_title(String title);

  /// No description provided for @agent_action_confirm_time.
  ///
  /// In en, this message translates to:
  /// **'Time: {startTime}{endTime}'**
  String agent_action_confirm_time(String startTime, String endTime);

  /// No description provided for @agent_action_confirm_recipient_to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get agent_action_confirm_recipient_to;

  /// No description provided for @agent_action_confirm_recipient_cc.
  ///
  /// In en, this message translates to:
  /// **'CC'**
  String get agent_action_confirm_recipient_cc;

  /// No description provided for @agent_action_confirm_recipient_bcc.
  ///
  /// In en, this message translates to:
  /// **'BCC'**
  String get agent_action_confirm_recipient_bcc;

  /// No description provided for @agent_action_task_completed.
  ///
  /// In en, this message translates to:
  /// **'Task completed successfully.'**
  String get agent_action_task_completed;

  /// No description provided for @agent_action_error_occurred_during_execution.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during task execution.'**
  String get agent_action_error_occurred_during_execution;

  /// No description provided for @agent_action_error_occurred_during_execution_with_function.
  ///
  /// In en, this message translates to:
  /// **'{functionName}: An error occurred during task execution: {error}'**
  String agent_action_error_occurred_during_execution_with_function(
    String functionName,
    String error,
  );

  /// No description provided for @agent_action_tasks_completed_count.
  ///
  /// In en, this message translates to:
  /// **'{count} tasks completed:\n{details}'**
  String agent_action_tasks_completed_count(int count, String details);

  /// No description provided for @agent_action_error_occurred_with_details.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during task execution:\n{details}'**
  String agent_action_error_occurred_with_details(String details);

  /// No description provided for @agent_action_partial_completion.
  ///
  /// In en, this message translates to:
  /// **'Some tasks completed:\n'**
  String get agent_action_partial_completion;

  /// No description provided for @agent_action_success_section.
  ///
  /// In en, this message translates to:
  /// **'Success:\n{details}'**
  String agent_action_success_section(String details);

  /// No description provided for @agent_action_failure_section.
  ///
  /// In en, this message translates to:
  /// **'Failure:\n{details}'**
  String agent_action_failure_section(String details);

  /// No description provided for @agent_tag_section_task.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get agent_tag_section_task;

  /// No description provided for @agent_tag_section_event.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get agent_tag_section_event;

  /// No description provided for @agent_tag_section_connections.
  ///
  /// In en, this message translates to:
  /// **'Connections'**
  String get agent_tag_section_connections;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @chat_history.
  ///
  /// In en, this message translates to:
  /// **'Chat History'**
  String get chat_history;

  /// No description provided for @chat_history_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search history...'**
  String get chat_history_search_hint;

  /// No description provided for @chat_history_conversation_start.
  ///
  /// In en, this message translates to:
  /// **'Conversation start'**
  String get chat_history_conversation_start;

  /// No description provided for @chat_history_messages_count.
  ///
  /// In en, this message translates to:
  /// **'{count} messages'**
  String chat_history_messages_count(int count);

  /// No description provided for @chat_history_load_error.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while loading history'**
  String get chat_history_load_error;

  /// No description provided for @chat_history_filter_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get chat_history_filter_all;

  /// No description provided for @chat_history_filter_unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get chat_history_filter_unknown;

  /// No description provided for @chat_history_sort_updated_desc.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get chat_history_sort_updated_desc;

  /// No description provided for @chat_history_sort_updated_asc.
  ///
  /// In en, this message translates to:
  /// **'Oldest'**
  String get chat_history_sort_updated_asc;

  /// No description provided for @chat_history_sort_message_count_desc.
  ///
  /// In en, this message translates to:
  /// **'Most messages'**
  String get chat_history_sort_message_count_desc;

  /// No description provided for @chat_history_sort_message_count_asc.
  ///
  /// In en, this message translates to:
  /// **'Fewest messages'**
  String get chat_history_sort_message_count_asc;

  /// No description provided for @mcp_previous_context_not_available.
  ///
  /// In en, this message translates to:
  /// **'No previous context available'**
  String get mcp_previous_context_not_available;

  /// No description provided for @mcp_previous_context_retrieved.
  ///
  /// In en, this message translates to:
  /// **'Previous context retrieved'**
  String get mcp_previous_context_retrieved;

  /// No description provided for @mcp_failed_to_get_previous_context.
  ///
  /// In en, this message translates to:
  /// **'Failed to get previous context'**
  String get mcp_failed_to_get_previous_context;

  /// No description provided for @mcp_mail_info_retrieved.
  ///
  /// In en, this message translates to:
  /// **'Mail information retrieved'**
  String get mcp_mail_info_retrieved;

  /// No description provided for @mcp_found_mails.
  ///
  /// In en, this message translates to:
  /// **'{count} mail(s) found'**
  String mcp_found_mails(int count);

  /// No description provided for @mcp_message_info_retrieved.
  ///
  /// In en, this message translates to:
  /// **'Message information retrieved'**
  String get mcp_message_info_retrieved;

  /// No description provided for @mcp_unknown_user.
  ///
  /// In en, this message translates to:
  /// **'Unknown user'**
  String get mcp_unknown_user;

  /// No description provided for @mcp_unknown_channel.
  ///
  /// In en, this message translates to:
  /// **'Unknown channel'**
  String get mcp_unknown_channel;

  /// No description provided for @mcp_found_messages.
  ///
  /// In en, this message translates to:
  /// **'{count} message(s) found'**
  String mcp_found_messages(int count);

  /// No description provided for @mcp_tasks_today.
  ///
  /// In en, this message translates to:
  /// **'{count} task(s) today'**
  String mcp_tasks_today(int count);

  /// No description provided for @mcp_events_today.
  ///
  /// In en, this message translates to:
  /// **'{count} event(s) today'**
  String mcp_events_today(int count);

  /// No description provided for @mcp_inbox_info_retrieved.
  ///
  /// In en, this message translates to:
  /// **'Inbox information retrieved'**
  String get mcp_inbox_info_retrieved;

  /// No description provided for @mcp_found_inboxes.
  ///
  /// In en, this message translates to:
  /// **'{count} inbox(es) found'**
  String mcp_found_inboxes(int count);

  /// No description provided for @mcp_project_info_retrieved.
  ///
  /// In en, this message translates to:
  /// **'Project information retrieved'**
  String get mcp_project_info_retrieved;

  /// No description provided for @mcp_tasks_rescheduled.
  ///
  /// In en, this message translates to:
  /// **'{count} task(s) rescheduled to today at appropriate times'**
  String mcp_tasks_rescheduled(int count);

  /// No description provided for @mcp_found_projects.
  ///
  /// In en, this message translates to:
  /// **'{count} project(s) found'**
  String mcp_found_projects(int count);

  /// No description provided for @mcp_found_tasks.
  ///
  /// In en, this message translates to:
  /// **'{count} task(s) found'**
  String mcp_found_tasks(int count);

  /// No description provided for @mcp_found_events.
  ///
  /// In en, this message translates to:
  /// **'{count} event(s) found'**
  String mcp_found_events(int count);

  /// No description provided for @mcp_task_info_retrieved.
  ///
  /// In en, this message translates to:
  /// **'Task information retrieved'**
  String get mcp_task_info_retrieved;

  /// No description provided for @mcp_event_info_retrieved.
  ///
  /// In en, this message translates to:
  /// **'Event information retrieved'**
  String get mcp_event_info_retrieved;

  /// No description provided for @mcp_found_calendars.
  ///
  /// In en, this message translates to:
  /// **'{count} calendar(s) found'**
  String mcp_found_calendars(int count);

  /// No description provided for @mcp_found_inbox_items.
  ///
  /// In en, this message translates to:
  /// **'{count} inbox item(s) found'**
  String mcp_found_inbox_items(int count);

  /// No description provided for @mcp_found_labels.
  ///
  /// In en, this message translates to:
  /// **'{count} label(s) found'**
  String mcp_found_labels(int count);

  /// No description provided for @mcp_found_attachments.
  ///
  /// In en, this message translates to:
  /// **'{count} attachment(s) found'**
  String mcp_found_attachments(int count);

  /// No description provided for @mcp_found_upcoming_tasks.
  ///
  /// In en, this message translates to:
  /// **'{count} upcoming task(s) found'**
  String mcp_found_upcoming_tasks(int count);

  /// No description provided for @mcp_found_upcoming_events.
  ///
  /// In en, this message translates to:
  /// **'{count} upcoming event(s) found'**
  String mcp_found_upcoming_events(int count);

  /// No description provided for @mcp_found_overdue_tasks.
  ///
  /// In en, this message translates to:
  /// **'{count} overdue task(s) found'**
  String mcp_found_overdue_tasks(int count);

  /// No description provided for @mcp_found_unscheduled_tasks.
  ///
  /// In en, this message translates to:
  /// **'{count} unscheduled task(s) found'**
  String mcp_found_unscheduled_tasks(int count);

  /// No description provided for @mcp_found_completed_tasks.
  ///
  /// In en, this message translates to:
  /// **'{count} completed task(s) found'**
  String mcp_found_completed_tasks(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
