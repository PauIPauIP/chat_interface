import 'package:get/get.dart';

class GeneralSettingsTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        //* English US
        'en_US': {
          // Categories
          'settings.tab.account': 'Account',
          'settings.tab.appearance': 'Appearance',
          'settings.tab.app': 'App',
          'settings.tab.security': 'Security',
          'settings.data': 'Data',
          'settings.data.desc': 'Manage your account.',
          'settings.profile': 'Profile',
          'settings.profile.desc': '',
          'settings.security': 'Security',
          'settings.devices': 'Devices',
          'settings.camera': 'Camera',
          'settings.camera.desc': 'Try out your camera.',
          'settings.audio': 'Audio',
          'settings.audio.desc': 'Microphone & headphones.',
          'settings.notifications': 'Notifications',
          'settings.language': 'Language',
          'settings.language.desc': 'Sprache, 言語 or language.',
          'settings.colors': 'Colors',
          'settings.colors.desc': 'The colors of the app.',
          'settings.call_app': 'Call appearance',
          'settings.requests': 'Friend requests',
          'settings.encryption': 'Encryption',
          'settings.spaces': 'Spaces',
          'settings.tabletop': 'Tabletop',
          'settings.tabletop.desc': 'Smooth scrolling and more.',
          'settings.chat': 'Chat',
          'settings.chat.desc': 'How the messages look.',
          'settings.files': 'Files',
          'settings.files.desc': 'How files are stored.',
          'settings.invites': 'Invites',
          'settings.invites.desc': 'Invite people to Liphium.',
          'settings.trusted_links': 'Trusted Links',
          'settings.trusted_links.desc': 'The websites you trust.',
          'settings.invites.title': 'You have @count invites left.',
          'settings.experimental': 'Experimental',

          // Trusted links
          'links.warning':
              'This an advanced section. Changing the default behavior of the app might result in leaks of your data or other various things. Only change things here if you know what you\'re doing.',
          'links.locations': 'Settings for locations',
          'links.unsafe_sources': 'Allow accessing resources from unsafe locations (e.g. websites with HTTP)',
          'links.trusted_domains': 'Trusted domains',
          'links.trust_mode': 'Select which domains you want to trust.',
          'links.trust_mode.all': 'All domains',
          'links.trust_mode.list_verified': 'A verified list of providers',
          'links.trust_mode.list': 'A custom list of domains (defined below)',
          'links.trust_mode.none': 'No domains',
          'links.trusted_list': 'Here\'s the list of domains you trust.',
          'links.trusted_list.add': 'Add a trusted domain',
          'links.trusted_list.placeholder': 'liphium.app',
          'links.trusted_list.empty': 'You currently don\'t trust any domains.',
        },
      };
}
