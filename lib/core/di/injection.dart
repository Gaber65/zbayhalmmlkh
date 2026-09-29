import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import '../../features/admin/data/datasources/admin_remote_data_source.dart';
import '../../features/admin/data/repositories/admin_repository_impl.dart';
import '../../features/admin/domain/repositories/admin_repository.dart';
import '../../features/admin/presentation/manager/admin_categories_cubit.dart';
import '../../features/admin/presentation/manager/admin_dashboard_cubit.dart';
import '../../features/admin/presentation/manager/admin_marketing_cubit.dart';
import '../../features/admin/presentation/manager/admin_options_cubit.dart';
import '../../features/admin/presentation/manager/admin_orders_cubit.dart';
import '../../features/admin/presentation/manager/admin_products_cubit.dart';
import '../../features/admin/presentation/manager/admin_users_cubit.dart';
import '../../features/admin/presentation/manager/admin_payments_cubit.dart';
import '../../features/admin/presentation/manager/admin_settings_cubit.dart';
import '../../features/admin/presentation/manager/admin_branches_cubit.dart';
import 'injection.config.dart';
import '../payment/payment_service.dart';
import '../payment/moyasar_payment_gateway.dart';
import '../payment/myfatoorah_payment_gateway.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init', // default
  preferRelativeImports: true, // default
  asExtension: true, // default
)
Future<void> configureDependencies() async {
  await getIt.init();
  final paymentService = PaymentService();
  paymentService.registerGateway(MoyasarPaymentGateway());
  paymentService.registerGateway(MyFatoorahPaymentGateway());
  getIt.registerLazySingleton<PaymentService>(() => paymentService);

  // ── Register Admin dependencies ──────────────────────────────────────────
  if (!getIt.isRegistered<AdminRemoteDataSource>()) {
    getIt.registerLazySingleton<AdminRemoteDataSource>(
      () => AdminRemoteDataSourceImpl(dio: getIt<Dio>()),
    );
  }
  if (!getIt.isRegistered<AdminRepository>()) {
    getIt.registerLazySingleton<AdminRepository>(
      () => AdminRepositoryImpl(remoteDataSource: getIt<AdminRemoteDataSource>()),
    );
  }
  if (!getIt.isRegistered<AdminDashboardCubit>()) {
    getIt.registerFactory<AdminDashboardCubit>(
      () => AdminDashboardCubit(repository: getIt<AdminRepository>()),
    );
  }
  if (!getIt.isRegistered<AdminOrdersCubit>()) {
    getIt.registerFactory<AdminOrdersCubit>(
      () => AdminOrdersCubit(repository: getIt<AdminRepository>()),
    );
  }
  if (!getIt.isRegistered<AdminProductsCubit>()) {
    getIt.registerFactory<AdminProductsCubit>(
      () => AdminProductsCubit(repository: getIt<AdminRepository>()),
    );
  }
  if (!getIt.isRegistered<AdminCategoriesCubit>()) {
    getIt.registerFactory<AdminCategoriesCubit>(
      () => AdminCategoriesCubit(repository: getIt<AdminRepository>()),
    );
  }
  if (!getIt.isRegistered<AdminOptionsCubit>()) {
    getIt.registerFactory<AdminOptionsCubit>(
      () => AdminOptionsCubit(repository: getIt<AdminRepository>()),
    );
  }
  if (!getIt.isRegistered<AdminMarketingCubit>()) {
    getIt.registerFactory<AdminMarketingCubit>(
      () => AdminMarketingCubit(repository: getIt<AdminRepository>()),
    );
  }
  if (!getIt.isRegistered<AdminUsersCubit>()) {
    getIt.registerFactory<AdminUsersCubit>(
      () => AdminUsersCubit(getIt<AdminRepository>()),
    );
  }
  if (!getIt.isRegistered<AdminPaymentsCubit>()) {
    getIt.registerFactory<AdminPaymentsCubit>(
      () => AdminPaymentsCubit(getIt<AdminRepository>()),
    );
  }
  if (!getIt.isRegistered<AdminSettingsCubit>()) {
    getIt.registerFactory<AdminSettingsCubit>(
      () => AdminSettingsCubit(getIt<AdminRepository>()),
    );
  }
  if (!getIt.isRegistered<AdminBranchesCubit>()) {
    getIt.registerFactory<AdminBranchesCubit>(
      () => AdminBranchesCubit(getIt<AdminRepository>()),
    );
  }
}
