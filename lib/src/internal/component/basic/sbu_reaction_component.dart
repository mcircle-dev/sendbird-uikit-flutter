// Copyright (c) 2024 Sendbird, Inc. All rights reserved.

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';
import 'package:sendbird_uikit/sendbird_uikit.dart';
import 'package:sendbird_uikit/src/internal/component/base/sbu_base_component.dart';
import 'package:sendbird_uikit/src/internal/component/basic/sbu_bottom_sheet_reaction_add_component.dart';
import 'package:sendbird_uikit/src/internal/component/basic/sbu_bottom_sheet_reaction_details_component.dart';
import 'package:sendbird_uikit/src/internal/component/basic/sbu_icon_component.dart';
import 'package:sendbird_uikit/src/internal/component/basic/sbu_image_component.dart';
import 'package:sendbird_uikit/src/internal/component/basic/sbu_text_component.dart';
import 'package:sendbird_uikit/src/internal/resource/sbu_text_styles.dart';
import 'package:sendbird_uikit/src/internal/utils/sbu_reaction_manager.dart';

class SBUReactionComponent extends SBUStatefulComponent {
  final BaseChannel? channel;
  final BaseMessage? message;
  final double? width;

  const SBUReactionComponent({
    required this.channel,
    required this.message,
    this.width,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => SBUReactionComponentState();
}

class SBUReactionComponentState extends State<SBUReactionComponent> {
  @override
  Widget build(BuildContext context) {
    final isLightTheme = context.watch<SBUThemeProvider>().isLight();

    final channel = widget.channel;
    final message = widget.message;
    final width = widget.width;

    if (!SBUReactionManager().isReactionAvailable(channel, message)) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [],
      );
    }

    const int maxCount = 4;
    final reactions = [...message!.reactions!];

    if (reactions.isEmpty) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [],
      );
    }

    const addReactionKey = 'add_reaction';
    final emojiList = SBUReactionManager().getEmojiList();
    if (reactions.length < emojiList.length) {
      reactions.add(
        Reaction(key: addReactionKey, userIds: [], updatedAt: 0),
      );
    }

    int columnCount = reactions.length ~/ maxCount;
    if (reactions.length % maxCount != 0) columnCount++;

    final currentUserId = SendbirdChat.currentUser?.userId;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: isLightTheme ? SBUColors.background50 : SBUColors.background600,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(
          color:
              isLightTheme ? SBUColors.background100 : SBUColors.background400,
          width: 1,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
      ),
      child: Scrollbar(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.only(left: 6, top: 6, right: 6, bottom: 6),
            height: columnCount * 34,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...List<Row>.generate(columnCount, (columnIndex) {
                  final startIndex = columnIndex * maxCount;
                  final endIndex = columnIndex * maxCount +
                      (columnIndex < columnCount - 1
                          ? maxCount
                          : reactions.length % maxCount == 0
                              ? maxCount
                              : reactions.length % maxCount);
                  final reactionSubList =
                      reactions.sublist(startIndex, endIndex);

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...reactionSubList.mapIndexed(
                        (subIndex, reaction) {
                          final emojiUrl =
                              SBUReactionManager().getEmoji(reaction.key)?.url;
                          if (emojiUrl == null &&
                              reaction.key != addReactionKey) {
                            return Container(); // Check
                          }

                          return Padding(
                            padding: const EdgeInsets.only(
                                left: 2, top: 2, right: 2, bottom: 2),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () async {
                                  if (reaction.key == addReactionKey) {
                                    await showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(8),
                                          topRight: Radius.circular(8),
                                        ),
                                      ),
                                      builder: (context) {
                                        return SBUBottomSheetReactionAddComponent(
                                          channel: channel,
                                          message: message,
                                        );
                                      },
                                    );
                                  } else {
                                    SBUReactionManager().toggleReaction(
                                        channel, message, reaction.key);
                                  }
                                },
                                onLongPress: () async {
                                  if (reaction.key != addReactionKey) {
                                    await showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(8),
                                          topRight: Radius.circular(8),
                                        ),
                                      ),
                                      builder: (context) {
                                        return SBUBottomSheetReactionDetailsComponent(
                                          channel: channel,
                                          message: message,
                                          selectedReaction: reaction,
                                        );
                                      },
                                    );
                                  }
                                },
                                child: (reaction.key == addReactionKey)
                                    ? Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            color: isLightTheme
                                                ? SBUColors.background100
                                                : SBUColors.background400),
                                        child: SizedBox(
                                          width: 53,
                                          height: 30,
                                          child: SBUIconComponent(
                                            iconSize: 20,
                                            iconData: SBUIcons.emoji,
                                            iconColor: isLightTheme
                                                ? SBUColors
                                                    .lightThemeTextLowEmphasis
                                                : SBUColors
                                                    .darkThemeTextLowEmphasis,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        decoration: (currentUserId != null &&
                                                reaction.userIds
                                                    .contains(currentUserId))
                                            ? BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                color: isLightTheme
                                                    ? SBUColors
                                                        .primaryExtraLight
                                                    : SBUColors
                                                        .primaryExtraDark)
                                            : BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                color: isLightTheme
                                                    ? SBUColors.background100
                                                    : SBUColors.background400),
                                        padding: const EdgeInsets.only(
                                            left: 8,
                                            top: 5,
                                            right: 8,
                                            bottom: 5),
                                        height: 30,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: emojiUrl != null
                                                  ? SBUImageComponent(
                                                      imageUrl: emojiUrl,
                                                      cacheKey: reaction.key,
                                                    )
                                                  : Container(), // Check
                                            ),
                                            const SizedBox(width: 4),
                                            Container(
                                              width: 13,
                                              height: 12,
                                              alignment: Alignment.center,
                                              child: SBUTextComponent(
                                                // '99+'(?)
                                                text:
                                                    '${reaction.userIds.length}',
                                                textType: SBUTextType.caption4,
                                                textColorType:
                                                    SBUTextColorType.text01,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                              ),
                            ),
                          );
                        },
                      ).toList(),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
