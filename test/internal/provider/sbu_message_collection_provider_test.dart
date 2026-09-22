import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';
import 'package:sendbird_uikit/src/internal/provider/sbu_message_collection_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await SendbirdChat.init(
      appId: 'message-collection-restart-test',
      options: SendbirdChatOptions(useCollectionCaching: false),
    );
    SendbirdChat().chat.apiClient.throwExceptionForTest = true;
  });

  tearDownAll(() {
    SendbirdChat().chat.apiClient.throwExceptionForTest = false;
  });

  test(
      'huge gap keeps the screen collection number and initializes its replacement',
      () async {
    final provider = SBUMessageCollectionProvider();
    final channel = GroupChannel.fromJson({'channel_url': 'huge-gap-test'});
    final collectionNo = provider.add(channel: channel);
    final nextCollectionNo = SBUMessageCollectionProvider.currentCollectionNo;
    final original = provider.getCollection(collectionNo)!;
    await original.initialize();

    final refreshed = Completer<MessageCollection>();
    void onChanged() {
      final current = provider.getCollection(collectionNo);
      if (current != null && !refreshed.isCompleted) {
        refreshed.complete(current);
      }
    }

    provider.addListener(onChanged);
    addTearDown(() {
      provider.removeListener(onChanged);
      provider.remove(collectionNo);
    });

    original.handler.onHugeGapDetected();
    original.handler.onHugeGapDetected();
    final replacement =
        await refreshed.future.timeout(const Duration(seconds: 2));

    expect(replacement, isNot(same(original)));
    expect(provider.getCollection(collectionNo), same(replacement));
    expect(SBUMessageCollectionProvider.currentCollectionNo, nextCollectionNo);
    expect(original.isDisposed, isTrue);
    expect(replacement.isInitialized, isTrue);

    original.handler.onHugeGapDetected();
    await Future<void>.delayed(Duration.zero);
    expect(provider.getCollection(collectionNo), same(replacement));
  });

  test('disposed screen does not receive a late restart notification',
      () async {
    final provider = SBUMessageCollectionProvider();
    final channel = GroupChannel.fromJson({'channel_url': 'disposed-gap-test'});
    final collectionNo = provider.add(channel: channel);
    final original = provider.getCollection(collectionNo)!;
    await original.initialize();

    var notifications = 0;
    void onChanged() => notifications++;
    provider.addListener(onChanged);
    addTearDown(() => provider.removeListener(onChanged));

    original.handler.onHugeGapDetected();
    provider.remove(collectionNo);
    await Future<void>.delayed(Duration.zero);

    expect(provider.getCollection(collectionNo), isNull);
    expect(notifications, 0);
  });
}
