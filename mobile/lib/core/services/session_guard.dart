import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../constants/storage_keys.dart';
import '../storage/local_storage.dart';
import 'auth_service.dart';

/// Decides where the app boots to. Called from splash and after any
/// login / register / logout.
class SessionGuard extends GetxService {
  SessionGuard(this._auth, this._local);
  final AuthService _auth;
  final LocalStorage _local;

  String initialRoute() {
    // First launch — no language chosen yet: show the language gate
    // before onboarding. The saved languageCode doubles as the
    // first-run flag, so this only triggers once.
    final language = _local.getString(StorageKeys.languageCode);
    if (language == null) return AppRoutes.language;

    final hasOnboarded = _local.getBool(StorageKeys.hasOnboarded) ?? false;
    if (!hasOnboarded) return AppRoutes.onboarding;
    if (!_auth.isAuthenticated) return AppRoutes.login;
    return _shellFor(_auth.role);
  }

  String _shellFor(String role) {
    switch (role) {
      case 'importer':
        return AppRoutes.importerShell;
      case 'admin':
        // Admin is not a mobile role. Surface login again so a wrongly
        // logged-in admin can switch accounts on the mobile app.
        return AppRoutes.login;
      case 'buyer':
      default:
        return AppRoutes.buyerShell;
    }
  }

  /// Called after login/register. Returns the target route.
  String routeForAuthenticated() => _shellFor(_auth.role);

  Future<void> completeOnboarding() async {
    await _local.setBool(StorageKeys.hasOnboarded, true);
  }
}
