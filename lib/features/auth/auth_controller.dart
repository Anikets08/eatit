import 'package:eatit/features/auth/auth_repository.dart';
import 'package:eatit/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userProvider = StateProvider<UserModel?>((ref) => null);

final authControllerProvider =
StateNotifierProvider<AuthController, bool>((ref) =>
    AuthController(
      authRepository: ref.watch(authRepositoryProvider),
      ref: ref,
    ));

class AuthController extends StateNotifier<bool> {
  final AuthRepository _authRepository;
  final Ref _ref;

  AuthController({required AuthRepository authRepository, required Ref ref})
      : _authRepository = authRepository,
        _ref = ref,
        super(false);

  void signInWithGoogle(BuildContext context) async {
    state = true;
    final user = await _authRepository.signInWithGoogle();
    state = false;
    user.fold(
          (l) =>
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l),
            ),
          ),
          (r) {
        _ref.read(userProvider.notifier).update((state) {
          state = r;
          return state;
        });
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      },
    );
  }

  void signOut(BuildContext context) async {
    final res = await _authRepository.signOut();
    res.fold(
          (l) =>
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(l),
          )),
          (r) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false)
            .then((value) =>
            _ref.read(userProvider.notifier).update((state) => null));
      },
    );
  }
}
