// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get sign_in => 'Sign In';

  @override
  String get search => 'Search';

  @override
  String get going_question => 'Going?';

  @override
  String get add_organization => 'Add Organization';

  @override
  String get create => 'Create';

  @override
  String get cancel => 'Cancel';

  @override
  String get add => 'Add';

  @override
  String get ok => 'OK';

  @override
  String get edit => 'Edit';

  @override
  String get window => 'Window';

  @override
  String get view => 'View';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get yesterday_short => 'Yest.';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get tab_calendar => 'Calendar';

  @override
  String get tab_home => 'Home';

  @override
  String get tab_board => 'Board';

  @override
  String get tab_chat => 'Chat';

  @override
  String get tab_mail => 'Mail';

  @override
  String get tab_settings => 'Pref';

  @override
  String get tab_inbox => 'Inbox';

  @override
  String get tab_task => 'Task';

  @override
  String get general_title => 'General';

  @override
  String get agent_pref_title => 'Agent';

  @override
  String get agent_pref_api_key => 'API Key';

  @override
  String get agent_pref_openai_api_key => 'OpenAI API Key';

  @override
  String get agent_pref_api_key_hint => 'Enter your OpenAI API key';

  @override
  String get agent_pref_provider_openai => 'OpenAI';

  @override
  String get agent_pref_provider_anthropic => 'Anthropic';

  @override
  String get agent_pref_provider_google => 'Google';

  @override
  String get agent_pref_api_key_hint_anthropic =>
      'Enter your Anthropic API key';

  @override
  String get agent_pref_api_key_hint_google => 'Enter your Google AI API key';

  @override
  String get agent_pref_description =>
      'We never log your data or engage in any activity that could threaten your privacy. However, if you want to use your own AI provider API directly, you can enter your API key here. With an API key, you can directly command or chat with AI even with a Pro subscription.';

  @override
  String get agent_pref_default_ai_provider => 'Default Agent AI Provider';

  @override
  String get agent_pref_default_ai_provider_description =>
      'Default inbox suggestions and next schedule summary features will use the API key you\'ve entered.';

  @override
  String get agent_pref_no_api_keys =>
      'No API keys configured. Please add an API key above.';

  @override
  String get agent_pref_none => 'None';

  @override
  String get agent_pref_additional_tokens => 'Additional Tokens';

  @override
  String agent_pref_current_tokens(String credits) {
    return 'Current: $credits';
  }

  @override
  String get agent_pref_additional_tokens_description =>
      'Purchase additional AI tokens for AI-based orders and summaries. Tokens are used when you don\'t provide your own API key.';

  @override
  String get agent_pref_system_prompt => 'System Prompt';

  @override
  String get agent_pref_system_prompt_description =>
      'Customize the system prompt that will be used for all agent actions. This prompt will be prepended to the default system message.';

  @override
  String get agent_pref_system_prompt_hint =>
      'Enter your custom system prompt (optional)';

  @override
  String get general_theme_title => 'Theme';

  @override
  String get general_text_size => 'Text size';

  @override
  String get general_theme_system => 'System';

  @override
  String get general_theme_light => 'Light';

  @override
  String get general_theme_dark => 'Dark';

  @override
  String get general_pref_appearance => 'Appearance';

  @override
  String get general_pref_tab_bar_display => 'Tab bar display';

  @override
  String get general_pref_tab_bar_standard => 'Standard';

  @override
  String get general_pref_tab_bar_always_collapsed => 'Always collapsed';

  @override
  String get general_pref_hide_unread_indicator => 'Tab icon badge';

  @override
  String get account_title => 'Account';

  @override
  String get account_sign_out => 'Sign Out';

  @override
  String get account_delete => 'Delete Account';

  @override
  String get version_title => 'Version';

  @override
  String get version_check_for_updates => 'Check for Updates';

  @override
  String get version_update_version => 'Get latest version';

  @override
  String get version_up_to_date_title => 'Up to date';

  @override
  String get version_up_to_date_description =>
      'You’re running the latest version. No action needed.';

  @override
  String get version_up_to_date_confirm => 'Got it';

  @override
  String get version_new_version_ready_title => 'New version ready';

  @override
  String get version_new_version_ready_description =>
      'A newer version is available. Update now for the best Visir experience.';

  @override
  String get version_new_version_ready_confirm => 'Update in Store';

  @override
  String get calendar_pref_title => 'Calendar';

  @override
  String get calendar_pref_start_title => 'Start week on';

  @override
  String get calendar_pref_week_title => 'Week view start day';

  @override
  String get calendar_pref_default => 'Default calendar';

  @override
  String get calendar_pref_duration => 'Default event duration';

  @override
  String get calendar_pref_last_used => 'Last used';

  @override
  String get calendar_pref_event_reminder => 'Default event reminders';

  @override
  String get calendar_pref_event_reminder_body =>
      'To update your preferences, access “Settings for my calendars” → “Event notifications” as you would in ';

  @override
  String get calendar_pref_event_reminder_link => 'Google Calendar';

  @override
  String get calendar_pref_include_conference_link => 'Add conference';

  @override
  String get calendar_list_title => 'Calendar Lists';

  @override
  String get calendar_simple_add_location => 'Add Location';

  @override
  String get calendar_connect_to_create => 'Connect Calendar to create events';

  @override
  String get integrate => 'Integrate';

  @override
  String get chat_pref_title => 'Chat';

  @override
  String get chat_display_preferences => 'Display Preferences';

  @override
  String get chat_chat_lists => 'Chat Lists';

  @override
  String get chat_show_channels => 'Show channels';

  @override
  String get chat_show_dms => 'Show DMs';

  @override
  String get chat_sort_channels => 'Sort';

  @override
  String get chat_all => 'All';

  @override
  String get chat_unread_only => 'Unread only';

  @override
  String get chat_alphabetically => 'Alphabetically';

  @override
  String get chat_most_recent => 'Most recent';

  @override
  String get channel_list_search => 'Search channels';

  @override
  String get channel_list_channels => 'Channels';

  @override
  String get channel_list_unlisted_channels => 'Hidden channels';

  @override
  String get channel_list_all_channels => 'All channels';

  @override
  String get channel_list_hide_channel => 'Hide channel';

  @override
  String get chat_search_emoji => 'Search emoji';

  @override
  String get chat_chats => 'Chats';

  @override
  String get chat_message => 'Add message';

  @override
  String chat_focus_last_message(Object shortcut) {
    return '(Press $shortcut to focus the last message)';
  }

  @override
  String get chat_replies => 'replies';

  @override
  String get chat_thread => 'Thread';

  @override
  String get chat_reply_thread => 'Reply thread';

  @override
  String get chat_control_edit_channel_list_of => 'Edit channel list of';

  @override
  String get chat_control_edit_channel_lists => 'Edit channel lists';

  @override
  String get chat_control_manage_integrations => 'Manage Integrations';

  @override
  String get chat_control_unread => 'Unread';

  @override
  String get chat_toast_downloaded => 'Downloaded';

  @override
  String get chat_toast_download_failed => 'Download failed';

  @override
  String get chat_toast_show_in_folder => 'Show in folder';

  @override
  String get chat_toast_open => 'Open';

  @override
  String get chat_toast_download_from_link => 'Download from link';

  @override
  String get chat_integrate_empty_title => 'Access and manage your Slack';

  @override
  String get chat_integrate_empty_description =>
      'Read, reply, and track important conversations in one place.';

  @override
  String get chat_integrate_chat_button => 'Connect chat providers';

  @override
  String get chat_edit_channel_list_of => 'Edit channel list of';

  @override
  String get chat_edit_channel_list => 'Edit channel list';

  @override
  String get chat_emoji_category_frequently_used => 'Frequently Used';

  @override
  String get chat_emoji_category_smiley_and_people => 'Smiley & People';

  @override
  String get chat_emoji_category_animals_and_nature => 'Animals & Nature';

  @override
  String get chat_emoji_category_food_and_drink => 'Food & Drink';

  @override
  String get chat_emoji_category_travel_and_places => 'Travel & Places';

  @override
  String get chat_emoji_category_activities => 'Activities';

  @override
  String get chat_emoji_category_objects => 'Objects';

  @override
  String get chat_emoji_category_symbols => 'Symbols';

  @override
  String get chat_emoji_category_flags => 'Flags';

  @override
  String get chat_emoji_category_custom => 'Custom';

  @override
  String get chat_emoji_search_result => 'Search result';

  @override
  String get chat_formatted_message_user_joines => 'joined';

  @override
  String get chat_formatted_message_user_archived => 'archived';

  @override
  String get chat_formatted_message_user_archived_description =>
      'The contents will still be browsable and available in search.';

  @override
  String get chat_formatted_message_user_unarchived => 'unarchived';

  @override
  String get chat_formatted_message_user_left => 'left';

  @override
  String get chat_message_edited => 'edited';

  @override
  String get chat_channel_you_are_viewing => 'You are viewing';

  @override
  String get chat_channel_archived => ', an archived channel';

  @override
  String get chat_channel_viewing_dm_with_deactivated_account =>
      'You are viewing the archives of a deactivated account';

  @override
  String get chat_block_check_this_message_on_slack =>
      'Check this message on Slack';

  @override
  String get chat_block_go_to_slack => 'Go to Slack';

  @override
  String get chat_settings => 'Settings';

  @override
  String get chat_upload => 'Upload';

  @override
  String get chat_photo_or_video => 'Photo or Video';

  @override
  String get chat_file => 'File';

  @override
  String get chat_this_is_the_very_beginning =>
      'This is the very beginning of the';

  @override
  String get chat_channel => 'Channel';

  @override
  String get chat_this_is_the_very_beginning_of_dm_with =>
      'This is the very beginning of your direct message history with';

  @override
  String get chat_channels => 'Channel';

  @override
  String get chat_dms => 'DM';

  @override
  String get chat_reaction_you => 'You';

  @override
  String get chat_new => 'New';

  @override
  String get chat_read_all => 'Read All';

  @override
  String get chat_app => 'Bot';

  @override
  String get file_options => 'File Options';

  @override
  String get file_options_download => 'Download';

  @override
  String get file_options_share => 'Share';

  @override
  String get add_reaction => 'Add reaction';

  @override
  String get create_task => 'Create task';

  @override
  String get integration_pref_title => 'Integrations';

  @override
  String get integration_calendars => 'Calendars';

  @override
  String get integration_emails => 'Mails';

  @override
  String get integration_messengers => 'Chats';

  @override
  String get integration_others => 'Others';

  @override
  String get notification_pref_title => 'Notifications';

  @override
  String get notification_pref_description =>
      'Notification preferences are applied separately for each device.';

  @override
  String get notification_tasks => 'Tasks';

  @override
  String get notification_calendars => 'Calendars';

  @override
  String get notification_mails => 'Mails';

  @override
  String get notification_messengers => 'Chats';

  @override
  String get notification_task_reminders => 'Task reminders';

  @override
  String get notification_mails_notifications => 'Notifications';

  @override
  String get notification_message_notifications => 'Notifications';

  @override
  String get notification_mail_description =>
      'Only receive notifications based on your preferences.';

  @override
  String get notification_message_description =>
      'Only receive notifications based on your preferences.';

  @override
  String get home_pref_title => 'Task';

  @override
  String get home_pref_task_preference => 'Task Preference';

  @override
  String get home_pref_default_task_color => 'Default color';

  @override
  String get home_pref_default_task_duration => 'Default duration';

  @override
  String get home_pref_double_click_action => 'Double click action';

  @override
  String get home_pref_drag_action => 'Drag action';

  @override
  String get home_pref_floating_button_action => 'Floating button action';

  @override
  String get home_pref_default_task_reminder => 'Default reminder';

  @override
  String get home_pref_default_all_day_task_reminder =>
      'Default all-day reminder';

  @override
  String get home_pref_home_calendar => 'Home Calendar';

  @override
  String get inbox_double_click_action_calendar_event => 'Calendar Event';

  @override
  String get inbox_double_click_action_task => 'Task';

  @override
  String get inbox_double_click_action_last_created => 'Last Created';

  @override
  String get preferences_title => 'Preference';

  @override
  String get preference_integration => 'Integration';

  @override
  String get preference_home => 'Home';

  @override
  String get preference_chat => 'Chat';

  @override
  String get preference_mail => 'Mail';

  @override
  String get preference_calendar => 'Calendar';

  @override
  String get preference_customize_tabs => 'Tabs';

  @override
  String get preference_terms => 'Terms';

  @override
  String get preference_privacy => 'Privacy';

  @override
  String get task_no_task_selected => 'No task selected';

  @override
  String get integration_connect => 'Connect';

  @override
  String get integration_gmail => 'Gmail';

  @override
  String get integration_outlook => 'Outlook';

  @override
  String get integration_gcal => 'Google Calendar';

  @override
  String get integration_outlook_cal => 'Outlook Calendar';

  @override
  String get integration_slack => 'Slack';

  @override
  String get integration_discord => 'Discord';

  @override
  String get calendar_title => 'Calendar';

  @override
  String get sign_out => 'Sign Out';

  @override
  String get calendar_configuration_day => 'Day';

  @override
  String get calendar_configuration_2_days => '2 Days';

  @override
  String get calendar_configuration_3_days => '3 Days';

  @override
  String get calendar_configuration_4_days => '4 Days';

  @override
  String get calendar_configuration_5_days => '5 Days';

  @override
  String get calendar_configuration_6_days => '6 Days';

  @override
  String get calendar_configuration_week => 'Week';

  @override
  String get calendar_configuration_month => 'Month';

  @override
  String get calendar_configuration_list => 'Schedule';

  @override
  String get calendar_event_edit_title => 'Edit Event';

  @override
  String get calendar_event_create_title => 'Create Event';

  @override
  String get calendar_event_edit_repeat => 'Repeat';

  @override
  String get calendar_event_edit_datetime => 'Date & Time';

  @override
  String get select_all => 'Select all';

  @override
  String get deselect_all => 'Deselect all';

  @override
  String get save => 'Save';

  @override
  String get all_day => 'All day';

  @override
  String get repeat_never => 'Never';

  @override
  String get select_date => 'Select date';

  @override
  String get type_description => '+ Add description';

  @override
  String get type_title => 'Enter title';

  @override
  String get type_location => '+ Add location';

  @override
  String get type_attendee => '+ Add guests';

  @override
  String get add_reminder => 'Add reminder';

  @override
  String get event_title => 'Event title';

  @override
  String get location => 'Location';

  @override
  String get description => 'Description';

  @override
  String get to => 'to';

  @override
  String get add_guest => 'Add guest';

  @override
  String get minutes => 'Minutes';

  @override
  String get hours => 'Hours';

  @override
  String get days => 'Days';

  @override
  String get weeks => 'Weeks';

  @override
  String get mail => 'Mail';

  @override
  String get push_notification => 'Push Notification';

  @override
  String get before => 'before';

  @override
  String on_day_of_event_at(Object time) {
    return 'On day of event at $time';
  }

  @override
  String week_before_at(Object time, Object week) {
    return '$week week before at $time';
  }

  @override
  String day_before_at(Object day, Object time) {
    return '$day day before at $time';
  }

  @override
  String get reminder_minute => '1 minute';

  @override
  String reminder_minutes(Object minute) {
    return '$minute minutes';
  }

  @override
  String get reminder_hour => '1 hour';

  @override
  String reminder_hours(Object hour) {
    return '$hour hour';
  }

  @override
  String get at_start_event => 'At the start of event';

  @override
  String get does_not_repeat => 'Does not repeat';

  @override
  String get none => 'None';

  @override
  String get annualy_on => 'Annualy on';

  @override
  String get every_weekday_monday_to_friday =>
      'Every weekday (Monday to Friday)';

  @override
  String get every_weekend_saturday_to_sunday =>
      'Every weekend (Saturday to Sunday)';

  @override
  String get custom_reminder => 'Custom...';

  @override
  String get custom_reminder_title => 'Custom reminder';

  @override
  String get custom_recurrence_title => 'Custom recurrence';

  @override
  String get add_conference => 'Add conference link';

  @override
  String get add_attachment => 'Add attachment';

  @override
  String get edit_recurring_event => 'Edit recurring event';

  @override
  String get delete_recurring_event => 'Delete recurring event';

  @override
  String get edit_recurring_task => 'Edit recurring task';

  @override
  String get delete_recurring_task => 'Delete recurring task';

  @override
  String get this_event_only => 'This event only';

  @override
  String get all_events => 'All events';

  @override
  String get this_and_following_events => 'This and following events';

  @override
  String get this_task_only => 'This task only';

  @override
  String get this_and_following_tasks => 'This and following tasks';

  @override
  String get all_tasks => 'All tasks';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get awaiting => 'Awaiting';

  @override
  String get accept => 'Accept';

  @override
  String get decline => 'Decline';

  @override
  String get maybe => 'Maybe';

  @override
  String get are_you_sure => 'Are you sure?';

  @override
  String get are_you_sure_body =>
      'By pressing ok button, your action will be applied and you will not be able to revert it.';

  @override
  String get email_address_copied_to_clipboard =>
      'Email address copied to clipboard';

  @override
  String get calendar_reminder_before => 'Before';

  @override
  String get calendar_reminder_at => 'At';

  @override
  String get calendar_reminder_by => 'By';

  @override
  String get calendar_recurrence_every => 'Every';

  @override
  String get calendar_recurrence_ends => 'Ends';

  @override
  String get calendar_recurrence_on => 'On';

  @override
  String get calendar_recurrence_daily => 'Day';

  @override
  String get calendar_recurrence_weekly => 'Week';

  @override
  String get calendar_recurrence_monthly => 'Month';

  @override
  String get calendar_recurrence_yearly => 'Year';

  @override
  String get calendar_recurrence_ends_never => 'Never';

  @override
  String get calendar_recurrence_ends_after => 'Ends after';

  @override
  String get calendar_recurrence_ends_on_date => 'Ends on date';

  @override
  String calendar_recurrence_count_times(Object number) {
    return '$number times';
  }

  @override
  String get link_copied_to_clipboard => 'Link copied to clipboard';

  @override
  String get image_copied_to_clipboard => 'Image copied to clipboard';

  @override
  String get first => '1st';

  @override
  String get second => '2nd';

  @override
  String get third => '3rd';

  @override
  String number(Object number) {
    return '${number}th';
  }

  @override
  String get sunday => 'Sunday';

  @override
  String get monday => 'Monday';

  @override
  String get hour => 'Hour';

  @override
  String get minute => 'Minute';

  @override
  String get more_options => 'More options';

  @override
  String get go_to_day_view => 'Go to Day View';

  @override
  String get new_event => 'New Event';

  @override
  String get new_task => 'New Task';

  @override
  String get mail_compose => 'Compose';

  @override
  String get mail_reply => 'Reply';

  @override
  String get mail_reply_all => 'Reply All';

  @override
  String get mail_forward => 'Forward';

  @override
  String get mail_attachments => 'Attachments';

  @override
  String get mail_download_all => 'Download all';

  @override
  String get mail_detail_tooltip_close => 'Close';

  @override
  String get mail_detail_tooltip_mark_as_read => 'Mark as read';

  @override
  String get mail_detail_tooltip_mark_as_unread => 'Mark as unread';

  @override
  String get mail_detail_tooltip_pin => 'Pin';

  @override
  String get mail_detail_tooltip_unpin => 'Unpin';

  @override
  String get mail_detail_tooltip_task => 'Create task';

  @override
  String get mail_detail_tooltip_archive => 'Archive';

  @override
  String get mail_detail_tooltip_unarchive => 'Unarchive';

  @override
  String get mail_detail_tooltip_delete => 'Delete';

  @override
  String get mail_detail_tooltip_delete_forever => 'Delete forever';

  @override
  String get mail_detail_tooltip_undelete => 'Move back to inbox';

  @override
  String get mail_detail_tooltip_report_spam => 'Report spam';

  @override
  String get mail_detail_tooltip_not_spam => 'Not spam';

  @override
  String get mail_detail_tooltip_report_unspam => 'Remove from spam';

  @override
  String get mail_detail_tooltip_move_to_inbox => 'Move to Inbox';

  @override
  String get mail_label_inbox => 'Inbox';

  @override
  String get mail_label_pinned => 'Pinned';

  @override
  String get mail_label_unread => 'Unread';

  @override
  String get mail_label_draft => 'Draft';

  @override
  String get mail_label_sent => 'Sent';

  @override
  String get mail_label_spam => 'Spam';

  @override
  String get mail_label_trash => 'Trash';

  @override
  String get mail_label_archive => 'Archive';

  @override
  String get mail_label_more => 'More';

  @override
  String get mail_label_less => 'Less';

  @override
  String get mail_label_all => 'All Mail';

  @override
  String get mail_new_message => 'New Message';

  @override
  String get mail_to => 'To';

  @override
  String get mail_from => 'From';

  @override
  String get mail_cc => 'Cc';

  @override
  String get mail_bcc => 'Bcc';

  @override
  String get mail_subject => 'Subject';

  @override
  String get mail_body_placeholder => 'Write your message here...';

  @override
  String get mail_send => 'Send';

  @override
  String get mail_toolbar_font_size_small => 'Small';

  @override
  String get mail_toolbar_font_size_normal => 'Normal';

  @override
  String get mail_toolbar_font_size_large => 'Large';

  @override
  String get mail_toolbar_font_size_huge => 'Huge';

  @override
  String get mail_toolbar_color_picker_reset_to_default => 'Reset to default';

  @override
  String get mail_toolbar_color_picker_font_color => 'Font color';

  @override
  String get mail_toolbar_color_picker_background_color => 'Background color';

  @override
  String get mail_toolbar_align_tooltips => 'Align';

  @override
  String get mail_toolbar_align_justify => 'Justify';

  @override
  String get mail_toolbar_align_left => 'Left';

  @override
  String get mail_toolbar_align_center => 'Center';

  @override
  String get mail_toolbar_align_right => 'Right';

  @override
  String get mail_color_picker_background => 'Background color';

  @override
  String get mail_color_picker_text => 'Text color';

  @override
  String get mail_toolbar_tooltip_attachments => 'Attachments';

  @override
  String get mail_toolbar_tooltip_signatures => 'Signatures';

  @override
  String get mail_pref_title => 'Mail';

  @override
  String get mail_pref_account_color => 'Account color';

  @override
  String get mail_pref_account_color_red => 'Red';

  @override
  String get mail_pref_account_color_deep_orange => 'Deep Orange';

  @override
  String get mail_pref_account_color_orange => 'Orange';

  @override
  String get mail_pref_account_color_yellow => 'Yellow';

  @override
  String get mail_pref_account_color_light_green => 'Light Green';

  @override
  String get mail_pref_account_color_green => 'Green';

  @override
  String get mail_pref_account_color_teal => 'Teal';

  @override
  String get mail_pref_account_color_light_blue => 'Light Blue';

  @override
  String get mail_pref_account_color_indigo => 'Indigo';

  @override
  String get mail_pref_account_color_deep_purple => 'Deep Purple';

  @override
  String get mail_pref_account_color_purple => 'Purple';

  @override
  String get mail_pref_account_color_brown => 'Brown';

  @override
  String get mail_pref_signature_list => 'Signatures';

  @override
  String get mail_pref_default_signature => 'Default signature';

  @override
  String get mail_pref_signature_list_select => 'Select signature';

  @override
  String get mail_pref_signature_create_new => '+ Create new';

  @override
  String mail_pref_signature_number(Object number) {
    return 'Signature $number';
  }

  @override
  String get mail_pref_signature_placeholder => 'Write signature...';

  @override
  String get mail_pref_signature_delete => 'Delete Signature';

  @override
  String get mail_pref_signature_none => 'None';

  @override
  String get mail_pref_swipe_actions => 'Swipe Actions';

  @override
  String get mail_pref_swipe_right => 'Swipe right';

  @override
  String get mail_pref_swipe_left => 'Swipe left';

  @override
  String get mail_pref_swipe_none => 'None';

  @override
  String get mail_pref_swipe_read_unread => 'Read / Unread';

  @override
  String get mail_pref_swipe_read => 'Read';

  @override
  String get mail_pref_swipe_unread => 'Unread';

  @override
  String get mail_pref_swipe_pin_unpin => 'Pin / Unpin';

  @override
  String get mail_pref_swipe_pin => 'Pin';

  @override
  String get mail_pref_swipe_unpin => 'Unpin';

  @override
  String get mail_pref_swipe_create_task => 'Create task';

  @override
  String get mail_pref_swipe_archive => 'Archive';

  @override
  String get mail_pref_swipe_delete => 'Delete';

  @override
  String get mail_pref_swipe_report_spam => 'Report spam';

  @override
  String get mail_pref_appearance => 'Appearance';

  @override
  String get mail_pref_email_content_theme => 'Email content theme';

  @override
  String get mail_pref_email_theme_follow_taskey_theme => 'Follow app';

  @override
  String get mail_pref_email_theme_light => 'Light';

  @override
  String get mail_pref_email_theme_dark => 'Dark';

  @override
  String get mail_write_signature => 'Signature';

  @override
  String get mail_write_message => 'Write your message here...';

  @override
  String get mail_sent => 'Mail sent';

  @override
  String get mail_toast_undo => 'Undo';

  @override
  String mail_reply_to(Object name) {
    return 'Reply to $name';
  }

  @override
  String get mail_empty_trash => 'Empty Trash';

  @override
  String get mail_empty_spam => 'Empty Spam';

  @override
  String get mail_toast_archive => 'Mail archived';

  @override
  String get mail_toast_trash => 'Mail moved to trash';

  @override
  String mail_toast_trashs(Object number) {
    return '$number mails moved to trash';
  }

  @override
  String get mail_toast_spam => 'Mail marked as spam';

  @override
  String get mail_search_placeholder => 'Search...';

  @override
  String get mail_empty_description =>
      'This will remove all messages in the folder, but it won’t delete messages from Outlook permanently.';

  @override
  String get inbox_filter_all => 'Show all';

  @override
  String get inbox_filter_unread => 'Unread';

  @override
  String get inbox_filter_pinned => 'Pinned';

  @override
  String get inbox_filter_chat => 'Chat';

  @override
  String get inbox_filter_mail => 'Mail';

  @override
  String get inbox_filter_deleted => 'Deleted';

  @override
  String get inbox_drag_event => 'Event';

  @override
  String get inbox_drag_task => 'Task';

  @override
  String get inbox_task_title => 'Task title';

  @override
  String get show_next_message => 'Show next message';

  @override
  String get mail_pref_filter_inbox_filter => 'Inbox Filter';

  @override
  String get mail_pref_filter_inbox_filter_description =>
      'Use Inbox Filter to control which mails appear in your Inbox.';

  @override
  String get mail_pref_filter_mails => 'Mails';

  @override
  String get mail_pref_filter_none => 'None';

  @override
  String get mail_pref_filter_with_specific_labels => 'With specific labels';

  @override
  String get mail_pref_filter_all => 'All';

  @override
  String get mail_pref_filter_labels => 'Labels';

  @override
  String get mail_pref_filter_with_labels => 'With labels';

  @override
  String get mail_pref_filter_all_mails => 'All mails';

  @override
  String get message_pref_filter_inbox_filter => 'Inbox Filter';

  @override
  String get message_pref_filter_inbox_filter_description =>
      'Use Inbox Filter to control which messages appear in your Inbox.';

  @override
  String get message_pref_filter_direct_messages => 'DMs';

  @override
  String get message_pref_filter_mentions_from_direct_messages =>
      'Mentions from DMs';

  @override
  String get message_pref_filter_channels => 'Channels';

  @override
  String get message_pref_filter_mentions_from_channels =>
      'Mentions from channels';

  @override
  String get message_pref_filter_none => 'None';

  @override
  String get message_pref_filter_mentions => 'Mentions';

  @override
  String get message_pref_filter_all => 'All';

  @override
  String message_forwarded_posted_in_channel(Object channelName) {
    return 'Posted in # $channelName';
  }

  @override
  String message_forwarded_thread_in_channel(Object channelName) {
    return 'Thread in # $channelName';
  }

  @override
  String get message_forwarded_direct_message => 'Direct Message';

  @override
  String get message_forwarded_view_message => 'View Message';

  @override
  String get message_forwarded_view_conversation => 'View Conversation';

  @override
  String get task_action_duplicate => 'Duplicate';

  @override
  String get task_action_delete => 'Delete';

  @override
  String get task_action_copy_link => 'Copy link';

  @override
  String get task_action_delete_link => 'Delete link';

  @override
  String get delete_message => 'Delete message';

  @override
  String get edit_message => 'Edit message';

  @override
  String get show_tasks => 'Show tasks';

  @override
  String get set_different_end_date => 'Set Different End Date';

  @override
  String get guests => 'Guests';

  @override
  String get reminder => 'Reminder';

  @override
  String get conference => 'Conference';

  @override
  String get mobile_task_edit_create_task => 'Create Task';

  @override
  String get mobile_task_edit_edit_task => 'Edit Task';

  @override
  String get delete_event_confirm_popup_title => 'Are you sure?';

  @override
  String get delete_event_confirm_popup_description =>
      'This will delete the event and cannot be undone.';

  @override
  String get delete_event_confirm_popup_cancel => 'Cancel';

  @override
  String get delete_event_confirm_popup_delete => 'Delete';

  @override
  String message_loaded_until(Object date) {
    return 'loaded until $date';
  }

  @override
  String get message_load_more => 'load more';

  @override
  String get mail_integration_empty_title => 'Access and manage your emails';

  @override
  String get mail_integration_empty_description =>
      'Read, reply, forward, compose, search, and archive your emails.';

  @override
  String get mail_integration_empty_button => 'Connect Mail';

  @override
  String get calendar_integration_empty_title =>
      'Connect your Calendar to begin';

  @override
  String get calendar_integration_empty_description =>
      'Sync with Calendar to bring in your schedule and stay organized.';

  @override
  String get calendar_integration_empty_button => 'Connect Calendar';

  @override
  String get mail_actions => 'Mail actions';

  @override
  String get mark_done => 'Mark done';

  @override
  String get mark_undone => 'Mark undone';

  @override
  String get mail_no_recepients => 'No Recipients';

  @override
  String get mail_no_subject => 'No Subject';

  @override
  String get mail_no_content => 'No Content';

  @override
  String get home_pref_task_completion_sound => 'Task completion sound';

  @override
  String get home_pref_completed_tasks => 'Completed tasks';

  @override
  String get home_pref_completed_tasks_show => 'Show';

  @override
  String get home_pref_completed_tasks_hide => 'Hide';

  @override
  String get home_pref_completed_tasks_delete => 'Delete';

  @override
  String get mail_google_api_limit_reached =>
      'Gmail API limit reached. Try again later';

  @override
  String get calendar_google_api_limit_reached =>
      'Google Calendar API limit reached. Try again later';

  @override
  String get message_slack_api_limit_reached =>
      'Slack API limit reached. Try again later';

  @override
  String get inbox_drop_to_cancel => 'Drop to cancel';

  @override
  String get inbox_drop_to_edit_details => 'Drop to edit details';

  @override
  String get inbox_you_are_all_set => 'You\'re all set!';

  @override
  String get inbox_no_issues_for_this_day => 'No issues for this day.';

  @override
  String get inbox_no_search_results => 'No search results';

  @override
  String get task_created => 'Task created';

  @override
  String get task_edited => 'Task edited';

  @override
  String get task_created_undo => 'Undo';

  @override
  String get event_created => 'Event created';

  @override
  String get event_created_undo => 'Undo';

  @override
  String get mail_empty_subject => '(No Subject)';

  @override
  String get mail_no_email_selected => 'No email selected.';

  @override
  String get mail_no_search_results => 'No search results';

  @override
  String get mail_no_email_inbox => 'No emails in your inbox.';

  @override
  String get mail_no_email_unread => 'No unread emails.';

  @override
  String get mail_no_email_pinned => 'No pinned emails.';

  @override
  String get mail_no_email_draft => 'No draft emails.';

  @override
  String get mail_no_email_sent => 'No sent emails.';

  @override
  String get mail_no_email_spam => 'No spam emails.';

  @override
  String get mail_no_email_trash => 'No emails in trash.';

  @override
  String get mail_me => 'me';

  @override
  String get mail_drop_to_attach => 'Drop to Attach';

  @override
  String get file_uploading_message_error =>
      'File uploading. Please wait to send your message.';

  @override
  String get mail_discard_drafts => 'Discard Drafts';

  @override
  String get mail_discard_draft => 'Discard Draft';

  @override
  String get mail_discard_drafts_description =>
      'This will discard all drafts and cannot be undone.';

  @override
  String get mail_organizer => 'Organizer';

  @override
  String get feedback => 'Feedback';

  @override
  String get feedback_send => 'Send';

  @override
  String get feedback_sent_successfully => 'Feedback sent successfully';

  @override
  String get feedback_sent_wrong => 'Something went wrong. Try again later';

  @override
  String get feedback_write_your_feedback => 'Write your feedback...';

  @override
  String get feedback_can_not_open_slack_app => 'Can\'t open Slack app';

  @override
  String get signup_warning =>
      'By signing in, I accept to the terms of service and privacy policy of Visir';

  @override
  String get pref_privacy => 'Privacy Policy';

  @override
  String get pref_terms => 'Terms of Service';

  @override
  String get pref_subscription => 'Subscription';

  @override
  String get pref_download => 'Download App';

  @override
  String get task_unscheduled => 'Unscheduled';

  @override
  String get task_overdue => 'Overdue';

  @override
  String get task_add_task => 'Add task';

  @override
  String get task_to => 'to';

  @override
  String get task_color => 'Task color';

  @override
  String get task_set_date => 'Set date';

  @override
  String get task_set_time => 'Set time';

  @override
  String get task_label_all => 'All Tasks';

  @override
  String get task_label_scheduled => 'Scheduled';

  @override
  String get task_label_completed => 'Completed';

  @override
  String get task_label_overdue => 'Overdue';

  @override
  String get task_label_unscheduled => 'Unscheduled';

  @override
  String get task_label_this_week => 'This Week';

  @override
  String get task_label_this_month => 'This Month';

  @override
  String get task_label_more => 'More';

  @override
  String get task_label_less => 'Less';

  @override
  String get task_no_tasks_today => 'No tasks today';

  @override
  String get task_no_scheduled_tasks => 'No scheduled tasks';

  @override
  String get task_no_completed_tasks => 'No completed tasks';

  @override
  String get task_no_overdue_tasks => 'No overdue tasks';

  @override
  String get task_no_unscheduled_tasks => 'No unscheduled tasks';

  @override
  String get task_no_title => 'No title';

  @override
  String get task_save_recurring_changes => 'Save recurring changes';

  @override
  String get onboarding_description =>
      'Manage all your emails, tasks, calendars, and chats in one place.\nSimplify your workflow and save time.';

  @override
  String get onboarding_continue_with_google => 'Continue with Google';

  @override
  String get onboarding_continue_with_apple => 'Continue with Apple';

  @override
  String get onboarding_continue_with_email => 'Continue with email';

  @override
  String get onboarding_signin_with_google => 'Sign in with Google';

  @override
  String get onboarding_signin_with_apple => 'Sign in with Apple';

  @override
  String get onboarding_signin_with_email => 'Sign in with email';

  @override
  String get onboarding_by_registering => 'By registering, you agree to the ';

  @override
  String get onboarding_terms_of_service => 'terms of service';

  @override
  String get onboarding_and => ' and';

  @override
  String get onboarding_privacy_policy => ' privacy policy';

  @override
  String get onboarding_of_taskey => ' of Visir.';

  @override
  String get onboarding_enter_your_email => 'Enter your email';

  @override
  String get onboarding_enter_your_password => 'Enter your password';

  @override
  String get onboarding_log_in => 'Log in';

  @override
  String get onboarding_sign_up => 'Sign Up';

  @override
  String get onboarding_send_password_reset_email =>
      'Send password reset email';

  @override
  String get onboarding_return_to_login_options => 'Return to login options';

  @override
  String get onboarding_forgot_your_password => 'Forgot your password?';

  @override
  String get onboarding_do_not_have_an_account =>
      'Don’t have an account? Sign up.';

  @override
  String get onboarding_already_have_an_account =>
      'Already have an account? Sign in.';

  @override
  String get onboarding_email => 'Email';

  @override
  String get onboarding_password => 'Password';

  @override
  String get onboarding_username => 'Username';

  @override
  String get onboarding_password_reset_email_sent =>
      'A password reset email has been sent.';

  @override
  String get onboarding_password_reset_email_failed =>
      'The email address is not registered. Please try again with a valid address.';

  @override
  String get onboarding_back_to_sign_in => 'Back to Sign in';

  @override
  String get onboarding_please_enter_a_username => 'Please enter a username.';

  @override
  String get onboarding_please_enter_a_valid_email_address =>
      'Please enter a valid email address.';

  @override
  String get onboarding_please_enter_a_long_password =>
      'Please enter a password that is at least 6 characters long.';

  @override
  String get onboarding_invalid_username_or_password =>
      'Invalid username or password. Please try again.';

  @override
  String get onboarding_email_sign_up_failed =>
      'An unexpected error occurred. Please try again.';

  @override
  String get onboarding_email_sign_up_failed_email_address_invalid =>
      'Please enter a valid email address.';

  @override
  String get onboarding_email_sign_up_failed_email_exists =>
      'This email address is already in use. Please log in.';

  @override
  String get onboarding_email_sign_up_failed_email_not_confirmed =>
      'This email address is pending confirmation. Please check your inbox or resend the confirmation email.';

  @override
  String get onboarding_email_sign_up_failed_over_email_send_rate_limit =>
      'Too many requests. Please wait a moment and try again.';

  @override
  String get onboarding_email_not_registered =>
      'The email address is not registered. Please try again with a valid address.';

  @override
  String get onboarding_email_sending_error =>
      'An error occurred while sending the email. Please try again later.';

  @override
  String get onboarding_waiting_for_confirm_email =>
      'Waiting for confirmation email';

  @override
  String get time_saved_todo => 'Todo';

  @override
  String get time_saved_load_more => 'load more';

  @override
  String get time_saved_most_frequent_transitions =>
      'Most Frequent Transitions';

  @override
  String get time_saved_according_to_research =>
      'According to research conducted by Qatalog in collaboration with Cornell University’s Ellis Idea Lab';

  @override
  String get time_saved_based_on_our => 'Based on our internal experiments';

  @override
  String get time_saved_calendars_are_not_separated =>
      'Calendars are not separated by account because they can be used without switching apps through subscription or sharing features.';

  @override
  String get time_saved_hourly_wage_only_device =>
      'The hourly wage is stored only on this device and is not saved anywhere else, ensuring your data remains secure.';

  @override
  String time_saved_button_title(Object number) {
    return 'Saved \$$number';
  }

  @override
  String time_saved_button_tooltip(Object month) {
    return 'Saved in $month';
  }

  @override
  String get time_saved_screen_title => 'Time Saved';

  @override
  String get time_saved_your_savings => 'Your Savings';

  @override
  String get time_saved_time_saved => 'Time Saved';

  @override
  String get time_saved_money_saved => 'Money Saved';

  @override
  String get time_saved_hour_per_week => 'h / week';

  @override
  String get time_saved_based_on_your_last_week_data =>
      '*based on the last 7 days of data';

  @override
  String get time_saved_based_on_your_hourly_wage =>
      '*based on your hourly wage';

  @override
  String get time_saved_hourly_wage => 'Hourly Wage';

  @override
  String get time_saved_per_hour => '/ hr';

  @override
  String get time_saved_time_spent_on_app_switching =>
      'Time Spent on App Switching (Direct)';

  @override
  String get time_saved_focus_lost_from_app_switching =>
      'Focus Lost from App Switching (Indirect)';

  @override
  String get time_saved_seconds => 'seconds';

  @override
  String get time_saved_app_switches => 'App Switches';

  @override
  String get time_saved_time_per_switch => 'Time Per Switch';

  @override
  String get time_saved_time_wasted => 'Time Wasted';

  @override
  String get time_saved_hours_in_low_focus => 'Hours in Low Focus';

  @override
  String get time_saved_productivity_loss => 'Productivity Loss';

  @override
  String get time_saved_calculation_method => 'Calculation Method';

  @override
  String get time_saved_hidden_coast => 'The Hidden Cost of App Switching';

  @override
  String get time_saved_opening_apps_title =>
      'Time Wasted Searching for and Opening Apps';

  @override
  String get time_saved_opening_apps_description =>
      'Switching between apps takes time to locate and open each tool, with every transition taking an average of 9 seconds. These small delays accumulate, creating unnecessary interruptions and slowing down your workflow.';

  @override
  String get time_saved_ease_switch_title =>
      'Productivity Loss After Each Switch';

  @override
  String get time_saved_ease_switch_description =>
      'After switching apps, it takes an average of 9.5 minutes to regain focus and return to a productive state. This repeated loss of focus leads to significant wasted time each week, impacting your overall efficiency.';

  @override
  String get time_saved_how_solved_title => 'How Visir Solves This';

  @override
  String get time_saved_how_solved_description =>
      'With Visir, all your apps are accessible and manageable in one place. By eliminating app switching, Visir saves you time and helps you maintain focus, ensuring your productivity remains uninterrupted.';

  @override
  String get time_saved_projection_description_first =>
      'You\'ve been using Visir for ';

  @override
  String time_saved_projection_days(Object count) {
    return '$count days';
  }

  @override
  String get time_saved_projection_description_second => ' and have reduced ';

  @override
  String time_saved_projection_app_switches(Object count) {
    return '$count app switches';
  }

  @override
  String get time_saved_projection_description_third =>
      ' so far. This saved you a total of ';

  @override
  String time_saved_projection_hours(Object count) {
    return '$count hours';
  }

  @override
  String get time_saved_projection_description_fourth => ', which equals ';

  @override
  String get time_saved_projection_description_fifth =>
      ' based on your hourly wage. If this pace continues, your projected annual savings are ';

  @override
  String get time_saved_productive_hours_reclaimed =>
      'Productive Hours Reclaimed';

  @override
  String get time_saved_most_frequent_switch => 'Most Frequent Switch';

  @override
  String get time_saved_wasted_switching => 'Wasted Switching';

  @override
  String get time_saved_wasted_regaining_focus => 'Wasted Regaining Focus';

  @override
  String get time_saved_last_7_days => 'Last 7 days';

  @override
  String get time_saved_last_14_days => 'Last 14 days';

  @override
  String get time_saved_last_28_days => 'Last 28 days';

  @override
  String get time_saved_last_12_weeks => 'Last 12 weeks';

  @override
  String get time_saved_last_12_months => 'Last 12 months';

  @override
  String get time_saved_this_week => 'This Week';

  @override
  String get time_saved_this_month => 'This Month';

  @override
  String get time_saved_this_year => 'This Year';

  @override
  String get time_saved_total => 'Total';

  @override
  String get time_saved_trend => 'Savings Trend';

  @override
  String get time_saved_times => 'times';

  @override
  String get time_saved_savings_with => 'Savings with';

  @override
  String get time_saved_switches_avoided => 'Switches Avoided';

  @override
  String get time_saved_that_is_equivalent_to => 'That\'s equivalent to';

  @override
  String get time_saved_how_i_did_it => 'How I did it';

  @override
  String get time_saved_watching => 'Watching';

  @override
  String get time_saved_episodes => 'episodes';

  @override
  String get time_saved_buy => 'Buy';

  @override
  String get time_saved_burgers => 'burgers';

  @override
  String get time_saved_start_using_taskey =>
      'Start using Visir to see your savings';

  @override
  String get time_saved_share => 'Share';

  @override
  String get time_saved_download_image => 'Download Image';

  @override
  String get time_saved_share_tutorial_title => 'Image copied to clipboard';

  @override
  String time_saved_share_tutorial_description(Object platform) {
    return 'Click Continue to open $platform, then paste the image';
  }

  @override
  String get time_saved_share_tutorial_button => 'Continue';

  @override
  String get time_saved_saved => 'Saved';

  @override
  String get time_saved_saved_in => 'Saved in';

  @override
  String get time_saved_saved_in_the => 'Saved in the';

  @override
  String time_saved_taskey_helped_you_save(Object hours, Object money) {
    return 'Visir helped you save $hours hours and \$$money';
  }

  @override
  String time_saved_in(Object viewType) {
    return 'in $viewType';
  }

  @override
  String time_saved_in_the(Object viewType) {
    return 'in the $viewType';
  }

  @override
  String time_saved_taskey_helped_you_save_total(Object money) {
    return 'Congrats 🎉🎉 \$$money saved so far.';
  }

  @override
  String time_saved_total_share_text(Object days, Object hours, Object money) {
    return '🙌 Only $days days with Visir and I\'ve already saved $hours hours and \$$money! Give it a try!';
  }

  @override
  String time_saved_check_out_taskey_here(Object url) {
    return '✨ Check out Visir here : $url';
  }

  @override
  String get subscription_visir_pro => 'Pro Plan';

  @override
  String get subscription_unlimited_integrations => 'Unlimited integrations';

  @override
  String get subscription_ai_suggestion =>
      'AI Suggestions and more AI features';

  @override
  String get subscription_pro_ai_based_inbox_summary =>
      'AI based inbox suggestions';

  @override
  String get subscription_pro_next_schedule_summary => 'Next schedule summary';

  @override
  String get subscription_pro_100k_ai_tokens =>
      '100K AI tokens monthly for AI-powered summaries and insights';

  @override
  String get subscription_all_features => 'All features';

  @override
  String get subscription_priority_support => 'Priority support';

  @override
  String get subscription_continuous_update =>
      'Continuous updates, no price increase';

  @override
  String get subscription_visir_ultra => 'Ultra Plan';

  @override
  String get subscription_ultra => 'Ultra';

  @override
  String get subscription_ultra_best_value => 'Best Value';

  @override
  String get subscription_ultra_all_pro_features => 'All features in Pro';

  @override
  String get subscription_ultra_500k_ai_tokens =>
      '500K additional AI tokens monthly';

  @override
  String get subscription_ultra_advanced_ai_features =>
      'Advanced AI features and unlimited AI requests';

  @override
  String get subscription_ultra_priority_support => 'Priority support';

  @override
  String get subscription_ultra_continuous_update =>
      'Continuous updates, no price increase';

  @override
  String get subscription_monthly => 'Monthly';

  @override
  String get subscription_yearly => 'Yearly';

  @override
  String get subscription_early_access_discout => 'Early Access Discount';

  @override
  String get subscription_active => 'Active';

  @override
  String get subscription_manage_billing => 'Manage billing';

  @override
  String get subscription_switch_subscription => 'Switch plan';

  @override
  String get subscription_per_month => ' /mo';

  @override
  String get subscription_next_billing_date => 'Next bill on';

  @override
  String get subscription_subscription_ends => 'Subscription ends on';

  @override
  String get subscription_free_trial_ends => 'Free trial ends on';

  @override
  String get subscription_upgrade_to_pro => 'Choose this plan';

  @override
  String get subscription_save_two_months_more => 'Save 2-months more';

  @override
  String get subscription_billed_annualy => 'Billed annually';

  @override
  String get subscription_restore_subscription => 'Restore subscription';

  @override
  String get subscription_contact_billing_support => 'Contact billing support';

  @override
  String get subscription_your_savings_tooptip_desktop =>
      'The range you choose here also updates the Saved amount in the app’s top right corner.';

  @override
  String get subscription_your_savings_tooptip_mobile =>
      'The range you choose here also updates the Saved amount below the settings icon in the bottom-right corner.';

  @override
  String get update_required_title => 'Update Required';

  @override
  String get update_required_body =>
      'This version is no longer supported. Please update to continue.';

  @override
  String get update_required_button => 'Update';

  @override
  String get delete_confirm_text =>
      'Are you sure you want to proceed? Deleting your account will permanently remove all your task data and account information from our system. This action is irreversible.';

  @override
  String get delete_confirm_title => 'Delete';

  @override
  String get join_community => 'Join community';

  @override
  String get join_slack_community => 'Join Slack community';

  @override
  String get download_for_mobile => 'Download for mobile';

  @override
  String get webview2_required_title => 'Need WebView2 Runtime';

  @override
  String get webview2_required_body =>
      'To view and edit emails in Visir, you need the WebView2 Runtime. You can get it from the official Microsoft website.';

  @override
  String get webview2_required_button => 'Download';

  @override
  String get error_message_dont_have_permission =>
      'You don\'t have permissions to do this action';

  @override
  String n_selected(Object count) {
    return '$count Selected';
  }

  @override
  String get mail_options => 'Options';

  @override
  String get mail_options_title => 'Reply & More';

  @override
  String get download_button => 'Download native Visir app';

  @override
  String get search_inbox => 'Search inbox';

  @override
  String get tooltip_prev_day => 'Previous day';

  @override
  String get tooltip_next_day => 'Next day';

  @override
  String tooltip_prev_n_day(Object count) {
    return 'Previous $count days';
  }

  @override
  String tooltip_next_n_day(Object count) {
    return 'Next $count days';
  }

  @override
  String get tooltip_prev_week => 'Previous week';

  @override
  String get tooltip_next_week => 'Next week';

  @override
  String get tooltip_prev_month => 'Previous month';

  @override
  String get tooltip_next_month => 'Next month';

  @override
  String get refresh => 'Refresh';

  @override
  String get show_hide_calendars => 'Show / Hide calendars';

  @override
  String get tooltip_view_range => 'View range';

  @override
  String get tooltip_view_range_shortcut_to_week => '1~7, W';

  @override
  String get tooltip_view_range_shortcut_to_month => '1~7, W, M';

  @override
  String get confirm => 'Confirm';

  @override
  String get quick_view => 'Quick view';

  @override
  String open_in(Object provider) {
    return 'Open in $provider';
  }

  @override
  String get remove_from_inbox => 'Remove from inbox';

  @override
  String get open_in_chat_tab => 'Open in chat tab';

  @override
  String get open_in_mail_tab => 'Open in mail tab';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get inbox_filter => 'Inbox filter';

  @override
  String get notification_preference => 'Notification perferences';

  @override
  String get chat_preference => 'Chat perferences';

  @override
  String get join_conference => 'Join';

  @override
  String get play => 'Play';

  @override
  String get pause => 'Pause';

  @override
  String get mute => 'Mute';

  @override
  String get unmute => 'Unmute';

  @override
  String get close => 'Close';

  @override
  String get go_back => 'Go back';

  @override
  String get delete => 'Delete';

  @override
  String get duplicate => 'Dupliacte';

  @override
  String get search_mail => 'Search mail';

  @override
  String get search_channels => 'Search channels';

  @override
  String get collapse => 'Collapse';

  @override
  String get expand => 'Expand';

  @override
  String get cancel_search => 'Cancel search';

  @override
  String get reaction => 'Reaction';

  @override
  String get reply_in_thread => 'Reply in thread';

  @override
  String get more_actions => 'More actions';

  @override
  String get attach => 'Attach';

  @override
  String get drag_and_drop => 'Drag & drop';

  @override
  String get send => 'Send';

  @override
  String get quick_link_hint_link => 'Link';

  @override
  String get quick_link_hint_title => 'Title (Optional)';

  @override
  String get quick_link_add => 'Add quick link';

  @override
  String get quick_link_more => 'More quick links';

  @override
  String get copy_message => 'Copy message';

  @override
  String get text_copied_to_clipboard => 'Message copied to clipboard';

  @override
  String get tutorial_welcome_to_taskey => 'Welcome to Visir!';

  @override
  String get tutorial_connect_apps => 'Connect Mail, Calendar, and Slack.';

  @override
  String get tutorial_keep_everything_organized =>
      'Keep everything organized and reclaim your time.';

  @override
  String get tutorial_get_started => 'Get started';

  @override
  String get feature_tutorial_inbox_integration_title => 'This is your Inbox';

  @override
  String get feature_tutorial_inbox_integration_description =>
      'This is where all your messages from Mail and Chats come together.';

  @override
  String get feature_tutorial_inbox_integration_button => 'Set up integrations';

  @override
  String get feature_tutorial_inbox_drag_and_drop_title =>
      'Drag and drop task creation';

  @override
  String get feature_tutorial_inbox_drag_and_drop_description =>
      'Drag an issue from your Inbox to create a task or event instantly.';

  @override
  String get feature_tutorial_inbox_drag_and_drop_button => 'Got it';

  @override
  String get feature_tutorial_mobile_inbox_drag_and_drop_title =>
      'Long press task creation';

  @override
  String get feature_tutorial_mobile_inbox_drag_and_drop_description =>
      'Tap and hold an item in your Inbox to create a task or event.';

  @override
  String get feature_tutorial_time_saved_title => 'Switch less. Save more.';

  @override
  String get feature_tutorial_time_saved_description =>
      'Every context switch drains focus and costs about 9.5 minutes and real dollars. Stay inside Visir and watch minutes and money stack up in Time Saved.';

  @override
  String get feature_tutorial_time_saved_button => 'Show my savings';

  @override
  String get feature_tutorial_create_task_from_mail_title =>
      'Turn mails into tasks';

  @override
  String get feature_tutorial_create_task_from_mail_description =>
      'Use the Create task button to directly create a task from Mail.';

  @override
  String get feature_tutorial_create_task_from_mail_button => 'Got it';

  @override
  String get google_calendar_permission_title =>
      'Grant full access to sync your calendar';

  @override
  String get google_calendar_permission_description =>
      'On the next screen, make sure to check all permission boxes. These permissions are required to manage your calendar events in Visir.';

  @override
  String get google_calendar_permission_button => 'Continue';

  @override
  String get google_mail_permission_title =>
      'Grant full access to connect your Gmail';

  @override
  String get google_mail_permission_description =>
      'On the next screen, make sure to check all permission boxes. These permissions are required to manage your emails in Visir.';

  @override
  String get google_mail_permission_button => 'Continue';

  @override
  String get inbox_filter_tutorial_title =>
      'Control what appears in your Inbox';

  @override
  String get inbox_filter_tutorial_description =>
      'Use inbox filter to choose which messages show up.';

  @override
  String get inbox_filter_tutorial_button => 'Got it';

  @override
  String get download_mobile_app_popup_title => 'Get Visir on mobile';

  @override
  String get download_mobile_app_popup_description =>
      'Scan this QR code to download the app for iOS or Android. Visir on mobile offers the same full functionality as desktop.';

  @override
  String get download_mobile_app_popup_button => 'Close';

  @override
  String get download_for_desktop => 'Download for desktop';

  @override
  String get reacting_members => 'Reacting members';

  @override
  String get system => 'System';

  @override
  String get launch_at_startup => 'Launch at startup';

  @override
  String get ai_suggestion_section => 'Suggestion';

  @override
  String get ai_suggestion => 'Suggested';

  @override
  String get ai_suggestion_urgency_urgent => 'Urgent';

  @override
  String get ai_suggestion_urgency_important => 'Important';

  @override
  String get ai_suggestion_urgency_action_required => 'Action Required';

  @override
  String get ai_suggestion_urgency_need_review => 'Need Review';

  @override
  String get ai_suggestion_reason_meeting_invitation => 'Meeting Invitation';

  @override
  String get ai_suggestion_reason_meeting_followup => 'Meeting Follow-up';

  @override
  String get ai_suggestion_reason_meeting_notes => 'Meeting Notes';

  @override
  String get ai_suggestion_reason_task_assignment => 'Task Assignment';

  @override
  String get ai_suggestion_reason_task_status_update => 'Task Update';

  @override
  String get ai_suggestion_reason_scheduling_request => 'Scheduling Request';

  @override
  String get ai_suggestion_reason_scheduling_confirmation =>
      'Scheduling Confirmation';

  @override
  String get ai_suggestion_reason_document_review => 'Document Review';

  @override
  String get ai_suggestion_reason_code_review => 'Code Review';

  @override
  String get ai_suggestion_reason_approval_request => 'Approval Request';

  @override
  String get ai_suggestion_reason_question => 'Question';

  @override
  String get ai_suggestion_reason_information_sharing => 'Info Sharing';

  @override
  String get ai_suggestion_reason_announcement => 'Announcement';

  @override
  String get ai_suggestion_reason_system_notification => 'System Notification';

  @override
  String get ai_suggestion_reason_cold_contact => 'Cold Contact';

  @override
  String get ai_suggestion_reason_customer_contact => 'Customer Contact';

  @override
  String get ai_suggestion_reason_other => 'Other';

  @override
  String ai_suggestion_due(Object due) {
    return 'Due: $due';
  }

  @override
  String get ai_suggestion_due_asap => 'ASAP';

  @override
  String ai_suggestion_duration(Object mininutes) {
    return '$mininutes min';
  }

  @override
  String get ai_thinking => 'Thinking...';

  @override
  String get inbox_sort_and_filter => 'Sort & Filter';

  @override
  String get inbox_sort_section => 'Sorting';

  @override
  String get inbox_sort_recent => 'Sort by recent';

  @override
  String get inbox_sort_due => 'Sort by due';

  @override
  String get inbox_sort_importnace => 'Sort by importance';

  @override
  String get inbox_filter_section => 'Filter';

  @override
  String get inbox_filter_urgent => 'Urgent only';

  @override
  String get inbox_filter_important => 'Important or higher';

  @override
  String get inbox_filter_action_required => 'Action Required or higher';

  @override
  String get inbox_filter_hide_all => 'Hide all';

  @override
  String get inbox_right_click_option_read => 'Read';

  @override
  String get inbox_right_click_option_unread => 'Unread';

  @override
  String get inbox_right_click_option_pin => 'Pin';

  @override
  String get inbox_right_click_option_unpin => 'Unpin';

  @override
  String get inbox_right_click_option_delete => 'Delete';

  @override
  String get inbox_right_click_option_undelete => 'Move back to inbox';

  @override
  String get failed_to_send_mail => 'Failed to send mail';

  @override
  String get retry_to_send_mail => 'Retry sending mail';

  @override
  String get select_prev => 'Select previous';

  @override
  String get select_next => 'Select next';

  @override
  String get new_message => 'New Message';

  @override
  String new_messages(Object count) {
    return '$count Messages';
  }

  @override
  String get ask_taskey => 'Search anything';

  @override
  String get command_bar_hint =>
      'Search for tasks, events, commands, and more…';

  @override
  String command_search_in_all(Object query) {
    return 'Search$query everywhere';
  }

  @override
  String command_search_in_mail(Object query) {
    return 'Search$query in emails';
  }

  @override
  String command_search_in_event(Object query) {
    return 'Search$query in calendar events';
  }

  @override
  String command_search_in_task(Object query) {
    return 'Search$query in tasks';
  }

  @override
  String command_search_in_chat(Object query) {
    return 'Search$query in chats';
  }

  @override
  String command_create_task(Object title) {
    return 'Create task $title';
  }

  @override
  String command_edit_task(Object title) {
    return 'Edit task $title';
  }

  @override
  String command_delete_task(Object title) {
    return 'Delete task $title';
  }

  @override
  String command_mark_as_done_task(Object title) {
    return 'Mark as done $title';
  }

  @override
  String command_mark_as_undone_task(Object title) {
    return 'Mark as undone $title';
  }

  @override
  String command_create_event(Object title) {
    return 'Create calendar event $title';
  }

  @override
  String command_edit_event(Object title) {
    return 'Edit calendar event $title';
  }

  @override
  String command_delete_event(Object title) {
    return 'Delete calendar event $title';
  }

  @override
  String command_chat_open_channel(Object title) {
    return 'Open channel $title';
  }

  @override
  String command_chat_send_message(Object title) {
    return 'Send message $title';
  }

  @override
  String command_chat_show_channel(Object title) {
    return 'Show channel $title';
  }

  @override
  String command_chat_hide_channel(Object title) {
    return 'Hide channel $title';
  }

  @override
  String get command_argument_title => 'Title';

  @override
  String get command_arguemnt_message => 'Message';

  @override
  String get command_argument_description => 'Description';

  @override
  String get command_argument_rrule => 'Recurrence rule';

  @override
  String get command_argument_at => 'At';

  @override
  String get command_argument_recurring => 'Every';

  @override
  String get command_argument_reminder => 'Reminder';

  @override
  String get command_argument_location => 'Location';

  @override
  String get command_argument_attendee => 'Attendee';

  @override
  String get command_argument_calendar => 'Calendar';

  @override
  String get command_argument_color => 'Color';

  @override
  String get command_argument_channel => 'Channel';

  @override
  String get command_suggestion => 'Suggestions';

  @override
  String get command_results => 'Results';

  @override
  String get command_argument_with => 'with ';

  @override
  String get command_argument_and => 'and ';

  @override
  String command_argument_add_flag(Object flag) {
    return 'Add $flag';
  }

  @override
  String command_argument_set_flag(Object flag, Object value) {
    return 'Set $flag: $value';
  }

  @override
  String get command_argument_marked_done => 'which marked as done';

  @override
  String get subscription_done_title => 'Welcome to Visir Pro';

  @override
  String get subscription_done_description =>
      'Manage all your emails, chats, calendars, and tasks in one place, simplify your workflow, and reclaim time for the work that matters.';

  @override
  String get subscription_done_button => 'Get started';

  @override
  String get early_access_done_title => 'Introducing Visir Pro';

  @override
  String get early_access_done_description =>
      'Free Early Access ends on August 30, continue with our discounted Early Access pricing after that.';

  @override
  String get early_access_done_button => 'Got it';

  @override
  String get upgrade_to_taskey_pro_title => 'Upgrade to Visir Pro';

  @override
  String get upgrade_to_taskey_pro_button => 'View plans';

  @override
  String get expired_title => 'Your subscription is expired';

  @override
  String get expired_title_ios =>
      'This account doesn\'t currently have access to Visir';

  @override
  String get expired_title_mobile => 'Visir Pro needed';

  @override
  String get expired_description =>
      'Upgrade to Visir Pro to access every feature, connect your calendars and inboxes, and keep your day organized from one place.';

  @override
  String get expired_button => 'View plans';

  @override
  String get expired_button_mobile => 'Download for desktop';

  @override
  String get expired_you_are_logged_in_as => 'You’re logged in as';

  @override
  String get expired_you_are_logged_in_with_apple =>
      'You’re logged in with Apple';

  @override
  String get expired_log_out => 'Log out';

  @override
  String get expired_delete_account => 'Delete account';

  @override
  String get undo => 'Undo';

  @override
  String get task_deleted => 'Task deleted';

  @override
  String get task_undone => 'Task marked as undone';

  @override
  String get task_done => 'Task marked as done';

  @override
  String get event_deleted => 'Calendar event deleted';

  @override
  String get event_edited => 'Calendar event edited';

  @override
  String get take_a_tour => 'See how it works';

  @override
  String get tour_inbox_list_title => 'Smart Unified Inbox';

  @override
  String get tour_inbox_list_description =>
      'Integrated emails and chats are organized by date.\nAI Suggestions highlight what matters most, tagging items as Action Required, Need Review, Important, or Urgent.\nThey’re also classified as Tasks or Calendar Events, with time information extracted automatically.';

  @override
  String get tour_inbox_item_title => 'Inbox from Mail & Chat';

  @override
  String get tour_inbox_item_description =>
      'Your connected emails and chats, all in one place.\nClick to read, Reply to respond, Drag & Drop to turn into tasks or calendar events.';

  @override
  String get tour_inbox_item_description_mobile =>
      'Your connected emails and chats, all in one place.\nClick to read, Reply to respond, Long press then Drag & Drop to turn into tasks or calendar events.';

  @override
  String get tour_task_calendar_title => 'Task & Calendar';

  @override
  String get tour_task_calendar_description =>
      'See all your connected calendars and tasks in one view.\nDouble-click anywhere or drag on the screen to create a new task or calendar event instantly.';

  @override
  String get tour_task_on_calendar_title => 'Inbox Linked Tasks & Events';

  @override
  String get tour_task_on_calendar_description =>
      'Any task or calendar event you create from the inbox stays connected.\nYou can always see which mail or chat it came from.';

  @override
  String get tour_task_linked_mail_title => 'Quick Mail Access';

  @override
  String get tour_task_linked_mail_description =>
      'Click the 👁 button to instantly open the linked mail in a popup.';

  @override
  String get tour_task_linked_chat_title => 'Quick Chat Access';

  @override
  String get tour_task_linked_chat_description =>
      'Also, click the 👁 button to instantly open the linked chat in a popup.';

  @override
  String get tour_task_linked_mail_detail_title => 'Full Mail Experience';

  @override
  String get tour_task_linked_mail_detail_description =>
      'Read, reply, forward, and manage your emails.\nAll right from the Home tab.';

  @override
  String get tour_task_linked_chat_detail_title => 'Full Chat Experience';

  @override
  String get tour_task_linked_chat_detail_description =>
      'Read, reply, and keep your conversation context.\nAll without leaving the Home tab.';

  @override
  String get tour_task_tab_title => 'Task Tab';

  @override
  String get tour_task_tab_description =>
      'Manage all your tasks created in Visir with a familiar list view. Use filters like Unscheduled and Today to organize your tasks efficiently.';

  @override
  String get tour_mail_tab_title => 'Full-Featured Mail Tab';

  @override
  String get tour_mail_tab_description =>
      'Access all the essential features of a standard mail app—star, unread, trash, spam, and more—right from the Mail tab.';

  @override
  String get tour_chat_tab_title => 'Unified Chat Tab';

  @override
  String get tour_chat_tab_description =>
      'View and manage channels from multiple workspaces in one place. Stay on top of new messages, reply, and react with ease.';

  @override
  String get tour_calendar_tab_title => 'Comprehensive Calendar Tab';

  @override
  String get tour_calendar_tab_description =>
      'Manage your team’s calendars together and focus on your schedule, even without tasks. Enjoy a full-featured calendar experience.';

  @override
  String get tour_chat_create_task_title => 'Create Tasks or Events from Chat';

  @override
  String get tour_chat_create_task_description =>
      'Turn any chat message into a task or calendar event instantly. Just drag and drop or use the quick action button.';

  @override
  String get tour_mail_create_task_title => 'Create Tasks or Events from Mail';

  @override
  String get tour_mail_create_task_description =>
      'Easily convert any email into a task or calendar event. Stay organized by turning important messages into actionable items.';

  @override
  String get tour_inbox_list_subject =>
      'See all your emails and chats together, sorted by date with AI highlights.';

  @override
  String get tour_inbox_item_subject =>
      'Quickly access and manage your connected emails and chats in one inbox.';

  @override
  String get tour_task_calendar_subject =>
      'View all your calendars and tasks together, create new ones with a click or drag.';

  @override
  String get tour_task_on_calendar_subject =>
      'Tasks and events from the inbox stay linked to their original mail or chat.';

  @override
  String get tour_task_linked_mail_subject =>
      'Open linked emails instantly from any task or event.';

  @override
  String get tour_task_linked_chat_subject =>
      'Open linked chats instantly from any task or event.';

  @override
  String get tour_task_linked_mail_detail_subject =>
      'Read, reply, and manage emails directly from Home.';

  @override
  String get tour_task_linked_chat_detail_subject =>
      'Read and reply to chats without leaving Home.';

  @override
  String get tour_task_tab_subject =>
      'Organize and manage all your Visir tasks with filters and lists.';

  @override
  String get tour_mail_tab_subject =>
      'Use all standard mail features—star, unread, trash, spam—in the Mail tab.';

  @override
  String get tour_chat_tab_subject =>
      'Manage all your chat channels and messages from every workspace in one place.';

  @override
  String get tour_calendar_tab_subject =>
      'See and manage your team’s calendars and events in a full-featured calendar view.';

  @override
  String get tour_chat_create_task_subject =>
      'Turn any chat message into a task or event instantly.';

  @override
  String get tour_mail_create_task_subject =>
      'Convert any email into a task or event to stay organized.';

  @override
  String get tour_list_title => 'Play Showcase';

  @override
  String get default_task_before_signin_tour_title => '1. Start the Tour 🚀';

  @override
  String get default_task_before_signin_tour_desc =>
      'Click the \"See how it works\" button to take a quick tour of Visir.';

  @override
  String get default_task_before_signin_explore_title =>
      '2. Explore the Tabs 🗂️';

  @override
  String get default_task_before_signin_explore_desc =>
      'Check out the Home, Calendar, Inbox, and Settings tabs to get familiar with the layout.';

  @override
  String get default_task_before_signin_inbox_title =>
      '3. Create a Task from the Inbox ✉️➡️✅';

  @override
  String get default_task_before_signin_inbox_desc =>
      'Easily create a task by dragging and dropping directly from the Inbox.';

  @override
  String get default_task_before_signin_quickview_title =>
      '4. Open Quick View 👁️';

  @override
  String get default_task_before_signin_quickview_desc =>
      'Open your new task in Quick View to review details and reply.';

  @override
  String get default_task_before_signin_signin_title => '5. Sign In 🔑';

  @override
  String get default_task_before_signin_signin_desc =>
      'Sign in to start using Visir and unlock all features.';

  @override
  String get default_task_after_signin_connect_services_title =>
      '1. Connect Services 🔗';

  @override
  String get default_task_after_signin_connect_services_desc =>
      'Link email, Slack, and more to bring everything into Inbox.';

  @override
  String get default_task_after_signin_revisit_tabs_title =>
      '2. Revisit Tabs 🗂️';

  @override
  String get default_task_after_signin_revisit_tabs_desc =>
      'If you skipped earlier, check each tab now.';

  @override
  String get default_task_after_signin_schedule_ai_title => '3. Schedule AI 🤖';

  @override
  String get default_task_after_signin_schedule_ai_desc =>
      'Drag an AI suggestion onto your calendar.';

  @override
  String get default_task_after_signin_reply_in_quick_view_title =>
      '4. Reply in Quick View 👁️';

  @override
  String get default_task_after_signin_reply_in_quick_view_desc =>
      'Reply and manage checklists right inside Quick View.';

  @override
  String get default_task_after_signin_create_from_message_title =>
      '5. Create from Message ✉️➡️✅';

  @override
  String get default_task_after_signin_create_from_message_desc =>
      'Use Create Task in email/chat to make a task instantly.';

  @override
  String get default_task_after_signin_use_free_trial_title =>
      '6. Use Free Trial 🎁';

  @override
  String get default_task_after_signin_use_free_trial_desc =>
      'Enjoy all features free for 7 days.';

  @override
  String get default_task_near_trial_end_check_time_saved_title =>
      '1. Check Time Saved ⏳';

  @override
  String get default_task_near_trial_end_check_time_saved_desc =>
      'Open Time Saved to see how much time you saved.';

  @override
  String get default_task_near_trial_end_share_image_title =>
      '2. Share Image 🖼️';

  @override
  String get default_task_near_trial_end_share_image_desc =>
      'Generate and share the image on social.';

  @override
  String get default_task_near_trial_end_start_subscription_title =>
      '3. Start Subscription 🚀';

  @override
  String get default_task_near_trial_end_start_subscription_desc =>
      'Subscribe if it’s boosting your workflow.';

  @override
  String oauth_disconnected_title(Object provider) {
    return '$provider account disconnected';
  }

  @override
  String oauth_disconnected_description(Object email, Object provider) {
    return 'Lost access to $provider account ($email). Reconnect to continue syncing.';
  }

  @override
  String get oauth_disconnected_ignore => 'Ignore';

  @override
  String get oauth_disconnected_reconnect => 'Reconnect';

  @override
  String get linked_task_evnet => 'Linked tasks / events';

  @override
  String get search_timezone => 'Search timezone...';

  @override
  String get no_selection => 'No item selected yet';

  @override
  String get no_history => 'No history';

  @override
  String get no_inbox_matched_with_filter => 'No inboxes match your filter';

  @override
  String get viewtype_section => 'View type';

  @override
  String get search_tasks => 'Search tasks';

  @override
  String get search_events => 'Search calendar events';

  @override
  String get no_channel_selected => 'Select a channel to get started';

  @override
  String get muted => 'Muted';

  @override
  String get emailprovider => 'Email & Provider';

  @override
  String get manage_account => 'Manage account';

  @override
  String get current_subscription => 'Current subscription';

  @override
  String get available_plans => 'Available plans';

  @override
  String get per_month_billed_monthly => 'Per month,\nBilled monthly';

  @override
  String get per_month_billed_yearly => 'Per month,\nBilled yearly';

  @override
  String get no_chat_provider_integrated =>
      'You haven’t connected any chat accounts yet';

  @override
  String get last_opened_channel => 'Last checked';

  @override
  String get suggested_unread_channels => 'Last updated & unread';

  @override
  String updated_at(Object date) {
    return 'Updated at $date';
  }

  @override
  String last_seen_at(Object date) {
    return 'Last check at $date';
  }

  @override
  String get project => 'Project';

  @override
  String get default_pref => 'Defaults';

  @override
  String get pref_actions => 'Actions';

  @override
  String get secondary_timezone => 'Secondary timezone';

  @override
  String get no_integration_yet_for_inbox =>
      'You haven’t integrated any mail or chat accounts yet. Inbox will display important emails and messages once you connect your accounts.';

  @override
  String get integrate_new_accounts => 'Connect new accounts';

  @override
  String get no_integration_yet_for_mail =>
      'You haven’t connected any mail accounts yet';

  @override
  String get need_to_integrate_calendar => 'Connect calendars';

  @override
  String get opened => 'Opened';

  @override
  String get home_calendar_default_ratio => 'Home calendar split ratio';

  @override
  String get create_signautre => 'Create new';

  @override
  String get create_signature_title => 'Create new signature';

  @override
  String get edit_signature_title => 'Edit signature';

  @override
  String get project_pref_title => 'Project';

  @override
  String get project_pref_structures => 'Manage projects';

  @override
  String get press_back_button => 'Press back button again to exit';

  @override
  String get create_new_project => 'New project';

  @override
  String get create_new_project_description => 'Add description';

  @override
  String get confirm_delete_project =>
      'Are you sure you want to delete this project? Items under project will be moved to default project.';

  @override
  String get default_project => 'Default project';

  @override
  String get hide_tab => 'Hide tab';

  @override
  String get task_section_braindump => 'Braindump';

  @override
  String get task_section_unscheduled => 'Unscheduled';

  @override
  String get dump_ideas_from_brain => 'Capture your thoughts';

  @override
  String get add_unscheduled_task => 'Add unscheduled task';

  @override
  String get agentic_home_hi => 'Hello, ';

  @override
  String agentic_home_summary_action_required(Object count) {
    return 'You have $count inboxes that need action in the last 24 hours';
  }

  @override
  String agentic_home_summary_events(Object eventCount, Object taskCount) {
    return 'You have $eventCount events and $taskCount tasks in the last 24 hours';
  }

  @override
  String agentic_home_summary_only_events(Object eventCount) {
    return 'You have $eventCount events in the last 24 hours';
  }

  @override
  String agentic_home_summary_only_tasks(Object taskCount) {
    return 'You have $taskCount tasks in the last 24 hours';
  }

  @override
  String get agentic_home_summary_all_clear => 'You\'re all caught up!';

  @override
  String get no_suggested_schedule => 'No schedule suggested';

  @override
  String get inbox_home_type => 'Home Mode';

  @override
  String get inbox_agent_type => 'Agent';

  @override
  String get inbox_manual_type => 'Helper';

  @override
  String get inbox_agent_loading =>
      'I\'m checking your inboxes from the last 24 hours';

  @override
  String inbox_agent_loading_dynamic(String duration) {
    return 'I\'m checking your inboxes from the last $duration';
  }

  @override
  String agentic_home_summary_action_required_dynamic(
    int count,
    String duration,
  ) {
    return 'You have $count inboxes that need action in the last $duration';
  }

  @override
  String agentic_home_summary_events_dynamic(
    int eventCount,
    int taskCount,
    String duration,
  ) {
    return 'You have $eventCount events and $taskCount tasks in the last $duration';
  }

  @override
  String agentic_home_summary_only_events_dynamic(
    int eventCount,
    String duration,
  ) {
    return 'You have $eventCount events in the last $duration';
  }

  @override
  String agentic_home_summary_only_tasks_dynamic(
    int taskCount,
    String duration,
  ) {
    return 'You have $taskCount tasks in the last $duration';
  }

  @override
  String duration_day(int count) {
    return '$count day';
  }

  @override
  String duration_days(int count) {
    return '$count days';
  }

  @override
  String get no_project_suggested => 'No Project';

  @override
  String get agent_select_model_hint => 'Change agent model';

  @override
  String get agent_suggested_actions_hint => 'Suggested actions';

  @override
  String get agent_use_taskey_api_key => 'With Visir API Key';

  @override
  String get agent_use_user_api_key => 'With User API Key';

  @override
  String get agent_select_project_hint => 'Add project based context';

  @override
  String get agent_select_project_remove => 'Remove project base context';

  @override
  String daily_summary_greeting(String timeOfDay) {
    return 'Good $timeOfDay. Here is your daily summary';
  }

  @override
  String daily_summary_project_greeting(String projectName) {
    return 'Here is $projectName summary for today';
  }

  @override
  String get morning => 'Morning';

  @override
  String get afternoon => 'Afternoon';

  @override
  String get evening => 'Evening';

  @override
  String get night => 'Night';

  @override
  String get dawn => 'Dawn';

  @override
  String get user => 'User';

  @override
  String daily_summary_overdue_tasks(int count, String plural) {
    return 'I found $count overdue task$plural that need your attention right away';
  }

  @override
  String daily_summary_meeting_invitation(int count, String plural) {
    return 'You\'ve got $count meeting invitation$plural waiting for your response';
  }

  @override
  String daily_summary_meeting_followup(
    int count,
    String plural,
    String isAre,
  ) {
    return 'There $isAre $count meeting$plural that need follow-up';
  }

  @override
  String daily_summary_meeting_notes(int count, String plural) {
    return 'You\'ve got $count meeting note$plural to check out';
  }

  @override
  String daily_summary_task_assignment(int count, String plural, String isAre) {
    return 'There $isAre $count task$plural assigned to you';
  }

  @override
  String daily_summary_task_status_update(int count, String plural) {
    return 'You\'ve got $count task$plural with status updates to review';
  }

  @override
  String daily_summary_scheduling_request(
    int count,
    String plural,
    String isAre,
  ) {
    return 'There $isAre $count scheduling request$plural waiting for your decision';
  }

  @override
  String daily_summary_scheduling_confirmation(int count, String plural) {
    return 'You\'ve got $count scheduling confirmation$plural to confirm';
  }

  @override
  String daily_summary_document_review(int count, String plural, String isAre) {
    return 'There $isAre $count document$plural waiting for you to review';
  }

  @override
  String daily_summary_code_review(int count, String plural) {
    return 'You\'ve got $count code review$plural waiting';
  }

  @override
  String daily_summary_approval_request(
    int count,
    String plural,
    String isAre,
  ) {
    return 'There $isAre $count approval request$plural that need your sign-off';
  }

  @override
  String daily_summary_question(int count, String plural, String needs) {
    return 'You\'ve got $count question$plural that need$needs an answer';
  }

  @override
  String daily_summary_information_sharing(
    int count,
    String plural,
    String isAre,
  ) {
    return 'There $isAre $count item$plural with important info to check out';
  }

  @override
  String daily_summary_announcement(int count, String plural) {
    return 'You\'ve got $count announcement$plural to check out';
  }

  @override
  String daily_summary_system_notification(
    int count,
    String plural,
    String isAre,
  ) {
    return 'There $isAre $count system notification$plural that might need your attention';
  }

  @override
  String daily_summary_cold_contact(int count, String plural) {
    return 'You\'ve got $count message$plural from new contacts';
  }

  @override
  String daily_summary_customer_contact(
    int count,
    String plural,
    String isAre,
  ) {
    return 'There $isAre $count customer inquiry$plural that need your response';
  }

  @override
  String daily_summary_other(int count, String plural) {
    return 'You\'ve got $count item$plural to check out';
  }

  @override
  String daily_summary_action_items(int count, String plural) {
    return 'You\'ve got $count action item$plural waiting';
  }

  @override
  String daily_summary_review_items(int count, String plural, String isAre) {
    return 'There $isAre $count item$plural for you to review when you have time';
  }

  @override
  String get daily_summary_schedule_clear => 'Your schedule is clear for today';

  @override
  String daily_summary_schedule_today(
    int eventCount,
    int taskCount,
    String eventPlural,
    String taskPlural,
  ) {
    return 'Today, you have $eventCount event$eventPlural and $taskCount task$taskPlural scheduled';
  }

  @override
  String get daily_summary_cross_inbox_highlights => 'Cross-Inbox Highlights';

  @override
  String get daily_summary_inbox_highlights => 'Inbox Highlights';

  @override
  String get daily_summary_urgent_overdue => 'Urgent & Overdue';

  @override
  String get daily_summary_overdue => 'Overdue';

  @override
  String get daily_summary_no_urgent_items => 'No urgent items';

  @override
  String get daily_summary_no_actions_pending => 'No actions pending';

  @override
  String get daily_summary_no_inbox_highlights =>
      'No inbox items need attention yet';

  @override
  String get daily_summary_no_inbox_highlights_friendly =>
      'All clear! Nothing needs your attention right now.';

  @override
  String get daily_summary_reading_previous_conversations =>
      'Reading previous conversations...';

  @override
  String get daily_summary_for_review => 'For Review';

  @override
  String get daily_summary_nothing_to_review => 'Nothing to review';

  @override
  String get daily_summary_schedule_overview => 'Schedule Overview';

  @override
  String get daily_summary_todays_remaining => 'Today\'s Remaining';

  @override
  String get daily_summary_no_more_events_today => 'No more events today';

  @override
  String get daily_summary_check_tomorrow_schedule =>
      'Check your calendar for tomorrow\'s schedule.';

  @override
  String get daily_summary_ai_synthesis => 'AI Synthesis';

  @override
  String get daily_summary_synthesis_label => 'Synthesis: ';

  @override
  String daily_summary_synthesis_urgent(int overdueCount, int urgentCount) {
    return 'Your primary focus today should be resolving $overdueCount overdue tasks and addressing $urgentCount urgent inbox items.';
  }

  @override
  String get daily_summary_synthesis_caught_up =>
      'You are caught up on urgent matters.';

  @override
  String daily_summary_synthesis_events_today(int eventCount) {
    return 'You have $eventCount events scheduled today.';
  }

  @override
  String get daily_summary_synthesis_schedule_clear =>
      'Your schedule is clear today.';

  @override
  String get daily_summary_next_schedule => 'Next Schedule';

  @override
  String get daily_summary_up_next => 'Up Next';

  @override
  String get daily_summary_previous_context => 'Previous Context';

  @override
  String get daily_summary_previously_completed_tasks =>
      'Previously Completed Tasks';

  @override
  String get daily_summary_anytime => 'Anytime';

  @override
  String get daily_summary_min => 'min';

  @override
  String get daily_summary_overdue_task => 'Overdue Task';

  @override
  String get daily_summary_move_to_today => 'Reschedule';

  @override
  String get daily_summary_inbox => 'Inbox';

  @override
  String get daily_summary_unknown => 'Unknown';

  @override
  String get agent_action_error_occurred =>
      'An error occurred. Please try again.';

  @override
  String get agent_action_mail_generation_failed =>
      'Failed to generate email. Please try again.';

  @override
  String get agent_action_mail_generated =>
      'Reply email has been generated. Please review and send.';

  @override
  String get agent_action_action_not_supported =>
      'This action type is not yet supported.';

  @override
  String get agent_action_starting_action => 'Starting action.';

  @override
  String agent_action_reply_initial_message(String contextInfo) {
    return 'I\'ll help you write a reply to the following email. Please tell me how you\'d like to respond in natural language.\n\n$contextInfo\n\nHow would you like to reply? For example:\n- \"Thank them for the email\"\n- \"Let them know I\'m available tomorrow at 2 PM\"\n- \"Provide a detailed explanation about the inquiry\"\nPlease make your request in this format.';
  }

  @override
  String agent_action_reply_suggested_response(String suggestedResponse) {
    return 'Here\'s a suggested reply:\n\n$suggestedResponse\n\nHow would you like to modify it? For example:\n- \"Make it more formal\"\n- \"Add a question about their availability\"\n- \"Shorten it\"\nPlease tell me how you\'d like to adjust the reply.';
  }

  @override
  String agent_action_create_task_initial_message(String contextInfo) {
    return 'I\'ll help you create a task from the following inbox item. Please tell me how you\'d like to customize it.\n\n$contextInfo\n\nHow would you like to create the task? For example:\n- \"Set the due date to tomorrow\"\n- \"Add it to the Marketing project\"\n- \"Make the title more specific\"\nPlease make your request in this format.';
  }

  @override
  String agent_action_create_task_suggested_response(String suggestedTask) {
    return '<div>Here\'s a suggested task:</div><br>$suggestedTask<br><div>Would you like to create this task as is, or would you like to make changes? If you\'d like to make changes, please tell me what you\'d like to modify.</div>';
  }

  @override
  String get agent_action_task_generation_failed =>
      'Failed to generate task. Please try again.';

  @override
  String get agent_action_task_created => 'Task has been created successfully.';

  @override
  String get agent_action_loading_thinking => 'Thinking...';

  @override
  String get agent_action_loading_processing_request =>
      'Processing your request...';

  @override
  String get agent_action_loading_creating_task => 'Creating task...';

  @override
  String get agent_action_loading_saving_task_details =>
      'Saving task details...';

  @override
  String get agent_action_loading_finalizing_task => 'Finalizing task...';

  @override
  String get agent_action_loading_updating_task_details =>
      'Updating task details...';

  @override
  String get agent_action_loading_modifying_task_info =>
      'Modifying task information...';

  @override
  String get agent_action_loading_adjusting_task_params =>
      'Adjusting task parameters...';

  @override
  String get agent_action_loading_analyzing_inbox => 'Analyzing inbox item...';

  @override
  String get agent_action_loading_generating_task_details =>
      'Generating task details...';

  @override
  String get agent_action_loading_preparing_task_info =>
      'Preparing task information...';

  @override
  String get agent_action_loading_updating_reply_draft =>
      'Updating reply draft...';

  @override
  String get agent_action_loading_modifying_email_content =>
      'Modifying email content...';

  @override
  String get agent_action_loading_adjusting_response => 'Adjusting response...';

  @override
  String get agent_action_loading_analyzing_email =>
      'Analyzing email content...';

  @override
  String get agent_action_loading_drafting_reply => 'Drafting reply...';

  @override
  String get agent_action_loading_generating_response =>
      'Generating response...';

  @override
  String get agent_action_loading_creating_event => 'Creating event...';

  @override
  String get agent_action_loading_saving_event_details =>
      'Saving event details...';

  @override
  String get agent_action_loading_finalizing_event => 'Finalizing event...';

  @override
  String get agent_action_loading_updating_event_details =>
      'Updating event details...';

  @override
  String get agent_action_loading_modifying_event_info =>
      'Modifying event information...';

  @override
  String get agent_action_loading_adjusting_event_params =>
      'Adjusting event parameters...';

  @override
  String get agent_action_loading_generating_event_details =>
      'Generating event details...';

  @override
  String get agent_action_loading_preparing_event_info =>
      'Preparing event information...';

  @override
  String get agent_action_loading_analyzing_info => 'Analyzing information...';

  @override
  String get ai_credits_title => 'AI Credits';

  @override
  String get ai_credits_purchase => 'Purchase';

  @override
  String get ai_credits_history => 'History';

  @override
  String get ai_credits_current_tokens => 'Current Tokens';

  @override
  String get ai_credits_purchase_packages => 'Credit Packages';

  @override
  String get ai_credits_best_value => 'Best Value';

  @override
  String get ai_credits_tokens => 'tokens';

  @override
  String get ai_credits_buy => 'Buy';

  @override
  String get ai_credits_history_empty => 'No usage history';

  @override
  String get ai_credits_purchase_coming_soon =>
      'Credit purchase will be available soon';

  @override
  String get ai_credits_insufficient => 'Insufficient credits';

  @override
  String ai_credits_insufficient_message(String required, String available) {
    return 'You need $required tokens but only have $available tokens available.';
  }

  @override
  String get ai_credits_purchase_now => 'Purchase Credits';

  @override
  String get ai_credits_purchase_on_desktop =>
      'You can purchase credits on the desktop version';

  @override
  String agent_action_task_proposal_message(
    String title,
    String description,
    String project,
    String startTime,
  ) {
    return 'I can create a task with the following details:\n\n**Title**: $title\n$description**Project**: $project\n$startTime\n\nPlease confirm if you\'d like me to create this task, or let me know if you\'d like to make any changes.';
  }

  @override
  String get agent_action_send_initial_message =>
      'Please provide the following information to send an email:\n- To recipients (required)\n- CC recipients (optional)\n- BCC recipients (optional)\n- Subject/title (required)\n- Body/content (required)\n\nYou can provide email addresses or names.';

  @override
  String get agent_action_send_request_message => 'Send an email';

  @override
  String get agent_action_email_thread_summary =>
      'Here\'s a summary of the email thread:';

  @override
  String get agent_action_suggested_reply => 'Here\'s a suggested reply:';

  @override
  String get agent_action_send_confirmation =>
      'Would you like to send this as is, or would you like me to modify it?';

  @override
  String get agent_action_reply_all_suggestion =>
      'Note: This email has CC recipients. Would you like to use \"Reply All\" instead?';

  @override
  String get agent_action_suggested_email => 'Here\'s a suggested email:';

  @override
  String get agent_action_see_full_email =>
      'To see full email rather than snippet, click';

  @override
  String get agent_action_no_email_account_configured =>
      'No email account configured. Please configure an email account first.';

  @override
  String get agent_action_no_email_account_available =>
      'No email account available.';

  @override
  String get agent_action_forward_preview => 'Here\'s the forward:';

  @override
  String get agent_action_forward_confirmation =>
      'Would you like to forward this email as is, or would you like to add a message? If you\'d like to add a message, please let me know what you\'d like to include.';

  @override
  String get agent_action_forwarding_as_is => 'Forwarding the email as is:';

  @override
  String get agent_action_send_forward_confirmation =>
      'Would you like to send this forward?';

  @override
  String get agent_action_suggested_forward => 'Here\'s a suggested forward:';

  @override
  String get agent_action_task_prepared_for_confirmation =>
      'A new task has been prepared from the inbox item and is waiting for your confirmation. Once you confirm, it will be created in your tasks.';

  @override
  String get agent_action_event_prepared_for_confirmation =>
      'A new event has been prepared from the inbox item and is waiting for your confirmation. Once you confirm, it will be created in your calendar.';

  @override
  String get agent_action_mail_prepared_for_confirmation =>
      'A new email has been prepared and is waiting for your confirmation. Once you confirm, it will be sent.';

  @override
  String get agent_action_prepared_for_confirmation =>
      'An action has been prepared and is waiting for your confirmation. Once you confirm, it will be executed.';

  @override
  String get agent_action_reply_fallback_message =>
      'Please write a reply to this email.';

  @override
  String get agent_action_reply_fallback_message_no_inbox =>
      'Please write a reply to the email.';

  @override
  String get agent_action_reply_request_message => 'Reply to this email';

  @override
  String get agent_action_reply_request_message_no_inbox =>
      'Reply to the email';

  @override
  String get agent_action_forward_fallback_message =>
      'Please forward this email.';

  @override
  String get agent_action_forward_fallback_message_no_inbox =>
      'Please forward the email.';

  @override
  String get agent_action_forward_request_message => 'Forward this email';

  @override
  String get agent_action_forward_request_message_no_inbox =>
      'Forward the email';

  @override
  String get agent_action_create_task_fallback_from_mail =>
      'Please create a task based on this email.';

  @override
  String get agent_action_create_task_fallback_from_inbox =>
      'Please create a task based on this inbox item.';

  @override
  String get agent_action_create_task_fallback_no_inbox =>
      'Please create a task.';

  @override
  String get agent_action_create_task_request_message =>
      'Create a task from this inbox item';

  @override
  String get agent_action_create_task_request_message_no_inbox =>
      'Create a task';

  @override
  String get agent_action_create_event_fallback_from_mail =>
      'Please create an event based on this email.';

  @override
  String get agent_action_create_event_fallback_from_inbox =>
      'Please create an event based on this inbox item.';

  @override
  String get agent_action_create_event_fallback_no_inbox =>
      'Please create an event.';

  @override
  String get agent_action_create_event_request_message =>
      'Create an event from this inbox item';

  @override
  String get agent_action_create_event_request_message_no_inbox =>
      'Create an event';

  @override
  String get agent_action_confirm_send_mail =>
      'Would you like to send the following email?';

  @override
  String get agent_action_confirm_reply_mail =>
      'Would you like to send a reply to this email?';

  @override
  String get agent_action_confirm_forward_mail =>
      'Would you like to forward this email?';

  @override
  String get agent_action_confirm_delete_task =>
      'Would you like to delete this task?';

  @override
  String get agent_action_confirm_delete_event =>
      'Would you like to delete this event?';

  @override
  String get agent_action_confirm_delete_mail =>
      'Would you like to delete this email?';

  @override
  String get agent_action_confirm_update_task =>
      'Would you like to update this task?';

  @override
  String get agent_action_confirm_update_event =>
      'Would you like to update this event?';

  @override
  String get agent_action_confirm_mark_mail_read =>
      'Would you like to mark this email as read?';

  @override
  String get agent_action_confirm_mark_mail_unread =>
      'Would you like to mark this email as unread?';

  @override
  String get agent_action_confirm_archive_mail =>
      'Would you like to archive this email?';

  @override
  String agent_action_confirm_response_calendar_invitation(String response) {
    return 'Would you like to respond to the calendar invitation with \"$response\"?';
  }

  @override
  String get agent_action_confirm_create_task =>
      'Would you like to create the following task?';

  @override
  String get agent_action_confirm_create_event =>
      'Would you like to create the following event?';

  @override
  String get agent_action_confirm_execute_action =>
      'Would you like to execute this action?';

  @override
  String agent_action_confirm_title(String title) {
    return 'Title: $title';
  }

  @override
  String agent_action_confirm_time(String startTime, String endTime) {
    return 'Time: $startTime$endTime';
  }

  @override
  String get agent_action_confirm_recipient_to => 'To';

  @override
  String get agent_action_confirm_recipient_cc => 'CC';

  @override
  String get agent_action_confirm_recipient_bcc => 'BCC';

  @override
  String get agent_action_task_completed => 'Task completed successfully.';

  @override
  String get agent_action_error_occurred_during_execution =>
      'An error occurred during task execution.';

  @override
  String agent_action_error_occurred_during_execution_with_function(
    String functionName,
    String error,
  ) {
    return '$functionName: An error occurred during task execution: $error';
  }

  @override
  String agent_action_tasks_completed_count(int count, String details) {
    return '$count tasks completed:\n$details';
  }

  @override
  String agent_action_error_occurred_with_details(String details) {
    return 'An error occurred during task execution:\n$details';
  }

  @override
  String get agent_action_partial_completion => 'Some tasks completed:\n';

  @override
  String agent_action_success_section(String details) {
    return 'Success:\n$details';
  }

  @override
  String agent_action_failure_section(String details) {
    return 'Failure:\n$details';
  }

  @override
  String get agent_tag_section_task => 'Task';

  @override
  String get agent_tag_section_event => 'Event';

  @override
  String get agent_tag_section_connections => 'Connections';

  @override
  String get loading => 'Loading...';

  @override
  String get chat_history => 'Chat History';

  @override
  String get chat_history_search_hint => 'Search history...';

  @override
  String get chat_history_conversation_start => 'Conversation start';

  @override
  String chat_history_messages_count(int count) {
    return '$count messages';
  }

  @override
  String get chat_history_load_error =>
      'An error occurred while loading history';

  @override
  String get chat_history_filter_all => 'All';

  @override
  String get chat_history_filter_unknown => 'Unknown';

  @override
  String get chat_history_sort_updated_desc => 'Newest';

  @override
  String get chat_history_sort_updated_asc => 'Oldest';

  @override
  String get chat_history_sort_message_count_desc => 'Most messages';

  @override
  String get chat_history_sort_message_count_asc => 'Fewest messages';

  @override
  String get mcp_previous_context_not_available =>
      'No previous context available';

  @override
  String get mcp_previous_context_retrieved => 'Previous context retrieved';

  @override
  String get mcp_failed_to_get_previous_context =>
      'Failed to get previous context';

  @override
  String get mcp_mail_info_retrieved => 'Mail information retrieved';

  @override
  String mcp_found_mails(int count) {
    return '$count mail(s) found';
  }

  @override
  String get mcp_message_info_retrieved => 'Message information retrieved';

  @override
  String get mcp_unknown_user => 'Unknown user';

  @override
  String get mcp_unknown_channel => 'Unknown channel';

  @override
  String mcp_found_messages(int count) {
    return '$count message(s) found';
  }

  @override
  String mcp_tasks_today(int count) {
    return '$count task(s) today';
  }

  @override
  String mcp_events_today(int count) {
    return '$count event(s) today';
  }

  @override
  String get mcp_inbox_info_retrieved => 'Inbox information retrieved';

  @override
  String mcp_found_inboxes(int count) {
    return '$count inbox(es) found';
  }

  @override
  String get mcp_project_info_retrieved => 'Project information retrieved';

  @override
  String mcp_tasks_rescheduled(int count) {
    return '$count task(s) rescheduled to today at appropriate times';
  }

  @override
  String mcp_found_projects(int count) {
    return '$count project(s) found';
  }

  @override
  String mcp_found_tasks(int count) {
    return '$count task(s) found';
  }

  @override
  String mcp_found_events(int count) {
    return '$count event(s) found';
  }

  @override
  String get mcp_task_info_retrieved => 'Task information retrieved';

  @override
  String get mcp_event_info_retrieved => 'Event information retrieved';

  @override
  String mcp_found_calendars(int count) {
    return '$count calendar(s) found';
  }

  @override
  String mcp_found_inbox_items(int count) {
    return '$count inbox item(s) found';
  }

  @override
  String mcp_found_labels(int count) {
    return '$count label(s) found';
  }

  @override
  String mcp_found_attachments(int count) {
    return '$count attachment(s) found';
  }

  @override
  String mcp_found_upcoming_tasks(int count) {
    return '$count upcoming task(s) found';
  }

  @override
  String mcp_found_upcoming_events(int count) {
    return '$count upcoming event(s) found';
  }

  @override
  String mcp_found_overdue_tasks(int count) {
    return '$count overdue task(s) found';
  }

  @override
  String mcp_found_unscheduled_tasks(int count) {
    return '$count unscheduled task(s) found';
  }

  @override
  String mcp_found_completed_tasks(int count) {
    return '$count completed task(s) found';
  }
}
