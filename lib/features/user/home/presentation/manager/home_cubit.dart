import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_home_data.dart';
import 'home_state.dart';

@injectable
class HomeCubit extends Cubit<HomeState> {
  final GetHomeData getHomeData;

  HomeCubit({required this.getHomeData}) : super(HomeInitial());

  Future<void> fetchHomeData() async {
    emit(HomeLoading());
    final result = await getHomeData(NoParams());
    result.fold(
      (failure) => emit(HomeError(message: failure.error.message)),
      (data) => emit(HomeLoaded(homeData: data)),
    );
  }
}
