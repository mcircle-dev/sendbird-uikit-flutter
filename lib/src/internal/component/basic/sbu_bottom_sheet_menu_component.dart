// Copyright (c) 2024 Sendbird, Inc. All rights reserved.

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';
import 'package:sendbird_uikit/sendbird_uikit.dart';
import 'package:sendbird_uikit/src/internal/component/base/sbu_base_component.dart';
import 'package:sendbird_uikit/src/internal/component/basic/sbu_bottom_sheet_reaction_add_component.dart';
import 'package:sendbird_uikit/src/internal/component/basic/sbu_icon_component.dart';
import 'package:sendbird_uikit/src/internal/component/basic/sbu_image_component.dart';
import 'package:sendbird_uikit/src/internal/component/basic/sbu_text_component.dart';
import 'package:sendbird_uikit/src/internal/resource/sbu_text_styles.dart';
import 'package:sendbird_uikit/src/internal/utils/sbu_reaction_manager.dart';

class SBUBottomSheetMenuComponent extends SBUStatefulComponent {
  final BaseChannel? channel;
  final BaseMessage? message;
  final List<IconData>? iconNames;
  final List<String> buttonNames;
  final void Function(String buttonName) onButtonClicked;
  final int? errorColorIndex;
  final List<String>? disabledNames;

  const SBUBottomSheetMenuComponent({
    this.channel,
    this.message,
    this.iconNames,
    required this.buttonNames,
    required this.onButtonClicked,
    this.errorColorIndex,
    this.disabledNames,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => SBUBottomSheetMenuComponentState();
}

class SBUBottomSheetMenuComponentState
    extends State<SBUBottomSheetMenuComponent> {
  @override
  Widget build(BuildContext context) {
    final isLightTheme = context.watch<SBUThemeProvider>().isLight();

    final channel = widget.channel;
    final message = widget.message;
    final iconNames = widget.iconNames;
    final buttonNames = widget.buttonNames;
    final onButtonClicked = widget.onButtonClicked;
    final errorColorIndex = widget.errorColorIndex;
    final disabledNames = widget.disabledNames;

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color:
              isLightTheme ? SBUColors.background50 : SBUColors.background500,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _getReactionWidget(channel, message, isLightTheme),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: buttonNames.mapIndexed((index, iconName) {
                final isError = (errorColorIndex == index);
                final isDisabled =
                    disabledNames?.any((name) => name == buttonNames[index]) ??
                        false;

                return Material(
                  color: Colors.transparent,
                  child: isDisabled
                      ? _menuItem(
                          index: index,
                          iconNames: iconNames,
                          buttonNames: buttonNames,
                          isError: isError,
                          isDisabled: isDisabled,
                          isLightTheme: isLightTheme,
                        )
                      : InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            onButtonClicked(buttonNames[index]);
                          },
                          child: _menuItem(
                            index: index,
                            iconNames: iconNames,
                            buttonNames: buttonNames,
                            isError: isError,
                            isDisabled: isDisabled,
                            isLightTheme: isLightTheme,
                          ),
                        ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem({
    required int index,
    required List<IconData>? iconNames,
    required List<String> buttonNames,
    required bool isError,
    required bool isDisabled,
    required bool isLightTheme,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 12),
      child: Row(
        children: [
          index < (iconNames?.length ?? 0)
              ? Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: SBUIconComponent(
                    iconSize: 24,
                    iconData: iconNames![index],
                    iconColor: isDisabled
                        ? (isLightTheme
                            ? SBUColors.lightThemeTextDisabled
                            : SBUColors.darkThemeTextDisabled)
                        : (isLightTheme
                            ? SBUColors.primaryMain
                            : SBUColors.primaryLight),
                  ),
                )
              : Container(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 24, right: 24),
              child: SBUTextComponent(
                text: buttonNames[index],
                textType: SBUTextType.body3,
                textColorType: isDisabled
                    ? SBUTextColorType.disabled
                    : isError
                        ? SBUTextColorType.error
                        : SBUTextColorType.text01,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getReactionWidget(
    BaseChannel? channel,
    BaseMessage? message,
    bool isLightTheme,
  ) {
    if (!SBUReactionManager().isReactionAvailable(channel, message)) {
      return Container();
    }

    final emojiList = SBUReactionManager().getEmojiList();
    final isExpandableEmoji = emojiList.length >= 7;

    if (emojiList.isEmpty) {
      return Container();
    }

    return Container(
      margin: const EdgeInsets.only(left: 12, top: 12, right: 12, bottom: 16),
      height: 44,
      child: Row(
        children: [
          ...emojiList
              .map(
                (emoji) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 6, right: 6),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          Navigator.pop(context);
                          SBUReactionManager()
                              .toggleReaction(channel, message, emoji.key);
                        },
                        child: Container(
                          decoration: message!.reactions!.any((reaction) {
                            final userId = SendbirdChat.currentUser?.userId;
                            if (reaction.key == emoji.key &&
                                userId != null &&
                                reaction.userIds.contains(userId)) {
                              return true;
                            }
                            return false;
                          })
                              ? BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: isLightTheme
                                      ? SBUColors.primaryExtraLight
                                      : SBUColors.primaryDark)
                              : null,
                          padding: const EdgeInsets.all(3),
                          width: 44,
                          height: 44,
                          child: SBUImageComponent(
                            imageUrl: emoji.url,
                            cacheKey: emoji.key,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              )
              .take(isExpandableEmoji ? 5 : emojiList.length)
              .toList(),
          if (isExpandableEmoji)
            Padding(
              padding: const EdgeInsets.only(left: 6, right: 6),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    Navigator.pop(context);
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
                  },
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    child: SBUIconComponent(
                      iconSize: 38,
                      iconData: SBUIcons.emoji,
                      iconColor: isLightTheme
                          ? SBUColors.lightThemeTextLowEmphasis
                          : SBUColors.darkThemeTextLowEmphasis,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
