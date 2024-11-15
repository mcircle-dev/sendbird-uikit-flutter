// Copyright (c) 2024 Sendbird, Inc. All rights reserved.

class SBUEmojiCache {
  final String key;
  final String url;

  SBUEmojiCache({
    required this.key,
    required this.url,
  });

  SBUEmojiCache.fromJson(Map<String, dynamic> json)
      : key = json['key'],
        url = json['url'];

  Map<String, dynamic> toJson() => {
        'key': key,
        'url': url,
      };
}
