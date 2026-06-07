// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ME2 Pack Loader';

  @override
  String get appTagline => 'Manage your ModEngine2 mod packs.';

  @override
  String get onboardingSelectFolder =>
      'Select the folder where ModEngine2 is installed.';

  @override
  String get onboardingChooseFolderButton => 'Choose ModEngine2 folder';

  @override
  String get onboardingPickerDialog => 'Select your ModEngine2 folder';

  @override
  String get languageLabel => 'Language';

  @override
  String get navMods => 'Mods';

  @override
  String get navSettings => 'Settings';

  @override
  String get navExternalDlls => 'External DLLs';

  @override
  String get navDebug => 'Debug';

  @override
  String get navAbout => 'About';

  @override
  String get headerSettings => 'Settings';

  @override
  String get headerExternalDlls => 'External DLLs';

  @override
  String get headerMods => 'Mods';

  @override
  String get headerDebug => 'Debug';

  @override
  String get settingModLoader => 'Mod Loader';

  @override
  String get settingLooseParams => 'Loose Params';

  @override
  String get settingScyllaHide => 'Scylla Hide';

  @override
  String get settingDebugMode => 'Debug Mode';

  @override
  String get settingDebugModeSubtitle =>
      'Developer option — disable for normal play';

  @override
  String get debugPageDescription =>
      'Developer options. Disable before playing online.';

  @override
  String get noDllsAdded => 'No DLLs added';

  @override
  String get addDllTooltip => 'Add DLL';

  @override
  String get removeTooltip => 'Remove';

  @override
  String get dllOutsideFolderError =>
      'DLL must be inside the ModEngine2 folder.';

  @override
  String get noModsYet => 'No mods yet.\nPress + to add one.';

  @override
  String get addModTooltip => 'Add mod';

  @override
  String get importFilesTooltip => 'Import files';

  @override
  String get deleteModTooltip => 'Delete mod';

  @override
  String get modFolderEmptyTooltip =>
      'Folder is empty — add files before enabling';

  @override
  String get addModTitle => 'Add mod';

  @override
  String importFilesForMod(String name) {
    return 'Import files — $name';
  }

  @override
  String get modNameLabel => 'Mod name';

  @override
  String get modNameHint => 'e.g. My Texture Pack';

  @override
  String get validationNameRequired => 'Name is required';

  @override
  String get validationEmptyFolderName => 'Name produces an empty folder name';

  @override
  String get validationNameTaken => 'Name already taken';

  @override
  String get slugFolderPrefix => 'Folder: ';

  @override
  String get slugAvailable => 'Available';

  @override
  String get slugTaken => 'Name already taken';

  @override
  String get slugFolderPlaceholder => '<folder>';

  @override
  String get importFilesButton => 'Import files';

  @override
  String importFilesTip(String path) {
    return 'Tip: after extracting your mod archive you can also move the files manually to:\n$path';
  }

  @override
  String filesImported(int count, String path) {
    return '$count file(s) imported to $path/';
  }

  @override
  String get deleteModDialogTitle => 'Delete mod?';

  @override
  String get deleteModDialogBodyBefore =>
      'This will permanently delete the folder and all its files for ';

  @override
  String get deleteModDialogBodyAfter => '. This cannot be undone.';

  @override
  String get buttonCancel => 'Cancel';

  @override
  String get buttonDelete => 'Delete';

  @override
  String get buttonDone => 'Done';

  @override
  String get buttonAdd => 'Add';

  @override
  String get buttonRetry => 'Retry';

  @override
  String get launchGameButton => 'Launch Game';

  @override
  String get launchGameDisabledTooltip =>
      'Configure Steam launch options first';

  @override
  String get setUpSteamButton => 'Set up Steam';

  @override
  String get switchLayoutTooltip => 'Switch layout';

  @override
  String get layoutDefaultName => 'Default';

  @override
  String get layoutGnomeName => 'GNOME';

  @override
  String get gameComingSoonTooltip => 'Coming in a future update';

  @override
  String get darkSouls3 => 'Dark Souls III';

  @override
  String configLoadFailed(String error) {
    return 'Failed to load config: $error';
  }

  @override
  String configSaveFailed(String error) {
    return 'Failed to save config: $error';
  }

  @override
  String get aboutVersion => 'v1.0.0';

  @override
  String get aboutDescription =>
      'A GUI for managing ModEngine2 mod packs for FromSoftware games.';

  @override
  String get aboutUnofficial =>
      'Unofficial community tool. Not affiliated with FromSoftware, Bandai Namco, or the ModEngine2 team.';

  @override
  String get aboutOnlineWarning =>
      '⚠ Always play offline when using mods to avoid Easy Anti-Cheat bans.';

  @override
  String get steamSetupTitle => 'Set up Steam';

  @override
  String get steamSetupHeading => 'Add ME2 Pack Loader to Steam';

  @override
  String get steamSetupInstructions =>
      '1. Open Steam\n2. Right-click Dark Souls III in your library\n3. Choose Properties → Launch Options\n4. Paste the command below and click OK';

  @override
  String get copyToClipboardTooltip => 'Copy to clipboard';

  @override
  String get copiedToClipboard => 'Copied to clipboard';
}
