// Copyright (c) 2024 Sendbird, Inc. All rights reserved.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';
import 'package:sendbird_uikit/src/internal/utils/sbu_emoji_cache.dart';
import 'package:sendbird_uikit/src/internal/utils/sbu_preferences.dart';

class SBUReactionManager {
  SBUReactionManager._();

  static final SBUReactionManager _instance = SBUReactionManager._();

  factory SBUReactionManager() => _instance;

  bool useReaction = false;

  // Emoji
  Future<void> initEmojiList() async {
    try {
      final emojiContainer = await SendbirdChat.getAllEmoji();
      if (emojiContainer.emojiCategories.isNotEmpty) {
        await SBUPreferences().setEmojiCaches(
          emojiContainer.emojiCategories.first.emojis,
        );
      }
    } catch (_) {
      // Check
    }
  }

  void cacheEmojiList(BuildContext context) {
    final emojiList = SBUPreferences().getEmojiCacheList();
    for (final emoji in emojiList) {
      CachedNetworkImageProvider theImage = CachedNetworkImageProvider(
        emoji.url,
      );
      precacheImage(theImage, context, onError: (e, s) {
        // Check
      });
    }
  }

  List<SBUEmojiCache> getEmojiList() {
    return SBUPreferences().getEmojiCacheList();
  }

  SBUEmojiCache? getEmoji(String key) {
    return SBUPreferences().getEmojiCache(key);
  }

  // Reaction
  bool isReactionAvailable(BaseChannel? channel, BaseMessage? message) {
    final useReactionInAppInfo =
        SendbirdChat.getAppInfo()?.useReaction ?? false;
    if (!kIsWeb &&
        useReaction &&
        useReactionInAppInfo &&
        channel != null &&
        channel is GroupChannel &&
        !channel.isSuper &&
        message?.reactions != null) {
      return true;
    }
    return false;
  }

  Future<void> toggleReaction(
    BaseChannel? channel,
    BaseMessage? message,
    String key,
  ) async {
    try {
      if (message?.reactions != null) {
        final userId = SendbirdChat.currentUser?.userId;
        for (final reaction in message!.reactions!) {
          if (reaction.key == key &&
              userId != null &&
              reaction.userIds.contains(userId)) {
            await channel?.deleteReaction(message, key);
            return;
          }
        }
        await channel?.addReaction(message, key);
      }
    } catch (_) {
      // Check
    }
  }
}
