// Copyright (c) 2024 Sendbird, Inc. All rights reserved.

import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';
import 'package:sendbird_uikit/sendbird_uikit.dart';

class SBUReplyManager {
  SBUReplyManager._();

  static final SBUReplyManager _instance = SBUReplyManager._();

  factory SBUReplyManager() => _instance;

  SBUReplyType replyType = SBUReplyType.none;

  bool isQuoteReplyAvailable(BaseChannel? channel) {
    final isMessageThreadingEnabledInAppInfo = SendbirdChat.getAppInfo()
            ?.attributesInUse
            .contains('enable_message_threading') ??
        false;
    if (replyType == SBUReplyType.quoteReply &&
        isMessageThreadingEnabledInAppInfo &&
        channel != null &&
        channel is GroupChannel &&
        !channel.isSuper) {
      return true;
    }
    return false;
  }
}
