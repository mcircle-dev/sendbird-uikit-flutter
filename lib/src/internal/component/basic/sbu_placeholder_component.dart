// Copyright (c) 2024 Sendbird, Inc. All rights reserved.

import 'package:flutter/material.dart';
import 'package:sendbird_uikit/sendbird_uikit.dart';
import 'package:sendbird_uikit/src/internal/component/base/sbu_base_component.dart';
import 'package:sendbird_uikit/src/internal/component/basic/sbu_icon_component.dart';
import 'package:sendbird_uikit/src/internal/component/basic/sbu_text_component.dart';
import 'package:sendbird_uikit/src/internal/resource/sbu_text_styles.dart';

class SBUPlaceholderComponent extends SBUStatelessComponent {
  final bool isLightTheme;
  final IconData iconData;
  final String text;
  final String? retryText;
  final void Function()? onRetryButtonClicked;

  const SBUPlaceholderComponent({
    required this.isLightTheme,
    required this.iconData,
    required this.text,
    this.retryText,
    this.onRetryButtonClicked,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (retryText == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/image_no_data.png',
                width: 120, height: 120),
            const SizedBox(height: 12),
            Text(
              '조회 된 메시지가 없어요',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF8F96A1),
                fontSize: 16,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w600,
                height: 1.50,
                letterSpacing: -0.32,
              ),
            ),
          ],
        ),
      );
    }

    // retryText가 있는 경우 기존 로직
    final retryWidget = Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onRetryButtonClicked,
          child: Container(
            width: 84,
            height: 32,
            padding:
                const EdgeInsets.only(left: 8, top: 4, right: 8, bottom: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SBUIconComponent(
                  iconSize: 24,
                  iconData: SBUIcons.refresh,
                  iconColor: isLightTheme
                      ? SBUColors.primaryMain
                      : SBUColors.primaryLight,
                ),
                const SizedBox(height: 12),
                SBUTextComponent(
                  text: retryText!,
                  textType: SBUTextType.body3,
                  textColorType: SBUTextColorType.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SBUIconComponent(
            iconSize: 64,
            iconData: iconData,
            iconColor: isLightTheme
                ? SBUColors.background700
                : SBUColors.background100,
          ),
          const SizedBox(height: 24),
          SBUTextComponent(
            text: text,
            textType: SBUTextType.body3,
            textColorType: SBUTextColorType.text02,
          ),
          retryWidget,
        ],
      ),
    );
  }
}
