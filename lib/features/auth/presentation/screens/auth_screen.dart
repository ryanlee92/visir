import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math';

import 'package:Visir/config/providers.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/auth/presentation/screens/email_confirm_screen.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/log_event.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/custom_circualr_loading_indicator.dart';
import 'package:Visir/features/common/presentation/widgets/keyboard_shortcut.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/feedback/application/feedback_controller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:crypto/crypto.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart' as sa;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

enum LoginType { google, apple, email }

extension LoginTypeX on LoginType {
  String get id {
    switch (this) {
      case LoginType.google:
        return 'google';
      case LoginType.apple:
        return 'apple';
      case LoginType.email:
        return 'email';
    }
  }

  String getLogoPath(BuildContext context) {
    switch (this) {
      case LoginType.google:
        return '${(kDebugMode && kIsWeb) ? "" : "assets/"}icons/icon_google.png';
      case LoginType.apple:
        return '${(kDebugMode && kIsWeb) ? "" : "assets/"}icons/icon_apple${context.isDarkMode ? '' : '_dark'}.png';
      case LoginType.email:
        return '${(kDebugMode && kIsWeb) ? "" : "assets/"}icons/icon_email${context.isDarkMode ? '' : '_dark'}.png';
    }
  }

  String getTitle(BuildContext context) {
    switch (this) {
      case LoginType.google:
        return context.tr.onboarding_continue_with_google;
      case LoginType.apple:
        return context.tr.onboarding_continue_with_apple;
      case LoginType.email:
        return context.tr.onboarding_continue_with_email;
    }
  }
}

enum EmailAuthExceptionType { emailAddressInvalid, emailExists, emailNotConfirmed, overEmailSendRateLimit, unknown }

extension EmailAuthExceptionTypeX on EmailAuthExceptionType {
  String get id {
    switch (this) {
      case EmailAuthExceptionType.emailAddressInvalid:
        return 'email_address_invalid';
      case EmailAuthExceptionType.emailExists:
        return 'email_exists';
      case EmailAuthExceptionType.emailNotConfirmed:
        return 'email_not_confirmed';
      case EmailAuthExceptionType.overEmailSendRateLimit:
        return 'over_email_send_rate_limit';
      case EmailAuthExceptionType.unknown:
        return 'unknown';
    }
  }

  String getMessage(BuildContext context) {
    switch (this) {
      case EmailAuthExceptionType.emailAddressInvalid:
        return context.tr.onboarding_email_sign_up_failed_email_address_invalid;
      case EmailAuthExceptionType.emailExists:
        return context.tr.onboarding_email_sign_up_failed_email_exists;
      case EmailAuthExceptionType.emailNotConfirmed:
        return context.tr.onboarding_email_sign_up_failed_email_not_confirmed;
      case EmailAuthExceptionType.overEmailSendRateLimit:
        return context.tr.onboarding_email_sign_up_failed_over_email_send_rate_limit;
      case EmailAuthExceptionType.unknown:
        return context.tr.onboarding_email_sign_up_failed;
    }
  }
}

class AuthScreen extends ConsumerStatefulWidget {
  /// Named route for [AuthScreen]
  static const String route = 'auth';
  final LoginType? loginType;

  const AuthScreen({super.key, this.loginType});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();

  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  final usernameFocusNode = FocusNode();

  String tosButtonId = 'tos';
  String privacyButtonId = 'privacy';
  String returnToLoginOptionsButtonId = 'return';
  String forgotPasswordButtonId = 'forgot';
  String signUpButtonId = 'signup';
  String emailTextFieldId = 'email';
  String passwordTextFieldId = 'password';
  String usernameTextFieldId = 'username';
  String emailColoredButtonId = 'emailColoredButton';
  String returnToSignInButtonId = 'returnToSignIn';

  String? resetPasswordErrorMessage;

  bool onLoading = false;
  bool isOnLoginWithEmail = false;
  bool isOnSignupWithEmail = false;
  bool isOnForgotPassword = false;
  bool? isEmailValid;
  bool? isPasswordValid;
  bool? isUsernameValid;
  bool? isEmailLoginFailed;
  bool? isEmailSignupFailed;
  bool? resetPasswordMailSentFailed;

  EmailAuthExceptionType? emailAuthExceptionType;

  String? get redirectUrl => kIsWeb
      ? kDebugMode
            ? 'http://localhost:7357/auth'
            : 'https://visir.pro/auth'
      : 'com.wavetogether.fillin://login-callback/';

  @override
  void initState() {
    super.initState();
    emailFocusNode.addListener(() {
      setState(() {});
    });
    passwordFocusNode.addListener(() {
      setState(() {});
    });
    usernameFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    usernameFocusNode.dispose();
    super.dispose();
  }

  /// Method when sign in failed
  Future<void> onFailedSignIn(WidgetRef ref, Object error) async {
    try {
      await ref.read(authControllerProvider.notifier).onSignInFailed(error);
    } catch (e) {
      developer.log(e.toString());
    }
  }

  String _generateRandomString() {
    final random = Random.secure();
    return base64Url.encode(List<int>.generate(16, (_) => random.nextInt(256)));
  }

  Future<void> signInWithApple() async {
    if (onLoading) return;
    setState(() {
      onLoading = true;
    });
    logAnalyticsEvent(eventName: 'onboarding_apple');

    try {
      if (PlatformX.isWeb || PlatformX.isWindows || PlatformX.isLinux || PlatformX.isAndroid || PlatformX.isMacOS) {
        await Supabase.instance.client.auth.signInWithOAuth(
          OAuthProvider.apple,
          redirectTo: redirectUrl,
          authScreenLaunchMode: kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication,
        );
      } else {
        final rawNonce = _generateRandomString();
        final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

        final credential = await sa.SignInWithApple.getAppleIDCredential(scopes: [sa.AppleIDAuthorizationScopes.email, sa.AppleIDAuthorizationScopes.fullName], nonce: hashedNonce);

        final idToken = credential.identityToken;
        if (idToken == null) {
          throw 'Could not find ID Token from generated credential.';
        }

        await Supabase.instance.client.auth.signInWithIdToken(provider: OAuthProvider.apple, idToken: idToken, nonce: rawNonce);
      }
      await ref.read(authControllerProvider.notifier).onSignInSuccess();
    } catch (e) {
      developer.log(e.toString());
    }

    if (mounted) {
      setState(() {
        onLoading = false;
      });
    }
  }

  Future<void> signInWithGoogle() async {
    if (onLoading) return;
    setState(() {
      onLoading = true;
    });

    logAnalyticsEvent(eventName: 'onboarding_google');

    try {
      if (PlatformX.isWeb || PlatformX.isWindows || PlatformX.isLinux) {
        await Supabase.instance.client.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: redirectUrl,
          authScreenLaunchMode: kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication,
        );
      } else {
        final auth = await GoogleSignIn.instance.authenticate();
        final idToken = auth.authentication.idToken;

        if (idToken == null) {
          throw 'No ID Token found.';
        }

        await Supabase.instance.client.auth.signInWithIdToken(provider: OAuthProvider.google, idToken: idToken);
      }
      await ref.read(authControllerProvider.notifier).onSignInSuccess();
    } catch (e) {
      developer.log(e.toString());
    }

    if (mounted) {
      setState(() {
        onLoading = false;
      });
    }
  }

  Future<void> signInWithEmail() async {
    bool validateResult = validateInputFields();

    if (!validateResult) return;

    if (onLoading) return;
    setState(() {
      onLoading = true;
    });

    logAnalyticsEvent(eventName: 'onboarding_email');

    try {
      if (isOnSignupWithEmail) {
        final response = await Supabase.instance.client.auth.signUp(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
          emailRedirectTo: redirectUrl,
          data: {'username': usernameController.text.trim()},
        );

        if (response.user?.identities?.isEmpty ?? false) {
          throw AuthException(EmailAuthExceptionType.emailExists.name, code: EmailAuthExceptionType.emailExists.id);
        } else {
          logAnalyticsEvent(eventName: 'signup_email_waiting_confirm');
          Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (context) => EmailConfirmScreen(email: emailController.text.trim(), password: passwordController.text.trim()),
              settings: RouteSettings(name: EmailConfirmScreen.routeName),
            ),
          );
        }
      } else {
        await Supabase.instance.client.auth.signInWithPassword(email: emailController.text.trim(), password: passwordController.text.trim());

        try {
          await ref.read(authControllerProvider.notifier).onSignInSuccess();
        } catch (e) {
          developer.log(e.toString());
          logAnalyticsEvent(eventName: 'login_email_fail');
        }
      }
    } on AuthException catch (e) {
      if (isOnSignupWithEmail) {
        isEmailSignupFailed = true;
        emailAuthExceptionType = EmailAuthExceptionType.values.where((v) => v.id == e.code).firstOrNull ?? EmailAuthExceptionType.unknown;
      } else {
        isEmailLoginFailed = true;
      }
      setState(() {});
      onFailedSignIn(ref, e);
      Utils.reportAutoFeedback(errorMessage: 'on AuthException / isOnSignupWithEmail ${isOnSignupWithEmail} / ${e.toString()}');
      logAnalyticsEvent(eventName: 'login_email_fail');
    } catch (e) {
      onFailedSignIn(ref, e);
      Utils.reportAutoFeedback(errorMessage: 'isOnSignupWithEmail ${isOnSignupWithEmail} / ${e.toString()}');
      logAnalyticsEvent(eventName: 'login_email_fail');
    }

    if (mounted) {
      setState(() {
        onLoading = false;
      });
    }
  }

  Future<void> sendPassWordResetEmail() async {
    bool validateResult = validateInputFields();
    if (!validateResult) return;

    if (onLoading) return;
    setState(() {
      onLoading = true;
    });

    final email = emailController.text.trim();
    final isUserExist = await ref.read(authControllerProvider.notifier).checkUserExistByEmail(email: email);

    if (!isUserExist) {
      setState(() {
        resetPasswordMailSentFailed = true;
        resetPasswordErrorMessage = context.tr.onboarding_password_reset_email_failed;
      });
    } else {
      try {
        await Supabase.instance.client.auth.resetPasswordForEmail(email);
        setState(() {
          resetPasswordMailSentFailed = false;
        });
      } on AuthException catch (error) {
        setState(() {
          resetPasswordMailSentFailed = true;
          resetPasswordErrorMessage = context.tr.onboarding_email_sending_error;
        });
        developer.log(error.toString());
      } catch (error) {
        setState(() {
          resetPasswordMailSentFailed = true;
          resetPasswordErrorMessage = context.tr.onboarding_email_sending_error;
        });
      }
    }

    if (mounted) {
      setState(() {
        onLoading = false;
      });
    }
  }

  Widget loginButton({required BuildContext context, required LoginType type, required Future<void> Function() onTap}) {
    final isMobileView = PlatformX.isMobileView;

    return VisirButton(
      key: UniqueKey(),
      type: VisirButtonAnimationType.scaleAndOpacity,
      style: VisirButtonStyle(
        margin: isMobileView ? EdgeInsets.symmetric(horizontal: 16) : EdgeInsets.zero,
        borderRadius: BorderRadius.circular(12),
        backgroundColor: context.surface,
        height: 48,
        width: isMobileView ? double.maxFinite : 360,
        alignment: Alignment.center,
        cursor: SystemMouseCursors.click,
      ),
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (type == LoginType.email)
            VisirIcon(type: VisirIconType.mail, size: 20, color: context.outlineVariant, isSelected: true)
          else
            Image.asset(type.getLogoPath(context), width: 20, height: 20),
          const SizedBox(width: 12),
          Text(type.getTitle(context), style: context.titleSmall?.textColor(context.outlineVariant)),
        ],
      ),
    );
  }

  Widget coloredButton({required String text, required String id, required Future<void> Function() onTap, required bool? isFailed, required String failText, String? successText}) {
    final isMobileView = PlatformX.isMobileView;

    return Padding(
      padding: isMobileView ? EdgeInsets.symmetric(horizontal: 16) : EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VisirButton(
            key: ValueKey(id),
            type: VisirButtonAnimationType.scaleAndOpacity,
            style: VisirButtonStyle(
              borderRadius: BorderRadius.circular(12),
              backgroundColor: context.secondary,
              height: 48,
              width: isMobileView ? null : 360,
              cursor: SystemMouseCursors.click,
            ),
            onTap: onTap,
            child: Center(
              child: onLoading
                  ? CustomCircularLoadingIndicator(size: 14, color: context.onSecondary)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Text(text, style: context.titleSmall?.textColor(context.onSecondary))],
                    ),
            ),
          ),
          if (isFailed == true)
            Padding(
              padding: EdgeInsets.only(top: 8, left: 20, right: 20),
              child: Text(failText, style: context.labelSmall?.textColor(context.error)),
            ),
          if (isFailed == false && successText != null)
            Padding(
              padding: EdgeInsets.only(top: 8, left: 20, right: 20),
              child: Text(successText, style: context.labelSmall?.textColor(context.primary)),
            ),
        ],
      ),
    );
  }

  Widget inputField({
    required String hintText,
    required String id,
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool? isValid,
    required String invalidWarningText,
  }) {
    final isMobileView = PlatformX.isMobileView;

    return Padding(
      padding: isMobileView ? EdgeInsets.symmetric(horizontal: 16) : EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VisirButton(
            key: ValueKey(id),
            type: VisirButtonAnimationType.none,
            onTap: focusNode.requestFocus,
            style: VisirButtonStyle(
              height: 48,
              width: isMobileView ? null : 360,
              backgroundColor: isMobileView
                  ? focusNode.hasFocus
                        ? context.surface
                        : context.outline
                  : context.outline,
              borderRadius: BorderRadius.circular(12),
              alignment: Alignment.center,
            ),
            child: TextFormField(
              onTapOutside: (event) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              onTap: focusNode.requestFocus,
              style: context.titleSmall?.textColor(context.outlineVariant),
              obscureText: id == passwordTextFieldId,
              controller: controller,
              focusNode: focusNode,
              inputFormatters: [
                TextInputFormatter.withFunction((oldValue, newValue) {
                  return TextEditingValue(text: newValue.text.trimRight(), selection: newValue.selection);
                }),
              ],
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: context.titleSmall?.textColor(context.inverseSurface),
                isDense: true,
                fillColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
          ),
          if (isValid == false)
            Padding(
              padding: EdgeInsets.only(top: 8, left: 20, right: 20),
              child: Text(invalidWarningText, style: context.labelSmall?.textColor(context.error)),
            ),
        ],
      ),
    );
  }

  Widget hoveringText({required String text, required String id, required Future<void> Function() onTap, Color? textColor}) {
    return VisirButton(
      key: ValueKey(id),
      style: VisirButtonStyle(hoverColor: Colors.transparent),
      type: VisirButtonAnimationType.scaleAndOpacity,
      onTap: onTap,
      builder: (isHover) {
        return Text(
          text,
          style: isHover ? context.titleSmall?.textColor(textColor ?? context.secondary).textUnderline : context.titleSmall?.textColor(textColor ?? context.secondary),
        );
      },
    );
  }

  bool validateInputFields() {
    String email = emailController.text;
    String password = passwordController.text;
    String username = usernameController.text;

    if (email.isEmpty || !EmailValidator.validate(email)) {
      isEmailValid = false;
    } else {
      isEmailValid = true;
    }

    if (!isOnForgotPassword) {
      if (password.isEmpty || password.length < 6) {
        isPasswordValid = false;
      } else {
        isPasswordValid = true;
      }
    }

    if (!isOnForgotPassword && isOnSignupWithEmail) {
      if (username.isEmpty) {
        isUsernameValid = false;
      } else {
        isUsernameValid = true;
      }
    }

    setState(() {});
    return (isEmailValid ?? false) &&
        (isOnForgotPassword ? true : (isPasswordValid ?? false)) &&
        ((!isOnForgotPassword && isOnSignupWithEmail) ? (isUsernameValid ?? false) : true);
  }

  Widget tosPrivacy() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text.rich(
        TextSpan(
          style: context.titleSmall?.textColor(context.onInverseSurface),
          text: context.tr.onboarding_by_registering,
          children: [
            WidgetSpan(
              child: IntrinsicWidth(
                child: VisirButton(
                  type: VisirButtonAnimationType.scaleAndOpacity,
                  onTap: () => launchUrl(Uri.parse(Constants.tosUrl)),
                  style: VisirButtonStyle(),
                  builder: (isHover) {
                    return Text(
                      context.tr.onboarding_terms_of_service,
                      style: isHover ? context.titleSmall?.textColor(context.secondary).textUnderline : context.titleSmall?.textColor(context.secondary),
                      textScaler: TextScaler.noScaling,
                    );
                  },
                ),
              ),
            ),
            TextSpan(text: context.tr.onboarding_and),
            WidgetSpan(
              child: IntrinsicWidth(
                child: VisirButton(
                  type: VisirButtonAnimationType.scaleAndOpacity,
                  onTap: () => launchUrl(Uri.parse(Constants.privacyUrl)),
                  style: VisirButtonStyle(),
                  builder: (isHover) {
                    return Text(
                      context.tr.onboarding_privacy_policy,
                      style: isHover ? context.titleSmall?.textColor(context.secondary).textUnderline : context.titleSmall?.textColor(context.secondary),
                      textScaler: TextScaler.noScaling,
                    );
                  },
                ),
              ),
            ),
            TextSpan(text: context.tr.onboarding_of_taskey),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  void resetEmailFields() {
    emailController.clear();
    passwordController.clear();
    usernameController.clear();
    isEmailValid = null;
    isPasswordValid = null;
    isUsernameValid = null;
    isEmailLoginFailed = null;
    isEmailSignupFailed = null;
    emailAuthExceptionType = null;
    setState(() {});
  }

  bool _onKeyDown(KeyEvent event, {bool? justReturnResult}) {
    final key = event.logicalKey;
    final logicalKeyPressed = ServicesBinding.instance.keyboard.logicalKeysPressed.where((e) => e != LogicalKeyboardKey.escape).toList();
    final shiftPressed = logicalKeyPressed.isShiftPressed;

    if (logicalKeyPressed.length == 1 && key == LogicalKeyboardKey.enter) {
      if (justReturnResult == true) return true;
      if (isOnLoginWithEmail) {
        if (emailFocusNode.hasFocus || passwordFocusNode.hasFocus || usernameFocusNode.hasFocus) {
          if (isOnForgotPassword) {
            sendPassWordResetEmail();
          } else {
            signInWithEmail();
          }
        }
      }
      return true;
    }

    if (logicalKeyPressed.length == 1 && key == LogicalKeyboardKey.tab) {
      if (isOnLoginWithEmail) {
        if (isOnSignupWithEmail) {
          if (emailFocusNode.hasFocus) {
            switchFocusTo(passwordFocusNode);
          } else if (passwordFocusNode.hasFocus) {
            switchFocusTo(usernameFocusNode);
          } else if (usernameFocusNode.hasFocus) {
            switchFocusTo(emailFocusNode);
          }
        } else if (!isOnForgotPassword) {
          if (emailFocusNode.hasFocus) {
            switchFocusTo(passwordFocusNode);
          } else if (passwordFocusNode.hasFocus) {
            switchFocusTo(emailFocusNode);
          }
        }
      }
      return true;
    }
    if (logicalKeyPressed.length == 2 && logicalKeyPressed.contains(LogicalKeyboardKey.tab) && shiftPressed) {
      if (isOnLoginWithEmail) {
        if (isOnSignupWithEmail) {
          if (emailFocusNode.hasFocus) {
            switchFocusTo(usernameFocusNode);
          } else if (passwordFocusNode.hasFocus) {
            switchFocusTo(emailFocusNode);
          } else if (usernameFocusNode.hasFocus) {
            switchFocusTo(passwordFocusNode);
          }
        } else if (!isOnForgotPassword) {
          if (emailFocusNode.hasFocus) {
            switchFocusTo(passwordFocusNode);
          } else if (passwordFocusNode.hasFocus) {
            switchFocusTo(emailFocusNode);
          }
        }
      }
      return true;
    }

    return false;
  }

  void switchFocusTo(FocusNode focusNode) {
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        focusNode.requestFocus();
      });
    } else {
      focusNode.requestFocus();
    }
  }

  enableDragging() async {
    if (!PlatformX.isWeb && PlatformX.isDesktop) {
      appWindow.startDragging();
    }
  }

  disableDragging() async {}

  @override
  Widget build(BuildContext context) {
    ref.watch(feedbackControllerProvider);

    final isMobileView = PlatformX.isMobileView;

    // double screenHeight = MediaQuery.of(context).size.height;
    double toolbarHeight = (isMobileView || kIsWeb) ? 0 : Constants.desktopTitleBarHeight.toDouble();
    // bool isShort = screenHeight < 700;
    // bool isLong = screenHeight >= 1000;

    return KeyboardShortcut(
      onKeyDown: _onKeyDown,
      bypassTextField: true,
      child: Material(
        color: Colors.transparent,
        child: SafeArea(
          child: Column(
            children: [
              GestureDetector(
                onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                onPanEnd: (details) {
                  disableDragging();
                },
                onPanStart: (details) {
                  enableDragging();
                },
                child: Container(height: toolbarHeight, color: Colors.transparent),
              ),
              Expanded(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 800),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    // mainAxisAlignment: isShort ? MainAxisAlignment.center : MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: isMobileView
                            ? isOnLoginWithEmail
                                  ? 44
                                  : 140
                            : 0,
                        // : isShort
                        // ? 0
                        // : isLong
                        // ? 260 - toolbarHeight
                        // : 180 - toolbarHeight,
                      ),
                      Row(
                        textDirection: TextDirection.ltr,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('${(kDebugMode && kIsWeb) ? "" : "assets/"}app_icon/visir_foreground.png', width: 72, height: 72),
                          const SizedBox(width: 16),
                          Text(
                            'Visir',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 68,
                              fontWeight: FontWeight.w600,
                              color: context.isDarkMode ? const Color(0xFFE5E5E5) : const Color(0xFF1C1C1B),
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ...isOnLoginWithEmail
                          ? [
                              if (isMobileView) const SizedBox(height: 8),
                              inputField(
                                hintText: isOnSignupWithEmail ? context.tr.onboarding_email : context.tr.onboarding_enter_your_email,
                                id: emailTextFieldId,
                                controller: emailController,
                                focusNode: emailFocusNode,
                                isValid: isEmailValid,
                                invalidWarningText: context.tr.onboarding_please_enter_a_valid_email_address,
                              ),
                              SizedBox(height: 12),
                              if (!isOnForgotPassword) ...[
                                inputField(
                                  hintText: isOnSignupWithEmail ? context.tr.onboarding_password : context.tr.onboarding_enter_your_password,
                                  id: passwordTextFieldId,
                                  controller: passwordController,
                                  focusNode: passwordFocusNode,
                                  isValid: isPasswordValid,
                                  invalidWarningText: context.tr.onboarding_please_enter_a_long_password,
                                ),
                                SizedBox(height: 12),
                              ],
                              if (isOnSignupWithEmail == true) ...[
                                inputField(
                                  hintText: context.tr.onboarding_username,
                                  id: usernameTextFieldId,
                                  controller: usernameController,
                                  focusNode: usernameFocusNode,
                                  isValid: isUsernameValid,
                                  invalidWarningText: context.tr.onboarding_please_enter_a_username,
                                ),
                                SizedBox(height: 12),
                              ],
                              coloredButton(
                                text: isOnSignupWithEmail
                                    ? context.tr.onboarding_sign_up
                                    : isOnForgotPassword
                                    ? context.tr.onboarding_send_password_reset_email
                                    : context.tr.onboarding_log_in,
                                id: emailColoredButtonId,
                                onTap: isOnForgotPassword ? sendPassWordResetEmail : signInWithEmail,
                                isFailed: isOnForgotPassword
                                    ? resetPasswordMailSentFailed
                                    : isOnSignupWithEmail
                                    ? isEmailSignupFailed
                                    : isEmailLoginFailed,
                                failText: isOnForgotPassword
                                    ? context.tr.onboarding_password_reset_email_failed
                                    : isOnSignupWithEmail
                                    ? emailAuthExceptionType?.getMessage(context) ?? context.tr.onboarding_email_sign_up_failed
                                    : context.tr.onboarding_invalid_username_or_password,
                                successText: context.tr.onboarding_password_reset_email_sent,
                              ),
                              const SizedBox(height: 36),
                              if (isOnSignupWithEmail && !isOnForgotPassword) ...[tosPrivacy(), const SizedBox(height: 24)],
                              if (!isOnForgotPassword) ...[
                                hoveringText(
                                  textColor: isOnSignupWithEmail ? null : context.primary,
                                  text: isOnSignupWithEmail ? context.tr.onboarding_already_have_an_account : context.tr.onboarding_do_not_have_an_account,
                                  id: signUpButtonId,
                                  onTap: () async {
                                    if (isOnSignupWithEmail) {
                                      isOnSignupWithEmail = false;
                                    } else {
                                      logAnalyticsEvent(eventName: 'login_email_signup');
                                      isOnSignupWithEmail = true;
                                    }
                                    resetEmailFields();
                                  },
                                ),
                                const SizedBox(height: 24),
                              ],
                              if (!isOnSignupWithEmail && !isOnForgotPassword) ...[
                                hoveringText(
                                  text: context.tr.onboarding_return_to_login_options,
                                  id: returnToLoginOptionsButtonId,
                                  onTap: () async {
                                    logAnalyticsEvent(eventName: 'login_email_return_options');
                                    isOnLoginWithEmail = false;
                                    resetEmailFields();
                                  },
                                ),
                                const SizedBox(height: 24),
                                hoveringText(
                                  text: context.tr.onboarding_forgot_your_password,
                                  id: forgotPasswordButtonId,
                                  onTap: () async {
                                    logAnalyticsEvent(eventName: 'login_email_forgot_password');
                                    setState(() {
                                      isOnForgotPassword = true;
                                    });
                                  },
                                ),
                                const SizedBox(height: 24),
                              ],
                              if (isOnForgotPassword)
                                hoveringText(
                                  text: context.tr.onboarding_back_to_sign_in,
                                  id: returnToSignInButtonId,
                                  onTap: () async {
                                    setState(() {
                                      isOnForgotPassword = false;
                                      resetPasswordMailSentFailed = null;
                                      resetPasswordErrorMessage = null;
                                    });
                                  },
                                ),
                            ]
                          : [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  context.tr.onboarding_description,
                                  style: context.titleSmall?.textColor(context.outlineVariant).appFont(context),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              if (widget.loginType != null) SizedBox(height: 12),
                              isMobileView ? Expanded(child: Container()) : const SizedBox(height: 24),
                              if (widget.loginType == LoginType.google || widget.loginType == null) loginButton(context: context, type: LoginType.google, onTap: signInWithGoogle),
                              if (widget.loginType == null) SizedBox(height: 12),
                              if (widget.loginType == LoginType.apple || widget.loginType == null) loginButton(context: context, type: LoginType.apple, onTap: signInWithApple),
                              if (widget.loginType == null) SizedBox(height: 12),
                              if (widget.loginType == LoginType.email || widget.loginType == null)
                                loginButton(
                                  context: context,
                                  type: LoginType.email,
                                  onTap: () async {
                                    setState(() {
                                      isOnLoginWithEmail = true;
                                    });

                                    switchFocusTo(emailFocusNode);
                                  },
                                ),
                              SizedBox(height: 36),
                              tosPrivacy(),
                              if (isMobileView) const SizedBox(height: 54),
                            ],

                      Consumer(
                        builder: (context, ref, child) {
                          final authState = ref.watch(authControllerProvider);
                          final isAdmin = authState.value?.userIsAdmin ?? false;
                          return ValueListenableBuilder(
                            valueListenable: Constants.isBetaBuildNotifier,
                            builder: (context, isBetaBuild, child) {
                              if (!isBetaBuild || !isAdmin) return const SizedBox.shrink();
                              return VisirButton(
                                type: VisirButtonAnimationType.scaleAndOpacity,
                                onTap: () {
                                  SharedPreferences.getInstance().then((value) async {
                                    await value.setBool('useDebugDb', !useDebugDb);
                                    exit(0);
                                  });
                                },
                                style: VisirButtonStyle(
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [Text(useDebugDb ? 'Use Production DB' : 'Use Beta DB', style: context.titleSmall?.textColor(context.error))],
                                ),
                              );
                            },
                          );
                        },
                      ),
                      Container(color: Colors.transparent, height: toolbarHeight),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
