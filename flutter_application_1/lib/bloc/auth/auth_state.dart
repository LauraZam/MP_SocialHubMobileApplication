abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String uid;
  final String name;
  final String email;
  final String phone;

  AuthSuccess({
    required this.uid, 
    this.name = '', 
    this.email = '', 
    this.phone = ''
  });
}

class AuthFailure extends AuthState {
  final String error;
  AuthFailure(this.error);
}