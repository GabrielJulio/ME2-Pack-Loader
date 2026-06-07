// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'ME2 Pack Loader';

  @override
  String get appTagline => 'Gerencie seus pacotes de mods do ModEngine2.';

  @override
  String get onboardingSelectFolder =>
      'Selecione a pasta onde o ModEngine2 está instalado.';

  @override
  String get onboardingChooseFolderButton => 'Escolher pasta do ModEngine2';

  @override
  String get onboardingPickerDialog => 'Selecione sua pasta do ModEngine2';

  @override
  String get languageLabel => 'Idioma';

  @override
  String get navMods => 'Mods';

  @override
  String get navSettings => 'Configurações';

  @override
  String get navExternalDlls => 'DLLs externas';

  @override
  String get navDebug => 'Depuração';

  @override
  String get navAbout => 'Sobre';

  @override
  String get headerSettings => 'Configurações';

  @override
  String get headerExternalDlls => 'DLLs externas';

  @override
  String get headerMods => 'Mods';

  @override
  String get headerDebug => 'Depuração';

  @override
  String get settingModLoader => 'Carregador de mods';

  @override
  String get settingLooseParams => 'Loose Params';

  @override
  String get settingScyllaHide => 'Scylla Hide';

  @override
  String get settingDebugMode => 'Modo de depuração';

  @override
  String get settingDebugModeSubtitle =>
      'Opção de desenvolvedor — desative para jogar normalmente';

  @override
  String get debugPageDescription =>
      'Opções de desenvolvedor. Desative antes de jogar online.';

  @override
  String get noDllsAdded => 'Nenhuma DLL adicionada';

  @override
  String get addDllTooltip => 'Adicionar DLL';

  @override
  String get removeTooltip => 'Remover';

  @override
  String get dllOutsideFolderError =>
      'A DLL precisa estar dentro da pasta do ModEngine2.';

  @override
  String get noModsYet => 'Nenhum mod ainda.\nClique em + para adicionar um.';

  @override
  String get addModTooltip => 'Adicionar mod';

  @override
  String get importFilesTooltip => 'Importar arquivos';

  @override
  String get deleteModTooltip => 'Excluir mod';

  @override
  String get modFolderEmptyTooltip =>
      'A pasta está vazia — adicione arquivos antes de ativar';

  @override
  String get addModTitle => 'Adicionar mod';

  @override
  String importFilesForMod(String name) {
    return 'Importar arquivos — $name';
  }

  @override
  String get modNameLabel => 'Nome do mod';

  @override
  String get modNameHint => 'ex.: Meu Pack de Texturas';

  @override
  String get validationNameRequired => 'O nome é obrigatório';

  @override
  String get validationEmptyFolderName =>
      'O nome resulta em um nome de pasta vazio';

  @override
  String get validationNameTaken => 'Esse nome já está em uso';

  @override
  String get slugFolderPrefix => 'Pasta: ';

  @override
  String get slugAvailable => 'Disponível';

  @override
  String get slugTaken => 'Esse nome já está em uso';

  @override
  String get slugFolderPlaceholder => '<pasta>';

  @override
  String get importFilesButton => 'Importar arquivos';

  @override
  String importFilesTip(String path) {
    return 'Dica: depois de extrair o arquivo do mod, você também pode mover os arquivos manualmente para:\n$path';
  }

  @override
  String filesImported(int count, String path) {
    return '$count arquivo(s) importado(s) para $path/';
  }

  @override
  String get deleteModDialogTitle => 'Excluir mod?';

  @override
  String get deleteModDialogBodyBefore =>
      'Isto excluirá permanentemente a pasta e todos os arquivos de ';

  @override
  String get deleteModDialogBodyAfter => '. Esta ação não pode ser desfeita.';

  @override
  String get buttonCancel => 'Cancelar';

  @override
  String get buttonDelete => 'Excluir';

  @override
  String get buttonDone => 'Concluído';

  @override
  String get buttonAdd => 'Adicionar';

  @override
  String get buttonRetry => 'Tentar novamente';

  @override
  String get launchGameButton => 'Iniciar jogo';

  @override
  String get launchGameDisabledTooltip =>
      'Configure as opções de inicialização do Steam primeiro';

  @override
  String get setUpSteamButton => 'Configurar Steam';

  @override
  String get switchLayoutTooltip => 'Trocar layout';

  @override
  String get layoutDefaultName => 'Padrão';

  @override
  String get layoutGnomeName => 'GNOME';

  @override
  String get gameComingSoonTooltip => 'Em breve em uma atualização futura';

  @override
  String get darkSouls3 => 'Dark Souls III';

  @override
  String configLoadFailed(String error) {
    return 'Falha ao carregar a configuração: $error';
  }

  @override
  String configSaveFailed(String error) {
    return 'Falha ao salvar a configuração: $error';
  }

  @override
  String get aboutVersion => 'v1.0.0';

  @override
  String get aboutDescription =>
      'Uma interface gráfica para gerenciar pacotes de mods do ModEngine2 para jogos da FromSoftware.';

  @override
  String get aboutUnofficial =>
      'Ferramenta não oficial feita pela comunidade. Sem afiliação com FromSoftware, Bandai Namco ou a equipe do ModEngine2.';

  @override
  String get aboutOnlineWarning =>
      '⚠ Sempre jogue offline ao usar mods para evitar banimentos do Easy Anti-Cheat.';

  @override
  String get steamSetupTitle => 'Configurar Steam';

  @override
  String get steamSetupHeading => 'Adicionar o ME2 Pack Loader ao Steam';

  @override
  String get steamSetupInstructions =>
      '1. Abra o Steam\n2. Clique com o botão direito em Dark Souls III na sua biblioteca\n3. Escolha Propriedades → Opções de inicialização\n4. Cole o comando abaixo e clique em OK';

  @override
  String get copyToClipboardTooltip => 'Copiar para a área de transferência';

  @override
  String get copiedToClipboard => 'Copiado para a área de transferência';
}
