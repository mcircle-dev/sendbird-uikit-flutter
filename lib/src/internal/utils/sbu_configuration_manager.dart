// Copyright (c) 2025 Sendbird, Inc. All rights reserved.

import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';
import 'package:sendbird_uikit/src/internal/utils/sbu_preferences.dart';

class SBUConfigurationManager {
  SBUConfigurationManager._();

  static final SBUConfigurationManager _instance = SBUConfigurationManager._();

  factory SBUConfigurationManager() => _instance;

  static String enableMarkAsUnreadKey =
      'group_channel-channel-enable_mark_as_unread';

  Future<void> checkConfiguration() async {
    final cachedLastUpdatedAt =
        SBUPreferences().getConfigurationLastUpdatedAt();
    final lastUpdatedAt =
        SendbirdChat.getAppInfo()?.uikitConfigInfo?.lastUpdatedAt;

    if (lastUpdatedAt != null && lastUpdatedAt > cachedLastUpdatedAt) {
      try {
        final uikitConfiguration = await SendbirdChat.getUIKitConfiguration();
        if (uikitConfiguration != null) {
          Map<String, bool> configurations = {};

          // TODO: Other configurations can be added here as needed
          bool? enableMarkAsUnread = uikitConfiguration['configuration']
              ['group_channel']['channel']['enable_mark_as_unread'];

          if (enableMarkAsUnread != null) {
            configurations[enableMarkAsUnreadKey] = enableMarkAsUnread;
          }

          final configurationCaches =
              await SBUPreferences().setConfigurationCaches(configurations);
          if (configurationCaches != null) {
            await SBUPreferences().setConfigurationLastUpdatedAt(lastUpdatedAt);
          }
        }
      } catch (_) {
        // Check
      }
    }
  }

  bool? isMarkAsUnreadEnabledOnDashboard() {
    return SBUPreferences().getConfigurationCache(enableMarkAsUnreadKey);
  }
}
