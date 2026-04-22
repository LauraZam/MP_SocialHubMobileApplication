import 'package:flutter_bloc/flutter_bloc.dart';
import '../../network/api_client.dart';

abstract class ApiState {}
class ApiInitial extends ApiState {}
class ApiLoading extends ApiState {}

class ApiLoaded extends ApiState { 
  final List<Quote> quotes; 
  ApiLoaded(this.quotes); 
}

class ApiError extends ApiState { 
  final String message; 
  ApiError(this.message); 
}

class ApiCubit extends Cubit<ApiState> {
  final ApiClient _apiClient;

  ApiCubit(this._apiClient) : super(ApiInitial());

  Future<void> fetchExploreData() async {
    try {
      emit(ApiLoading());
      
      final data = await _apiClient.getQuotesList(); 
      
      emit(ApiLoaded(data));
    } catch (e) {
      emit(ApiError("Failed to fetch data: ${e.toString()}"));
    }
  }
}