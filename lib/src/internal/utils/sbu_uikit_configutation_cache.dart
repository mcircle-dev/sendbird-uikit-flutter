// Copyright (c) 2025 Sendbird, Inc. All rights reserved.

class SBUConfigurationCache {
  final String key;
  final bool value;

  SBUConfigurationCache({
    required this.key,
    required this.value,
  });

  SBUConfigurationCache.fromJson(Map<String, dynamic> json)
      : key = json['key'],
        value = json['value'];

  Map<String, dynamic> toJson() => {
        'key': key,
        'value': value,
      };
}
