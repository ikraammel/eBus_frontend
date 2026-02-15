import 'package:bloc/bloc.dart';
import 'package:smart_bus/bloc/login/login_actions.dart';
import 'package:smart_bus/bloc/login/login_state.dart';
import 'package:smart_bus/main.dart';
import 'package:smart_bus/services/auth_service.dart';
import 'package:smart_bus/services/local_storage_service.dart';

class LoginBloc extends Bloc<LoginActions,LoginState>{
  final AuthService _authService = getIt<AuthService>();
  final LocalStorageService _localStorageService = getIt<LocalStorageService>();

  LoginBloc():super(LoginInitial()){
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
      LoginSubmitted event,
      Emitter<LoginState> emit
      ) async{
    emit(LoginLoading());
    try{
      final user = await _authService.login(event.email, event.password);
      await _localStorageService.saveUser(user);
      emit(LoginSuccess(user: user));
    }catch(e){
      emit(LoginFailure(error: e.toString()));
    }
  }
}