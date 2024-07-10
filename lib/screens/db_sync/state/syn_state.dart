import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_wappsi/providers/sync_db_provider.dart';

/// Manage db sync elements status on sync db screen
final syncStateProvider = StateProvider.autoDispose<List<String>>((ref) => []);

/// Manage db sync elements status on sync db screen
final currentSyncStateProvider = StateProvider.autoDispose<String>((ref) => '');

final dbSyncProvider = FutureProvider.autoDispose<bool>((ref) async {
  final value = ref.watch(currentSyncStateProvider);
  return value.isNotEmpty ? await SyncDBProvider.syncOption(value) : true;
});
