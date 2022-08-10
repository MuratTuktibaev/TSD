import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharmacy_arrival/core/error/failure.dart';
import 'package:pharmacy_arrival/domain/repositories/auth_repository.dart';
import 'package:pharmacy_arrival/domain/usecases/auth_check.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository _authRepository;

  LoginBloc(this._authRepository) : super(LoadingLoginState()) {
    on<InitialLoginEvent>((event, emit) => _onInitialLoginEvent(emit));
    on<LogInEvent>((event, emit) => _onLogInEvent(event, emit));
    on<LogOutEvent>((event, emit) => _onLogOutEvent(event, emit));
  }

  // _onInitialLoginEvent(InitialLoginEvent event, Emitter<LoginState> emit) async {
  //   // await _tokensRepository.save("5|QoBqf9Mf4lYLLU2zLW0dIzd57u2s4TyHPv2PF6g7");
  //   if (_tokensRepository.call()) {
  //     emit(AuthorizedState());
  //   } else {
  //     emit(UnauthorizedState());
  //   }
  // }

  Future<void> _onLogInEvent(LogInEvent event, Emitter<LoginState> emit) async {
    try {
      emit(AuthorizedState());
    } catch (e) {
      emit(ErrorLoginState('errorMessage'));
      emit(UnauthorizedState());
      rethrow;
    }
  }

  Future<void> _onLogOutEvent(LogOutEvent event, Emitter<LoginState> emit) async {
    try {
      emit(LoadingLoginState());
      final resut = await _authRepository.logout();
      resut.fold(
        (l) => emit(ErrorLoginState(mapFailureToMessage(l))),
        (r) => emit(UnauthorizedState()),
      );
    } catch (e) {
      emit(ErrorLoginState('errorMessage'));
      rethrow;
    }
  }

  Future<void> _onInitialLoginEvent(
    Emitter<LoginState> emit,
  ) async {
    emit(LoadingLoginState());
    final result = await _authRepository.authCheck();

    result.fold(
      (l) => emit(UnauthorizedState()),
      (r) async {
        emit(AuthorizedState());
      },
    );
  }
}
