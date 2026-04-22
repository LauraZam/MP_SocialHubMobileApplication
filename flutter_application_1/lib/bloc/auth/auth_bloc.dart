import 'dart:convert';
import 'package:flutter_application_1/bloc/auth/auth_event.dart';
import 'package:flutter_application_1/bloc/auth/auth_state.dart';
import 'package:flutter_application_1/repositories/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc(this.authRepository) : super(AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckStatus);
    on<RegisterEvent>(_onRegister);
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
    on<UpdateNameEvent>(_onUpdateName);
  }

  Future<void> _onCheckStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    final userData = await authRepository.getUserData();

    if (user != null) {
      emit(
        AuthSuccess(
          uid: user.uid,
          name: userData['name'] ?? '',
          email: user.email ?? '',
          phone: userData['phone'] ?? '',
        ),
      );
    } else {
      emit(AuthInitial());
    }
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.register(
        email: event.email,
        password: event.password,
      );

      final user = FirebaseAuth.instance.currentUser;
      final String uid = user?.uid ?? '';

      const url =
          'https://myflutterproject-9958d-default-rtdb.asia-southeast1.firebasedatabase.app/user.json';
      await http.post(
        Uri.parse(url),
        body: jsonEncode({
          'uid': uid,
          'name': event.name,
          'phone': event.phone,
          'Email': event.email,
        }),
      );

      await authRepository.saveUserData(
        name: event.name,
        email: event.email,
        phone: event.phone,
      );

      emit(
        AuthSuccess(
          uid: uid,
          name: event.name,
          email: event.email,
          phone: event.phone,
        ),
      );
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.login(email: event.email, password: event.password);

      final user = FirebaseAuth.instance.currentUser;
      final String uid = user?.uid ?? '';

      final response = await http.get(
        Uri.parse(
          'https://myflutterproject-9958d-default-rtdb.asia-southeast1.firebasedatabase.app/user.json',
        ),
      );

      final Map<String, dynamic> allUsers = jsonDecode(response.body);
      String name = '';
      String phone = '';

      allUsers.forEach((key, value) {
        if (value['Email'] == event.email) {
          name = value['name'] ?? '';
          phone = value['phone'] ?? '';
        }
      });

      await authRepository.saveUserData(
        email: event.email,
        name: name,
        phone: phone,
      );

      emit(AuthSuccess(uid: uid, email: event.email, name: name, phone: phone));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    await authRepository.logout();
    emit(AuthInitial());
  }

  
  Future<void> _onUpdateName(
    UpdateNameEvent event,
    Emitter<AuthState> emit,
  ) async {
    if (state is AuthSuccess) {
      final current = state as AuthSuccess;
      try {
        // 1. Find the user in Firebase Realtime Database to update the name
        final response = await http.get(
          Uri.parse(
            'https://myflutterproject-9958d-default-rtdb.asia-southeast1.firebasedatabase.app/user.json',
          ),
        );

        final Map<String, dynamic> allUsers = jsonDecode(response.body);
        String? userKey;

        allUsers.forEach((key, value) {
          if (value['Email'] == current.email) userKey = key;
        });

        if (userKey != null) {
          // 2. Update the name in the Database
          await http.patch(
            Uri.parse(
              'https://myflutterproject-9958d-default-rtdb.asia-southeast1.firebasedatabase.app/user/$userKey.json',
            ),
            body: jsonEncode({'name': event.newName}),
          );
        }

        // 3. Update Local Storage
        await authRepository.saveUserData(
          email: current.email,
          name: event.newName,
          phone: current.phone,
        );

        // 4. Emit new state to refresh UI
        emit(
          AuthSuccess(
            uid: current.uid,
            email: current.email,
            name: event.newName,
            phone: current.phone,
          ),
        );
      } catch (e) {
        emit(AuthFailure("Failed to update name: ${e.toString()}"));
      }
    }
  }
}
