abstract class AuthEvent {}

class AppStarted extends AuthEvent {}

class CheckAuthStatusEvent extends AuthEvent {}

class RegisterEvent extends AuthEvent {
  final String name;
  final String email;
  final String phone;
  final String password;

  RegisterEvent({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
  });
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  LoginEvent({required this.email, required this.password});
}

class UpdateNameEvent extends AuthEvent {
  final String newName;
  UpdateNameEvent(this.newName);
}

class LogoutEvent extends AuthEvent {}