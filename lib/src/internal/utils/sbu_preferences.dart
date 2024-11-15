// Copyright (c) 2024 Sendbird, Inc. All rights reserved.

import 'dart:convert';

import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';
import 'package:sendbird_uikit/src/internal/utils/sbu_emoji_cache.dart';
import 'package:sendbird_uikit/src/internal/utils/sbu_thumbnail_cache.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SBUPreferences {
  static const String prefDarkTheme = 'prefDartTheme';
  static const String prefPushNotifications = 'prefPushNotifications';
  static const String prefDoNotDisturb = 'prefDoNotDisturb';
  static const String prefSBUThumbnailCaches = 'prefSBUThumbnailCaches';
  static const String prefSBUEmojiCaches = 'prefSBUEmojiCaches';

  SBUPreferences._();

  static final SBUPreferences _instance = SBUPreferences._();

  factory SBUPreferences() => _instance;

  late SharedPreferences _prefs;

  final List<SBUThumbnailCache> _thumbnailCaches = [];
  final List<SBUEmojiCache> _emojiCaches = [];

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    initializeThumbnailCaches();
    initializeEmojiCaches();
  }

  Future<void> clear() async {
    await SBUPreferences().removeDarkTheme();
    await SBUPreferences().removePushNotifications();
    await SBUPreferences().removeDoNotDisturb();
    await SBUPreferences().removeThumbnailCaches();
    await SBUPreferences().removeEmojiCaches();
  }

  // Dark theme
  Future<bool> setDarkTheme(bool value) async {
    return await _prefs.setBool(prefDarkTheme, value);
  }

  bool getDarkTheme() {
    return _prefs.getBool(prefDarkTheme) ?? false;
  }

  Future<bool> removeDarkTheme() async {
    return await _prefs.remove(prefDarkTheme);
  }

  // Push notifications
  Future<bool> setPushNotifications(bool value) async {
    return await _prefs.setBool(prefPushNotifications, value);
  }

  bool getPushNotifications() {
    return _prefs.getBool(prefPushNotifications) ?? false;
  }

  Future<bool> removePushNotifications() async {
    return await _prefs.remove(prefPushNotifications);
  }

  // Do not disturb
  Future<bool> setDoNotDisturb(bool value) async {
    return await _prefs.setBool(prefDoNotDisturb, value);
  }

  bool getDoNotDisturb() {
    return _prefs.getBool(prefDoNotDisturb) ?? false;
  }

  Future<bool> removeDoNotDisturb() async {
    return await _prefs.remove(prefDoNotDisturb);
  }

  // Thumbnail caches
  List<SBUThumbnailCache> initializeThumbnailCaches() {
    _thumbnailCaches.clear();

    final caches = _prefs.getString(prefSBUThumbnailCaches);
    if (caches != null) {
      final decode = jsonDecode(caches);
      if (decode is List<dynamic>) {
        for (final cache in decode) {
          _thumbnailCaches.add(SBUThumbnailCache.fromJson(cache));
        }
      }
    }
    return _thumbnailCaches;
  }

  Future<SBUThumbnailCache?> addThumbnailCache(
    FileMessage message,
    String filePath,
  ) async {
    final cacheKey = (message.messageId > 0)
        ? message.messageId.toString()
        : message.requestId;

    if (cacheKey != null && cacheKey.isNotEmpty) {
      final cache = SBUThumbnailCache(id: cacheKey, path: filePath);
      _thumbnailCaches.add(cache);
      final encode = jsonEncode(_thumbnailCaches);
      final result = await _prefs.setString(prefSBUThumbnailCaches, encode);
      if (result) {
        return cache;
      }
    }
    return null;
  }

  SBUThumbnailCache? getThumbnailCache(FileMessage message) {
    if (message.requestId != null && message.requestId!.isNotEmpty) {
      final cacheKey = message.requestId;
      for (final cache in _thumbnailCaches) {
        if (cache.id == cacheKey) {
          return cache;
        }
      }
    }

    if (message.messageId > 0) {
      final cacheKey = message.messageId.toString();
      for (final cache in _thumbnailCaches) {
        if (cache.id == cacheKey) {
          return cache;
        }
      }
    }

    return null;
  }

  Future<bool> removeThumbnailCaches() async {
    _thumbnailCaches.clear();
    return await _prefs.remove(prefSBUThumbnailCaches);
  }

  // Emoji caches
  List<SBUEmojiCache> initializeEmojiCaches() {
    _emojiCaches.clear();

    final caches = _prefs.getString(prefSBUEmojiCaches);
    if (caches != null) {
      final decode = jsonDecode(caches);
      if (decode is List<dynamic>) {
        for (final cache in decode) {
          _emojiCaches.add(SBUEmojiCache.fromJson(cache));
        }
      }
    }
    return _emojiCaches;
  }

  Future<List<SBUEmojiCache>?> setEmojiCaches(List<Emoji> emojiList) async {
    if (emojiList.isNotEmpty) {
      final emojiCacheList =
          emojiList.map((e) => SBUEmojiCache(key: e.key, url: e.url));

      _emojiCaches.clear();
      _emojiCaches.addAll(emojiCacheList);
      final encode = jsonEncode(_emojiCaches);
      final result = await _prefs.setString(prefSBUEmojiCaches, encode);
      if (result) {
        return _emojiCaches;
      }
    }
    return null;
  }

  List<SBUEmojiCache> getEmojiCacheList() {
    return _emojiCaches;
  }

  SBUEmojiCache? getEmojiCache(String key) {
    for (final emoji in _emojiCaches) {
      if (emoji.key == key) {
        return emoji;
      }
    }
    return null;
  }

  Future<bool> removeEmojiCaches() async {
    _emojiCaches.clear();
    return await _prefs.remove(prefSBUEmojiCaches);
  }
}
