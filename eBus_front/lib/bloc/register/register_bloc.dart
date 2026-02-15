import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:smart_bus/bloc/register/register_actions.dart';
import 'package:smart_bus/bloc/register/register_state.dart';

import '../../main.dart';
import '../../services/auth_service.dart';
import '../../services/local_storage_service.dart';

class RegisterBloc extends Bloc<RegisterActions,RegisterState>{
  final AuthService _authService = getIt<AuthService>();
  final LocalStorageService _localStorageService = getIt<LocalStorageService>();

  RegisterBloc():super(RegisterInitial()){
    on<RegisterSubmitted>(_onRegisterSubmitted);
  }

  Future<void> _onRegisterSubmitted(
      RegisterSubmitted event,
      Emitter<RegisterState> emit) async{
    emit(RegisterLoading());
    try{
      final user = await _authService.register(
        event.request,
        event.image,
        event.carteScolaire,
        event.cin
      );
      await _localStorageService.saveUser(user);
      emit(RegisterSuccess(user: user));
    }catch(e){
      emit(RegisterFailure(error: e.toString()));
    }
  }
}