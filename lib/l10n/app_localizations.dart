import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('en'),
    Locale('pt'),
  ];

  /// App's display name. Brand name — usually not translated.
  ///
  /// In en, this message translates to:
  /// **'ME2 Pack Loader'**
  String get appTitle;

  /// Short description shown on the onboarding screen.
  ///
  /// In en, this message translates to:
  /// **'Manage your ModEngine2 mod packs.'**
  String get appTagline;

  /// No description provided for @onboardingSelectFolder.
  ///
  /// In en, this message translates to:
  /// **'Select the folder where ModEngine2 is installed.'**
  String get onboardingSelectFolder;

  /// No description provided for @onboardingChooseFolderButton.
  ///
  /// In en, this message translates to:
  /// **'Choose ModEngine2 folder'**
  String get onboardingChooseFolderButton;

  /// No description provided for @onboardingPickerDialog.
  ///
  /// In en, this message translates to:
  /// **'Select your ModEngine2 folder'**
  String get onboardingPickerDialog;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @navMods.
  ///
  /// In en, this message translates to:
  /// **'Mods'**
  String get navMods;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @navExternalDlls.
  ///
  /// In en, this message translates to:
  /// **'External DLLs'**
  String get navExternalDlls;

  /// No description provided for @navDebug.
  ///
  /// In en, this message translates to:
  /// **'Debug'**
  String get navDebug;

  /// No description provided for @navAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get navAbout;

  /// No description provided for @headerSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get headerSettings;

  /// No description provided for @headerExternalDlls.
  ///
  /// In en, this message translates to:
  /// **'External DLLs'**
  String get headerExternalDlls;

  /// No description provided for @headerMods.
  ///
  /// In en, this message translates to:
  /// **'Mods'**
  String get headerMods;

  /// No description provided for @headerDebug.
  ///
  /// In en, this message translates to:
  /// **'Debug'**
  String get headerDebug;

  /// No description provided for @settingModLoader.
  ///
  /// In en, this message translates to:
  /// **'Mod Loader'**
  String get settingModLoader;

  /// No description provided for @settingLooseParams.
  ///
  /// In en, this message translates to:
  /// **'Loose Params'**
  String get settingLooseParams;

  /// No description provided for @settingScyllaHide.
  ///
  /// In en, this message translates to:
  /// **'Scylla Hide'**
  String get settingScyllaHide;

  /// No description provided for @settingDebugMode.
  ///
  /// In en, this message translates to:
  /// **'Debug Mode'**
  String get settingDebugMode;

  /// No description provided for @settingDebugModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Developer option — disable for normal play'**
  String get settingDebugModeSubtitle;

  /// No description provided for @debugPageDescription.
  ///
  /// In en, this message translates to:
  /// **'Developer options. Disable before playing online.'**
  String get debugPageDescription;

  /// No description provided for @noDllsAdded.
  ///
  /// In en, this message translates to:
  /// **'No DLLs added'**
  String get noDllsAdded;

  /// No description provided for @addDllTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add DLL'**
  String get addDllTooltip;

  /// No description provided for @removeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeTooltip;

  /// No description provided for @dllOutsideFolderError.
  ///
  /// In en, this message translates to:
  /// **'DLL must be inside the ModEngine2 folder.'**
  String get dllOutsideFolderError;

  /// No description provided for @noModsYet.
  ///
  /// In en, this message translates to:
  /// **'No mods yet.\nPress + to add one.'**
  String get noModsYet;

  /// No description provided for @addModTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add mod'**
  String get addModTooltip;

  /// No description provided for @importFilesTooltip.
  ///
  /// In en, this message translates to:
  /// **'Import files'**
  String get importFilesTooltip;

  /// No description provided for @deleteModTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete mod'**
  String get deleteModTooltip;

  /// No description provided for @modFolderEmptyTooltip.
  ///
  /// In en, this message translates to:
  /// **'Folder is empty — add files before enabling'**
  String get modFolderEmptyTooltip;

  /// No description provided for @addModTitle.
  ///
  /// In en, this message translates to:
  /// **'Add mod'**
  String get addModTitle;

  /// No description provided for @importFilesForMod.
  ///
  /// In en, this message translates to:
  /// **'Import files — {name}'**
  String importFilesForMod(String name);

  /// No description provided for @modNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Mod name'**
  String get modNameLabel;

  /// No description provided for @modNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. My Texture Pack'**
  String get modNameHint;

  /// No description provided for @validationNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get validationNameRequired;

  /// No description provided for @validationEmptyFolderName.
  ///
  /// In en, this message translates to:
  /// **'Name produces an empty folder name'**
  String get validationEmptyFolderName;

  /// No description provided for @validationNameTaken.
  ///
  /// In en, this message translates to:
  /// **'Name already taken'**
  String get validationNameTaken;

  /// No description provided for @slugFolderPrefix.
  ///
  /// In en, this message translates to:
  /// **'Folder: '**
  String get slugFolderPrefix;

  /// No description provided for @slugAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get slugAvailable;

  /// No description provided for @slugTaken.
  ///
  /// In en, this message translates to:
  /// **'Name already taken'**
  String get slugTaken;

  /// No description provided for @slugFolderPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'<folder>'**
  String get slugFolderPlaceholder;

  /// No description provided for @importFilesButton.
  ///
  /// In en, this message translates to:
  /// **'Import files'**
  String get importFilesButton;

  /// No description provided for @importFilesTip.
  ///
  /// In en, this message translates to:
  /// **'Tip: after extracting your mod archive you can also move the files manually to:\n{path}'**
  String importFilesTip(String path);

  /// No description provided for @filesImported.
  ///
  /// In en, this message translates to:
  /// **'{count} file(s) imported to {path}/'**
  String filesImported(int count, String path);

  /// No description provided for @deleteModDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete mod?'**
  String get deleteModDialogTitle;

  /// No description provided for @deleteModDialogBodyBefore.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete the folder and all its files for '**
  String get deleteModDialogBodyBefore;

  /// No description provided for @deleteModDialogBodyAfter.
  ///
  /// In en, this message translates to:
  /// **'. This cannot be undone.'**
  String get deleteModDialogBodyAfter;

  /// No description provided for @buttonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get buttonCancel;

  /// No description provided for @buttonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get buttonDelete;

  /// No description provided for @buttonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get buttonDone;

  /// No description provided for @buttonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get buttonAdd;

  /// No description provided for @buttonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get buttonRetry;

  /// No description provided for @launchGameButton.
  ///
  /// In en, this message translates to:
  /// **'Launch Game'**
  String get launchGameButton;

  /// No description provided for @launchGameDisabledTooltip.
  ///
  /// In en, this message translates to:
  /// **'Configure Steam launch options first'**
  String get launchGameDisabledTooltip;

  /// No description provided for @setUpSteamButton.
  ///
  /// In en, this message translates to:
  /// **'Set up Steam'**
  String get setUpSteamButton;

  /// No description provided for @switchLayoutTooltip.
  ///
  /// In en, this message translates to:
  /// **'Switch layout'**
  String get switchLayoutTooltip;

  /// No description provided for @layoutDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get layoutDefaultName;

  /// No description provided for @layoutGnomeName.
  ///
  /// In en, this message translates to:
  /// **'GNOME'**
  String get layoutGnomeName;

  /// No description provided for @gameComingSoonTooltip.
  ///
  /// In en, this message translates to:
  /// **'Coming in a future update'**
  String get gameComingSoonTooltip;

  /// No description provided for @darkSouls3.
  ///
  /// In en, this message translates to:
  /// **'Dark Souls III'**
  String get darkSouls3;

  /// No description provided for @configLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load config: {error}'**
  String configLoadFailed(String error);

  /// No description provided for @configSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save config: {error}'**
  String configSaveFailed(String error);

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'v1.0.0'**
  String get aboutVersion;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'A GUI for managing ModEngine2 mod packs for FromSoftware games.'**
  String get aboutDescription;

  /// No description provided for @aboutUnofficial.
  ///
  /// In en, this message translates to:
  /// **'Unofficial community tool. Not affiliated with FromSoftware, Bandai Namco, or the ModEngine2 team.'**
  String get aboutUnofficial;

  /// No description provided for @aboutOnlineWarning.
  ///
  /// In en, this message translates to:
  /// **'⚠ Always play offline when using mods to avoid Easy Anti-Cheat bans.'**
  String get aboutOnlineWarning;

  /// No description provided for @steamSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up Steam'**
  String get steamSetupTitle;

  /// No description provided for @steamSetupHeading.
  ///
  /// In en, this message translates to:
  /// **'Add ME2 Pack Loader to Steam'**
  String get steamSetupHeading;

  /// No description provided for @steamSetupInstructions.
  ///
  /// In en, this message translates to:
  /// **'1. Open Steam\n2. Right-click Dark Souls III in your library\n3. Choose Properties → Launch Options\n4. Paste the command below and click OK'**
  String get steamSetupInstructions;

  /// No description provided for @copyToClipboardTooltip.
  ///
  /// In en, this message translates to:
  /// **'Copy to clipboard'**
  String get copyToClipboardTooltip;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;
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
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
