// Copyright (c) 2025 Sendbird, Inc. All rights reserved.

import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';
import 'package:sendbird_uikit/src/internal/provider/sbu_message_collection_provider.dart';
import 'package:sendbird_uikit/src/internal/utils/sbu_configuration_manager.dart';

class SBUMarkAsUnreadManager {
  SBUMarkAsUnreadManager._();

  static final SBUMarkAsUnreadManager _instance = SBUMarkAsUnreadManager._();

  factory SBUMarkAsUnreadManager() => _instance;

  bool? useMarkAsUnread;

  bool isOn() {
    final isMarkAsUnreadEnabledOnDashboard =
        SBUConfigurationManager().isMarkAsUnreadEnabledOnDashboard();

    if (useMarkAsUnread != null) {
      return useMarkAsUnread!;
    } else if (isMarkAsUnreadEnabledOnDashboard != null) {
      return isMarkAsUnreadEnabledOnDashboard;
    }
    return false;
  }

  Future<void> markAsUnread(GroupChannel channel, BaseMessage message) async {
    if (isOn()) {
      try {
        await channel.markAsUnread(message);
      } catch (e) {
        // Check
      }
    }
  }

  // [Reverse]
  // ---- New messages line ----
  // [3] Old message
  // [2]
  // [1]
  // [0] New message
  bool hasNewMessageLine({
    required MessageCollection collection,
    required List<BaseMessage> messageList,
    required int messageIndex,
  }) {
    if (!isOn()) {
      return false;
    }

    if (!SBUMessageCollectionProvider()
        .isEnabledNewLine(collection.channel.channelUrl)) {
      return false;
    }

    if (messageIndex < 0 || messageIndex >= messageList.length) {
      return false; // Invalid index
    }

    final message = messageList[messageIndex];

    if (message.messageId <= 0) {
      return false; // Invalid message ID
    }

    if (message.sendingStatus != SendingStatus.succeeded) {
      return false; // Not a sent message
    }

    if (message.isSilent) {
      return false;
    }

    final myLastRead = SBUMessageCollectionProvider()
            .getMyLastRead(collection.channel.channelUrl) ??
        0;

    bool result = _hasNewMessageLine(
      collection,
      myLastRead,
      messageList,
      messageIndex,
    );

    if (result) {
      if (messageIndex + 1 < messageList.length) {
        final prevMessageIndex = messageIndex + 1;
        if (_hasNewMessageLine(
          collection,
          myLastRead,
          messageList,
          prevMessageIndex,
        )) {
          result = false; // Check
        }
      }
    }

    if (result) {
      final messageListSize = messageList.length;
      final resultSize = collection.loadPreviousParams.previousResultSize;
      final quotient = messageListSize ~/ resultSize;
      final checkIndex = quotient * resultSize - 1;

      if (checkIndex >= 0 && checkIndex < messageIndex) {
        if (messageList[messageIndex].createdAt ==
            messageList[checkIndex].createdAt) {
          result = false; // Check
        }
      }
    }

    return result;
  }

  bool _hasNewMessageLine(
    MessageCollection collection,
    int myLastRead,
    List<BaseMessage> messageList,
    int messageIndex,
  ) {
    BaseMessage message = messageList[messageIndex];
    if (message.isSilent) {
      return false;
    }

    BaseMessage? prevMessage = (messageIndex + 1 < messageList.length)
        ? messageList[messageIndex + 1]
        : null;

    final isBottomOfScreen = SBUMessageCollectionProvider()
        .isBottomOfScreen(collection.channel.channelUrl);

    if (prevMessage == null) {
      if (myLastRead == message.createdAt - 1) {
        // if (collection.hasPrevious == false) { // Check
        return true;
        // }
      } else if (collection.hasPrevious == false &&
          isBottomOfScreen &&
          myLastRead < message.createdAt) {
        return true;
      }
    } else {
      if (myLastRead >= prevMessage.createdAt &&
          myLastRead < message.createdAt) {
        return true;
      } else if (collection.hasPrevious == false &&
          isBottomOfScreen &&
          myLastRead < message.createdAt) {
        bool result = true;
        for (int i = messageIndex + 1; i < messageList.length; i++) {
          if (messageList[i].isSilent == false ||
              myLastRead >= messageList[i].createdAt) {
            result = false;
            break;
          }
        }

        if (result) {
          SBUMessageCollectionProvider().setMyLastRead(
              collection.channel.channelUrl, message.createdAt - 1); // Check
        }
        return result;
      }
    }
    return false;
  }
}
