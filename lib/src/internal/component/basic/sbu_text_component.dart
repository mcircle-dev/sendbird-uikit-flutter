// Copyright (c) 2024 Sendbird, Inc. All rights reserved.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sendbird_uikit/src/internal/component/base/sbu_base_component.dart';
import 'package:sendbird_uikit/src/internal/resource/sbu_text_styles.dart';
import 'package:sendbird_uikit/src/public/resource/sbu_theme_provider.dart';

enum SBUTextOverflowType {
  clip,
  ellipsisEnd,
  ellipsisMiddle,
}

class SBUTextComponent extends SBUStatefulComponent {
  final String text;
  final SBUTextType textType;
  final SBUTextColorType textColorType;
  final SBUTextOverflowType? textOverflowType;
  final int? maxLines;
  final bool? transparent;

  const SBUTextComponent({
    required this.text,
    required this.textType,
    required this.textColorType,
    this.textOverflowType = SBUTextOverflowType.ellipsisEnd,
    this.maxLines = 1,
    this.transparent = false,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => SBUTextComponentState();
}

class SBUTextComponentState extends State<SBUTextComponent> {
  @override
  Widget build(BuildContext context) {
    final theme = context.watch<SBUThemeProvider>().theme;

    final text = widget.text;
    final textType = widget.textType;
    final textColorType = widget.textColorType;
    final textOverflowType = widget.textOverflowType;
    final maxLines = widget.maxLines;

    TextStyle textStyle = SBUTextStyles.getTextStyle(
      theme: theme,
      textType: textType,
      textColorType: textColorType,
    );

    if (widget.transparent == true) {
      textStyle = textStyle.copyWith(
        color: Colors.transparent,
      );
    }

    TextOverflow? overflow;
    if (textOverflowType != null) {
      if (textOverflowType == SBUTextOverflowType.clip) {
        overflow = TextOverflow.clip;
      } else if (textOverflowType == SBUTextOverflowType.ellipsisMiddle) {
        overflow = TextOverflow.ellipsis; // Check
      } else if (textOverflowType == SBUTextOverflowType.ellipsisEnd) {
        overflow = TextOverflow.ellipsis;
      }
    }

    return Text(
      text,
      style: textStyle,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
