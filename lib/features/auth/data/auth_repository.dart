import 'package:medipulse_medical/core/result/result.dart';
import 'package:medipulse_medical/features/auth/domain/auth_user.dart';
// `hide AuthUser`: Supabase has its own AuthUser class. We hide it so
// that AuthUser in this file always means ours.
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  AuthUser? get currentUser => _toUser(_client.auth.currentUser);

  Stream<AuthUser?> get changes => _client.auth.onAuthStateChange
      .map((event) => _toUser(event.session?.user));

  Future<Result<AuthUser?>> signIn(String email, String password) {
    return _run(() async {
      final response = await _client.auth
          .signInWithPassword(email: email, password: password);
      return _toUser(response.user);
    });
  }

  /// Success(null) means the account exists but the email must be confirmed first.
  Future<Result<AuthUser?>> signUp(String email, String password) {
    return _run(() async {
      final response =
          await _client.auth.signUp(email: email, password: password);
      return _toUser(response.session?.user);
    });
  }

  Future<void> signOut() => _client.auth.signOut();

  // One place that turns exceptions into Failure, so screens never use try/catch
  Future<Result<AuthUser?>> _run(Future<AuthUser?> Function() action) async {
    try {
      return Success(await action());
    } on AuthException catch (error) {
      return Failure(error.message, cause: error);
    } on Object catch (error) {
      return Failure(
        'Could not reach the server. Check your internet connection.',
        cause: error,
      );
    }
  }

  static AuthUser? _toUser(User? user) =>
      user == null ? null : (id: user.id, email: user.email ?? '');
}