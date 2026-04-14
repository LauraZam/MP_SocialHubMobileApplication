import '../../models/profile.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileListLoaded extends ProfileState {
  final List<Profile> profiles;
  ProfileListLoaded(this.profiles);
}

class ProfileLoaded extends ProfileState {
  final Profile profile;
  
  ProfileLoaded(this.profile);
}

class ProfileError extends ProfileState {
  final String message;

  ProfileError(this.message);
}