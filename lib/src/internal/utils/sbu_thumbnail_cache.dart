// Copyright (c) 2024 Sendbird, Inc. All rights reserved.

class SBUThumbnailCache {
  final String id;
  final String path;

  SBUThumbnailCache({
    required this.id,
    required this.path,
  });

  SBUThumbnailCache.fromJson(Map<String, dynamic> json)
      : id = json['messageId'],
        path = json['path'];

  Map<String, dynamic> toJson() => {
        'messageId': id,
        'path': path,
      };
}
