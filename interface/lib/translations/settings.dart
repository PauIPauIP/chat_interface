import 'package:get/get.dart';

class SettingsTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {

    //* English US
    'en_US': {
      // Categories
      'settings.tab.account': 'Account',
      'settings.tab.appearance': 'Appearance',
      'settings.tab.app': 'App',
      'settings.tab.privacy': 'Privacy',
      'settings.data': 'Data',
      'settings.profile': 'Profile',
      'settings.security': 'Security',
      'settings.devices': 'Devices',
      'settings.video': 'Video',
      'settings.audio': 'Audio',
      'settings.notifications': 'Notifications',
      'settings.language': 'Language',
      'settings.colors': 'Colors',
      'settings.call_app': 'Call appearance',
      'settings.requests': 'Friend requests',
      'settings.encryption': 'Encryption',
      'settings.spaces': 'Spaces',
      'settings.files': 'Files',

      // Audio settings
      'audio.device': 'Select a device',
      'audio.device.default': "If you don't know what to select here, the default is probably fine:",
      'audio.device.default.button': 'Use system default',
      'audio.microphone': 'Microphone',
      'audio.microphone.device': 'Or you just select one of these devices (the green verified indicator tries detecting the best microphone):',
      'audio.microphone.muted': 'Start muted in Spaces',
      'audio.microphone.sensitivity': 'Microphone sensitivity',
      'audio.microphone.sensitivity.text': 'The green line is your current talking volume. Drag the slider to the point where you would like others to start hearing you.',
      'audio.output': 'Output',
      'audio.output.device': 'Or you just select one of these devices:',

      // Theme settings
      'theme.presets': 'Presets',
      'theme.default_dark': 'Advanched Dark',
      'theme.default_light': 'Advanched Light',
      'theme.winter': 'Winter',
      'theme.custom': 'Create your own',
      'theme.custom.title': 'Custom theme',
      'custom.primary_hue': 'Primary hue',
      'custom.secondary_hue': 'Secondary hue',
      'custom.base_saturation': 'Base saturation',
      'custom.theme_mode': 'Theme brightness',
      'custom.dark': 'Dark',
      'custom.light': 'Light',
      'custom.background_mode': 'What color should the background have?',
      'custom.none': 'None',
      'custom.colored': 'Primary color',
      'theme.apply': 'Apply your theme',

      // File settings
      'auto_download.images': 'Automatically download images',
      'auto_download.videos': 'Automatically download videos',
      'auto_download.audio': 'Automatically download audio',
      'settings.file.auto_download.types': 'Types of files to automatically download',
      'settings.file.max_size': 'Maximum file size for automatic downloads',
      'settings.file.max_size.description': 'Files larger than this will not be downloaded automatically.',
      'settings.file.mb': 'MB',

      // Data settings
      'settings.data.profile_picture': 'Profile picture',
      'settings.data.profile_picture.select': 'Now just zoom and move your image into the perfect spot! So it makes your beauty shine, if you even have any...',
      'settings.data.profile_picture.requirements': 'Can only be a JPEG or PNG and can\'t be larger than 10 MB.',
      'settings.data.profile_picture.remove': 'Remove profile picture',
      'settings.data.profile_picture.remove.confirm': 'Are you sure you want to remove your profile picture?',

      // Spaces settings
      'game.music': 'Play music in Game Mode',
    },

    //* German
    'de_DE': {
      // Categories
      'settings.tab.account': 'Konto',
      'settings.tab.appearance': 'Aussehen',
      'settings.tab.app': 'App',
      'settings.tab.privacy': 'Privatsphäre',
      'settings.data': 'Daten',
      'settings.profile': 'Profil',
      'settings.security': 'Sicherheit',
      'settings.devices': 'Geräte',
      'settings.video': 'Video',
      'settings.audio': 'Audio',
      'settings.notifications': 'Benachrichtigungen',
      'settings.language': 'Sprache',
      'settings.colors': 'Farben',
      'settings.call_app': 'Anrufe',
      'settings.requests': 'Freundschaftsanfragen',
      'settings.encryption': 'Verschlüsselung',
      'settings.spaces': 'Spaces',
      'settings.files': 'Dateien',

      // Audio settings
      'audio.device': 'Wähle ein Gerät aus',
      'audio.device.default': 'Wenn du nicht weißt, was du hier auswählen sollst, ist oft das Standardgerät in Ordnung:',
      'audio.device.default.button': 'Systemstandard verwenden',
      'audio.microphone': 'Mikrofon',
      'audio.microphone.device': 'Oder du wählst einfach eines dieser Geräte aus (der grüne Verifizierungsindikator steht für das beste Mikrofon):',
      'audio.microphone.muted': 'In einem Space stummgeschaltet starten',
      'audio.microphone.sensitivity': 'Mikrofonempfindlichkeit',
      'audio.microphone.sensitivity.text': 'Die grüne Linie ist deine aktuelle Lautstärke. Ziehe den Regler an die Stelle, an der andere dich hören sollen.',
      'audio.output': 'Ausgabe',
      'audio.output.device': 'Oder du wählst einfach eines dieser Geräte aus:',

      // File settings
      'auto_download.images': 'Bilder automatisch herunterladen',
      'auto_download.videos': 'Videos automatisch herunterladen',
      'auto_download.audio': 'Audio automatisch herunterladen',
      'settings.file.auto_download.types': 'Dateitypen, die automatisch heruntergeladen werden sollen',
      'settings.file.max_size': 'Maximale Dateigröße für automatische Downloads',
      'settings.file.max_size.description': 'Dateien, die größer sind, werden nicht automatisch heruntergeladen.',
      'settings.file.mb': 'MB',

      // Theme settings
      'theme.presets': 'Vorlagen',
      'theme.default_dark': 'Dunkel',
      'theme.default_light': 'Hell',
      'theme.winter': 'Winter',
      'theme.custom': 'Erstelle dein eigenes',
      'theme.custom.title': 'Eigenes Design',
      'custom.primary_hue': 'Primärfarbe',
      'custom.secondary_hue': 'Sekundärfarbe',
      'custom.base_saturation': 'Sättigung',
      'custom.theme_mode': 'Helligkeit',
      'custom.dark': 'Dunkel',
      'custom.light': 'Hell',
      'custom.background_mode': 'Welche Farbe soll der Hintergrund haben?',
      'custom.none': 'Keine',
      'custom.colored': 'Primärfarbe',
      'theme.apply': 'Design anwenden',

      // Data settings
      'settings.data.profile_picture': 'Profilbild',
      'settings.data.profile_picture.select': 'Wähle dein neuestes Meme aus, damit jeder sehen kann, wie cool du bist!',
      'settings.data.profile_picture.requirements': 'Kann nur ein JPEG oder PNG sein und darf nicht größer als 10 MB sein.',
      'settings.data.profile_picture.remove': 'Profilbild entfernen',
      'settings.data.profile_picture.remove.confirm': 'Bist du sicher, dass du dein Profilbild entfernen möchtest?',

      // Spaces settings
      'game.music': 'Musik im Spielmodus abspielen',
    }
  };
}