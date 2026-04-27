import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:give_track/features/auth/domain/entities/user.dart';
import 'package:give_track/features/auth/presentation/providers/auth_provider.dart';

/// Notifies [GoRouter] when [authStateProvider] changes so [redirect] re-runs.
final routerAuthRefreshProvider = Provider<RouterAuthRefresh>((ref) {
  final refresh = RouterAuthRefresh();
  ref.listen<AsyncValue<User?>>(authStateProvider, (_, _) {
    refresh.tick();
  });
  ref.onDispose(refresh.dispose);
  return refresh;
});

final class RouterAuthRefresh extends ChangeNotifier {
  void tick() => notifyListeners();
}
