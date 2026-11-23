import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @letsGet.
  ///
  /// In en, this message translates to:
  /// **'Let\'s get'**
  String get letsGet;

  /// No description provided for @started.
  ///
  /// In en, this message translates to:
  /// **'started!'**
  String get started;

  /// No description provided for @createYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Create your account to start \ndelivering smarter.'**
  String get createYourAccount;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @signupStepYourDetails.
  ///
  /// In en, this message translates to:
  /// **'Your details'**
  String get signupStepYourDetails;

  /// No description provided for @signupStepYourVehicle.
  ///
  /// In en, this message translates to:
  /// **'Your vehicle'**
  String get signupStepYourVehicle;

  /// No description provided for @signupStepPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get signupStepPassword;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @enterYourFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterYourFullName;

  /// No description provided for @enterYourFirstName.
  ///
  /// In en, this message translates to:
  /// **'Enter first name'**
  String get enterYourFirstName;

  /// No description provided for @enterYourLastName.
  ///
  /// In en, this message translates to:
  /// **'Enter last name'**
  String get enterYourLastName;

  /// No description provided for @enterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get somethingWentWrong;

  /// No description provided for @driverLoginScreenTodo.
  ///
  /// In en, this message translates to:
  /// **'Driver Login Screen — TODO'**
  String get driverLoginScreenTodo;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcomeBack;

  /// No description provided for @welcomeBackHighlight.
  ///
  /// In en, this message translates to:
  /// **'back.'**
  String get welcomeBackHighlight;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue\noptimizing your routes.'**
  String get loginSubtitle;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @errPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get errPasswordRequired;

  /// No description provided for @errPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get errPasswordMismatch;

  /// No description provided for @errPasswordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get errPasswordMinLength;

  /// No description provided for @errPasswordUppercase.
  ///
  /// In en, this message translates to:
  /// **'Include at least one uppercase letter'**
  String get errPasswordUppercase;

  /// No description provided for @errPasswordLowercase.
  ///
  /// In en, this message translates to:
  /// **'Include at least one lowercase letter'**
  String get errPasswordLowercase;

  /// No description provided for @errPasswordNumber.
  ///
  /// In en, this message translates to:
  /// **'Include at least one number'**
  String get errPasswordNumber;

  /// No description provided for @errPasswordSymbol.
  ///
  /// In en, this message translates to:
  /// **'Include at least one special character'**
  String get errPasswordSymbol;

  /// No description provided for @errOtpRequired.
  ///
  /// In en, this message translates to:
  /// **'Verification code is required'**
  String get errOtpRequired;

  /// No description provided for @errOtpInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 6-digit code'**
  String get errOtpInvalid;

  /// No description provided for @errVehicleRequired.
  ///
  /// In en, this message translates to:
  /// **'Vehicle type and number are required for drivers'**
  String get errVehicleRequired;

  /// No description provided for @errResetTokenRequired.
  ///
  /// In en, this message translates to:
  /// **'Reset token is required'**
  String get errResetTokenRequired;

  /// No description provided for @errRefreshTokenRequired.
  ///
  /// In en, this message translates to:
  /// **'Refresh token is required'**
  String get errRefreshTokenRequired;

  /// No description provided for @errOrderAddressRequired.
  ///
  /// In en, this message translates to:
  /// **'Pickup and dropoff addresses are required'**
  String get errOrderAddressRequired;

  /// No description provided for @errPickupLocationRequired.
  ///
  /// In en, this message translates to:
  /// **'Pickup location is required'**
  String get errPickupLocationRequired;

  /// No description provided for @errDropoffLocationRequired.
  ///
  /// In en, this message translates to:
  /// **'Dropoff location is required'**
  String get errDropoffLocationRequired;

  /// No description provided for @errLoggedOut.
  ///
  /// In en, this message translates to:
  /// **'Please log in to continue'**
  String get errLoggedOut;

  /// No description provided for @errUnexpectedResponse.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errUnexpectedResponse;

  /// No description provided for @errIncompleteResponse.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t complete your request. Please try again.'**
  String get errIncompleteResponse;

  /// No description provided for @errNoInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your network and try again.'**
  String get errNoInternetConnection;

  /// No description provided for @errGoogleNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in isn\'t available in this build yet. Please try again later.'**
  String get errGoogleNotConfigured;

  /// No description provided for @errGoogleSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t sign you in with Google. Please try again.'**
  String get errGoogleSignInFailed;

  /// No description provided for @errGoogleAuthFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t complete your Google sign-in. Please try again.'**
  String get errGoogleAuthFailed;

  /// No description provided for @errRequestTimeout.
  ///
  /// In en, this message translates to:
  /// **'The request took too long. Please try again.'**
  String get errRequestTimeout;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @driverRegistrationScreenTodo.
  ///
  /// In en, this message translates to:
  /// **'Driver Registration Screen — TODO'**
  String get driverRegistrationScreenTodo;

  /// No description provided for @setNewPasswordScreenTodo.
  ///
  /// In en, this message translates to:
  /// **'Set New Password Screen — TODO'**
  String get setNewPasswordScreenTodo;

  /// No description provided for @verifyCodeScreenTodo.
  ///
  /// In en, this message translates to:
  /// **'Verify Code Screen — TODO'**
  String get verifyCodeScreenTodo;

  /// No description provided for @onboardingHeadline1.
  ///
  /// In en, this message translates to:
  /// **'Deliver '**
  String get onboardingHeadline1;

  /// No description provided for @onboardingHeadline2.
  ///
  /// In en, this message translates to:
  /// **'More.'**
  String get onboardingHeadline2;

  /// No description provided for @onboardingHeadline3.
  ///
  /// In en, this message translates to:
  /// **'\nDrive '**
  String get onboardingHeadline3;

  /// No description provided for @onboardingHeadline4.
  ///
  /// In en, this message translates to:
  /// **'Less.'**
  String get onboardingHeadline4;

  /// No description provided for @onboardingSubheadline.
  ///
  /// In en, this message translates to:
  /// **'Smarter routes, fewer miles.\nBetter results for your business.'**
  String get onboardingSubheadline;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @onboarding2Headline1.
  ///
  /// In en, this message translates to:
  /// **'Every '**
  String get onboarding2Headline1;

  /// No description provided for @onboarding2Headline2.
  ///
  /// In en, this message translates to:
  /// **'stop,'**
  String get onboarding2Headline2;

  /// No description provided for @onboarding2Headline3.
  ///
  /// In en, this message translates to:
  /// **'\nin '**
  String get onboarding2Headline3;

  /// No description provided for @onboarding2Headline4.
  ///
  /// In en, this message translates to:
  /// **'order.'**
  String get onboarding2Headline4;

  /// No description provided for @onboarding2Subheadline.
  ///
  /// In en, this message translates to:
  /// **'Orders are grouped into one sorted route.\nGo online and it comes straight to you.'**
  String get onboarding2Subheadline;

  /// No description provided for @slideToGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Slide to get started'**
  String get slideToGetStarted;

  /// No description provided for @appNavigationScreenTodo.
  ///
  /// In en, this message translates to:
  /// **'App Navigation Screen — TODO'**
  String get appNavigationScreenTodo;

  /// No description provided for @homeNavHubTitle.
  ///
  /// In en, this message translates to:
  /// **'Home Screens Navigator'**
  String get homeNavHubTitle;

  /// No description provided for @homeNavHubSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Preview & navigate across all Home scenarios, states and flows'**
  String get homeNavHubSubtitle;

  /// No description provided for @homeNavHubSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search screens, scenarios or keys (e.g. HM1, N01)...'**
  String get homeNavHubSearchHint;

  /// No description provided for @homeNavCategoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get homeNavCategoryAll;

  /// No description provided for @homeNavCategoryScenarios.
  ///
  /// In en, this message translates to:
  /// **'Delivery Scenarios'**
  String get homeNavCategoryScenarios;

  /// No description provided for @homeNavCategoryNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get homeNavCategoryNotifications;

  /// No description provided for @homeNavCategoryFleet.
  ///
  /// In en, this message translates to:
  /// **'Fleet & Joining'**
  String get homeNavCategoryFleet;

  /// No description provided for @homeNavCategoryShell.
  ///
  /// In en, this message translates to:
  /// **'App Shell'**
  String get homeNavCategoryShell;

  /// No description provided for @homeNavScenarioHm1Title.
  ///
  /// In en, this message translates to:
  /// **'HM1 · Ready to Start'**
  String get homeNavScenarioHm1Title;

  /// No description provided for @homeNavScenarioHm1Desc.
  ///
  /// In en, this message translates to:
  /// **'Assigned orders ready, driver hasn\'t started delivery yet'**
  String get homeNavScenarioHm1Desc;

  /// No description provided for @homeNavScenarioHm2Title.
  ///
  /// In en, this message translates to:
  /// **'HM2 · On Route'**
  String get homeNavScenarioHm2Title;

  /// No description provided for @homeNavScenarioHm2Desc.
  ///
  /// In en, this message translates to:
  /// **'Active delivery navigation with next stop card and live ETA'**
  String get homeNavScenarioHm2Desc;

  /// No description provided for @homeNavScenarioHm3Title.
  ///
  /// In en, this message translates to:
  /// **'HM3 · All Caught Up'**
  String get homeNavScenarioHm3Title;

  /// No description provided for @homeNavScenarioHm3Desc.
  ///
  /// In en, this message translates to:
  /// **'All orders delivered, waiting for new assigned orders'**
  String get homeNavScenarioHm3Desc;

  /// No description provided for @homeNavScenarioHm4Title.
  ///
  /// In en, this message translates to:
  /// **'HM4 · Offline Mode'**
  String get homeNavScenarioHm4Title;

  /// No description provided for @homeNavScenarioHm4Desc.
  ///
  /// In en, this message translates to:
  /// **'No internet connection banner & offline warning state'**
  String get homeNavScenarioHm4Desc;

  /// No description provided for @homeNavScenarioHm5Title.
  ///
  /// In en, this message translates to:
  /// **'HM5 · First Day Online'**
  String get homeNavScenarioHm5Title;

  /// No description provided for @homeNavScenarioHm5Desc.
  ///
  /// In en, this message translates to:
  /// **'New driver on duty for the first time, waiting for first orders'**
  String get homeNavScenarioHm5Desc;

  /// No description provided for @homeNavScenarioHm6Title.
  ///
  /// In en, this message translates to:
  /// **'HM6 · No Orders Today'**
  String get homeNavScenarioHm6Title;

  /// No description provided for @homeNavScenarioHm6Desc.
  ///
  /// In en, this message translates to:
  /// **'No packages assigned to driver today'**
  String get homeNavScenarioHm6Desc;

  /// No description provided for @homeNavScenarioHm8Title.
  ///
  /// In en, this message translates to:
  /// **'HM8 · New Order (First Day)'**
  String get homeNavScenarioHm8Title;

  /// No description provided for @homeNavScenarioHm8Desc.
  ///
  /// In en, this message translates to:
  /// **'In-app order notification overlay over first day dashboard'**
  String get homeNavScenarioHm8Desc;

  /// No description provided for @homeNavScenarioHm9Title.
  ///
  /// In en, this message translates to:
  /// **'HM9 · New Order (On Route)'**
  String get homeNavScenarioHm9Title;

  /// No description provided for @homeNavScenarioHm9Desc.
  ///
  /// In en, this message translates to:
  /// **'In-app order notification overlay during active route navigation'**
  String get homeNavScenarioHm9Desc;

  /// No description provided for @homeNavScenarioHm0Title.
  ///
  /// In en, this message translates to:
  /// **'HM0 · Loading Skeleton'**
  String get homeNavScenarioHm0Title;

  /// No description provided for @homeNavScenarioHm0Desc.
  ///
  /// In en, this message translates to:
  /// **'Shimmer skeleton loader placeholders while payload loads'**
  String get homeNavScenarioHm0Desc;

  /// No description provided for @homeNavScreenN01Title.
  ///
  /// In en, this message translates to:
  /// **'N01 · Notifications List'**
  String get homeNavScreenN01Title;

  /// No description provided for @homeNavScreenN01Desc.
  ///
  /// In en, this message translates to:
  /// **'Populated list with New & Earlier sections and read states'**
  String get homeNavScreenN01Desc;

  /// No description provided for @homeNavScreenN02Title.
  ///
  /// In en, this message translates to:
  /// **'N02 · Notifications Empty'**
  String get homeNavScreenN02Title;

  /// No description provided for @homeNavScreenN02Desc.
  ///
  /// In en, this message translates to:
  /// **'Empty inbox with 3D bell illustration and empty copy'**
  String get homeNavScreenN02Desc;

  /// No description provided for @homeNavScreenFindFleetTitle.
  ///
  /// In en, this message translates to:
  /// **'Find Fleet'**
  String get homeNavScreenFindFleetTitle;

  /// No description provided for @homeNavScreenFindFleetDesc.
  ///
  /// In en, this message translates to:
  /// **'Search delivery fleets with filter chips and location pills'**
  String get homeNavScreenFindFleetDesc;

  /// No description provided for @homeNavScreenEnterCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter Fleet Code'**
  String get homeNavScreenEnterCodeTitle;

  /// No description provided for @homeNavScreenEnterCodeDesc.
  ///
  /// In en, this message translates to:
  /// **'6-digit code entry with validation and status handling'**
  String get homeNavScreenEnterCodeDesc;

  /// No description provided for @homeNavScreenHomeFirstRunTitle.
  ///
  /// In en, this message translates to:
  /// **'Driver Home (First Run)'**
  String get homeNavScreenHomeFirstRunTitle;

  /// No description provided for @homeNavScreenHomeFirstRunDesc.
  ///
  /// In en, this message translates to:
  /// **'Get started card, fleets near you, today overview (Figma 5222:8139)'**
  String get homeNavScreenHomeFirstRunDesc;

  /// No description provided for @homeNavScreenMainShellTitle.
  ///
  /// In en, this message translates to:
  /// **'Main Layout Shell'**
  String get homeNavScreenMainShellTitle;

  /// No description provided for @homeNavScreenMainShellDesc.
  ///
  /// In en, this message translates to:
  /// **'Animated switcher with 4 tabs and bottom floating pill bar'**
  String get homeNavScreenMainShellDesc;

  /// No description provided for @homeNavLaunchButton.
  ///
  /// In en, this message translates to:
  /// **'Open Screen'**
  String get homeNavLaunchButton;

  /// No description provided for @homeNavScreensCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Screens & Scenarios'**
  String homeNavScreensCount(int count);

  /// No description provided for @step2ComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Step 2 — Coming soon'**
  String get step2ComingSoon;

  /// No description provided for @selectCountryCode.
  ///
  /// In en, this message translates to:
  /// **'Select Country Code'**
  String get selectCountryCode;

  /// No description provided for @searchCountry.
  ///
  /// In en, this message translates to:
  /// **'Search country...'**
  String get searchCountry;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @countryPalestine.
  ///
  /// In en, this message translates to:
  /// **'Palestine'**
  String get countryPalestine;

  /// No description provided for @countrySaudiArabia.
  ///
  /// In en, this message translates to:
  /// **'Saudi Arabia'**
  String get countrySaudiArabia;

  /// No description provided for @countryEgypt.
  ///
  /// In en, this message translates to:
  /// **'Egypt'**
  String get countryEgypt;

  /// No description provided for @countryUAE.
  ///
  /// In en, this message translates to:
  /// **'United Arab Emirates'**
  String get countryUAE;

  /// No description provided for @countryJordan.
  ///
  /// In en, this message translates to:
  /// **'Jordan'**
  String get countryJordan;

  /// No description provided for @countryQatar.
  ///
  /// In en, this message translates to:
  /// **'Qatar'**
  String get countryQatar;

  /// No description provided for @countryKuwait.
  ///
  /// In en, this message translates to:
  /// **'Kuwait'**
  String get countryKuwait;

  /// No description provided for @countryOman.
  ///
  /// In en, this message translates to:
  /// **'Oman'**
  String get countryOman;

  /// No description provided for @countryBahrain.
  ///
  /// In en, this message translates to:
  /// **'Bahrain'**
  String get countryBahrain;

  /// No description provided for @errNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Full name is required'**
  String get errNameRequired;

  /// No description provided for @errNameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 3 characters'**
  String get errNameMinLength;

  /// No description provided for @errFirstNameRequired.
  ///
  /// In en, this message translates to:
  /// **'First name is required'**
  String get errFirstNameRequired;

  /// No description provided for @errFirstNameMinLength.
  ///
  /// In en, this message translates to:
  /// **'First name must be at least 3 characters'**
  String get errFirstNameMinLength;

  /// No description provided for @errLastNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Last name is required'**
  String get errLastNameRequired;

  /// No description provided for @errLastNameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Last name must be at least 3 characters'**
  String get errLastNameMinLength;

  /// No description provided for @errEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get errEmailRequired;

  /// No description provided for @errEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get errEmailInvalid;

  /// No description provided for @errPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get errPhoneRequired;

  /// No description provided for @errPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get errPhoneInvalid;

  /// No description provided for @tellUsAboutYour.
  ///
  /// In en, this message translates to:
  /// **'Tell us about'**
  String get tellUsAboutYour;

  /// No description provided for @vehicle.
  ///
  /// In en, this message translates to:
  /// **'your vehicle.'**
  String get vehicle;

  /// No description provided for @vehicleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This helps us match you with\nthe right deliveries. '**
  String get vehicleSubtitle;

  /// No description provided for @vehicleMotorcycle.
  ///
  /// In en, this message translates to:
  /// **'Motorcycle'**
  String get vehicleMotorcycle;

  /// No description provided for @vehicleCar.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get vehicleCar;

  /// No description provided for @vehicleVan.
  ///
  /// In en, this message translates to:
  /// **'Van'**
  String get vehicleVan;

  /// No description provided for @vehicleTruck.
  ///
  /// In en, this message translates to:
  /// **'Truck'**
  String get vehicleTruck;

  /// No description provided for @vehicleNumber.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Plate Number'**
  String get vehicleNumber;

  /// No description provided for @vehicleNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Enter vehicle number'**
  String get vehicleNumberHint;

  /// No description provided for @createA.
  ///
  /// In en, this message translates to:
  /// **'Create a'**
  String get createA;

  /// No description provided for @securePassword.
  ///
  /// In en, this message translates to:
  /// **'secure password.'**
  String get securePassword;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep your account safe with\na strong password.'**
  String get passwordSubtitle;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get enterPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @passwordRequirements.
  ///
  /// In en, this message translates to:
  /// **'Password requirements'**
  String get passwordRequirements;

  /// No description provided for @reqMinLength.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get reqMinLength;

  /// No description provided for @reqCapitalLetter.
  ///
  /// In en, this message translates to:
  /// **'Includes an uppercase letter'**
  String get reqCapitalLetter;

  /// No description provided for @reqNumber.
  ///
  /// In en, this message translates to:
  /// **'Includes a number'**
  String get reqNumber;

  /// No description provided for @reqSymbol.
  ///
  /// In en, this message translates to:
  /// **'Includes a special character'**
  String get reqSymbol;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @byCreatingAccount.
  ///
  /// In en, this message translates to:
  /// **'By creating an account, you agree to our \n'**
  String get byCreatingAccount;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get and;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @verifyYourEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your'**
  String get verifyYourEmailTitle;

  /// No description provided for @verifyYourEmailTitleHighlight.
  ///
  /// In en, this message translates to:
  /// **'email.'**
  String get verifyYourEmailTitleHighlight;

  /// No description provided for @otpSentToEmailMessage.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a 6-digit verification code to\nyour email to activate your account.'**
  String get otpSentToEmailMessage;

  /// No description provided for @didntReceiveCode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code? '**
  String get didntReceiveCode;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// No description provided for @useDifferentEmail.
  ///
  /// In en, this message translates to:
  /// **'Use a different email'**
  String get useDifferentEmail;

  /// No description provided for @brandRoute.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get brandRoute;

  /// No description provided for @navHomeLabel.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHomeLabel;

  /// No description provided for @navRouteLabel.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get navRouteLabel;

  /// No description provided for @brandX.
  ///
  /// In en, this message translates to:
  /// **'X'**
  String get brandX;

  /// No description provided for @youAreAllSet.
  ///
  /// In en, this message translates to:
  /// **'You\'re all set!'**
  String get youAreAllSet;

  /// No description provided for @accountCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your account has been created successfully. Welcome to RouteX!'**
  String get accountCreatedSuccess;

  /// No description provided for @continueToHome.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueToHome;

  /// No description provided for @reviewYourDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Review your'**
  String get reviewYourDetailsTitle;

  /// No description provided for @reviewYourDetailsHighlight.
  ///
  /// In en, this message translates to:
  /// **'Details!'**
  String get reviewYourDetailsHighlight;

  /// No description provided for @reviewDetailsSubtext.
  ///
  /// In en, this message translates to:
  /// **'Make sure everything looks good before you continue.'**
  String get reviewDetailsSubtext;

  /// No description provided for @editLabel.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editLabel;

  /// No description provided for @vehicleTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'VEHICLE TYPE'**
  String get vehicleTypeLabel;

  /// No description provided for @vehicleNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'VEHICLE NUMBER'**
  String get vehicleNumberLabel;

  /// No description provided for @verifyEmailButton.
  ///
  /// In en, this message translates to:
  /// **'Verify email'**
  String get verifyEmailButton;

  /// No description provided for @emailOrPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Email or phone'**
  String get emailOrPasswordTitle;

  /// No description provided for @emailOrPassword.
  ///
  /// In en, this message translates to:
  /// **'Email or phone number'**
  String get emailOrPassword;

  /// No description provided for @detailsReadyCaptionLine.
  ///
  /// In en, this message translates to:
  /// **'Your details are ready.\nVerify your email to activate your account.'**
  String get detailsReadyCaptionLine;

  /// No description provided for @reviewYour.
  ///
  /// In en, this message translates to:
  /// **'Review your'**
  String get reviewYour;

  /// No description provided for @detailsExclamation.
  ///
  /// In en, this message translates to:
  /// **'Details!'**
  String get detailsExclamation;

  /// No description provided for @verifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify email'**
  String get verifyEmail;

  /// No description provided for @makeSureEverythingLooksGood.
  ///
  /// In en, this message translates to:
  /// **'Make sure everything looks good\nbefore you continue.'**
  String get makeSureEverythingLooksGood;

  /// No description provided for @reviewDetailsButton.
  ///
  /// In en, this message translates to:
  /// **'Review details'**
  String get reviewDetailsButton;

  /// No description provided for @otpCodeMismatchTitle.
  ///
  /// In en, this message translates to:
  /// **'The code you entered is incorrect.'**
  String get otpCodeMismatchTitle;

  /// No description provided for @otpCodeMismatchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please check the code and try again'**
  String get otpCodeMismatchSubtitle;

  /// No description provided for @forgetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forget your'**
  String get forgetPasswordTitle;

  /// No description provided for @forgetPasswordTitleHighlight.
  ///
  /// In en, this message translates to:
  /// **'password?'**
  String get forgetPasswordTitleHighlight;

  /// No description provided for @forgetPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and\nwe\'ll send you a verification code.'**
  String get forgetPasswordSubtitle;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send verification code'**
  String get sendResetLink;

  /// No description provided for @rememberYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Remember your password? '**
  String get rememberYourPassword;

  /// No description provided for @emailAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddressLabel;

  /// No description provided for @enterYourEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get enterYourEmailAddress;

  /// No description provided for @checkYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Check your'**
  String get checkYourEmail;

  /// No description provided for @checkYourEmailHighlight.
  ///
  /// In en, this message translates to:
  /// **'email.'**
  String get checkYourEmailHighlight;

  /// No description provided for @forgotOtpSentMessage.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a 6-digit code to your email'**
  String get forgotOtpSentMessage;

  /// No description provided for @setNewPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Set a new'**
  String get setNewPasswordTitle;

  /// No description provided for @setNewPasswordTitleHighlight.
  ///
  /// In en, this message translates to:
  /// **'Password.'**
  String get setNewPasswordTitleHighlight;

  /// No description provided for @setNewPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a strong password to keep your account safe.'**
  String get setNewPasswordSubtitle;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @enterPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get enterPasswordHint;

  /// No description provided for @resetPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPasswordButton;

  /// No description provided for @passwordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your password has been reset successfully.'**
  String get passwordResetSuccess;

  /// No description provided for @verificationCodeSentMessage.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a 6-digit verification code to\nyour email to activate your account.'**
  String get verificationCodeSentMessage;

  /// No description provided for @youreReadyTitleStart.
  ///
  /// In en, this message translates to:
  /// **'You\'re ready'**
  String get youreReadyTitleStart;

  /// No description provided for @youreReadyTitleEnd.
  ///
  /// In en, this message translates to:
  /// **'to roll!'**
  String get youreReadyTitleEnd;

  /// No description provided for @youreAllSetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your account is ready.\nexplore the app and start driving.'**
  String get youreAllSetSubtitle;

  /// No description provided for @startDrivingLabel.
  ///
  /// In en, this message translates to:
  /// **'Join your company!'**
  String get startDrivingLabel;

  /// No description provided for @routeErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get routeErrorTitle;

  /// No description provided for @routeNotFound.
  ///
  /// In en, this message translates to:
  /// **'Page not found or invalid arguments'**
  String get routeNotFound;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @editVehicle.
  ///
  /// In en, this message translates to:
  /// **'Edit Vehicle'**
  String get editVehicle;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @errVehicleNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Vehicle number is required'**
  String get errVehicleNumberRequired;

  /// No description provided for @selectPhotoSource.
  ///
  /// In en, this message translates to:
  /// **'Select Photo Source'**
  String get selectPhotoSource;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get addPhoto;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get changePhoto;

  /// No description provided for @otpVerifiedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Code verified successfully!'**
  String get otpVerifiedSuccessfully;

  /// No description provided for @otpCodeResentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'A new code has been sent to your email.'**
  String get otpCodeResentSuccessfully;

  /// No description provided for @googleVehicleTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete your vehicle details'**
  String get googleVehicleTitle;

  /// No description provided for @googleVehicleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We need your vehicle to finish setting up your account.'**
  String get googleVehicleSubtitle;

  /// No description provided for @errorAlertTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorAlertTitle;

  /// No description provided for @successTitle.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get successTitle;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @requestTimeoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Request timed out'**
  String get requestTimeoutTitle;

  /// No description provided for @noConnectionTitle.
  ///
  /// In en, this message translates to:
  /// **'No connection'**
  String get noConnectionTitle;

  /// No description provided for @discardChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get discardChangesTitle;

  /// No description provided for @discardChangesMessage.
  ///
  /// In en, this message translates to:
  /// **'If you leave now, your edits\nwill be lost.'**
  String get discardChangesMessage;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @logOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get logOutTitle;

  /// No description provided for @logOutMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'ll need to sign in again to continue using RouteX.'**
  String get logOutMessage;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @confirmYourEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm your email'**
  String get confirmYourEmailTitle;

  /// No description provided for @confirmYourEmailMessage.
  ///
  /// In en, this message translates to:
  /// **'Please make sure this email is correct. We\'ll send a verification code to:'**
  String get confirmYourEmailMessage;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCode;

  /// No description provided for @profileUpdatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdatedTitle;

  /// No description provided for @profileUpdatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your information has been\nsaved successfully.'**
  String get profileUpdatedMessage;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @sessionExpiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Session expired'**
  String get sessionExpiredTitle;

  /// No description provided for @sessionExpiredMessage.
  ///
  /// In en, this message translates to:
  /// **'For your security, please\nsign in again.'**
  String get sessionExpiredMessage;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @enableLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable location'**
  String get enableLocationTitle;

  /// No description provided for @enableLocationMessage.
  ///
  /// In en, this message translates to:
  /// **'RouteX needs your location to show trips and navigation.'**
  String get enableLocationMessage;

  /// No description provided for @allowAccess.
  ///
  /// In en, this message translates to:
  /// **'Allow access'**
  String get allowAccess;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Welcome,'**
  String get homeGreeting;

  /// No description provided for @homeTodayOverview.
  ///
  /// In en, this message translates to:
  /// **'Today’s overview'**
  String get homeTodayOverview;

  /// No description provided for @homeOverviewStartsFirstShift.
  ///
  /// In en, this message translates to:
  /// **'Starts with your first shift'**
  String get homeOverviewStartsFirstShift;

  /// No description provided for @homeDeliveries.
  ///
  /// In en, this message translates to:
  /// **'Deliveries'**
  String get homeDeliveries;

  /// No description provided for @homeDeliveriesOf.
  ///
  /// In en, this message translates to:
  /// **'of {target}'**
  String homeDeliveriesOf(int target);

  /// No description provided for @homeDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get homeDistance;

  /// No description provided for @homeDistanceUnit.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get homeDistanceUnit;

  /// No description provided for @homeTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get homeTime;

  /// No description provided for @homeOnShift.
  ///
  /// In en, this message translates to:
  /// **'on shift'**
  String get homeOnShift;

  /// No description provided for @homeShiftHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String homeShiftHoursMinutes(int hours, int minutes);

  /// No description provided for @homeGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get homeGetStarted;

  /// No description provided for @homeJoinFleetToStart.
  ///
  /// In en, this message translates to:
  /// **'Join a fleet to start'**
  String get homeJoinFleetToStart;

  /// No description provided for @homeReadyStatusDoneOf.
  ///
  /// In en, this message translates to:
  /// **'Ready status · {done} of {total} done'**
  String homeReadyStatusDoneOf(int done, int total);

  /// No description provided for @homeStepAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get homeStepAccount;

  /// No description provided for @homeStepPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get homeStepPhone;

  /// No description provided for @homeStepFleet.
  ///
  /// In en, this message translates to:
  /// **'Fleet'**
  String get homeStepFleet;

  /// No description provided for @homeStepDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get homeStepDone;

  /// No description provided for @homeStepToDo.
  ///
  /// In en, this message translates to:
  /// **'To do'**
  String get homeStepToDo;

  /// No description provided for @homeQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get homeQuickActions;

  /// No description provided for @homeFindAFleet.
  ///
  /// In en, this message translates to:
  /// **'Find a fleet'**
  String get homeFindAFleet;

  /// No description provided for @homeEnterFleetCode.
  ///
  /// In en, this message translates to:
  /// **'Enter fleet code'**
  String get homeEnterFleetCode;

  /// No description provided for @homeFleetsNearYou.
  ///
  /// In en, this message translates to:
  /// **'Fleets near you'**
  String get homeFleetsNearYou;

  /// No description provided for @homeSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get homeSeeAll;

  /// No description provided for @homeJoin.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get homeJoin;

  /// No description provided for @homeZoneAndDistance.
  ///
  /// In en, this message translates to:
  /// **'{zone} · {distance} km'**
  String homeZoneAndDistance(String zone, String distance);

  /// No description provided for @errJoinFleetBeforeGoingOnline.
  ///
  /// In en, this message translates to:
  /// **'Join a fleet before going online.'**
  String get errJoinFleetBeforeGoingOnline;

  /// No description provided for @errFleetNotFound.
  ///
  /// In en, this message translates to:
  /// **'That fleet is no longer available.'**
  String get errFleetNotFound;

  /// No description provided for @errInvalidOrExpiredCode.
  ///
  /// In en, this message translates to:
  /// **'That code is invalid or has expired.'**
  String get errInvalidOrExpiredCode;

  /// No description provided for @errSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please log in again.'**
  String get errSessionExpired;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @homeGoOnlineSwitch.
  ///
  /// In en, this message translates to:
  /// **'Go online'**
  String get homeGoOnlineSwitch;

  /// No description provided for @findFleetTitle.
  ///
  /// In en, this message translates to:
  /// **'Find a fleet'**
  String get findFleetTitle;

  /// No description provided for @findFleetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Search by name or browse fleets operating near you. Join one to start receiving routes.'**
  String get findFleetSubtitle;

  /// No description provided for @findFleetSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search fleet name or zone'**
  String get findFleetSearchHint;

  /// No description provided for @findFleetFilterNearby.
  ///
  /// In en, this message translates to:
  /// **'Nearby'**
  String get findFleetFilterNearby;

  /// No description provided for @findFleetFilterActive.
  ///
  /// In en, this message translates to:
  /// **'Open to join'**
  String get findFleetFilterActive;

  /// No description provided for @findFleetFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All fleets'**
  String get findFleetFilterAll;

  /// No description provided for @findFleetFilterPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get findFleetFilterPaused;

  /// No description provided for @findFleetSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'FLEETS NEAR YOU'**
  String get findFleetSectionLabel;

  /// No description provided for @findFleetResultsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} results'**
  String findFleetResultsCount(int count);

  /// No description provided for @findFleetInviteTitle.
  ///
  /// In en, this message translates to:
  /// **'Got an invite from your fleet manager?'**
  String get findFleetInviteTitle;

  /// No description provided for @findFleetInviteButton.
  ///
  /// In en, this message translates to:
  /// **'Enter fleet code'**
  String get findFleetInviteButton;

  /// No description provided for @errFleetCodeInvalid.
  ///
  /// In en, this message translates to:
  /// **'This code isn\'t valid or has expired'**
  String get errFleetCodeInvalid;

  /// No description provided for @findFleetCity.
  ///
  /// In en, this message translates to:
  /// **'Jeddah'**
  String get findFleetCity;

  /// No description provided for @findFleetDriversCount.
  ///
  /// In en, this message translates to:
  /// **'{count} drivers'**
  String findFleetDriversCount(int count);

  /// No description provided for @findFleetActiveStatus.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get findFleetActiveStatus;

  /// No description provided for @findFleetPausedStatus.
  ///
  /// In en, this message translates to:
  /// **'PAUSED'**
  String get findFleetPausedStatus;

  /// No description provided for @enterFleetCodeTitleStart.
  ///
  /// In en, this message translates to:
  /// **'Enter your '**
  String get enterFleetCodeTitleStart;

  /// No description provided for @enterFleetCodeTitleEnd.
  ///
  /// In en, this message translates to:
  /// **'fleet code'**
  String get enterFleetCodeTitleEnd;

  /// No description provided for @enterFleetCodeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Type the 6-character code your fleet manager sent you by SMS or email.'**
  String get enterFleetCodeSubtitle;

  /// No description provided for @enterFleetCodeCaption.
  ///
  /// In en, this message translates to:
  /// **'Letters and numbers, not case-sensitive'**
  String get enterFleetCodeCaption;

  /// No description provided for @enterFleetCodePaste.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get enterFleetCodePaste;

  /// No description provided for @enterFleetCodeWhereFindTitle.
  ///
  /// In en, this message translates to:
  /// **'Where do I find my code?'**
  String get enterFleetCodeWhereFindTitle;

  /// No description provided for @enterFleetCodeWhereFindBody.
  ///
  /// In en, this message translates to:
  /// **'Your fleet manager creates it in the fleet dashboard. Ask them to send one. Codes expire after 10 days.'**
  String get enterFleetCodeWhereFindBody;

  /// No description provided for @enterFleetCodeJoinButton.
  ///
  /// In en, this message translates to:
  /// **'Join fleet'**
  String get enterFleetCodeJoinButton;

  /// No description provided for @enterFleetCodeLostCode.
  ///
  /// In en, this message translates to:
  /// **'Lost your code? '**
  String get enterFleetCodeLostCode;

  /// No description provided for @enterFleetCodeFindFleetInstead.
  ///
  /// In en, this message translates to:
  /// **'Find a fleet instead'**
  String get enterFleetCodeFindFleetInstead;

  /// No description provided for @enterFleetCodeHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get enterFleetCodeHelp;

  /// No description provided for @enterFleetCodeTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get enterFleetCodeTryAgain;

  /// No description provided for @enterFleetCodeAskManager.
  ///
  /// In en, this message translates to:
  /// **'Ask manager for a new code'**
  String get enterFleetCodeAskManager;

  /// No description provided for @enterFleetCodeStillStuck.
  ///
  /// In en, this message translates to:
  /// **'Still stuck? '**
  String get enterFleetCodeStillStuck;

  /// No description provided for @goOnlineSheetNoFleetTitle.
  ///
  /// In en, this message translates to:
  /// **'Join a fleet to go online'**
  String get goOnlineSheetNoFleetTitle;

  /// No description provided for @goOnlineSheetNoFleetBody.
  ///
  /// In en, this message translates to:
  /// **'Going online sends you routes from a fleet. You\'re one step away.'**
  String get goOnlineSheetNoFleetBody;

  /// No description provided for @goOnlineSheetProgressAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get goOnlineSheetProgressAccount;

  /// No description provided for @goOnlineSheetProgressPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get goOnlineSheetProgressPhone;

  /// No description provided for @goOnlineSheetProgressFleet.
  ///
  /// In en, this message translates to:
  /// **'Fleet'**
  String get goOnlineSheetProgressFleet;

  /// No description provided for @goOnlineSheetProgressDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get goOnlineSheetProgressDone;

  /// No description provided for @goOnlineSheetProgressNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get goOnlineSheetProgressNext;

  /// No description provided for @goOnlineSheetFindFleet.
  ///
  /// In en, this message translates to:
  /// **'Find a fleet'**
  String get goOnlineSheetFindFleet;

  /// No description provided for @goOnlineSheetEnterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter fleet code'**
  String get goOnlineSheetEnterCode;

  /// No description provided for @goOnlineSheetNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get goOnlineSheetNotNow;

  /// No description provided for @goOnlineSheetPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Waiting for {fleetName}'**
  String goOnlineSheetPendingTitle(String fleetName);

  /// No description provided for @goOnlineSheetPendingBody.
  ///
  /// In en, this message translates to:
  /// **'You can go online as soon as the dispatcher approves your request. We\'ll notify you.'**
  String get goOnlineSheetPendingBody;

  /// No description provided for @goOnlineSheetRequestedToday.
  ///
  /// In en, this message translates to:
  /// **'Requested today, {time}'**
  String goOnlineSheetRequestedToday(String time);

  /// No description provided for @goOnlineSheetInReview.
  ///
  /// In en, this message translates to:
  /// **'In review'**
  String get goOnlineSheetInReview;

  /// No description provided for @goOnlineSheetViewRequest.
  ///
  /// In en, this message translates to:
  /// **'View request'**
  String get goOnlineSheetViewRequest;

  /// No description provided for @goOnlineSheetGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get goOnlineSheetGotIt;

  /// No description provided for @goOnlineSheetDeclinedTitle.
  ///
  /// In en, this message translates to:
  /// **'{fleetName} declined your request'**
  String goOnlineSheetDeclinedTitle(String fleetName);

  /// No description provided for @goOnlineSheetDeclinedBody.
  ///
  /// In en, this message translates to:
  /// **'Choose another fleet, or update what they flagged and ask again.'**
  String get goOnlineSheetDeclinedBody;

  /// No description provided for @goOnlineSheetReasonTitle.
  ///
  /// In en, this message translates to:
  /// **'Reason from the dispatcher'**
  String get goOnlineSheetReasonTitle;

  /// No description provided for @goOnlineSheetFindAnotherFleet.
  ///
  /// In en, this message translates to:
  /// **'Find another fleet'**
  String get goOnlineSheetFindAnotherFleet;

  /// No description provided for @goOnlineSheetUpdateVehicle.
  ///
  /// In en, this message translates to:
  /// **'Update my vehicle'**
  String get goOnlineSheetUpdateVehicle;

  /// No description provided for @defaultDeclinedReason.
  ///
  /// In en, this message translates to:
  /// **'Vehicle type isn\'t supported. This fleet takes bikes and cars only.'**
  String get defaultDeclinedReason;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get notificationsEmptyTitle;

  /// No description provided for @notificationsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Route updates, replies from fleets and messages from dispatch will show up here.'**
  String get notificationsEmptySubtitle;

  /// No description provided for @notificationsSettingsButton.
  ///
  /// In en, this message translates to:
  /// **'Notification settings'**
  String get notificationsSettingsButton;

  /// No description provided for @homeSetupDoneOf.
  ///
  /// In en, this message translates to:
  /// **'Setup · {done} of {total} done'**
  String homeSetupDoneOf(int done, int total);

  /// No description provided for @homeStepPending.
  ///
  /// In en, this message translates to:
  /// **'In review'**
  String get homeStepPending;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsVehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get settingsVehicle;

  /// No description provided for @settingsPlate.
  ///
  /// In en, this message translates to:
  /// **'Plate'**
  String get settingsPlate;

  /// No description provided for @settingsFleets.
  ///
  /// In en, this message translates to:
  /// **'Fleets'**
  String get settingsFleets;

  /// No description provided for @settingsQuickSettings.
  ///
  /// In en, this message translates to:
  /// **'Quick settings'**
  String get settingsQuickSettings;

  /// No description provided for @settingsNavigation.
  ///
  /// In en, this message translates to:
  /// **'Navigation'**
  String get settingsNavigation;

  /// No description provided for @settingsGoogleMaps.
  ///
  /// In en, this message translates to:
  /// **'Google Maps'**
  String get settingsGoogleMaps;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get settingsEnabled;

  /// No description provided for @settingsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get settingsDisabled;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageName.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageName;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsMyFleets.
  ///
  /// In en, this message translates to:
  /// **'My fleets'**
  String get settingsMyFleets;

  /// No description provided for @settingsNoFleetJoined.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t joined a fleet'**
  String get settingsNoFleetJoined;

  /// No description provided for @settingsJoin.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get settingsJoin;

  /// No description provided for @settingsPrivacySecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy & security'**
  String get settingsPrivacySecurity;

  /// No description provided for @settingsChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get settingsChangePassword;

  /// No description provided for @settingsLocationAccess.
  ///
  /// In en, this message translates to:
  /// **'Location access'**
  String get settingsLocationAccess;

  /// No description provided for @settingsLocationAlways.
  ///
  /// In en, this message translates to:
  /// **'Always'**
  String get settingsLocationAlways;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get settingsSupport;

  /// No description provided for @settingsContactDispatch.
  ///
  /// In en, this message translates to:
  /// **'Contact dispatch'**
  String get settingsContactDispatch;

  /// No description provided for @settingsContactDispatchLocked.
  ///
  /// In en, this message translates to:
  /// **'Unlocks when a fleet approves you'**
  String get settingsContactDispatchLocked;

  /// No description provided for @settingsHelpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help center'**
  String get settingsHelpCenter;

  /// No description provided for @settingsReportProblem.
  ///
  /// In en, this message translates to:
  /// **'Report a problem'**
  String get settingsReportProblem;

  /// No description provided for @settingsLogOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get settingsLogOut;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfileTitle;

  /// No description provided for @editProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fleets see this when you join'**
  String get editProfileSubtitle;

  /// No description provided for @editProfilePersonalDetails.
  ///
  /// In en, this message translates to:
  /// **'Personal details'**
  String get editProfilePersonalDetails;

  /// No description provided for @editProfileFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get editProfileFullName;

  /// No description provided for @editProfileFullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get editProfileFullNameHint;

  /// No description provided for @editProfileEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get editProfileEmail;

  /// No description provided for @editProfileEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get editProfileEmailHint;

  /// No description provided for @editProfilePhone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get editProfilePhone;

  /// No description provided for @editProfilePhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get editProfilePhoneHint;

  /// No description provided for @editProfilePhoneHelper.
  ///
  /// In en, this message translates to:
  /// **'A new number needs a quick code check'**
  String get editProfilePhoneHelper;

  /// No description provided for @editProfileChangeVehicle.
  ///
  /// In en, this message translates to:
  /// **'Change in Vehicle'**
  String get editProfileChangeVehicle;

  /// No description provided for @editProfileSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get editProfileSaveChanges;

  /// No description provided for @editProfileNotSaved.
  ///
  /// In en, this message translates to:
  /// **'Changes not saved'**
  String get editProfileNotSaved;

  /// No description provided for @editProfileEmailTaken.
  ///
  /// In en, this message translates to:
  /// **'Already used by another account'**
  String get editProfileEmailTaken;

  /// No description provided for @editProfilePhoneDigits.
  ///
  /// In en, this message translates to:
  /// **'Enter {count} digits after {dialCode}'**
  String editProfilePhoneDigits(int count, String dialCode);

  /// No description provided for @editProfileSummaryNameMissing.
  ///
  /// In en, this message translates to:
  /// **'the full name is missing'**
  String get editProfileSummaryNameMissing;

  /// No description provided for @editProfileSummaryNameShort.
  ///
  /// In en, this message translates to:
  /// **'the full name is too short'**
  String get editProfileSummaryNameShort;

  /// No description provided for @editProfileSummaryEmailMissing.
  ///
  /// In en, this message translates to:
  /// **'the email is missing'**
  String get editProfileSummaryEmailMissing;

  /// No description provided for @editProfileSummaryEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'the email is not valid'**
  String get editProfileSummaryEmailInvalid;

  /// No description provided for @editProfileSummaryEmailTaken.
  ///
  /// In en, this message translates to:
  /// **'this email is already used by another account'**
  String get editProfileSummaryEmailTaken;

  /// No description provided for @editProfileSummaryPhoneMissing.
  ///
  /// In en, this message translates to:
  /// **'the phone number is missing'**
  String get editProfileSummaryPhoneMissing;

  /// No description provided for @editProfileSummaryPhoneShort.
  ///
  /// In en, this message translates to:
  /// **'the phone number is too short'**
  String get editProfileSummaryPhoneShort;

  /// No description provided for @editProfileSummaryPhoneLong.
  ///
  /// In en, this message translates to:
  /// **'the phone number is too long'**
  String get editProfileSummaryPhoneLong;

  /// No description provided for @editProfileSummaryPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'the phone number is not valid'**
  String get editProfileSummaryPhoneInvalid;

  /// No description provided for @listSeparator.
  ///
  /// In en, this message translates to:
  /// **', '**
  String get listSeparator;

  /// No description provided for @listLastSeparator.
  ///
  /// In en, this message translates to:
  /// **', and '**
  String get listLastSeparator;

  /// No description provided for @profilePhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get profilePhotoTitle;

  /// No description provided for @profilePhotoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fleets and dispatch see this photo.'**
  String get profilePhotoSubtitle;

  /// No description provided for @profilePhotoTake.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get profilePhotoTake;

  /// No description provided for @profilePhotoGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get profilePhotoGallery;

  /// No description provided for @vehiclePageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fleets match orders to what you drive'**
  String get vehiclePageSubtitle;

  /// No description provided for @vehiclePageType.
  ///
  /// In en, this message translates to:
  /// **'Vehicle type'**
  String get vehiclePageType;

  /// No description provided for @vehiclePageDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get vehiclePageDetails;

  /// No description provided for @vehiclePagePlate.
  ///
  /// In en, this message translates to:
  /// **'Plate number'**
  String get vehiclePagePlate;

  /// No description provided for @vehiclePagePlateHint.
  ///
  /// In en, this message translates to:
  /// **'Enter plate number'**
  String get vehiclePagePlateHint;

  /// No description provided for @vehiclePageCapacity.
  ///
  /// In en, this message translates to:
  /// **'Load capacity'**
  String get vehiclePageCapacity;

  /// No description provided for @vehiclePageCapacityHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 800'**
  String get vehiclePageCapacityHint;

  /// No description provided for @vehiclePageKg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get vehiclePageKg;

  /// No description provided for @vehiclePageCapacityHelper.
  ///
  /// In en, this message translates to:
  /// **'Keeps your routes within what your {vehicle} can carry'**
  String vehiclePageCapacityHelper(String vehicle);

  /// No description provided for @vehiclePageCapacityInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter the load capacity in kg'**
  String get vehiclePageCapacityInvalid;

  /// No description provided for @navigationPageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Opens when you tap Start navigation'**
  String get navigationPageSubtitle;

  /// No description provided for @navigationPageApp.
  ///
  /// In en, this message translates to:
  /// **'Navigation app'**
  String get navigationPageApp;

  /// No description provided for @navigationPageSoon.
  ///
  /// In en, this message translates to:
  /// **'(Soon)'**
  String get navigationPageSoon;

  /// No description provided for @navigationPageAvoid.
  ///
  /// In en, this message translates to:
  /// **'Avoid on routes'**
  String get navigationPageAvoid;

  /// No description provided for @navigationPageAvoidSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We plan around these when we can'**
  String get navigationPageAvoidSubtitle;

  /// No description provided for @navigationPageTolls.
  ///
  /// In en, this message translates to:
  /// **'Toll roads'**
  String get navigationPageTolls;

  /// No description provided for @navigationPageHighways.
  ///
  /// In en, this message translates to:
  /// **'Highways'**
  String get navigationPageHighways;

  /// No description provided for @navigationPageUnpaved.
  ///
  /// In en, this message translates to:
  /// **'Unpaved roads'**
  String get navigationPageUnpaved;

  /// No description provided for @notificationsPageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stay informed without looking at your phone'**
  String get notificationsPageSubtitle;

  /// No description provided for @notificationsPageAlerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get notificationsPageAlerts;

  /// No description provided for @notificationsPageNewRoutes.
  ///
  /// In en, this message translates to:
  /// **'New routes'**
  String get notificationsPageNewRoutes;

  /// No description provided for @notificationsPageNewRoutesHint.
  ///
  /// In en, this message translates to:
  /// **'Always on while you\'re online'**
  String get notificationsPageNewRoutesHint;

  /// No description provided for @notificationsPageOrderChanges.
  ///
  /// In en, this message translates to:
  /// **'Order changes'**
  String get notificationsPageOrderChanges;

  /// No description provided for @notificationsPageOrderChangesHint.
  ///
  /// In en, this message translates to:
  /// **'Cancelled, updated or returned'**
  String get notificationsPageOrderChangesHint;

  /// No description provided for @notificationsPageDispatch.
  ///
  /// In en, this message translates to:
  /// **'Dispatch messages'**
  String get notificationsPageDispatch;

  /// No description provided for @notificationsPageSoundVibration.
  ///
  /// In en, this message translates to:
  /// **'Sound & vibration'**
  String get notificationsPageSoundVibration;

  /// No description provided for @notificationsPageSound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get notificationsPageSound;

  /// No description provided for @notificationsPageVibrate.
  ///
  /// In en, this message translates to:
  /// **'Vibrate'**
  String get notificationsPageVibrate;

  /// No description provided for @notificationsPageQuietHours.
  ///
  /// In en, this message translates to:
  /// **'Quiet hours'**
  String get notificationsPageQuietHours;

  /// No description provided for @notificationsPageQuietHoursHint.
  ///
  /// In en, this message translates to:
  /// **'Mutes non-urgent alerts while you\'re offline'**
  String get notificationsPageQuietHoursHint;

  /// No description provided for @notificationsPageSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get notificationsPageSchedule;

  /// No description provided for @quietScheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Quiet hours schedule'**
  String get quietScheduleTitle;

  /// No description provided for @quietScheduleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Non-urgent alerts stay silent in these hours. New routes still come through.'**
  String get quietScheduleSubtitle;

  /// No description provided for @quietScheduleFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get quietScheduleFrom;

  /// No description provided for @quietScheduleTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get quietScheduleTo;

  /// No description provided for @quietScheduleRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get quietScheduleRepeat;

  /// No description provided for @quietScheduleSave.
  ///
  /// In en, this message translates to:
  /// **'Save schedule'**
  String get quietScheduleSave;

  /// No description provided for @languagePageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Used across the app, including spoken directions'**
  String get languagePageSubtitle;

  /// No description provided for @languagePageLtr.
  ///
  /// In en, this message translates to:
  /// **'Left to right'**
  String get languagePageLtr;

  /// No description provided for @languagePageArabicRtl.
  ///
  /// In en, this message translates to:
  /// **'Arabic • right to left'**
  String get languagePageArabicRtl;

  /// No description provided for @languagePageInfo.
  ///
  /// In en, this message translates to:
  /// **'Switching to Arabic flips the layout right to left. Your orders and reports stay the same.'**
  String get languagePageInfo;

  /// No description provided for @languagePageApply.
  ///
  /// In en, this message translates to:
  /// **'Apply language'**
  String get languagePageApply;

  /// No description provided for @themePageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose how RouteX looks on this phone'**
  String get themePageSubtitle;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themePageSystemHint.
  ///
  /// In en, this message translates to:
  /// **'System follows your phone\'s light or dark setting.'**
  String get themePageSystemHint;

  /// No description provided for @themePageApply.
  ///
  /// In en, this message translates to:
  /// **'Apply theme'**
  String get themePageApply;

  /// No description provided for @myFleetsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join a fleet to start getting routes'**
  String get myFleetsSubtitle;

  /// No description provided for @myFleetsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t joined a fleet'**
  String get myFleetsEmptyTitle;

  /// No description provided for @myFleetsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Ask your fleet manager for a join code, or send a request to a fleet near you.'**
  String get myFleetsEmptyBody;

  /// No description provided for @myFleetsEnterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter fleet code'**
  String get myFleetsEnterCode;

  /// No description provided for @myFleetsNearYou.
  ///
  /// In en, this message translates to:
  /// **'Fleets near you'**
  String get myFleetsNearYou;

  /// No description provided for @myFleetsNearYouHint.
  ///
  /// In en, this message translates to:
  /// **'Based on where you are now'**
  String get myFleetsNearYouHint;

  /// No description provided for @myFleetsDistanceKm.
  ///
  /// In en, this message translates to:
  /// **'{distance} km'**
  String myFleetsDistanceKm(String distance);

  /// No description provided for @joinCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Join with code'**
  String get joinCodeTitle;

  /// No description provided for @joinCodeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your fleet manager can share it with you'**
  String get joinCodeSubtitle;

  /// No description provided for @joinCodeFleetCode.
  ///
  /// In en, this message translates to:
  /// **'Fleet code'**
  String get joinCodeFleetCode;

  /// No description provided for @joinCodeFleetCodeHint.
  ///
  /// In en, this message translates to:
  /// **'6 letters or numbers'**
  String get joinCodeFleetCodeHint;

  /// No description provided for @joinCodeMatches.
  ///
  /// In en, this message translates to:
  /// **'Code matches • {area}'**
  String joinCodeMatches(String area);

  /// No description provided for @joinCodeNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No fleet uses this code. Check it with your fleet manager.'**
  String get joinCodeNoMatch;

  /// No description provided for @joinCodeSend.
  ///
  /// In en, this message translates to:
  /// **'Send join request'**
  String get joinCodeSend;

  /// No description provided for @joinCodeReviewNote.
  ///
  /// In en, this message translates to:
  /// **'The fleet reviews your request before you can get routes.'**
  String get joinCodeReviewNote;

  /// No description provided for @joinCodeSent.
  ///
  /// In en, this message translates to:
  /// **'Join request sent to {fleet}'**
  String joinCodeSent(String fleet);

  /// No description provided for @pendingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your request is with the fleet'**
  String get pendingSubtitle;

  /// No description provided for @pendingBadge.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingBadge;

  /// No description provided for @pendingSentToday.
  ///
  /// In en, this message translates to:
  /// **'sent today, {time}'**
  String pendingSentToday(String time);

  /// No description provided for @pendingSentOn.
  ///
  /// In en, this message translates to:
  /// **'sent {date}'**
  String pendingSentOn(String date);

  /// No description provided for @pendingStepSent.
  ///
  /// In en, this message translates to:
  /// **'Request sent'**
  String get pendingStepSent;

  /// No description provided for @pendingToday.
  ///
  /// In en, this message translates to:
  /// **'Today, {time}'**
  String pendingToday(String time);

  /// No description provided for @pendingStepReviewing.
  ///
  /// In en, this message translates to:
  /// **'Fleet is reviewing your request'**
  String get pendingStepReviewing;

  /// No description provided for @pendingStepReviewingHint.
  ///
  /// In en, this message translates to:
  /// **'You\'ll get a notification when they reply'**
  String get pendingStepReviewingHint;

  /// No description provided for @pendingStepFirstShift.
  ///
  /// In en, this message translates to:
  /// **'Start your first shift'**
  String get pendingStepFirstShift;

  /// No description provided for @pendingStepFirstShiftHint.
  ///
  /// In en, this message translates to:
  /// **'Routes and orders unlock after approval'**
  String get pendingStepFirstShiftHint;

  /// No description provided for @pendingDispatchLocked.
  ///
  /// In en, this message translates to:
  /// **'Contact dispatch unlocks once {fleet} approves you.'**
  String pendingDispatchLocked(String fleet);

  /// No description provided for @pendingCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel request'**
  String get pendingCancel;

  /// No description provided for @dispatchLockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact dispatch unlocks after you join a fleet'**
  String get dispatchLockedTitle;

  /// No description provided for @dispatchLockedBody.
  ///
  /// In en, this message translates to:
  /// **'Once a fleet approves you, you can call or message their dispatch team from here.'**
  String get dispatchLockedBody;

  /// No description provided for @dispatchLockedFindFleet.
  ///
  /// In en, this message translates to:
  /// **'Find a fleet'**
  String get dispatchLockedFindFleet;

  /// No description provided for @dispatchLockedNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get dispatchLockedNotNow;

  /// No description provided for @changePasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use one you don\'t use anywhere else'**
  String get changePasswordSubtitle;

  /// No description provided for @changePasswordCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get changePasswordCurrent;

  /// No description provided for @changePasswordNew.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get changePasswordNew;

  /// No description provided for @changePasswordConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get changePasswordConfirm;

  /// No description provided for @changePasswordConfirmHint.
  ///
  /// In en, this message translates to:
  /// **'Type it again'**
  String get changePasswordConfirmHint;

  /// No description provided for @changePasswordConfirmationTo.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send a confirmation to'**
  String get changePasswordConfirmationTo;

  /// No description provided for @changePasswordUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get changePasswordUpdate;

  /// No description provided for @changePasswordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated'**
  String get changePasswordUpdated;

  /// No description provided for @passwordUpdatedSentTo.
  ///
  /// In en, this message translates to:
  /// **'We sent a confirmation to'**
  String get passwordUpdatedSentTo;

  /// No description provided for @passwordUpdatedNextLogin.
  ///
  /// In en, this message translates to:
  /// **'Use your new password next time you log in.'**
  String get passwordUpdatedNextLogin;

  /// No description provided for @passwordUpdatedBack.
  ///
  /// In en, this message translates to:
  /// **'Back to settings'**
  String get passwordUpdatedBack;

  /// No description provided for @forgotPwTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get forgotPwTitle;

  /// No description provided for @forgotPwSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send you an OTP code to reset it'**
  String get forgotPwSubtitle;

  /// No description provided for @forgotPwEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Use the email on your RouteX account'**
  String get forgotPwEmailHint;

  /// No description provided for @forgotPwSend.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get forgotPwSend;

  /// No description provided for @settingsOtpSentMessage.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a 6-digit code to your email'**
  String get settingsOtpSentMessage;

  /// No description provided for @locationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Dispatch sees where you are only while you\'re online'**
  String get locationSubtitle;

  /// No description provided for @locationAlwaysHint.
  ///
  /// In en, this message translates to:
  /// **'Keeps routes and ETAs live when the app is in the background'**
  String get locationAlwaysHint;

  /// No description provided for @locationWhileUsing.
  ///
  /// In en, this message translates to:
  /// **'While using the app'**
  String get locationWhileUsing;

  /// No description provided for @locationWhileUsingHint.
  ///
  /// In en, this message translates to:
  /// **'Tracking stops when you switch to another app'**
  String get locationWhileUsingHint;

  /// No description provided for @locationNever.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get locationNever;

  /// No description provided for @locationNeverHint.
  ///
  /// In en, this message translates to:
  /// **'You won\'t be able to go online or get routes'**
  String get locationNeverHint;

  /// No description provided for @locationWhyTitle.
  ///
  /// In en, this message translates to:
  /// **'Why it\'s required?'**
  String get locationWhyTitle;

  /// No description provided for @locationWhyDispatch.
  ///
  /// In en, this message translates to:
  /// **'Shows dispatch where you are during a shift'**
  String get locationWhyDispatch;

  /// No description provided for @locationWhyEta.
  ///
  /// In en, this message translates to:
  /// **'Keeps customer arrival times accurate'**
  String get locationWhyEta;

  /// No description provided for @locationWhyBattery.
  ///
  /// In en, this message translates to:
  /// **'Sends your position as you move, not every second, to save battery'**
  String get locationWhyBattery;

  /// No description provided for @helpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Answers to common questions'**
  String get helpSubtitle;

  /// No description provided for @helpSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search help'**
  String get helpSearchHint;

  /// No description provided for @helpGettingStarted.
  ///
  /// In en, this message translates to:
  /// **'Getting started'**
  String get helpGettingStarted;

  /// No description provided for @helpDeliveries.
  ///
  /// In en, this message translates to:
  /// **'Deliveries'**
  String get helpDeliveries;

  /// No description provided for @helpStillNeedHelp.
  ///
  /// In en, this message translates to:
  /// **'Still need help?'**
  String get helpStillNeedHelp;

  /// No description provided for @helpReportProblemHint.
  ///
  /// In en, this message translates to:
  /// **'Add details and a screenshot'**
  String get helpReportProblemHint;

  /// No description provided for @helpNoResults.
  ///
  /// In en, this message translates to:
  /// **'No answers match your search.'**
  String get helpNoResults;

  /// No description provided for @helpQJoinFleet.
  ///
  /// In en, this message translates to:
  /// **'How do I join a fleet?'**
  String get helpQJoinFleet;

  /// No description provided for @helpAJoinFleet.
  ///
  /// In en, this message translates to:
  /// **'Open Settings, then My fleets. Tap Join on a fleet near you, or enter the code your fleet manager gave you. Routes unlock once the fleet approves you.'**
  String get helpAJoinFleet;

  /// No description provided for @helpQGoOnline.
  ///
  /// In en, this message translates to:
  /// **'Why can\'t I go online yet?'**
  String get helpQGoOnline;

  /// No description provided for @helpAGoOnline.
  ///
  /// In en, this message translates to:
  /// **'You can go online once a fleet approves you and location access is set to Always or While using the app.'**
  String get helpAGoOnline;

  /// No description provided for @helpQChangeVehicle.
  ///
  /// In en, this message translates to:
  /// **'How do I change my vehicle?'**
  String get helpQChangeVehicle;

  /// No description provided for @helpAChangeVehicle.
  ///
  /// In en, this message translates to:
  /// **'Open Settings and tap your vehicle details under your profile. Choose the vehicle type, update the plate and load capacity, then save.'**
  String get helpAChangeVehicle;

  /// No description provided for @helpQProofOfDelivery.
  ///
  /// In en, this message translates to:
  /// **'How does proof of delivery work?'**
  String get helpQProofOfDelivery;

  /// No description provided for @helpAProofOfDelivery.
  ///
  /// In en, this message translates to:
  /// **'When you hand over an order, take a photo or collect the customer\'s signature in the app. The order is marked delivered once the proof is attached.'**
  String get helpAProofOfDelivery;

  /// No description provided for @helpQOffline.
  ///
  /// In en, this message translates to:
  /// **'Can I work without internet?'**
  String get helpQOffline;

  /// No description provided for @helpAOffline.
  ///
  /// In en, this message translates to:
  /// **'Yes. Your route and orders stay on your phone, and delivery updates are sent as soon as you\'re back online.'**
  String get helpAOffline;

  /// No description provided for @helpQCustomerNotHome.
  ///
  /// In en, this message translates to:
  /// **'What if the customer isn\'t home?'**
  String get helpQCustomerNotHome;

  /// No description provided for @helpACustomerNotHome.
  ///
  /// In en, this message translates to:
  /// **'Call the customer from the order. If they still don\'t answer, mark the delivery as failed with a reason and follow your fleet\'s return instructions.'**
  String get helpACustomerNotHome;

  /// No description provided for @reportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us what went wrong'**
  String get reportSubtitle;

  /// No description provided for @reportWhatAbout.
  ///
  /// In en, this message translates to:
  /// **'What\'s it about?'**
  String get reportWhatAbout;

  /// No description provided for @reportCatApp.
  ///
  /// In en, this message translates to:
  /// **'App not working'**
  String get reportCatApp;

  /// No description provided for @reportCatRoute.
  ///
  /// In en, this message translates to:
  /// **'Route or map'**
  String get reportCatRoute;

  /// No description provided for @reportCatOrder.
  ///
  /// In en, this message translates to:
  /// **'Order or proof'**
  String get reportCatOrder;

  /// No description provided for @reportCatAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get reportCatAccount;

  /// No description provided for @reportCatOther.
  ///
  /// In en, this message translates to:
  /// **'Something else'**
  String get reportCatOther;

  /// No description provided for @reportWhatHappened.
  ///
  /// In en, this message translates to:
  /// **'What happened?'**
  String get reportWhatHappened;

  /// No description provided for @reportWhatHappenedHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the problem, e.g. which order and when'**
  String get reportWhatHappenedHint;

  /// No description provided for @reportScreenshot.
  ///
  /// In en, this message translates to:
  /// **'Screenshot'**
  String get reportScreenshot;

  /// No description provided for @reportScreenshotHint.
  ///
  /// In en, this message translates to:
  /// **'Optional, but it helps us fix it faster'**
  String get reportScreenshotHint;

  /// No description provided for @reportAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get reportAdd;

  /// No description provided for @reportDeviceDetails.
  ///
  /// In en, this message translates to:
  /// **'Include device details'**
  String get reportDeviceDetails;

  /// No description provided for @reportDeviceDetailsHint.
  ///
  /// In en, this message translates to:
  /// **'Phone model and app version'**
  String get reportDeviceDetailsHint;

  /// No description provided for @reportSend.
  ///
  /// In en, this message translates to:
  /// **'Send report'**
  String get reportSend;

  /// No description provided for @reportSent.
  ///
  /// In en, this message translates to:
  /// **'Thanks, we got your report.'**
  String get reportSent;

  /// No description provided for @reportSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Report sent'**
  String get reportSentTitle;

  /// No description provided for @reportSentBody.
  ///
  /// In en, this message translates to:
  /// **'Thanks, {name}. We\'ll reply by email to {email}.'**
  String reportSentBody(String name, String email);

  /// No description provided for @reportReference.
  ///
  /// In en, this message translates to:
  /// **'Reference {reference}'**
  String reportReference(String reference);

  /// No description provided for @logoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out of RouteX?'**
  String get logoutTitle;

  /// No description provided for @logoutBody.
  ///
  /// In en, this message translates to:
  /// **'Anything that hasn\'t uploaded yet stays on this phone and uploads the next time you log in.'**
  String get logoutBody;

  /// No description provided for @homeToday.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get homeToday;

  /// No description provided for @homePercentDone.
  ///
  /// In en, this message translates to:
  /// **'{percent}% done'**
  String homePercentDone(int percent);

  /// No description provided for @homeNoOrdersYet.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get homeNoOrdersYet;

  /// No description provided for @homeOfDelivered.
  ///
  /// In en, this message translates to:
  /// **'of {total} delivered'**
  String homeOfDelivered(int total);

  /// No description provided for @homeDistanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get homeDistanceLabel;

  /// No description provided for @homeOnRouteLabel.
  ///
  /// In en, this message translates to:
  /// **'On route'**
  String get homeOnRouteLabel;

  /// No description provided for @homeCouldNotDeliverLabel.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t deliver'**
  String get homeCouldNotDeliverLabel;

  /// No description provided for @homeUpNext.
  ///
  /// In en, this message translates to:
  /// **'UP NEXT'**
  String get homeUpNext;

  /// No description provided for @homeOrdersReadyToGo.
  ///
  /// In en, this message translates to:
  /// **'{count} orders ready to go'**
  String homeOrdersReadyToGo(int count);

  /// No description provided for @homePlanFastestRoute.
  ///
  /// In en, this message translates to:
  /// **'We\'ll plan the fastest route when you start.'**
  String get homePlanFastestRoute;

  /// No description provided for @homeStartDelivery.
  ///
  /// In en, this message translates to:
  /// **'Start delivery'**
  String get homeStartDelivery;

  /// No description provided for @homeOpenRoute.
  ///
  /// In en, this message translates to:
  /// **'Open route'**
  String get homeOpenRoute;

  /// No description provided for @homeConnectToStartDelivery.
  ///
  /// In en, this message translates to:
  /// **'Connect to start delivery'**
  String get homeConnectToStartDelivery;

  /// No description provided for @homeAllCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'You’re all caught up'**
  String get homeAllCaughtUp;

  /// No description provided for @homeNewOrdersFromCompany.
  ///
  /// In en, this message translates to:
  /// **'New orders from {company} will show up here.'**
  String homeNewOrdersFromCompany(String company);

  /// No description provided for @homeGreetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get homeGreetingMorning;

  /// No description provided for @homeGreetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get homeGreetingAfternoon;

  /// No description provided for @homeGreetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get homeGreetingEvening;

  /// No description provided for @homeGreetingWithName.
  ///
  /// In en, this message translates to:
  /// **'{greeting}, {name}'**
  String homeGreetingWithName(String greeting, String name);

  /// No description provided for @homeAttentionNewOrderOffered.
  ///
  /// In en, this message translates to:
  /// **'1 new order offered'**
  String get homeAttentionNewOrderOffered;

  /// No description provided for @homeAttentionJoinsNextRoute.
  ///
  /// In en, this message translates to:
  /// **'It joins your next route'**
  String get homeAttentionJoinsNextRoute;

  /// No description provided for @homeNeedsAttention.
  ///
  /// In en, this message translates to:
  /// **'NEEDS YOUR ATTENTION'**
  String get homeNeedsAttention;

  /// No description provided for @homeYoureOffline.
  ///
  /// In en, this message translates to:
  /// **'You’re offline'**
  String get homeYoureOffline;

  /// No description provided for @homeOfflineDescription.
  ///
  /// In en, this message translates to:
  /// **'Delivery updates are saved on this phone and sync when you’re back online.'**
  String get homeOfflineDescription;

  /// No description provided for @homeOnlineWithCompany.
  ///
  /// In en, this message translates to:
  /// **'You’re online with {company}'**
  String homeOnlineWithCompany(String company);

  /// No description provided for @homeWaitingFirstOrder.
  ///
  /// In en, this message translates to:
  /// **'Waiting for your first order'**
  String get homeWaitingFirstOrder;

  /// No description provided for @homeWaitingFirstOrderBody.
  ///
  /// In en, this message translates to:
  /// **'We\'ll notify you as soon as your company sends an order. You can keep the app closed.'**
  String get homeWaitingFirstOrderBody;

  /// No description provided for @homeHowYourDayWorks.
  ///
  /// In en, this message translates to:
  /// **'HOW YOUR DAY WORKS'**
  String get homeHowYourDayWorks;

  /// No description provided for @homeStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Get orders'**
  String get homeStep1Title;

  /// No description provided for @homeStep1Desc.
  ///
  /// In en, this message translates to:
  /// **'New orders show up in the Orders tab.'**
  String get homeStep1Desc;

  /// No description provided for @homeStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Accept the ones you\'ll deliver'**
  String get homeStep2Title;

  /// No description provided for @homeStep2Desc.
  ///
  /// In en, this message translates to:
  /// **'Accepted orders join your next route.'**
  String get homeStep2Desc;

  /// No description provided for @homeStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Start delivery'**
  String get homeStep3Title;

  /// No description provided for @homeStep3Desc.
  ///
  /// In en, this message translates to:
  /// **'We plan the route and guide each stop.'**
  String get homeStep3Desc;

  /// No description provided for @homeBeforeFirstOrder.
  ///
  /// In en, this message translates to:
  /// **'BEFORE YOUR FIRST ORDER'**
  String get homeBeforeFirstOrder;

  /// No description provided for @homeNotificationsSetting.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get homeNotificationsSetting;

  /// No description provided for @homeLocationAccess.
  ///
  /// In en, this message translates to:
  /// **'Location access'**
  String get homeLocationAccess;

  /// No description provided for @homeYourVehicle.
  ///
  /// In en, this message translates to:
  /// **'Your vehicle'**
  String get homeYourVehicle;

  /// No description provided for @homeStatusOn.
  ///
  /// In en, this message translates to:
  /// **'✓ On'**
  String get homeStatusOn;

  /// No description provided for @homeStatusAlways.
  ///
  /// In en, this message translates to:
  /// **'✓ Always'**
  String get homeStatusAlways;

  /// No description provided for @homeStatusToyotaHiace.
  ///
  /// In en, this message translates to:
  /// **'Toyota Hiace'**
  String get homeStatusToyotaHiace;

  /// No description provided for @homeInAppNewOrderOffered.
  ///
  /// In en, this message translates to:
  /// **'New order offered'**
  String get homeInAppNewOrderOffered;

  /// No description provided for @homeInAppNow.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get homeInAppNow;

  /// No description provided for @homeReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get homeReview;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsSectionNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get notificationsSectionNew;

  /// No description provided for @notificationsSectionEarlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get notificationsSectionEarlier;

  /// No description provided for @notificationsEmptyDesc.
  ///
  /// In en, this message translates to:
  /// **'Route updates, replies from fleets and messages from dispatch will show up here.'**
  String get notificationsEmptyDesc;

  /// No description provided for @notifNewOrderOfferedTitle.
  ///
  /// In en, this message translates to:
  /// **'New order offered'**
  String get notifNewOrderOfferedTitle;

  /// No description provided for @notifNewOrderOfferedBody.
  ///
  /// In en, this message translates to:
  /// **'Ahmed Ali · Al Rawdah, Jeddah'**
  String get notifNewOrderOfferedBody;

  /// No description provided for @notifTime2m.
  ///
  /// In en, this message translates to:
  /// **'2m'**
  String get notifTime2m;

  /// No description provided for @notifOrderCancelledTitle.
  ///
  /// In en, this message translates to:
  /// **'Order cancelled'**
  String get notifOrderCancelledTitle;

  /// No description provided for @notifOrderCancelledBody.
  ///
  /// In en, this message translates to:
  /// **'Red Sea Express cancelled #RX-1035'**
  String get notifOrderCancelledBody;

  /// No description provided for @notifTime1h.
  ///
  /// In en, this message translates to:
  /// **'1h'**
  String get notifTime1h;

  /// No description provided for @notifRouteStartedTitle.
  ///
  /// In en, this message translates to:
  /// **'Route started'**
  String get notifRouteStartedTitle;

  /// No description provided for @notifRouteStartedBody.
  ///
  /// In en, this message translates to:
  /// **'2 of 3 orders are on your route. 1 was sent for review.'**
  String get notifRouteStartedBody;

  /// No description provided for @notifTimeYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get notifTimeYesterday;

  /// No description provided for @notifVehicleUpdatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle updated'**
  String get notifVehicleUpdatedTitle;

  /// No description provided for @notifVehicleUpdatedBody.
  ///
  /// In en, this message translates to:
  /// **'Your company set your vehicle to Toyota Hiace · PAL-99488'**
  String get notifVehicleUpdatedBody;

  /// No description provided for @notifTime2d.
  ///
  /// In en, this message translates to:
  /// **'2d'**
  String get notifTime2d;

  /// No description provided for @notifYoureApprovedTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re approved'**
  String get notifYoureApprovedTitle;

  /// No description provided for @notifYoureApprovedBody.
  ///
  /// In en, this message translates to:
  /// **'Red Sea Express approved your request. Welcome aboard!'**
  String get notifYoureApprovedBody;

  /// No description provided for @notifTime3d.
  ///
  /// In en, this message translates to:
  /// **'3d'**
  String get notifTime3d;

  /// No description provided for @joinCompanyTitleStart.
  ///
  /// In en, this message translates to:
  /// **'Join your '**
  String get joinCompanyTitleStart;

  /// No description provided for @joinCompanyTitleEnd.
  ///
  /// In en, this message translates to:
  /// **'company.'**
  String get joinCompanyTitleEnd;

  /// No description provided for @joinCompanySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-character code your company gave you. They\'ll review your request before you can take orders.'**
  String get joinCompanySubtitle;

  /// No description provided for @joinCompanyCodeCaption.
  ///
  /// In en, this message translates to:
  /// **'Letters and numbers, not case-sensitive'**
  String get joinCompanyCodeCaption;

  /// No description provided for @joinCompanyPaste.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get joinCompanyPaste;

  /// No description provided for @joinCompanyWhereFindTitle.
  ///
  /// In en, this message translates to:
  /// **'Where do I find my code?'**
  String get joinCompanyWhereFindTitle;

  /// No description provided for @joinCompanyWhereFindBody.
  ///
  /// In en, this message translates to:
  /// **'Ask your company manager. They can copy it from the RouteX dashboard and send it to you.'**
  String get joinCompanyWhereFindBody;

  /// No description provided for @joinCompanyContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get joinCompanyContinue;

  /// No description provided for @joinCompanyInvalidCode.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find a company with this code. Check it and try again.'**
  String get joinCompanyInvalidCode;

  /// No description provided for @joinCompanyCodeDisabled.
  ///
  /// In en, this message translates to:
  /// **'This code is turned off. Ask your company for a new one.'**
  String get joinCompanyCodeDisabled;

  /// No description provided for @confirmCompanyTitleStart.
  ///
  /// In en, this message translates to:
  /// **'Is this your '**
  String get confirmCompanyTitleStart;

  /// No description provided for @confirmCompanyTitleEnd.
  ///
  /// In en, this message translates to:
  /// **'company?'**
  String get confirmCompanyTitleEnd;

  /// No description provided for @confirmCompanySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Make sure it\'s the company you work with before sending your request.'**
  String get confirmCompanySubtitle;

  /// No description provided for @confirmCompanyCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Company code · {code}'**
  String confirmCompanyCodeLabel(String code);

  /// No description provided for @confirmCompanyWhatHappensNext.
  ///
  /// In en, this message translates to:
  /// **'What happens next'**
  String get confirmCompanyWhatHappensNext;

  /// No description provided for @confirmCompanyStep1.
  ///
  /// In en, this message translates to:
  /// **'{company} gets your request'**
  String confirmCompanyStep1(String company);

  /// No description provided for @confirmCompanyStep2.
  ///
  /// In en, this message translates to:
  /// **'They review it and add your vehicle'**
  String get confirmCompanyStep2;

  /// No description provided for @confirmCompanyStep3.
  ///
  /// In en, this message translates to:
  /// **'Once approved, you start getting orders'**
  String get confirmCompanyStep3;

  /// No description provided for @confirmCompanyPrivacyNotice.
  ///
  /// In en, this message translates to:
  /// **'{company} will see your name, email and phone number.'**
  String confirmCompanyPrivacyNotice(String company);

  /// No description provided for @confirmCompanySendRequest.
  ///
  /// In en, this message translates to:
  /// **'Send request'**
  String get confirmCompanySendRequest;

  /// No description provided for @requestTakingLonger.
  ///
  /// In en, this message translates to:
  /// **'This is taking longer than usual. The server may be waking up, please keep waiting.'**
  String get requestTakingLonger;

  /// No description provided for @confirmCompanyNotMyCompany.
  ///
  /// In en, this message translates to:
  /// **'Not my company'**
  String get confirmCompanyNotMyCompany;

  /// No description provided for @underReviewGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}'**
  String underReviewGreeting(String name);

  /// No description provided for @underReviewDriverAccount.
  ///
  /// In en, this message translates to:
  /// **'Driver account'**
  String get underReviewDriverAccount;

  /// No description provided for @underReviewPullDown.
  ///
  /// In en, this message translates to:
  /// **'Pull down to check for updates'**
  String get underReviewPullDown;

  /// No description provided for @underReviewChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking for updates...'**
  String get underReviewChecking;

  /// No description provided for @underReviewBadge.
  ///
  /// In en, this message translates to:
  /// **'Under review'**
  String get underReviewBadge;

  /// No description provided for @underReviewWaitingFor.
  ///
  /// In en, this message translates to:
  /// **'Waiting for {company}'**
  String underReviewWaitingFor(String company);

  /// No description provided for @underReviewWaitingBody.
  ///
  /// In en, this message translates to:
  /// **'They\'re reviewing your request. We\'ll notify you as soon as they decide.'**
  String get underReviewWaitingBody;

  /// No description provided for @underReviewYourRequest.
  ///
  /// In en, this message translates to:
  /// **'Your request'**
  String get underReviewYourRequest;

  /// No description provided for @underReviewStepSent.
  ///
  /// In en, this message translates to:
  /// **'Request sent'**
  String get underReviewStepSent;

  /// No description provided for @underReviewStepSentTime.
  ///
  /// In en, this message translates to:
  /// **'Today, 10:24 AM'**
  String get underReviewStepSentTime;

  /// No description provided for @underReviewStepReview.
  ///
  /// In en, this message translates to:
  /// **'Company review'**
  String get underReviewStepReview;

  /// No description provided for @underReviewStepInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get underReviewStepInProgress;

  /// No description provided for @underReviewStepOrders.
  ///
  /// In en, this message translates to:
  /// **'Start getting orders'**
  String get underReviewStepOrders;

  /// No description provided for @underReviewContactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get underReviewContactSupport;

  /// No description provided for @underReviewCancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel request'**
  String get underReviewCancelRequest;

  /// No description provided for @underReviewCancelDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel request?'**
  String get underReviewCancelDialogTitle;

  /// No description provided for @underReviewCancelDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel your request to join {company}?'**
  String underReviewCancelDialogMessage(String company);

  /// No description provided for @underReviewKeepRequest.
  ///
  /// In en, this message translates to:
  /// **'Keep request'**
  String get underReviewKeepRequest;

  /// No description provided for @underReviewCancelSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel your request?'**
  String get underReviewCancelSheetTitle;

  /// No description provided for @underReviewCancelSheetMessage.
  ///
  /// In en, this message translates to:
  /// **'{company} won\'t see your request anymore. You can join again later with a code.'**
  String underReviewCancelSheetMessage(String company);

  /// No description provided for @underReviewCancelSheetConfirm.
  ///
  /// In en, this message translates to:
  /// **'Yes, cancel request'**
  String get underReviewCancelSheetConfirm;

  /// No description provided for @underReviewCancelSheetKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep my request'**
  String get underReviewCancelSheetKeep;

  /// No description provided for @ordersTitle.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get ordersTitle;

  /// No description provided for @ordersSegmentOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get ordersSegmentOrders;

  /// No description provided for @ordersSegmentHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get ordersSegmentHistory;

  /// No description provided for @ordersSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search orders'**
  String get ordersSearchLabel;

  /// No description provided for @ordersNewOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 new order} other{{count} new orders}}'**
  String ordersNewOrdersTitle(int count);

  /// No description provided for @ordersNewOrdersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Added to tomorrow by dispatch'**
  String get ordersNewOrdersSubtitle;

  /// No description provided for @ordersReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get ordersReview;

  /// No description provided for @ordersSectionToday.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get ordersSectionToday;

  /// No description provided for @ordersSectionUpcoming.
  ///
  /// In en, this message translates to:
  /// **'UPCOMING'**
  String get ordersSectionUpcoming;

  /// No description provided for @ordersTodaySummary.
  ///
  /// In en, this message translates to:
  /// **'{count} left · done by {time}'**
  String ordersTodaySummary(int count, String time);

  /// No description provided for @ordersOnTheWay.
  ///
  /// In en, this message translates to:
  /// **'On the way'**
  String get ordersOnTheWay;

  /// No description provided for @ordersDeliveredToday.
  ///
  /// In en, this message translates to:
  /// **'{count} delivered today'**
  String ordersDeliveredToday(int count);

  /// No description provided for @ordersSeeThemInHistory.
  ///
  /// In en, this message translates to:
  /// **'See them in History'**
  String get ordersSeeThemInHistory;

  /// No description provided for @ordersDayOrdersCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 order} other{{count} orders}}'**
  String ordersDayOrdersCount(int count);

  /// No description provided for @ordersTodayEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing left for today'**
  String get ordersTodayEmpty;

  /// No description provided for @ordersUpcomingEmpty.
  ///
  /// In en, this message translates to:
  /// **'No scheduled days yet'**
  String get ordersUpcomingEmpty;

  /// No description provided for @errOrdersLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t load your orders. Pull down to try again.'**
  String get errOrdersLoadFailed;

  /// No description provided for @orderStatusToDo.
  ///
  /// In en, this message translates to:
  /// **'To do'**
  String get orderStatusToDo;

  /// No description provided for @orderStopOfTotal.
  ///
  /// In en, this message translates to:
  /// **'Stop {current} of {total} · Today'**
  String orderStopOfTotal(int current, int total);

  /// No description provided for @orderActionCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get orderActionCall;

  /// No description provided for @orderActionMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get orderActionMessage;

  /// No description provided for @orderActionNavigate.
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get orderActionNavigate;

  /// No description provided for @orderActionUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open that app on this phone.'**
  String get orderActionUnavailable;

  /// No description provided for @orderSectionAddress.
  ///
  /// In en, this message translates to:
  /// **'ADDRESS'**
  String get orderSectionAddress;

  /// No description provided for @orderGateCode.
  ///
  /// In en, this message translates to:
  /// **'Gate code'**
  String get orderGateCode;

  /// No description provided for @orderSectionDeliveryWindow.
  ///
  /// In en, this message translates to:
  /// **'DELIVERY WINDOW'**
  String get orderSectionDeliveryWindow;

  /// No description provided for @orderEtaOnTime.
  ///
  /// In en, this message translates to:
  /// **'ETA {time} · on time'**
  String orderEtaOnTime(String time);

  /// No description provided for @orderEtaLate.
  ///
  /// In en, this message translates to:
  /// **'ETA {time} · running late'**
  String orderEtaLate(String time);

  /// No description provided for @orderSectionPackages.
  ///
  /// In en, this message translates to:
  /// **'PACKAGES'**
  String get orderSectionPackages;

  /// No description provided for @orderPackagesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 package} other{{count} packages}}'**
  String orderPackagesCount(int count);

  /// No description provided for @orderPackagesScanned.
  ///
  /// In en, this message translates to:
  /// **'{scanned} of {total} scanned'**
  String orderPackagesScanned(int scanned, int total);

  /// No description provided for @orderRequirementSignature.
  ///
  /// In en, this message translates to:
  /// **'Signature needed'**
  String get orderRequirementSignature;

  /// No description provided for @orderRequirementPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo on delivery'**
  String get orderRequirementPhoto;

  /// No description provided for @orderSectionDispatchNote.
  ///
  /// In en, this message translates to:
  /// **'NOTE FROM DISPATCH'**
  String get orderSectionDispatchNote;

  /// No description provided for @orderMessageDispatch.
  ///
  /// In en, this message translates to:
  /// **'Message dispatch about this order'**
  String get orderMessageDispatch;

  /// No description provided for @errOrderDetailLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t load this order. Go back and try again.'**
  String get errOrderDetailLoadFailed;

  /// No description provided for @ordersCancelledTitle.
  ///
  /// In en, this message translates to:
  /// **'{name}’s order was cancelled'**
  String ordersCancelledTitle(String name);

  /// No description provided for @ordersCancelledBody.
  ///
  /// In en, this message translates to:
  /// **'Dispatch cancelled #{code} at {time}. Keep the package in your van and hand it back at the depot.'**
  String ordersCancelledBody(String code, String time);

  /// No description provided for @ordersCancelledOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ordersCancelledOk;

  /// No description provided for @ordersStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get ordersStatusCancelled;

  /// No description provided for @ordersReturnToDepot.
  ///
  /// In en, this message translates to:
  /// **'return to depot'**
  String get ordersReturnToDepot;

  /// No description provided for @searchCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get searchCancel;

  /// No description provided for @searchScanPackage.
  ///
  /// In en, this message translates to:
  /// **'Scan a package'**
  String get searchScanPackage;

  /// No description provided for @searchScopeAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get searchScopeAll;

  /// No description provided for @searchScopeToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get searchScopeToday;

  /// No description provided for @searchScopeUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get searchScopeUpcoming;

  /// No description provided for @searchResultsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 RESULT} other{{count} RESULTS}}'**
  String searchResultsCount(int count);

  /// No description provided for @searchNewBadge.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get searchNewBadge;

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No orders match “{query}”'**
  String searchNoResults(String query);

  /// No description provided for @searchHelp.
  ///
  /// In en, this message translates to:
  /// **'Search by name, street, order number or the last 4 digits of the phone. Tap the box icon to scan a package.'**
  String get searchHelp;

  /// No description provided for @searchNoResultsHint.
  ///
  /// In en, this message translates to:
  /// **'Check the spelling, or try a street name or order number. Finished orders are in History.'**
  String get searchNoResultsHint;

  /// No description provided for @searchScanInstead.
  ///
  /// In en, this message translates to:
  /// **'Scan a package instead'**
  String get searchScanInstead;

  /// No description provided for @ordersEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No orders right now'**
  String get ordersEmptyTitle;

  /// No description provided for @ordersEmptyMessageFleet.
  ///
  /// In en, this message translates to:
  /// **'When {fleet} assigns you orders, they’ll show up here and we’ll send you a notification.'**
  String ordersEmptyMessageFleet(String fleet);

  /// No description provided for @ordersEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'When dispatch assigns you orders, they’ll show up here and we’ll send you a notification.'**
  String get ordersEmptyMessage;

  /// No description provided for @ordersSeePastOrders.
  ///
  /// In en, this message translates to:
  /// **'See past orders'**
  String get ordersSeePastOrders;

  /// No description provided for @ordersOfflineNotice.
  ///
  /// In en, this message translates to:
  /// **'Showing saved orders · Updated {time}'**
  String ordersOfflineNotice(String time);

  /// No description provided for @ordersConnectionLostTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t load new orders'**
  String get ordersConnectionLostTitle;

  /// No description provided for @ordersConnectionLostMessage.
  ///
  /// In en, this message translates to:
  /// **'Showing what’s saved on this phone'**
  String get ordersConnectionLostMessage;

  /// No description provided for @ordersTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get ordersTryAgain;

  /// No description provided for @ordersLoadFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t load your orders'**
  String get ordersLoadFailedTitle;

  /// No description provided for @ordersLoadFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Check your signal and try again. If it keeps happening, call dispatch.'**
  String get ordersLoadFailedMessage;

  /// No description provided for @ordersArrivedOnDay.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 order added to {day}} other{{count} orders added to {day}}}'**
  String ordersArrivedOnDay(int count, String day);

  /// No description provided for @ordersArrived.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 new order added} other{{count} new orders added}}'**
  String ordersArrived(int count);

  /// No description provided for @ordersDayNewCount.
  ///
  /// In en, this message translates to:
  /// **'{count} new'**
  String ordersDayNewCount(int count);

  /// No description provided for @orderMinutesAway.
  ///
  /// In en, this message translates to:
  /// **'{minutes, plural, =1{1 min away} other{{minutes} min away}}'**
  String orderMinutesAway(int minutes);

  /// No description provided for @historyPeriodToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get historyPeriodToday;

  /// No description provided for @historyPeriodWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get historyPeriodWeek;

  /// No description provided for @historyPeriodMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get historyPeriodMonth;

  /// No description provided for @historyHeading.
  ///
  /// In en, this message translates to:
  /// **'{period, select, today{TODAY} week{THIS WEEK} month{THIS MONTH} other{}}'**
  String historyHeading(String period);

  /// No description provided for @historyDeliveriesUnit.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{delivery} other{deliveries}}'**
  String historyDeliveriesUnit(int count);

  /// No description provided for @historyBusier.
  ///
  /// In en, this message translates to:
  /// **'{period, select, today{A bit busier than your usual day.} week{A bit busier than your usual week.} month{A bit busier than your usual month.} other{}}'**
  String historyBusier(String period);

  /// No description provided for @historyUsual.
  ///
  /// In en, this message translates to:
  /// **'{period, select, today{About your usual day.} week{About your usual week.} month{About your usual month.} other{}}'**
  String historyUsual(String period);

  /// No description provided for @historyQuieter.
  ///
  /// In en, this message translates to:
  /// **'{period, select, today{Quieter than your usual day.} week{Quieter than your usual week.} month{Quieter than your usual month.} other{}}'**
  String historyQuieter(String period);

  /// No description provided for @historyPercent.
  ///
  /// In en, this message translates to:
  /// **'{value}%'**
  String historyPercent(int value);

  /// No description provided for @historyKm.
  ///
  /// In en, this message translates to:
  /// **'{km} km'**
  String historyKm(int km);

  /// No description provided for @historyDuration.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String historyDuration(int hours, String minutes);

  /// No description provided for @historyStatDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get historyStatDelivered;

  /// No description provided for @historyStatDriven.
  ///
  /// In en, this message translates to:
  /// **'Driven'**
  String get historyStatDriven;

  /// No description provided for @historyStatOnTheRoad.
  ///
  /// In en, this message translates to:
  /// **'On the road'**
  String get historyStatOnTheRoad;

  /// No description provided for @historyCouldNotDeliver.
  ///
  /// In en, this message translates to:
  /// **'{count} couldn’t deliver'**
  String historyCouldNotDeliver(int count);

  /// No description provided for @historyMostCommon.
  ///
  /// In en, this message translates to:
  /// **'Most common: {reason}'**
  String historyMostCommon(String reason);

  /// No description provided for @historyReasonNoAnswer.
  ///
  /// In en, this message translates to:
  /// **'customer not answering'**
  String get historyReasonNoAnswer;

  /// No description provided for @historyReasonAddress.
  ///
  /// In en, this message translates to:
  /// **'address not found'**
  String get historyReasonAddress;

  /// No description provided for @historyReasonRefused.
  ///
  /// In en, this message translates to:
  /// **'customer refused'**
  String get historyReasonRefused;

  /// No description provided for @historySectionDays.
  ///
  /// In en, this message translates to:
  /// **'DAYS'**
  String get historySectionDays;

  /// No description provided for @historyDeliveredSoFar.
  ///
  /// In en, this message translates to:
  /// **'{count} delivered so far'**
  String historyDeliveredSoFar(int count);

  /// No description provided for @historyDeliveredOfTotal.
  ///
  /// In en, this message translates to:
  /// **'{delivered} of {total} delivered'**
  String historyDeliveredOfTotal(int delivered, int total);

  /// No description provided for @historyDayOff.
  ///
  /// In en, this message translates to:
  /// **'Day off'**
  String get historyDayOff;

  /// No description provided for @historyInReview.
  ///
  /// In en, this message translates to:
  /// **'{count} in review'**
  String historyInReview(int count);

  /// No description provided for @historyDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'{period, select, today{Today} week{This week} month{This month} other{}}'**
  String historyDetailTitle(String period);

  /// No description provided for @historyDetailMore.
  ///
  /// In en, this message translates to:
  /// **'You delivered {orders}, {diff} more than your usual {period, select, today{day} week{week} month{month} other{}}.'**
  String historyDetailMore(String orders, int diff, String period);

  /// No description provided for @historyDetailFewer.
  ///
  /// In en, this message translates to:
  /// **'You delivered {orders}, {diff} fewer than your usual {period, select, today{day} week{week} month{month} other{}}.'**
  String historyDetailFewer(String orders, int diff, String period);

  /// No description provided for @historyDetailSame.
  ///
  /// In en, this message translates to:
  /// **'You delivered {orders}, the same as your usual {period, select, today{day} week{week} month{month} other{}}.'**
  String historyDetailSame(String orders, String period);

  /// No description provided for @historyDeliveredUnitShort.
  ///
  /// In en, this message translates to:
  /// **'delivered'**
  String get historyDeliveredUnitShort;

  /// No description provided for @historyUsualPerBar.
  ///
  /// In en, this message translates to:
  /// **'{period, select, today{Your usual for this time: {value}} week{Your usual day: {value}} month{Your usual week: {value}} other{}}'**
  String historyUsualPerBar(String period, String value);

  /// No description provided for @historyDeliveredOfAssigned.
  ///
  /// In en, this message translates to:
  /// **'{delivered} of {assigned} orders. Cancelled orders don’t count.'**
  String historyDeliveredOfAssigned(int delivered, int assigned);

  /// No description provided for @historyDriving.
  ///
  /// In en, this message translates to:
  /// **'{duration} driving'**
  String historyDriving(String duration);

  /// No description provided for @historyAtStops.
  ///
  /// In en, this message translates to:
  /// **'{duration} at stops'**
  String historyAtStops(String duration);

  /// No description provided for @historyDistanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get historyDistanceTitle;

  /// No description provided for @historyKmPerDay.
  ///
  /// In en, this message translates to:
  /// **'About {km} km a day you worked'**
  String historyKmPerDay(int km);

  /// No description provided for @historyCouldNotDeliverTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t deliver'**
  String get historyCouldNotDeliverTitle;

  /// No description provided for @historyPrivacyFleet.
  ///
  /// In en, this message translates to:
  /// **'Only you and {fleet} dispatch can see these numbers.'**
  String historyPrivacyFleet(String fleet);

  /// No description provided for @historyPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Only you and dispatch can see these numbers.'**
  String get historyPrivacy;

  /// No description provided for @historySectionStops.
  ///
  /// In en, this message translates to:
  /// **'STOPS'**
  String get historySectionStops;

  /// No description provided for @historyOfTotal.
  ///
  /// In en, this message translates to:
  /// **'{delivered} of {total}'**
  String historyOfTotal(int delivered, int total);

  /// No description provided for @historyStopInReview.
  ///
  /// In en, this message translates to:
  /// **'In review'**
  String get historyStopInReview;

  /// No description provided for @historyStopOfTotal.
  ///
  /// In en, this message translates to:
  /// **'Stop {n} of {total}'**
  String historyStopOfTotal(int n, int total);

  /// No description provided for @historyStopNotDelivered.
  ///
  /// In en, this message translates to:
  /// **'Not delivered'**
  String get historyStopNotDelivered;

  /// No description provided for @historyFailedInReview.
  ///
  /// In en, this message translates to:
  /// **'{reason}. Dispatch is checking it, nothing to do for now.'**
  String historyFailedInReview(String reason);

  /// No description provided for @historyFailedClosed.
  ///
  /// In en, this message translates to:
  /// **'{reason}.'**
  String historyFailedClosed(String reason);

  /// No description provided for @historyDeliveredAt.
  ///
  /// In en, this message translates to:
  /// **'Handed over at {time}.'**
  String historyDeliveredAt(String time);

  /// No description provided for @historyWhatHappened.
  ///
  /// In en, this message translates to:
  /// **'WHAT HAPPENED'**
  String get historyWhatHappened;

  /// No description provided for @historyEventArrived.
  ///
  /// In en, this message translates to:
  /// **'Arrived'**
  String get historyEventArrived;

  /// No description provided for @historyEventArrivedDetail.
  ///
  /// In en, this message translates to:
  /// **'GPS: {meters} m from the address'**
  String historyEventArrivedDetail(int meters);

  /// No description provided for @historyEventCalled.
  ///
  /// In en, this message translates to:
  /// **'Called the customer'**
  String get historyEventCalled;

  /// No description provided for @historyEventCalledAgain.
  ///
  /// In en, this message translates to:
  /// **'Called again'**
  String get historyEventCalledAgain;

  /// No description provided for @historyEventNoAnswer.
  ///
  /// In en, this message translates to:
  /// **'No answer'**
  String get historyEventNoAnswer;

  /// No description provided for @historyEventAnswered.
  ///
  /// In en, this message translates to:
  /// **'Answered'**
  String get historyEventAnswered;

  /// No description provided for @historyEventWaited.
  ///
  /// In en, this message translates to:
  /// **'waited {minutes} min'**
  String historyEventWaited(int minutes);

  /// No description provided for @historyEventMarkedFailed.
  ///
  /// In en, this message translates to:
  /// **'Marked couldn’t deliver'**
  String get historyEventMarkedFailed;

  /// No description provided for @historyEventReason.
  ///
  /// In en, this message translates to:
  /// **'Reason: {reason}'**
  String historyEventReason(String reason);

  /// No description provided for @historyEventPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo taken'**
  String get historyEventPhoto;

  /// No description provided for @historyEventDelivered.
  ///
  /// In en, this message translates to:
  /// **'Marked delivered'**
  String get historyEventDelivered;

  /// No description provided for @historyEventReturned.
  ///
  /// In en, this message translates to:
  /// **'Package handed back at depot'**
  String get historyEventReturned;

  /// No description provided for @historyClosedPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Customer details are hidden once a stop is closed.'**
  String get historyClosedPrivacy;

  /// No description provided for @historyReportIssue.
  ///
  /// In en, this message translates to:
  /// **'Report an issue with this stop'**
  String get historyReportIssue;

  /// No description provided for @reportIssueTitle.
  ///
  /// In en, this message translates to:
  /// **'What’s wrong with this stop?'**
  String get reportIssueTitle;

  /// No description provided for @reportIssueStatusWrong.
  ///
  /// In en, this message translates to:
  /// **'The status is wrong'**
  String get reportIssueStatusWrong;

  /// No description provided for @reportIssueNotInControl.
  ///
  /// In en, this message translates to:
  /// **'It wasn’t in my control'**
  String get reportIssueNotInControl;

  /// No description provided for @reportIssueTimesWrong.
  ///
  /// In en, this message translates to:
  /// **'The times are wrong'**
  String get reportIssueTimesWrong;

  /// No description provided for @reportIssueOther.
  ///
  /// In en, this message translates to:
  /// **'Something else'**
  String get reportIssueOther;

  /// No description provided for @reportIssueNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Add details for dispatch (optional)'**
  String get reportIssueNoteHint;

  /// No description provided for @reportIssueNoteHintRequired.
  ///
  /// In en, this message translates to:
  /// **'Tell dispatch what happened'**
  String get reportIssueNoteHintRequired;

  /// No description provided for @reportIssueSend.
  ///
  /// In en, this message translates to:
  /// **'Send to dispatch'**
  String get reportIssueSend;

  /// No description provided for @reportIssueFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t send. Check your signal and try again.'**
  String get reportIssueFailed;

  /// No description provided for @historyIssueSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Issue sent to dispatch'**
  String get historyIssueSentTitle;

  /// No description provided for @historyIssueSentBody.
  ///
  /// In en, this message translates to:
  /// **'You’ll get their reply in Notifications.'**
  String get historyIssueSentBody;

  /// No description provided for @historyIssueSentToast.
  ///
  /// In en, this message translates to:
  /// **'Sent. Thanks for flagging it.'**
  String get historyIssueSentToast;

  /// No description provided for @historyProofTitle.
  ///
  /// In en, this message translates to:
  /// **'PROOF OF DELIVERY'**
  String get historyProofTitle;

  /// No description provided for @historyProofPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get historyProofPhoto;

  /// No description provided for @historyProofSignature.
  ///
  /// In en, this message translates to:
  /// **'Signature'**
  String get historyProofSignature;

  /// No description provided for @historyProofDistance.
  ///
  /// In en, this message translates to:
  /// **'{meters} m away'**
  String historyProofDistance(int meters);

  /// No description provided for @historyHandoverCustomer.
  ///
  /// In en, this message translates to:
  /// **'Handed to the customer at the door.'**
  String get historyHandoverCustomer;

  /// No description provided for @historyHandoverReception.
  ///
  /// In en, this message translates to:
  /// **'Left with reception.'**
  String get historyHandoverReception;

  /// No description provided for @historyHandoverGuard.
  ///
  /// In en, this message translates to:
  /// **'Handed to the building guard.'**
  String get historyHandoverGuard;

  /// No description provided for @historyEventSigned.
  ///
  /// In en, this message translates to:
  /// **'Signed by the customer'**
  String get historyEventSigned;

  /// No description provided for @historyNotEnoughData.
  ///
  /// In en, this message translates to:
  /// **'Not enough data yet'**
  String get historyNotEnoughData;

  /// No description provided for @historyNotEnoughDataBody.
  ///
  /// In en, this message translates to:
  /// **'{period, select, today{After your first few deliveries you’ll see your day here, compared with your usual day.} week{After your first few deliveries you’ll see your week here, compared with your usual week.} month{After your first few deliveries you’ll see your month here, compared with your usual month.} other{}}'**
  String historyNotEnoughDataBody(String period);

  /// No description provided for @historyEmptyDaysTitle.
  ///
  /// In en, this message translates to:
  /// **'Your finished stops will show up here'**
  String get historyEmptyDaysTitle;

  /// No description provided for @historyEmptyDaysBody.
  ///
  /// In en, this message translates to:
  /// **'Each day gets its own record you can open later.'**
  String get historyEmptyDaysBody;

  /// No description provided for @historyMonthComparison.
  ///
  /// In en, this message translates to:
  /// **'{comparison, select, busier{A bit busier than your usual month so far.} usual{About the same as your usual month so far.} quieter{Quieter than your usual month so far.} other{}}'**
  String historyMonthComparison(String comparison);

  /// No description provided for @historyWorthALook.
  ///
  /// In en, this message translates to:
  /// **'Worth a look'**
  String get historyWorthALook;

  /// No description provided for @historyDeliveredBelowUsual.
  ///
  /// In en, this message translates to:
  /// **'Delivered is at {percent}%, a little under your usual {usual}%.'**
  String historyDeliveredBelowUsual(int percent, int usual);

  /// No description provided for @historyMostMissesThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Most misses this month: {reason} ({count}).'**
  String historyMostMissesThisMonth(String reason, int count);

  /// No description provided for @historyMissTip.
  ///
  /// In en, this message translates to:
  /// **'{reason, select, customerNotAnswering{Calling before you arrive can help.} addressNotFound{Checking the pin before you set off can help.} other{}}'**
  String historyMissTip(String reason);

  /// No description provided for @historySectionWeeks.
  ///
  /// In en, this message translates to:
  /// **'WEEKS'**
  String get historySectionWeeks;

  /// No description provided for @historyThisWeekRange.
  ///
  /// In en, this message translates to:
  /// **'This week · {range}'**
  String historyThisWeekRange(String range);

  /// No description provided for @historyCountDelivered.
  ///
  /// In en, this message translates to:
  /// **'{count} delivered'**
  String historyCountDelivered(int count);

  /// No description provided for @historyOfflineNotice.
  ///
  /// In en, this message translates to:
  /// **'Showing saved history · Updated {time}'**
  String historyOfflineNotice(String time);

  /// No description provided for @historyIncludesUnsynced.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Includes 1 stop not synced yet} other{Includes {count} stops not synced yet}}'**
  String historyIncludesUnsynced(int count);

  /// No description provided for @historyWaitingToSync.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 update waiting to sync} other{{count} updates waiting to sync}}'**
  String historyWaitingToSync(int count);

  /// No description provided for @historyWaitingToSyncBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Saved on this phone. It’ll upload on its own.} other{Saved on this phone. They’ll upload on their own.}}'**
  String historyWaitingToSyncBody(int count);

  /// No description provided for @syncTitle.
  ///
  /// In en, this message translates to:
  /// **'Waiting to sync'**
  String get syncTitle;

  /// No description provided for @syncSubtitle.
  ///
  /// In en, this message translates to:
  /// **'These are saved on your phone and will upload by themselves when you have signal.'**
  String get syncSubtitle;

  /// No description provided for @syncWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get syncWaiting;

  /// No description provided for @syncDeliveredAt.
  ///
  /// In en, this message translates to:
  /// **'Delivered {time}'**
  String syncDeliveredAt(String time);

  /// No description provided for @syncFailedAt.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t deliver {time}'**
  String syncFailedAt(String time);

  /// No description provided for @syncPartPhoto.
  ///
  /// In en, this message translates to:
  /// **'photo'**
  String get syncPartPhoto;

  /// No description provided for @syncPartSignature.
  ///
  /// In en, this message translates to:
  /// **'signature'**
  String get syncPartSignature;

  /// No description provided for @syncPartStatus.
  ///
  /// In en, this message translates to:
  /// **'status'**
  String get syncPartStatus;

  /// No description provided for @syncPartsJoin.
  ///
  /// In en, this message translates to:
  /// **'{rest} and {last}'**
  String syncPartsJoin(String rest, String last);

  /// No description provided for @syncKeepAppWarning.
  ///
  /// In en, this message translates to:
  /// **'Don’t sign out or delete the app until these are synced, or they’ll be lost.'**
  String get syncKeepAppWarning;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get syncNow;

  /// No description provided for @syncNoSignal.
  ///
  /// In en, this message translates to:
  /// **'No signal yet. They’ll upload once you’re back online.'**
  String get syncNoSignal;

  /// No description provided for @syncAllUploaded.
  ///
  /// In en, this message translates to:
  /// **'Everything is uploaded.'**
  String get syncAllUploaded;

  /// No description provided for @historySummaryFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'{period, select, today{Today’s summary didn’t load} week{This week’s summary didn’t load} month{This month’s summary didn’t load} other{}}'**
  String historySummaryFailedTitle(String period);

  /// No description provided for @historySummaryFailedBody.
  ///
  /// In en, this message translates to:
  /// **'{period, select, month{Your weeks below are up to date.} other{Your days below are up to date.}}'**
  String historySummaryFailedBody(String period);

  /// No description provided for @orderOfferNotificationAppLabel.
  ///
  /// In en, this message translates to:
  /// **'ROUTEX · NEW ORDER · NOW'**
  String get orderOfferNotificationAppLabel;

  /// No description provided for @orderOfferNotificationGroupAppLabel.
  ///
  /// In en, this message translates to:
  /// **'ROUTEX · {count} NEW ORDERS · NOW'**
  String orderOfferNotificationGroupAppLabel(int count);

  /// No description provided for @orderOfferNotificationSingleTitle.
  ///
  /// In en, this message translates to:
  /// **'New order: {customer}, {area}'**
  String orderOfferNotificationSingleTitle(String customer, String area);

  /// No description provided for @orderOfferNotificationGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'{count} new orders for tomorrow'**
  String orderOfferNotificationGroupTitle(int count);

  /// No description provided for @orderOfferNotificationDetails.
  ///
  /// In en, this message translates to:
  /// **'{packages, plural, =1{1 package} other{{packages} packages}} · {distance} to your route · answer in {deadline}'**
  String orderOfferNotificationDetails(
    int packages,
    String distance,
    String deadline,
  );

  /// No description provided for @orderOfferNotificationGroupDetails.
  ///
  /// In en, this message translates to:
  /// **'{areas} · {distance} · answer in {deadline}'**
  String orderOfferNotificationGroupDetails(
    String areas,
    String distance,
    String deadline,
  );

  /// No description provided for @homeOrderOfferTitle.
  ///
  /// In en, this message translates to:
  /// **'{count} new orders'**
  String homeOrderOfferTitle(int count);

  /// No description provided for @homeOrderOfferSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{fleet} · answer in {deadline}'**
  String homeOrderOfferSubtitle(String fleet, String deadline);

  /// No description provided for @homeOrderOfferView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get homeOrderOfferView;

  /// No description provided for @offerOneOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get offerOneOrderTitle;

  /// No description provided for @offerOneOrderCountdown.
  ///
  /// In en, this message translates to:
  /// **'{time} left'**
  String offerOneOrderCountdown(String time);

  /// No description provided for @offerOneOrderNewFromFleet.
  ///
  /// In en, this message translates to:
  /// **'New order · {fleet}'**
  String offerOneOrderNewFromFleet(String fleet);

  /// No description provided for @offerOneOrderTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get offerOneOrderTomorrow;

  /// No description provided for @offerOneOrderRouteDistance.
  ///
  /// In en, this message translates to:
  /// **'{distance} · +{minutes} min to your route'**
  String offerOneOrderRouteDistance(String distance, int minutes);

  /// No description provided for @offerOneOrderAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get offerOneOrderAddress;

  /// No description provided for @offerOneOrderDelivery.
  ///
  /// In en, this message translates to:
  /// **'Deliver {window}'**
  String offerOneOrderDelivery(String window);

  /// No description provided for @offerOneOrderFitsAfterStop.
  ///
  /// In en, this message translates to:
  /// **'Fits after stop {stop} on your route'**
  String offerOneOrderFitsAfterStop(int stop);

  /// No description provided for @offerOneOrderPackages.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 package} other{{count} packages}}'**
  String offerOneOrderPackages(int count);

  /// No description provided for @offerOneOrderSignatureNeeded.
  ///
  /// In en, this message translates to:
  /// **'Signature needed at the door'**
  String get offerOneOrderSignatureNeeded;

  /// No description provided for @offerOneOrderCompanyNote.
  ///
  /// In en, this message translates to:
  /// **'Note from your company'**
  String get offerOneOrderCompanyNote;

  /// No description provided for @offerOneOrderNoAnswer.
  ///
  /// In en, this message translates to:
  /// **'If you don’t answer, the order goes back to {fleet}.'**
  String offerOneOrderNoAnswer(String fleet);

  /// No description provided for @offerOneOrderDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get offerOneOrderDecline;

  /// No description provided for @offerOneOrderAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept order'**
  String get offerOneOrderAccept;

  /// No description provided for @orderOfferNotificationAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get orderOfferNotificationAccept;

  /// No description provided for @orderOfferNotificationDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get orderOfferNotificationDecline;

  /// No description provided for @orderOfferNotificationViewOrders.
  ///
  /// In en, this message translates to:
  /// **'View orders'**
  String get orderOfferNotificationViewOrders;

  /// No description provided for @historyRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get historyRetry;

  /// No description provided for @offerTimesUp.
  ///
  /// In en, this message translates to:
  /// **'Time’s up'**
  String get offerTimesUp;

  /// No description provided for @offerNoLongerAvailable.
  ///
  /// In en, this message translates to:
  /// **'No longer available'**
  String get offerNoLongerAvailable;

  /// No description provided for @offerGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 new order} other{{count} new orders}}'**
  String offerGroupTitle(int count);

  /// No description provided for @offerGroupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'For {day}. Pick the ones you can take.'**
  String offerGroupSubtitle(String day);

  /// No description provided for @offerStopsAdded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{stop added} other{stops added}}'**
  String offerStopsAdded(int count);

  /// No description provided for @offerToYourRoute.
  ///
  /// In en, this message translates to:
  /// **'to your route'**
  String get offerToYourRoute;

  /// No description provided for @offerDriving.
  ///
  /// In en, this message translates to:
  /// **'driving'**
  String get offerDriving;

  /// No description provided for @offerKmDelta.
  ///
  /// In en, this message translates to:
  /// **'+{km} km'**
  String offerKmDelta(String km);

  /// No description provided for @offerMinutesDelta.
  ///
  /// In en, this message translates to:
  /// **'+{minutes} min'**
  String offerMinutesDelta(int minutes);

  /// No description provided for @offerRowTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} · #{code}'**
  String offerRowTitle(String name, String code);

  /// No description provided for @offerRowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{area} · {window}'**
  String offerRowSubtitle(String area, String window);

  /// No description provided for @offerSkipping.
  ///
  /// In en, this message translates to:
  /// **'Skipping'**
  String get offerSkipping;

  /// No description provided for @offerSkipHint.
  ///
  /// In en, this message translates to:
  /// **'Tap an order to leave it out. Your company sees which ones you skipped.'**
  String get offerSkipHint;

  /// No description provided for @offerGroupNoAnswer.
  ///
  /// In en, this message translates to:
  /// **'If you don’t answer, all {count} go back to {fleet}.'**
  String offerGroupNoAnswer(int count, String fleet);

  /// No description provided for @offerDeclineAll.
  ///
  /// In en, this message translates to:
  /// **'Decline all'**
  String get offerDeclineAll;

  /// No description provided for @offerAcceptAll.
  ///
  /// In en, this message translates to:
  /// **'Accept all {count}'**
  String offerAcceptAll(int count);

  /// No description provided for @offerAcceptSome.
  ///
  /// In en, this message translates to:
  /// **'Accept {accepted}, skip {skipped}'**
  String offerAcceptSome(int accepted, int skipped);

  /// No description provided for @offerDeclineTitle.
  ///
  /// In en, this message translates to:
  /// **'Why are you declining?'**
  String get offerDeclineTitle;

  /// No description provided for @offerReasonVanFull.
  ///
  /// In en, this message translates to:
  /// **'My van is full'**
  String get offerReasonVanFull;

  /// No description provided for @offerReasonOutsideArea.
  ///
  /// In en, this message translates to:
  /// **'It’s outside my area'**
  String get offerReasonOutsideArea;

  /// No description provided for @offerReasonShiftEnds.
  ///
  /// In en, this message translates to:
  /// **'My shift ends before then'**
  String get offerReasonShiftEnds;

  /// No description provided for @offerReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Something else'**
  String get offerReasonOther;

  /// No description provided for @offerDeclineNotice.
  ///
  /// In en, this message translates to:
  /// **'{fleet} will offer the order to another driver.'**
  String offerDeclineNotice(String fleet);

  /// No description provided for @offerDeclineOrder.
  ///
  /// In en, this message translates to:
  /// **'Decline order'**
  String get offerDeclineOrder;

  /// No description provided for @offerKeepOrder.
  ///
  /// In en, this message translates to:
  /// **'Keep the order'**
  String get offerKeepOrder;

  /// No description provided for @offerAcceptedTitle.
  ///
  /// In en, this message translates to:
  /// **'Added to your route'**
  String get offerAcceptedTitle;

  /// No description provided for @offerAcceptedOne.
  ///
  /// In en, this message translates to:
  /// **'{name} is now stop {stop} of {total}. We re-planned the route so you still finish by {time}.'**
  String offerAcceptedOne(String name, int stop, int total, String time);

  /// No description provided for @offerAcceptedMany.
  ///
  /// In en, this message translates to:
  /// **'{count} orders added, from stop {stop} of {total}. We re-planned the route so you still finish by {time}.'**
  String offerAcceptedMany(int count, int stop, int total, String time);

  /// No description provided for @offerStopsTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Stops tomorrow'**
  String get offerStopsTomorrow;

  /// No description provided for @offerDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get offerDistance;

  /// No description provided for @offerDoneBy.
  ///
  /// In en, this message translates to:
  /// **'Done by'**
  String get offerDoneBy;

  /// No description provided for @offerKm.
  ///
  /// In en, this message translates to:
  /// **'{km} km'**
  String offerKm(String km);

  /// No description provided for @offerSeeRoute.
  ///
  /// In en, this message translates to:
  /// **'See tomorrow’s route'**
  String get offerSeeRoute;

  /// No description provided for @offerBackToOrders.
  ///
  /// In en, this message translates to:
  /// **'Back to orders'**
  String get offerBackToOrders;

  /// No description provided for @offerDeclinedTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Order declined} other{Orders declined}}'**
  String offerDeclinedTitle(int count);

  /// No description provided for @offerDeclinedBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{fleet} will give it to another driver.} other{{fleet} will give them to another driver.}}'**
  String offerDeclinedBody(int count, String fleet);

  /// No description provided for @offerUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get offerUndo;

  /// No description provided for @offerExpiredTitle.
  ///
  /// In en, this message translates to:
  /// **'This offer expired'**
  String get offerExpiredTitle;

  /// No description provided for @offerExpiredBody.
  ///
  /// In en, this message translates to:
  /// **'You didn’t answer in {minutes} minutes, so it went back to {fleet}. Nothing changed on your route.'**
  String offerExpiredBody(int minutes, String fleet);

  /// No description provided for @offerTakenBackTitle.
  ///
  /// In en, this message translates to:
  /// **'{fleet} took this order back'**
  String offerTakenBackTitle(String fleet);

  /// No description provided for @offerTakenBackBody.
  ///
  /// In en, this message translates to:
  /// **'They gave it to another driver before you answered. Nothing changed on your route.'**
  String get offerTakenBackBody;

  /// No description provided for @offerOfflineAcceptTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t accept. You’re offline.'**
  String get offerOfflineAcceptTitle;

  /// No description provided for @offerOfflineDeclineTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t decline. You’re offline.'**
  String get offerOfflineDeclineTitle;

  /// No description provided for @offerOfflineBody.
  ///
  /// In en, this message translates to:
  /// **'The offer stays open while the timer runs.'**
  String get offerOfflineBody;

  /// No description provided for @offerFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t send your answer.'**
  String get offerFailedTitle;

  /// No description provided for @offerFailedBody.
  ///
  /// In en, this message translates to:
  /// **'Try again before the timer runs out.'**
  String get offerFailedBody;

  /// No description provided for @offersWaitingTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 order waiting for you} other{{count} orders waiting for you}}'**
  String offersWaitingTitle(int count);

  /// No description provided for @offersWaitingBody.
  ///
  /// In en, this message translates to:
  /// **'Answer in {time} or they go back'**
  String offersWaitingBody(String time);

  /// No description provided for @offersView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get offersView;

  /// No description provided for @editProfileFirstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get editProfileFirstName;

  /// No description provided for @editProfileFirstNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your first name'**
  String get editProfileFirstNameHint;

  /// No description provided for @editProfileLastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get editProfileLastName;

  /// No description provided for @editProfileLastNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your last name'**
  String get editProfileLastNameHint;

  /// No description provided for @editProfileSummaryFirstNameMissing.
  ///
  /// In en, this message translates to:
  /// **'the first name is missing'**
  String get editProfileSummaryFirstNameMissing;

  /// No description provided for @editProfileSummaryFirstNameShort.
  ///
  /// In en, this message translates to:
  /// **'the first name is too short'**
  String get editProfileSummaryFirstNameShort;

  /// No description provided for @editProfileSummaryLastNameMissing.
  ///
  /// In en, this message translates to:
  /// **'the last name is missing'**
  String get editProfileSummaryLastNameMissing;

  /// No description provided for @editProfileSummaryLastNameShort.
  ///
  /// In en, this message translates to:
  /// **'the last name is too short'**
  String get editProfileSummaryLastNameShort;

  /// No description provided for @editProfileCompanySees.
  ///
  /// In en, this message translates to:
  /// **'{company} sees these details'**
  String editProfileCompanySees(String company);

  /// No description provided for @editProfileSetByCompany.
  ///
  /// In en, this message translates to:
  /// **'Set by your company'**
  String get editProfileSetByCompany;

  /// No description provided for @profilePhotoCompanySees.
  ///
  /// In en, this message translates to:
  /// **'Your company sees this photo.'**
  String get profilePhotoCompanySees;

  /// No description provided for @vehicleManagedBy.
  ///
  /// In en, this message translates to:
  /// **'Managed by {company}'**
  String vehicleManagedBy(String company);

  /// No description provided for @vehicleManagedByYourCompany.
  ///
  /// In en, this message translates to:
  /// **'Managed by your company'**
  String get vehicleManagedByYourCompany;

  /// No description provided for @vehicleCompanyManages.
  ///
  /// In en, this message translates to:
  /// **'Your company manages your vehicle. Contact them if anything needs to change.'**
  String get vehicleCompanyManages;

  /// No description provided for @vehicleType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get vehicleType;

  /// No description provided for @vehicleColour.
  ///
  /// In en, this message translates to:
  /// **'Colour'**
  String get vehicleColour;

  /// No description provided for @navigationPageSubtitleStop.
  ///
  /// In en, this message translates to:
  /// **'Opens when you tap Navigate on a stop'**
  String get navigationPageSubtitleStop;

  /// No description provided for @editProfileYourCompanySees.
  ///
  /// In en, this message translates to:
  /// **'Your company sees these details'**
  String get editProfileYourCompanySees;

  /// No description provided for @settingsCompany.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get settingsCompany;

  /// No description provided for @settingsCompanyActiveJoined.
  ///
  /// In en, this message translates to:
  /// **'Active · Joined {date}'**
  String settingsCompanyActiveJoined(String date);

  /// No description provided for @settingsCompanyActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get settingsCompanyActive;

  /// No description provided for @myCompanyTitle.
  ///
  /// In en, this message translates to:
  /// **'My company'**
  String get myCompanyTitle;

  /// No description provided for @myCompanySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Who you deliver for'**
  String get myCompanySubtitle;

  /// No description provided for @myCompanyJoined.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get myCompanyJoined;

  /// No description provided for @myCompanyCode.
  ///
  /// In en, this message translates to:
  /// **'Company code'**
  String get myCompanyCode;

  /// No description provided for @myCompanyVehicle.
  ///
  /// In en, this message translates to:
  /// **'Your vehicle'**
  String get myCompanyVehicle;

  /// No description provided for @myCompanyCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get myCompanyCall;

  /// No description provided for @myCompanyEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get myCompanyEmail;

  /// No description provided for @myCompanyCantOpen.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open this on your phone.'**
  String get myCompanyCantOpen;

  /// No description provided for @settingsContactCompany.
  ///
  /// In en, this message translates to:
  /// **'Contact your company'**
  String get settingsContactCompany;

  /// No description provided for @settingsContactCompanyHint.
  ///
  /// In en, this message translates to:
  /// **'Call or message {company}'**
  String settingsContactCompanyHint(String company);

  /// No description provided for @settingsContactCompanyHintFallback.
  ///
  /// In en, this message translates to:
  /// **'Call or message your company'**
  String get settingsContactCompanyHintFallback;

  /// No description provided for @contactCompanyTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact {company}'**
  String contactCompanyTitle(String company);

  /// No description provided for @contactCompanyBody.
  ///
  /// In en, this message translates to:
  /// **'For questions about orders, your vehicle or your account.'**
  String get contactCompanyBody;

  /// No description provided for @routeYouveArrived.
  ///
  /// In en, this message translates to:
  /// **'You\'ve arrived'**
  String get routeYouveArrived;

  /// No description provided for @routeYouveArrivedCaps.
  ///
  /// In en, this message translates to:
  /// **'YOU\'VE ARRIVED'**
  String get routeYouveArrivedCaps;

  /// No description provided for @routeOpeningStopIn3s.
  ///
  /// In en, this message translates to:
  /// **'Opening the stop in 3 s'**
  String get routeOpeningStopIn3s;

  /// No description provided for @routeNotHereYet.
  ///
  /// In en, this message translates to:
  /// **'Not here yet'**
  String get routeNotHereYet;

  /// No description provided for @routeOpenStop.
  ///
  /// In en, this message translates to:
  /// **'Open stop'**
  String get routeOpenStop;

  /// No description provided for @routeSignRefused.
  ///
  /// In en, this message translates to:
  /// **'They refused to sign'**
  String get routeSignRefused;

  /// No description provided for @routeSignHandsFull.
  ///
  /// In en, this message translates to:
  /// **'Hands are full or they can\'t use the phone'**
  String get routeSignHandsFull;

  /// No description provided for @routeSignGuard.
  ///
  /// In en, this message translates to:
  /// **'Left with the building guard'**
  String get routeSignGuard;

  /// No description provided for @routeSignOther.
  ///
  /// In en, this message translates to:
  /// **'Something else'**
  String get routeSignOther;

  /// No description provided for @routeWhyCantSign.
  ///
  /// In en, this message translates to:
  /// **'Why can\'t they sign?'**
  String get routeWhyCantSign;

  /// No description provided for @routeMarkDeliveredPhotoOnly.
  ///
  /// In en, this message translates to:
  /// **'Mark delivered with photo only'**
  String get routeMarkDeliveredPhotoOnly;

  /// No description provided for @routeBackToSignature.
  ///
  /// In en, this message translates to:
  /// **'Back to signature'**
  String get routeBackToSignature;

  /// No description provided for @routeBeforeYouGo.
  ///
  /// In en, this message translates to:
  /// **'BEFORE YOU GO'**
  String get routeBeforeYouGo;

  /// No description provided for @routeAllPackagesInVan.
  ///
  /// In en, this message translates to:
  /// **'Are all {total} packages in the van?'**
  String routeAllPackagesInVan(String total);

  /// No description provided for @routeTapEachOrScan.
  ///
  /// In en, this message translates to:
  /// **'Tap each one or scan its label.'**
  String get routeTapEachOrScan;

  /// No description provided for @routeScanLabelsInstead.
  ///
  /// In en, this message translates to:
  /// **'Scan labels instead'**
  String get routeScanLabelsInstead;

  /// No description provided for @routeStartRoute.
  ///
  /// In en, this message translates to:
  /// **'Start route'**
  String get routeStartRoute;

  /// No description provided for @routeCheckedOf.
  ///
  /// In en, this message translates to:
  /// **'{checked} of {total} checked'**
  String routeCheckedOf(String checked, String total);

  /// No description provided for @routePackageMissing.
  ///
  /// In en, this message translates to:
  /// **'A package is missing'**
  String get routePackageMissing;

  /// No description provided for @routeNoRouteRightNow.
  ///
  /// In en, this message translates to:
  /// **'No route right now'**
  String get routeNoRouteRightNow;

  /// No description provided for @routeNoRouteDesc.
  ///
  /// In en, this message translates to:
  /// **'Accept orders, then tap Start delivery. Your route appears here.'**
  String get routeNoRouteDesc;

  /// No description provided for @routeSeeMyOrders.
  ///
  /// In en, this message translates to:
  /// **'See my orders'**
  String get routeSeeMyOrders;

  /// No description provided for @routeTurnOnLocation.
  ///
  /// In en, this message translates to:
  /// **'Turn on location to start'**
  String get routeTurnOnLocation;

  /// No description provided for @routeLocationWhy.
  ///
  /// In en, this message translates to:
  /// **'Red Sea Express sees your location only while you’re on a route. It’s how we guide you and how they know orders are on the way.'**
  String get routeLocationWhy;

  /// No description provided for @routeAllowLocation.
  ///
  /// In en, this message translates to:
  /// **'Allow location'**
  String get routeAllowLocation;

  /// No description provided for @routeNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get routeNotNow;

  /// No description provided for @routeReturningToDepot.
  ///
  /// In en, this message translates to:
  /// **'RETURNING TO DEPOT'**
  String get routeReturningToDepot;

  /// No description provided for @routeImAtDepot.
  ///
  /// In en, this message translates to:
  /// **'I\'m at the depot'**
  String get routeImAtDepot;

  /// No description provided for @routeUpdatedBy.
  ///
  /// In en, this message translates to:
  /// **'Route updated by {company}'**
  String routeUpdatedBy(String company);

  /// No description provided for @routeOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get routeOk;

  /// No description provided for @routeViewWhenStopped.
  ///
  /// In en, this message translates to:
  /// **'View when stopped'**
  String get routeViewWhenStopped;

  /// No description provided for @routeFindingNewWay.
  ///
  /// In en, this message translates to:
  /// **'Finding a new way'**
  String get routeFindingNewWay;

  /// No description provided for @routeLeftRoute.
  ///
  /// In en, this message translates to:
  /// **'You left the route. We\'re updating directions to {customer}.'**
  String routeLeftRoute(String customer);

  /// No description provided for @routeWeakGps.
  ///
  /// In en, this message translates to:
  /// **'Weak GPS signal'**
  String get routeWeakGps;

  /// No description provided for @routeWeakGpsBody.
  ///
  /// In en, this message translates to:
  /// **'Your position may be off for a moment. Keep driving safely.'**
  String get routeWeakGpsBody;

  /// No description provided for @routeOffline.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline'**
  String get routeOffline;

  /// No description provided for @routeOfflineBody.
  ///
  /// In en, this message translates to:
  /// **'Keep going. 1 update is saved and will send when you\'re back online.'**
  String get routeOfflineBody;

  /// No description provided for @routeStopMovedToEnd.
  ///
  /// In en, this message translates to:
  /// **'{customer} moved to the end of your route'**
  String routeStopMovedToEnd(String customer);

  /// No description provided for @routeUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get routeUndo;

  /// No description provided for @routeDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get routeDelivered;

  /// No description provided for @routeDeliveredTo.
  ///
  /// In en, this message translates to:
  /// **'Delivered · {customer}'**
  String routeDeliveredTo(String customer);

  /// No description provided for @routeEndRouteNowQ.
  ///
  /// In en, this message translates to:
  /// **'End route now?'**
  String get routeEndRouteNowQ;

  /// No description provided for @routeEndRouteWarning.
  ///
  /// In en, this message translates to:
  /// **'You still have {count} stops. Their orders go back to Red Sea Express so they can be reassigned. This can\'t be undone.'**
  String routeEndRouteWarning(String count);

  /// No description provided for @routeKeepDelivering.
  ///
  /// In en, this message translates to:
  /// **'Keep delivering'**
  String get routeKeepDelivering;

  /// No description provided for @routeEndRoute.
  ///
  /// In en, this message translates to:
  /// **'End route'**
  String get routeEndRoute;

  /// No description provided for @routeAtTheDepot.
  ///
  /// In en, this message translates to:
  /// **'AT THE DEPOT'**
  String get routeAtTheDepot;

  /// No description provided for @routeHandBackOne.
  ///
  /// In en, this message translates to:
  /// **'Hand back {count} package'**
  String routeHandBackOne(String count);

  /// No description provided for @routeHandBackMany.
  ///
  /// In en, this message translates to:
  /// **'Hand back {count} packages'**
  String routeHandBackMany(String count);

  /// No description provided for @routeHandBackDesc.
  ///
  /// In en, this message translates to:
  /// **'Give it to the depot team. They\'ll confirm it on their side too.'**
  String get routeHandBackDesc;

  /// No description provided for @routeReturnedEndDay.
  ///
  /// In en, this message translates to:
  /// **'Returned · end my day'**
  String get routeReturnedEndDay;

  /// No description provided for @routeNeedHelp.
  ///
  /// In en, this message translates to:
  /// **'Need help?'**
  String get routeNeedHelp;

  /// No description provided for @routeDispatchAnswers.
  ///
  /// In en, this message translates to:
  /// **'{company} dispatch · usually answers in 2 min'**
  String routeDispatchAnswers(String company);

  /// No description provided for @routeCallDispatch.
  ///
  /// In en, this message translates to:
  /// **'Call dispatch'**
  String get routeCallDispatch;

  /// No description provided for @routeMessageDispatch.
  ///
  /// In en, this message translates to:
  /// **'Message dispatch'**
  String get routeMessageDispatch;

  /// No description provided for @routeTakeBreak.
  ///
  /// In en, this message translates to:
  /// **'Take a break'**
  String get routeTakeBreak;

  /// No description provided for @routeVehicleProblem.
  ///
  /// In en, this message translates to:
  /// **'Vehicle problem'**
  String get routeVehicleProblem;

  /// No description provided for @routeVehicleProblemSub.
  ///
  /// In en, this message translates to:
  /// **'Breakdown, flat tyre, accident'**
  String get routeVehicleProblemSub;

  /// No description provided for @routeFeelUnsafe.
  ///
  /// In en, this message translates to:
  /// **'I feel unsafe'**
  String get routeFeelUnsafe;

  /// No description provided for @routeFeelUnsafeSub.
  ///
  /// In en, this message translates to:
  /// **'Calls 999 and alerts dispatch'**
  String get routeFeelUnsafeSub;

  /// No description provided for @routeClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get routeClose;

  /// No description provided for @routeMoreOptions.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get routeMoreOptions;

  /// No description provided for @routeTryAgainLater.
  ///
  /// In en, this message translates to:
  /// **'Try again later'**
  String get routeTryAgainLater;

  /// No description provided for @routeTryAgainLaterSub.
  ///
  /// In en, this message translates to:
  /// **'Move this stop to the end of your route'**
  String get routeTryAgainLaterSub;

  /// No description provided for @routeDeliverDifferentStop.
  ///
  /// In en, this message translates to:
  /// **'Deliver a different stop next'**
  String get routeDeliverDifferentStop;

  /// No description provided for @routeDeliverDifferentStopSub.
  ///
  /// In en, this message translates to:
  /// **'Pick which stop to go to now'**
  String get routeDeliverDifferentStopSub;

  /// No description provided for @routeReportWrongLocation.
  ///
  /// In en, this message translates to:
  /// **'Report wrong location'**
  String get routeReportWrongLocation;

  /// No description provided for @routeReportWrongLocationSub.
  ///
  /// In en, this message translates to:
  /// **'The pin or address doesn\'t match'**
  String get routeReportWrongLocationSub;

  /// No description provided for @routeGetHelp.
  ///
  /// In en, this message translates to:
  /// **'Get help'**
  String get routeGetHelp;

  /// No description provided for @routeGetHelpSub.
  ///
  /// In en, this message translates to:
  /// **'Call or message Red Sea Express'**
  String get routeGetHelpSub;

  /// No description provided for @routeWhatChanged.
  ///
  /// In en, this message translates to:
  /// **'What changed'**
  String get routeWhatChanged;

  /// No description provided for @routeUpdatedYourRouteAt.
  ///
  /// In en, this message translates to:
  /// **'{company} updated your route at {time}.'**
  String routeUpdatedYourRouteAt(String company, String time);

  /// No description provided for @routeChangeAdded.
  ///
  /// In en, this message translates to:
  /// **'Added · Sara Khalid'**
  String get routeChangeAdded;

  /// No description provided for @routeChangeAddedSub.
  ///
  /// In en, this message translates to:
  /// **'Quraish St, Al Salamah · now stop 3'**
  String get routeChangeAddedSub;

  /// No description provided for @routeChangeRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed · Yousef Nasser'**
  String get routeChangeRemoved;

  /// No description provided for @routeChangeRemovedSub.
  ///
  /// In en, this message translates to:
  /// **'Cancelled by the customer'**
  String get routeChangeRemovedSub;

  /// No description provided for @routeNowStops.
  ///
  /// In en, this message translates to:
  /// **'Route now 4 stops'**
  String get routeNowStops;

  /// No description provided for @routeAboutLonger.
  ///
  /// In en, this message translates to:
  /// **'About 6 min longer'**
  String get routeAboutLonger;

  /// No description provided for @routeGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get routeGotIt;

  /// No description provided for @routeNextStopOf.
  ///
  /// In en, this message translates to:
  /// **'NEXT STOP · {n} OF {total}'**
  String routeNextStopOf(String n, String total);

  /// No description provided for @routeGateCode.
  ///
  /// In en, this message translates to:
  /// **'Gate code'**
  String get routeGateCode;

  /// No description provided for @routeTimeWindow.
  ///
  /// In en, this message translates to:
  /// **'Time window'**
  String get routeTimeWindow;

  /// No description provided for @routePackages.
  ///
  /// In en, this message translates to:
  /// **'Packages'**
  String get routePackages;

  /// No description provided for @routeCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get routeCall;

  /// No description provided for @routeMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get routeMessage;

  /// No description provided for @routeBackToMap.
  ///
  /// In en, this message translates to:
  /// **'Back to map'**
  String get routeBackToMap;

  /// No description provided for @routeTodaysRoute.
  ///
  /// In en, this message translates to:
  /// **'Today\'s route'**
  String get routeTodaysRoute;

  /// No description provided for @routeDoneOfTotal.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} done'**
  String routeDoneOfTotal(String done, String total);

  /// No description provided for @routeEnRouteEta.
  ///
  /// In en, this message translates to:
  /// **'En route · ETA {eta}'**
  String routeEnRouteEta(String eta);

  /// No description provided for @routeEta.
  ///
  /// In en, this message translates to:
  /// **'ETA {eta}'**
  String routeEta(String eta);

  /// No description provided for @routeBackToDirections.
  ///
  /// In en, this message translates to:
  /// **'Back to directions'**
  String get routeBackToDirections;

  /// No description provided for @routeEndRouteEarly.
  ///
  /// In en, this message translates to:
  /// **'End route early'**
  String get routeEndRouteEarly;

  /// No description provided for @routeWrongEntrance.
  ///
  /// In en, this message translates to:
  /// **'Entrance is somewhere else'**
  String get routeWrongEntrance;

  /// No description provided for @routeWrongStreet.
  ///
  /// In en, this message translates to:
  /// **'Pin is on the wrong street'**
  String get routeWrongStreet;

  /// No description provided for @routeAddressMissing.
  ///
  /// In en, this message translates to:
  /// **'Address doesn\'t exist'**
  String get routeAddressMissing;

  /// No description provided for @routeWrongLocationFor.
  ///
  /// In en, this message translates to:
  /// **'WRONG LOCATION · {name}'**
  String routeWrongLocationFor(String name);

  /// No description provided for @routeWhatsWrongPin.
  ///
  /// In en, this message translates to:
  /// **'What\'s wrong with the pin?'**
  String get routeWhatsWrongPin;

  /// No description provided for @routeSendToDispatch.
  ///
  /// In en, this message translates to:
  /// **'Send to dispatch'**
  String get routeSendToDispatch;

  /// No description provided for @routeNavigateWith.
  ///
  /// In en, this message translates to:
  /// **'Navigate with'**
  String get routeNavigateWith;

  /// No description provided for @routePickDirections.
  ///
  /// In en, this message translates to:
  /// **'Pick how you want directions to {customer}.'**
  String routePickDirections(String customer);

  /// No description provided for @routeTurnByTurnInApp.
  ///
  /// In en, this message translates to:
  /// **'Turn-by-turn inside the app'**
  String get routeTurnByTurnInApp;

  /// No description provided for @routeOpensOneStop.
  ///
  /// In en, this message translates to:
  /// **'Opens one stop at a time'**
  String get routeOpensOneStop;

  /// No description provided for @routeAlwaysUseApp.
  ///
  /// In en, this message translates to:
  /// **'Always use this app'**
  String get routeAlwaysUseApp;

  /// No description provided for @routeComeBackToMark.
  ///
  /// In en, this message translates to:
  /// **'Come back to RouteX to mark each stop as delivered.'**
  String get routeComeBackToMark;

  /// No description provided for @routeStartDirections.
  ///
  /// In en, this message translates to:
  /// **'Start directions'**
  String get routeStartDirections;

  /// No description provided for @routeOnBreakCaps.
  ///
  /// In en, this message translates to:
  /// **'ON BREAK'**
  String get routeOnBreakCaps;

  /// No description provided for @routeOfMin.
  ///
  /// In en, this message translates to:
  /// **'of {mins} min'**
  String routeOfMin(String mins);

  /// No description provided for @routeBreakStarted.
  ///
  /// In en, this message translates to:
  /// **'Started {time}. Dispatch can see you\'re on break and customer ETAs moved by {mins} min.'**
  String routeBreakStarted(String time, String mins);

  /// No description provided for @routeResumeRoute.
  ///
  /// In en, this message translates to:
  /// **'Resume route'**
  String get routeResumeRoute;

  /// No description provided for @routeAdd5Minutes.
  ///
  /// In en, this message translates to:
  /// **'Add 5 minutes'**
  String get routeAdd5Minutes;

  /// No description provided for @routeReasonNotAnswering.
  ///
  /// In en, this message translates to:
  /// **'Customer not answering'**
  String get routeReasonNotAnswering;

  /// No description provided for @routeReasonWrongAddress.
  ///
  /// In en, this message translates to:
  /// **'Wrong address'**
  String get routeReasonWrongAddress;

  /// No description provided for @routeReasonRefused.
  ///
  /// In en, this message translates to:
  /// **'Customer refused'**
  String get routeReasonRefused;

  /// No description provided for @routeReasonCantReach.
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach location'**
  String get routeReasonCantReach;

  /// No description provided for @routeWhatHappened.
  ///
  /// In en, this message translates to:
  /// **'What happened?'**
  String get routeWhatHappened;

  /// No description provided for @routeWillReviewOrder.
  ///
  /// In en, this message translates to:
  /// **'{customer} · {company} will review this order.'**
  String routeWillReviewOrder(String customer, String company);

  /// No description provided for @routeAddNoteOptional.
  ///
  /// In en, this message translates to:
  /// **'Add a note (optional)'**
  String get routeAddNoteOptional;

  /// No description provided for @routeSendToCompany.
  ///
  /// In en, this message translates to:
  /// **'Send to {company}'**
  String routeSendToCompany(String company);

  /// No description provided for @routeNextStopCaps.
  ///
  /// In en, this message translates to:
  /// **'NEXT STOP'**
  String get routeNextStopCaps;

  /// No description provided for @routeStartingDirectionsIn.
  ///
  /// In en, this message translates to:
  /// **'Starting directions in {secs} s'**
  String routeStartingDirectionsIn(String secs);

  /// No description provided for @routeGoToNextStop.
  ///
  /// In en, this message translates to:
  /// **'Go to next stop'**
  String get routeGoToNextStop;

  /// No description provided for @routeNextSignature.
  ///
  /// In en, this message translates to:
  /// **'Next: signature'**
  String get routeNextSignature;

  /// No description provided for @routeUsePhoto.
  ///
  /// In en, this message translates to:
  /// **'Use photo'**
  String get routeUsePhoto;

  /// No description provided for @routeRetake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get routeRetake;

  /// No description provided for @routeLooksGood.
  ///
  /// In en, this message translates to:
  /// **'Looks good?'**
  String get routeLooksGood;

  /// No description provided for @routePhotoClearHint.
  ///
  /// In en, this message translates to:
  /// **'Make sure the package and door number are clear.'**
  String get routePhotoClearHint;

  /// No description provided for @routePhotoThenSignature.
  ///
  /// In en, this message translates to:
  /// **'Photo, then a signature for this order'**
  String get routePhotoThenSignature;

  /// No description provided for @routeRequiredEveryDelivery.
  ///
  /// In en, this message translates to:
  /// **'Required for every delivery'**
  String get routeRequiredEveryDelivery;

  /// No description provided for @routeStopNumberName.
  ///
  /// In en, this message translates to:
  /// **'Stop {n} · {name}'**
  String routeStopNumberName(String n, String name);

  /// No description provided for @routeAllowCameraAccess.
  ///
  /// In en, this message translates to:
  /// **'Allow camera access to take the photo'**
  String get routeAllowCameraAccess;

  /// No description provided for @routeCameraUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Camera is not available'**
  String get routeCameraUnavailable;

  /// No description provided for @routeShowPackageAndDoor.
  ///
  /// In en, this message translates to:
  /// **'Show the package and the door number'**
  String get routeShowPackageAndDoor;

  /// No description provided for @routePhotoOfDelivery.
  ///
  /// In en, this message translates to:
  /// **'Photo of the delivery'**
  String get routePhotoOfDelivery;

  /// No description provided for @routePhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get routePhoto;

  /// No description provided for @routeAskToSign.
  ///
  /// In en, this message translates to:
  /// **'Ask {name} to sign'**
  String routeAskToSign(String name);

  /// No description provided for @routeHandPhoneSign.
  ///
  /// In en, this message translates to:
  /// **'Hand them the phone. They sign with a finger.'**
  String get routeHandPhoneSign;

  /// No description provided for @routeHandPhoneType.
  ///
  /// In en, this message translates to:
  /// **'Hand them the phone. They type their full name.'**
  String get routeHandPhoneType;

  /// No description provided for @routeDraw.
  ///
  /// In en, this message translates to:
  /// **'Draw'**
  String get routeDraw;

  /// No description provided for @routeType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get routeType;

  /// No description provided for @routeSignHere.
  ///
  /// In en, this message translates to:
  /// **'Sign here'**
  String get routeSignHere;

  /// No description provided for @routePreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get routePreview;

  /// No description provided for @routeClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get routeClear;

  /// No description provided for @routeSignedBy.
  ///
  /// In en, this message translates to:
  /// **'Signed by'**
  String get routeSignedBy;

  /// No description provided for @routeFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get routeFullName;

  /// No description provided for @routeSomeoneElseCanSign.
  ///
  /// In en, this message translates to:
  /// **'Someone else can sign for them. Just change the name.'**
  String get routeSomeoneElseCanSign;

  /// No description provided for @routePreviewUpdates.
  ///
  /// In en, this message translates to:
  /// **'The preview updates as they type. Someone else can sign for them with their own name.'**
  String get routePreviewUpdates;

  /// No description provided for @routeDoneMarkDelivered.
  ///
  /// In en, this message translates to:
  /// **'Done · mark delivered'**
  String get routeDoneMarkDelivered;

  /// No description provided for @routeCantSign.
  ///
  /// In en, this message translates to:
  /// **'They can\'t sign'**
  String get routeCantSign;

  /// No description provided for @routeStopOfCustomer.
  ///
  /// In en, this message translates to:
  /// **'STOP {n} OF {total} · {name}'**
  String routeStopOfCustomer(String n, String total, String name);

  /// No description provided for @routeTryingToReach.
  ///
  /// In en, this message translates to:
  /// **'Trying to reach {name}'**
  String routeTryingToReach(String name);

  /// No description provided for @routeWaitBeforeMarking.
  ///
  /// In en, this message translates to:
  /// **'Wait a few more minutes before marking this stop. Red Sea Express asks for 2 calls and a 5-minute wait.'**
  String get routeWaitBeforeMarking;

  /// No description provided for @routeCalled.
  ///
  /// In en, this message translates to:
  /// **'Called'**
  String get routeCalled;

  /// No description provided for @routeNoAnswerAt.
  ///
  /// In en, this message translates to:
  /// **'{time} · no answer'**
  String routeNoAnswerAt(String time);

  /// No description provided for @routeMessageSent.
  ///
  /// In en, this message translates to:
  /// **'Message sent'**
  String get routeMessageSent;

  /// No description provided for @routeCallAgain.
  ///
  /// In en, this message translates to:
  /// **'Call again'**
  String get routeCallAgain;

  /// No description provided for @routeMarkCouldntDeliver.
  ///
  /// In en, this message translates to:
  /// **'Mark as couldn\'t deliver'**
  String get routeMarkCouldntDeliver;

  /// No description provided for @routeAvailableAfterWait.
  ///
  /// In en, this message translates to:
  /// **'Available after the 5-minute wait'**
  String get routeAvailableAfterWait;

  /// No description provided for @routeLocationSharingStopped.
  ///
  /// In en, this message translates to:
  /// **'Location sharing stopped'**
  String get routeLocationSharingStopped;

  /// No description provided for @routeWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get routeWelcomeBack;

  /// No description provided for @routeCantSeeYourRoute.
  ///
  /// In en, this message translates to:
  /// **'{company} can\'t see your route. Turn it back on to keep delivering.'**
  String routeCantSeeYourRoute(String company);

  /// No description provided for @routeYouWereNavigating.
  ///
  /// In en, this message translates to:
  /// **'You were navigating to {customer} in {app}.'**
  String routeYouWereNavigating(String customer, String app);

  /// No description provided for @routeTurnOn.
  ///
  /// In en, this message translates to:
  /// **'Turn on'**
  String get routeTurnOn;

  /// No description provided for @routeIveArrived.
  ///
  /// In en, this message translates to:
  /// **'I\'ve arrived'**
  String get routeIveArrived;

  /// No description provided for @routeResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get routeResume;

  /// No description provided for @routeStopNotMarked.
  ///
  /// In en, this message translates to:
  /// **'STOP {n} NOT MARKED'**
  String routeStopNotMarked(String n);

  /// No description provided for @routeDidYouDeliverTo.
  ///
  /// In en, this message translates to:
  /// **'Did you deliver to {customer}?'**
  String routeDidYouDeliverTo(String customer);

  /// No description provided for @routeLeftAddress.
  ///
  /// In en, this message translates to:
  /// **'You left his address {ago}. Marking it now keeps the customer updated.'**
  String routeLeftAddress(String ago);

  /// No description provided for @routeYesDelivered.
  ///
  /// In en, this message translates to:
  /// **'Yes, delivered'**
  String get routeYesDelivered;

  /// No description provided for @routeCouldntDeliver.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t deliver'**
  String get routeCouldntDeliver;

  /// No description provided for @routeGoBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get routeGoBack;

  /// No description provided for @routeArrivedAt.
  ///
  /// In en, this message translates to:
  /// **'Arrived {time}'**
  String routeArrivedAt(String time);

  /// No description provided for @routeNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get routeNote;

  /// No description provided for @routeMaps.
  ///
  /// In en, this message translates to:
  /// **'Maps'**
  String get routeMaps;

  /// No description provided for @routeMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get routeMore;

  /// No description provided for @routeStopsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} stops'**
  String routeStopsCount(String count);

  /// No description provided for @routeCalculating.
  ///
  /// In en, this message translates to:
  /// **'Calculating'**
  String get routeCalculating;

  /// No description provided for @routeSlideToStart.
  ///
  /// In en, this message translates to:
  /// **'Slide to start route'**
  String get routeSlideToStart;

  /// No description provided for @routeGettingRouteReady.
  ///
  /// In en, this message translates to:
  /// **'Getting your route ready'**
  String get routeGettingRouteReady;

  /// No description provided for @routePlanningYourRoute.
  ///
  /// In en, this message translates to:
  /// **'Planning your route'**
  String get routePlanningYourRoute;

  /// No description provided for @routeFindingFastestOrder.
  ///
  /// In en, this message translates to:
  /// **'Finding the fastest order for your {count} stops.'**
  String routeFindingFastestOrder(String count);

  /// No description provided for @routeYourRouteIsReady.
  ///
  /// In en, this message translates to:
  /// **'Your route is ready'**
  String get routeYourRouteIsReady;

  /// No description provided for @routeStopsOrderedHint.
  ///
  /// In en, this message translates to:
  /// **'Stops are ordered for the fastest drive. Times are estimates.'**
  String get routeStopsOrderedHint;

  /// No description provided for @routeAppOptimizesArea.
  ///
  /// In en, this message translates to:
  /// **'The app optimizes stops in your 2 km area.'**
  String get routeAppOptimizesArea;

  /// No description provided for @routeRouteComplete.
  ///
  /// In en, this message translates to:
  /// **'Route complete'**
  String get routeRouteComplete;

  /// No description provided for @routeAlmostDone.
  ///
  /// In en, this message translates to:
  /// **'You\'re almost done, {name}. One thing left.'**
  String routeAlmostDone(String name);

  /// No description provided for @routeAllDone.
  ///
  /// In en, this message translates to:
  /// **'You\'re all done, {name}. Great job!'**
  String routeAllDone(String name);

  /// No description provided for @routeOneThingLeft.
  ///
  /// In en, this message translates to:
  /// **'1 THING LEFT'**
  String get routeOneThingLeft;

  /// No description provided for @routeReturnPackageToDepot.
  ///
  /// In en, this message translates to:
  /// **'Return {name}\'s package to the depot'**
  String routeReturnPackageToDepot(String name);

  /// No description provided for @routeDepotAway.
  ///
  /// In en, this message translates to:
  /// **'{depot} · {distance} away'**
  String routeDepotAway(String depot, String distance);

  /// No description provided for @routeDirectionsToDepot.
  ///
  /// In en, this message translates to:
  /// **'Directions to depot'**
  String get routeDirectionsToDepot;

  /// No description provided for @routeDeliveredOfTotal.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} delivered'**
  String routeDeliveredOfTotal(String done, String total);

  /// No description provided for @routeCountDelivered.
  ///
  /// In en, this message translates to:
  /// **'{count} delivered'**
  String routeCountDelivered(String count);

  /// No description provided for @routeCountCouldntDeliver.
  ///
  /// In en, this message translates to:
  /// **'{count} couldn\'t deliver'**
  String routeCountCouldntDeliver(String count);

  /// No description provided for @routeKmUnit.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get routeKmUnit;

  /// No description provided for @routeMinUnit.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get routeMinUnit;

  /// No description provided for @routeDrivenToday.
  ///
  /// In en, this message translates to:
  /// **'Driven today'**
  String get routeDrivenToday;

  /// No description provided for @routeOnTheRoad.
  ///
  /// In en, this message translates to:
  /// **'On the road'**
  String get routeOnTheRoad;

  /// No description provided for @routeStopsCaps.
  ///
  /// In en, this message translates to:
  /// **'STOPS'**
  String get routeStopsCaps;

  /// No description provided for @routeSentForReview.
  ///
  /// In en, this message translates to:
  /// **'{reason} · sent for review'**
  String routeSentForReview(String reason);

  /// No description provided for @routeDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get routeDone;

  /// No description provided for @routeSeeInHistory.
  ///
  /// In en, this message translates to:
  /// **'See in history'**
  String get routeSeeInHistory;

  /// No description provided for @routeMinutesShort.
  ///
  /// In en, this message translates to:
  /// **'{n} min'**
  String routeMinutesShort(String n);

  /// No description provided for @routeKmShort.
  ///
  /// In en, this message translates to:
  /// **'{n} km'**
  String routeKmShort(String n);

  /// No description provided for @routeArrival.
  ///
  /// In en, this message translates to:
  /// **'arrival'**
  String get routeArrival;

  /// No description provided for @routeThen.
  ///
  /// In en, this message translates to:
  /// **'Then'**
  String get routeThen;

  /// No description provided for @routeApprovedCaps.
  ///
  /// In en, this message translates to:
  /// **'APPROVED'**
  String get routeApprovedCaps;

  /// No description provided for @routeYoureInWelcome.
  ///
  /// In en, this message translates to:
  /// **'You\'re in! Welcome to {fleet}'**
  String routeYoureInWelcome(String fleet);

  /// No description provided for @routeAccountActiveStartShift.
  ///
  /// In en, this message translates to:
  /// **'Your account is active. Start a shift to receive routes and see your stops on the map.'**
  String get routeAccountActiveStartShift;

  /// No description provided for @routeStartShift.
  ///
  /// In en, this message translates to:
  /// **'Start shift'**
  String get routeStartShift;

  /// No description provided for @routeCancelYourRequestTo.
  ///
  /// In en, this message translates to:
  /// **'Cancel your request to {fleet}?'**
  String routeCancelYourRequestTo(String fleet);

  /// No description provided for @routeCancelRequestBody.
  ///
  /// In en, this message translates to:
  /// **'They won\'t see your details anymore. You can send a new request any time.'**
  String get routeCancelRequestBody;

  /// No description provided for @routeCancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel request'**
  String get routeCancelRequest;

  /// No description provided for @routeKeepMyRequest.
  ///
  /// In en, this message translates to:
  /// **'Keep my request'**
  String get routeKeepMyRequest;

  /// No description provided for @routeRequestDeclinedCaps.
  ///
  /// In en, this message translates to:
  /// **'REQUEST DECLINED'**
  String get routeRequestDeclinedCaps;

  /// No description provided for @routeFleetDeclinedYou.
  ///
  /// In en, this message translates to:
  /// **'{fleet} declined your request'**
  String routeFleetDeclinedYou(String fleet);

  /// No description provided for @routeReasonFromDispatcherCaps.
  ///
  /// In en, this message translates to:
  /// **'REASON FROM DISPATCHER'**
  String get routeReasonFromDispatcherCaps;

  /// No description provided for @routeChooseAnotherFleet.
  ///
  /// In en, this message translates to:
  /// **'Choose another fleet'**
  String get routeChooseAnotherFleet;

  /// No description provided for @routeUpdateVehicleRetry.
  ///
  /// In en, this message translates to:
  /// **'Update vehicle & retry'**
  String get routeUpdateVehicleRetry;

  /// No description provided for @routeOffShiftCaps.
  ///
  /// In en, this message translates to:
  /// **'OFF SHIFT'**
  String get routeOffShiftCaps;

  /// No description provided for @routeYoureOffShift.
  ///
  /// In en, this message translates to:
  /// **'You\'re off shift'**
  String get routeYoureOffShift;

  /// No description provided for @routeOffShiftBody.
  ///
  /// In en, this message translates to:
  /// **'{fleet} • Al Hamra. Start a shift when you’re ready and routes will appear on the map.'**
  String routeOffShiftBody(String fleet);

  /// No description provided for @routePendingReviewCaps.
  ///
  /// In en, this message translates to:
  /// **'PENDING REVIEW'**
  String get routePendingReviewCaps;

  /// No description provided for @routeRequestSentTo.
  ///
  /// In en, this message translates to:
  /// **'Request sent to {fleet}'**
  String routeRequestSentTo(String fleet);

  /// No description provided for @routeDispatcherReviewingNotify.
  ///
  /// In en, this message translates to:
  /// **'The dispatcher is reviewing your details. We’ll notify the moment you’re approved.'**
  String get routeDispatcherReviewingNotify;

  /// No description provided for @routeTimelineSent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get routeTimelineSent;

  /// No description provided for @routeTimelineReviewing.
  ///
  /// In en, this message translates to:
  /// **'Reviewing'**
  String get routeTimelineReviewing;

  /// No description provided for @routeJoinAnotherFleet.
  ///
  /// In en, this message translates to:
  /// **'Join another fleet'**
  String get routeJoinAnotherFleet;

  /// No description provided for @routeOnShiftCaps.
  ///
  /// In en, this message translates to:
  /// **'ON SHIFT'**
  String get routeOnShiftCaps;

  /// No description provided for @routeWaitingFirstRoute.
  ///
  /// In en, this message translates to:
  /// **'Waiting for your first route'**
  String get routeWaitingFirstRoute;

  /// No description provided for @routeDispatchAssignsRoutes.
  ///
  /// In en, this message translates to:
  /// **'Dispatch assigns routes as orders come in. Keep the app open and you’ll hear an alert.'**
  String get routeDispatchAssignsRoutes;

  /// No description provided for @routeZeroStops.
  ///
  /// In en, this message translates to:
  /// **'0 stops'**
  String get routeZeroStops;

  /// No description provided for @routeSoFarToday.
  ///
  /// In en, this message translates to:
  /// **'So far today'**
  String get routeSoFarToday;

  /// No description provided for @routeAlertsOn.
  ///
  /// In en, this message translates to:
  /// **'Alerts on'**
  String get routeAlertsOn;

  /// No description provided for @routeSoundAndVibrate.
  ///
  /// In en, this message translates to:
  /// **'Sound and vibrate'**
  String get routeSoundAndVibrate;

  /// No description provided for @routeEndShift.
  ///
  /// In en, this message translates to:
  /// **'End shift'**
  String get routeEndShift;

  /// No description provided for @routeAskManagerNewCode.
  ///
  /// In en, this message translates to:
  /// **'Ask your manager for a new code'**
  String get routeAskManagerNewCode;

  /// No description provided for @routeSendMessageToManager.
  ///
  /// In en, this message translates to:
  /// **'Send this message to whoever manages your fleet.'**
  String get routeSendMessageToManager;

  /// No description provided for @routeManagerMessage.
  ///
  /// In en, this message translates to:
  /// **'Hi, the RouteX fleet code {code} isn\'t working for me. Could you send me a new one? Thanks, Hamza'**
  String routeManagerMessage(String code);

  /// No description provided for @routeShareOnWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'Share on WhatsApp'**
  String get routeShareOnWhatsapp;

  /// No description provided for @routeCopyMessage.
  ///
  /// In en, this message translates to:
  /// **'Copy message'**
  String get routeCopyMessage;

  /// No description provided for @routeCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get routeCancel;

  /// No description provided for @routeFindYour.
  ///
  /// In en, this message translates to:
  /// **'Find your '**
  String get routeFindYour;

  /// No description provided for @routeFleetWord.
  ///
  /// In en, this message translates to:
  /// **'fleet'**
  String get routeFleetWord;

  /// No description provided for @routeSearchBrowseFleets.
  ///
  /// In en, this message translates to:
  /// **'Search by name or browse fleets operating near you. Join one to start receiving routes.'**
  String get routeSearchBrowseFleets;

  /// No description provided for @routeSearchFleetHint.
  ///
  /// In en, this message translates to:
  /// **'Search fleet name or zone'**
  String get routeSearchFleetHint;

  /// No description provided for @routeFilterNearby.
  ///
  /// In en, this message translates to:
  /// **'Nearby'**
  String get routeFilterNearby;

  /// No description provided for @routeFilterOpenToJoin.
  ///
  /// In en, this message translates to:
  /// **'Open to join'**
  String get routeFilterOpenToJoin;

  /// No description provided for @routeFilterAllFleets.
  ///
  /// In en, this message translates to:
  /// **'All fleets'**
  String get routeFilterAllFleets;

  /// No description provided for @routeRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get routeRetry;

  /// No description provided for @routeNoFleetsMatch.
  ///
  /// In en, this message translates to:
  /// **'No fleets match \"{query}\"'**
  String routeNoFleetsMatch(String query);

  /// No description provided for @routeTryShorterName.
  ///
  /// In en, this message translates to:
  /// **'Try a shorter name or search by area. If your manager sent you a code, you can enter it below.'**
  String get routeTryShorterName;

  /// No description provided for @routeClearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get routeClearSearch;

  /// No description provided for @routeDriversCount.
  ///
  /// In en, this message translates to:
  /// **'{count} drivers'**
  String routeDriversCount(String count);

  /// No description provided for @routeActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get routeActive;

  /// No description provided for @routeActiveCaps.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get routeActiveCaps;

  /// No description provided for @routeGotInvite.
  ///
  /// In en, this message translates to:
  /// **'Got an invite from your fleet manager?'**
  String get routeGotInvite;

  /// No description provided for @routeEnterFleetCode.
  ///
  /// In en, this message translates to:
  /// **'Enter fleet code'**
  String get routeEnterFleetCode;

  /// No description provided for @routeRequested.
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get routeRequested;

  /// No description provided for @routeJoin.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get routeJoin;

  /// No description provided for @routeJoinFleetQ.
  ///
  /// In en, this message translates to:
  /// **'Join {fleet}?'**
  String routeJoinFleetQ(String fleet);

  /// No description provided for @routeNearbyFleet.
  ///
  /// In en, this message translates to:
  /// **'Nearby fleet'**
  String get routeNearbyFleet;

  /// No description provided for @routeStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get routeStatus;

  /// No description provided for @routeCompany.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get routeCompany;

  /// No description provided for @routeNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get routeNetwork;

  /// No description provided for @routeVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get routeVerified;

  /// No description provided for @routeDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get routeDelivery;

  /// No description provided for @routeSharedWithFleet.
  ///
  /// In en, this message translates to:
  /// **'Shared with the fleet'**
  String get routeSharedWithFleet;

  /// No description provided for @routeName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get routeName;

  /// No description provided for @routeDriver.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get routeDriver;

  /// No description provided for @routeVehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get routeVehicle;

  /// No description provided for @routeActiveVehicle.
  ///
  /// In en, this message translates to:
  /// **'Active vehicle'**
  String get routeActiveVehicle;

  /// No description provided for @routeStoppedAccepting.
  ///
  /// In en, this message translates to:
  /// **'{fleet} stopped accepting drivers'**
  String routeStoppedAccepting(String fleet);

  /// No description provided for @routeSeeOtherFleets.
  ///
  /// In en, this message translates to:
  /// **'See other fleets'**
  String get routeSeeOtherFleets;

  /// No description provided for @routeDispatcherReviewsBeforeRoutes.
  ///
  /// In en, this message translates to:
  /// **'The dispatcher reviews your details before you can take routes. You\'ll get a notification when they reply.'**
  String get routeDispatcherReviewsBeforeRoutes;

  /// No description provided for @routeSendJoinRequest.
  ///
  /// In en, this message translates to:
  /// **'Send join request'**
  String get routeSendJoinRequest;

  /// No description provided for @routeReasonFromDispatcher.
  ///
  /// In en, this message translates to:
  /// **'Reason from the dispatcher'**
  String get routeReasonFromDispatcher;

  /// No description provided for @routeLookingForFleets.
  ///
  /// In en, this message translates to:
  /// **'Looking for fleets that accept your vehicle?'**
  String get routeLookingForFleets;

  /// No description provided for @routeOtherFleetsMatch.
  ///
  /// In en, this message translates to:
  /// **'3 other fleets in Al Hamra match your vehicle type.'**
  String get routeOtherFleetsMatch;

  /// No description provided for @routeFindAnotherFleet.
  ///
  /// In en, this message translates to:
  /// **'Find another fleet'**
  String get routeFindAnotherFleet;

  /// No description provided for @routeUpdateMyVehicle.
  ///
  /// In en, this message translates to:
  /// **'Update my vehicle'**
  String get routeUpdateMyVehicle;

  /// No description provided for @routeYoureInAt.
  ///
  /// In en, this message translates to:
  /// **'You’re in at '**
  String get routeYoureInAt;

  /// No description provided for @routeApprovedAccountActive.
  ///
  /// In en, this message translates to:
  /// **'Your account is active. Start a shift whenever you\'re ready to take routes in Al Hamra.'**
  String get routeApprovedAccountActive;

  /// No description provided for @routeRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Request sent'**
  String get routeRequestSent;

  /// No description provided for @routeApprovedByDispatcher.
  ///
  /// In en, this message translates to:
  /// **'Approved by the dispatcher'**
  String get routeApprovedByDispatcher;

  /// No description provided for @routeStartFirstShift.
  ///
  /// In en, this message translates to:
  /// **'Start your first shift'**
  String get routeStartFirstShift;

  /// No description provided for @routeRoutesAppearOnMap.
  ///
  /// In en, this message translates to:
  /// **'Routes appear on your map'**
  String get routeRoutesAppearOnMap;

  /// No description provided for @routeJoinMoreFleetsLater.
  ///
  /// In en, this message translates to:
  /// **'You can join more fleets later and choose which one to work for each time you start a shift.'**
  String get routeJoinMoreFleetsLater;

  /// No description provided for @routeIsReviewing.
  ///
  /// In en, this message translates to:
  /// **'{fleet} is reviewing your details. Most fleets reply within a\nday.'**
  String routeIsReviewing(String fleet);

  /// No description provided for @routeDispatcherReviewsDetails.
  ///
  /// In en, this message translates to:
  /// **'Dispatcher reviews your details'**
  String get routeDispatcherReviewsDetails;

  /// No description provided for @routeUsuallyWithin24.
  ///
  /// In en, this message translates to:
  /// **'Usually within 24 hours'**
  String get routeUsuallyWithin24;

  /// No description provided for @routeNotificationsOn.
  ///
  /// In en, this message translates to:
  /// **'Notifications are on. You can close the app while you wait.'**
  String get routeNotificationsOn;

  /// No description provided for @routeBrowseOtherFleets.
  ///
  /// In en, this message translates to:
  /// **'Browse other fleets'**
  String get routeBrowseOtherFleets;

  /// No description provided for @routeHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get routeHelp;

  /// No description provided for @routeEnterYour.
  ///
  /// In en, this message translates to:
  /// **'Enter your '**
  String get routeEnterYour;

  /// No description provided for @routeFleetCodeWord.
  ///
  /// In en, this message translates to:
  /// **'fleet\ncode'**
  String get routeFleetCodeWord;

  /// No description provided for @routeTypeSixCharCode.
  ///
  /// In en, this message translates to:
  /// **'Type the 6-character code your fleet manager sent you\nby SMS or email.'**
  String get routeTypeSixCharCode;

  /// No description provided for @routeLettersNumbersHint.
  ///
  /// In en, this message translates to:
  /// **'Letters and numbers, not case-sensitive'**
  String get routeLettersNumbersHint;

  /// No description provided for @routePaste.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get routePaste;

  /// No description provided for @routeWhereFindCode.
  ///
  /// In en, this message translates to:
  /// **'Where do I find my code?'**
  String get routeWhereFindCode;

  /// No description provided for @routeManagerCreatesCode.
  ///
  /// In en, this message translates to:
  /// **'Your fleet manager creates it in the fleet dashboard. Ask them to send one. Codes expire after 10 days.'**
  String get routeManagerCreatesCode;

  /// No description provided for @routeJoinFleet.
  ///
  /// In en, this message translates to:
  /// **'Join fleet'**
  String get routeJoinFleet;

  /// No description provided for @routeTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get routeTryAgain;

  /// No description provided for @routeAskManagerForNewCode.
  ///
  /// In en, this message translates to:
  /// **'Ask manager for a new code'**
  String get routeAskManagerForNewCode;

  /// No description provided for @routeLostYourCode.
  ///
  /// In en, this message translates to:
  /// **'Lost your code?'**
  String get routeLostYourCode;

  /// No description provided for @routeStillStuck.
  ///
  /// In en, this message translates to:
  /// **'Still stuck?'**
  String get routeStillStuck;

  /// No description provided for @routeFindFleetInstead.
  ///
  /// In en, this message translates to:
  /// **'Find a fleet instead'**
  String get routeFindFleetInstead;

  /// No description provided for @routeLiveFleetNavigation.
  ///
  /// In en, this message translates to:
  /// **'Live Fleet Navigation'**
  String get routeLiveFleetNavigation;

  /// No description provided for @routeActiveRoute.
  ///
  /// In en, this message translates to:
  /// **'Active Route'**
  String get routeActiveRoute;

  /// No description provided for @routeRouteProgress.
  ///
  /// In en, this message translates to:
  /// **'Route Progress'**
  String get routeRouteProgress;

  /// No description provided for @routeProgressLeft.
  ///
  /// In en, this message translates to:
  /// **'{percent}% • {distance} Left'**
  String routeProgressLeft(String percent, String distance);

  /// No description provided for @routeMapLayersStyle.
  ///
  /// In en, this message translates to:
  /// **'Map Layers & Style'**
  String get routeMapLayersStyle;

  /// No description provided for @routeMapStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard (Normal)'**
  String get routeMapStandard;

  /// No description provided for @routeMapStandardSub.
  ///
  /// In en, this message translates to:
  /// **'Standard vector map tiles'**
  String get routeMapStandardSub;

  /// No description provided for @routeMapSatellite.
  ///
  /// In en, this message translates to:
  /// **'Satellite'**
  String get routeMapSatellite;

  /// No description provided for @routeMapSatelliteSub.
  ///
  /// In en, this message translates to:
  /// **'Real-world aerial imagery'**
  String get routeMapSatelliteSub;

  /// No description provided for @routeMapTerrain.
  ///
  /// In en, this message translates to:
  /// **'Terrain'**
  String get routeMapTerrain;

  /// No description provided for @routeMapTerrainSub.
  ///
  /// In en, this message translates to:
  /// **'Topographic elevation map'**
  String get routeMapTerrainSub;

  /// No description provided for @routeShowTraffic.
  ///
  /// In en, this message translates to:
  /// **'Show Traffic Overlay'**
  String get routeShowTraffic;

  /// No description provided for @routeCheckPackages.
  ///
  /// In en, this message translates to:
  /// **'Check packages'**
  String get routeCheckPackages;

  /// No description provided for @routeLastStop.
  ///
  /// In en, this message translates to:
  /// **'LAST STOP'**
  String get routeLastStop;

  /// No description provided for @routeStopNofM.
  ///
  /// In en, this message translates to:
  /// **'STOP {n} OF {total}'**
  String routeStopNofM(String n, String total);

  /// No description provided for @routeSentToCompanyForReview.
  ///
  /// In en, this message translates to:
  /// **'Sent to Red Sea Express for review'**
  String get routeSentToCompanyForReview;

  /// No description provided for @routeDragMapPin.
  ///
  /// In en, this message translates to:
  /// **'Drag the map to put the pin on the door'**
  String get routeDragMapPin;

  /// No description provided for @routeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} minutes ago'**
  String routeMinutesAgo(String count);

  /// No description provided for @routePackagesToHandBack.
  ///
  /// In en, this message translates to:
  /// **'{count} packages to hand back'**
  String routePackagesToHandBack(String count);

  /// No description provided for @routePackageToHandBack.
  ///
  /// In en, this message translates to:
  /// **'{count} package to hand back'**
  String routePackageToHandBack(String count);

  /// No description provided for @routeNoFleetConnectionCaps.
  ///
  /// In en, this message translates to:
  /// **'NO FLEET CONNECTION'**
  String get routeNoFleetConnectionCaps;

  /// No description provided for @routeNotConnectedToFleet.
  ///
  /// In en, this message translates to:
  /// **'You’re not connected to a fleet yet'**
  String get routeNotConnectedToFleet;

  /// No description provided for @routeJoinFleetToReceive.
  ///
  /// In en, this message translates to:
  /// **'Join a fleet to receive routes, see your stops on the map, and start delivering.'**
  String get routeJoinFleetToReceive;

  /// No description provided for @routeFindAFleet.
  ///
  /// In en, this message translates to:
  /// **'Find a fleet'**
  String get routeFindAFleet;

  /// No description provided for @routeOneStopAdded.
  ///
  /// In en, this message translates to:
  /// **'1 stop added. Your next stop hasn\'t changed.'**
  String get routeOneStopAdded;

  /// No description provided for @notificationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String notificationMinutes(int minutes);

  /// No description provided for @notificationChannelOffers.
  ///
  /// In en, this message translates to:
  /// **'New orders'**
  String get notificationChannelOffers;

  /// No description provided for @notificationChannelOffersDesc.
  ///
  /// In en, this message translates to:
  /// **'Orders a company offers you, with a short time to answer'**
  String get notificationChannelOffersDesc;

  /// No description provided for @notificationChannelRoute.
  ///
  /// In en, this message translates to:
  /// **'Route in progress'**
  String get notificationChannelRoute;

  /// No description provided for @notificationChannelRouteDesc.
  ///
  /// In en, this message translates to:
  /// **'Your next stop while a route is running'**
  String get notificationChannelRouteDesc;

  /// No description provided for @notificationChannelUpdates.
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get notificationChannelUpdates;

  /// No description provided for @notificationChannelUpdatesDesc.
  ///
  /// In en, this message translates to:
  /// **'Cancelled orders, route and vehicle changes, and messages from your company.'**
  String get notificationChannelUpdatesDesc;

  /// No description provided for @notificationsPageSystemOffTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off on this phone'**
  String get notificationsPageSystemOffTitle;

  /// No description provided for @notificationsPageSystemOffBody.
  ///
  /// In en, this message translates to:
  /// **'You won\'t get new orders or route updates until you allow them in your phone\'s settings.'**
  String get notificationsPageSystemOffBody;

  /// No description provided for @notificationsPageSystemOffAction.
  ///
  /// In en, this message translates to:
  /// **'Open phone settings'**
  String get notificationsPageSystemOffAction;

  /// No description provided for @routeOngoingNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Stop {stop} of {total} · {customer}'**
  String routeOngoingNotificationTitle(int stop, int total, String customer);

  /// No description provided for @routeOngoingNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'{address} · {minutes} min · arrive {time}'**
  String routeOngoingNotificationBody(String address, int minutes, String time);

  /// No description provided for @routeOngoingNotificationOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get routeOngoingNotificationOpen;

  /// No description provided for @routeOngoingNotificationNavigate.
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get routeOngoingNotificationNavigate;

  /// No description provided for @joinApprovedTitle.
  ///
  /// In en, this message translates to:
  /// **'You’re in!'**
  String get joinApprovedTitle;

  /// No description provided for @joinApprovedBody.
  ///
  /// In en, this message translates to:
  /// **'{company} approved you. New orders from them will show up on your Home screen.'**
  String joinApprovedBody(String company);

  /// No description provided for @joinApprovedYourVehicle.
  ///
  /// In en, this message translates to:
  /// **'Your vehicle'**
  String get joinApprovedYourVehicle;

  /// No description provided for @joinApprovedSetByCompany.
  ///
  /// In en, this message translates to:
  /// **'Set by your company'**
  String get joinApprovedSetByCompany;

  /// No description provided for @joinApprovedVehicleHelp.
  ///
  /// In en, this message translates to:
  /// **'Need a different vehicle? Contact {company} and they\'ll update it for you.'**
  String joinApprovedVehicleHelp(String company);

  /// No description provided for @joinApprovedYourCompany.
  ///
  /// In en, this message translates to:
  /// **'Your company'**
  String get joinApprovedYourCompany;

  /// No description provided for @joinApprovedActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get joinApprovedActive;

  /// No description provided for @joinApprovedGoHome.
  ///
  /// In en, this message translates to:
  /// **'Go to Home'**
  String get joinApprovedGoHome;

  /// No description provided for @joinDeclinedBadge.
  ///
  /// In en, this message translates to:
  /// **'Not approved'**
  String get joinDeclinedBadge;

  /// No description provided for @joinDeclinedTitle.
  ///
  /// In en, this message translates to:
  /// **'{company} didn\'t approve your request'**
  String joinDeclinedTitle(String company);

  /// No description provided for @joinDeclinedCodeUsed.
  ///
  /// In en, this message translates to:
  /// **'Code used'**
  String get joinDeclinedCodeUsed;

  /// No description provided for @joinDeclinedSent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get joinDeclinedSent;

  /// No description provided for @joinDeclinedReviewed.
  ///
  /// In en, this message translates to:
  /// **'Reviewed'**
  String get joinDeclinedReviewed;

  /// No description provided for @joinDeclinedWhatNow.
  ///
  /// In en, this message translates to:
  /// **'WHAT YOU CAN DO NOW'**
  String get joinDeclinedWhatNow;

  /// No description provided for @joinDeclinedCheckCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Double-check your code'**
  String get joinDeclinedCheckCodeTitle;

  /// No description provided for @joinDeclinedCheckCodeBody.
  ///
  /// In en, this message translates to:
  /// **'A typo or an old code is the usual reason.'**
  String get joinDeclinedCheckCodeBody;

  /// No description provided for @joinDeclinedAnotherCompanyTitle.
  ///
  /// In en, this message translates to:
  /// **'Join another company'**
  String get joinDeclinedAnotherCompanyTitle;

  /// No description provided for @joinDeclinedAnotherCompanyBody.
  ///
  /// In en, this message translates to:
  /// **'Use the code from any company you drive for.'**
  String get joinDeclinedAnotherCompanyBody;

  /// No description provided for @joinDeclinedAccountSavedTitle.
  ///
  /// In en, this message translates to:
  /// **'Your account is saved'**
  String get joinDeclinedAccountSavedTitle;

  /// No description provided for @joinDeclinedAccountSavedBody.
  ///
  /// In en, this message translates to:
  /// **'Your profile stays, nothing to fill in again.'**
  String get joinDeclinedAccountSavedBody;

  /// No description provided for @joinDeclinedDifferentCode.
  ///
  /// In en, this message translates to:
  /// **'Join with a different code'**
  String get joinDeclinedDifferentCode;

  /// No description provided for @referralLinkShared.
  ///
  /// In en, this message translates to:
  /// **'Referral link shared'**
  String get referralLinkShared;

  /// No description provided for @preciseLocationRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Precise Location Required'**
  String get preciseLocationRequiredTitle;

  /// No description provided for @preciseLocationRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'RouteX requires precise location tracking for navigation, accurate ETA calculations, and route guidance. Please enable precise location to continue.'**
  String get preciseLocationRequiredMessage;

  /// No description provided for @preciseLocationRequiredEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable Precise Location'**
  String get preciseLocationRequiredEnable;

  /// No description provided for @preciseLocationRequiredOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get preciseLocationRequiredOpenSettings;

  /// No description provided for @permLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable location access'**
  String get permLocationTitle;

  /// No description provided for @permLocationBody.
  ///
  /// In en, this message translates to:
  /// **'Allow RouteX to use your precise location to provide accurate live tracking, show your exact position on the map, and guide you through your delivery routes'**
  String get permLocationBody;

  /// No description provided for @permLocationButton.
  ///
  /// In en, this message translates to:
  /// **'Allow location access'**
  String get permLocationButton;

  /// No description provided for @permNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications'**
  String get permNotificationsTitle;

  /// No description provided for @permNotificationsBody.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications to receive important route updates, delivery assignments, shift changes, and alerts from your fleet.'**
  String get permNotificationsBody;

  /// No description provided for @permNotificationsButton.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications access'**
  String get permNotificationsButton;

  /// No description provided for @permGalleryTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow gallery access'**
  String get permGalleryTitle;

  /// No description provided for @permGalleryBody.
  ///
  /// In en, this message translates to:
  /// **'Allow gallery access to upload your profile picture and attach delivery photos when proof of delivery is required.'**
  String get permGalleryBody;

  /// No description provided for @permGalleryButton.
  ///
  /// In en, this message translates to:
  /// **'Allow gallery access'**
  String get permGalleryButton;
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
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
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
