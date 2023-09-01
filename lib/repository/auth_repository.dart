import 'dart:convert';

import 'package:google_docs/models/error_model.dart';
import 'package:google_docs/models/user_model.dart';
import 'package:google_docs/repository/local_storage_repository.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:riverpod/riverpod.dart';
import 'package:google_docs/contants/constants.dart';

final AuthRepositoryProvider = Provider((ref) => AuthRepository(
      googleSignIn: GoogleSignIn(),
      client: Client(),
      localStorage: LocalStorageRepo(),
    ));

final userProvider = StateProvider<ModelUser?>((ref) => null);

class AuthRepository {
  final GoogleSignIn _googleSignIn;
  final Client _client;
  final LocalStorageRepo _localStorage;

  AuthRepository({
    required GoogleSignIn googleSignIn,
    required Client client,
    required LocalStorageRepo localStorage,
  })  : _googleSignIn = googleSignIn,
        _localStorage = localStorage,
        _client = client;

  Future<ErrorModel> signWithGoogle() async {
    ErrorModel error = ErrorModel(error: 'Some Error occured', data: null);

    try {
      final user = await _googleSignIn.signIn();
      if (user != null) {
        final userAcc = ModelUser(
          email: user.email,
          name: user.displayName ?? '',
          profilePic: user.photoUrl ?? '',
          token: '',
          uid: '',
        );

        var res = await _client.post(Uri.parse('$host/api/signup'),
            body: userAcc.toJson(),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
            });

        switch (res.statusCode) {
          case 200:
            final newUser = userAcc.copyWith(
              uid: jsonDecode(res.body)['user']['_id'],
              token: jsonDecode(res.body)['token'],
            );
            error = ErrorModel(error: null, data: newUser);
            _localStorage.setToken(newUser.token);
            break;
        }
      }
    } catch (e) {
      error = ErrorModel(error: e.toString(), data: null);
    }
    return error;
  }

  Future<ErrorModel> getUserData() async {
    ErrorModel error = ErrorModel(error: 'Some Error occured', data: null);

    try {
      String? token = await _localStorage.getToken();
      if (token != null) {
        var res = await _client.get(Uri.parse('$host/'), headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        });

        switch (res.statusCode) {
          case 200:
            final newUser = ModelUser.fromJson(
              jsonEncode(
                jsonDecode((res.body))['user'],
              ),
            ).copyWith(
              token: token,
            );

            error = ErrorModel(error: null, data: newUser);
            _localStorage.setToken(newUser.token);
            break;
        }
      }
    } catch (e) {
      error = ErrorModel(error: e.toString(), data: null);
    }
    return error;
  }

  void signOut() async {
    await _googleSignIn.signOut();
    _localStorage.setToken('');
  }
}
