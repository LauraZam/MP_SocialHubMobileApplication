import 'package:flutter_bloc/flutter_bloc.dart';
import '../../network/dio_client.dart'; // Твой DioClient, содержащий Retrofit client
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final DioClient api;

  ProfileBloc(this.api) : super(ProfileInitial()) {
    on<LoadProfileList>(_onLoadProfileList);
    
    on<LoadProfile>(_onLoadSingleProfile);
  }

  Future<void> _onLoadProfileList(
      LoadProfileList event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final profiles = await api.client.getListData();
      emit(ProfileListLoaded(profiles));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onLoadSingleProfile(
      LoadProfile event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final profile = await api.client.getProfile();
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
