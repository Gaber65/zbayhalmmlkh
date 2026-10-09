// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:internet_connection_checker/internet_connection_checker.dart'
    as _i973;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/admin/data/datasources/admin_remote_data_source.dart'
    as _i517;
import '../../features/admin/data/repositories/admin_repository_impl.dart'
    as _i335;
import '../../features/admin/domain/repositories/admin_repository.dart'
    as _i583;
import '../../features/admin/presentation/manager/admin_branches_cubit.dart'
    as _i154;
import '../../features/admin/presentation/manager/admin_categories_cubit.dart'
    as _i462;
import '../../features/admin/presentation/manager/admin_dashboard_cubit.dart'
    as _i528;
import '../../features/admin/presentation/manager/admin_marketing_cubit.dart'
    as _i464;
import '../../features/admin/presentation/manager/admin_options_cubit.dart'
    as _i969;
import '../../features/admin/presentation/manager/admin_orders_cubit.dart'
    as _i878;
import '../../features/admin/presentation/manager/admin_payments_cubit.dart'
    as _i386;
import '../../features/admin/presentation/manager/admin_products_cubit.dart'
    as _i533;
import '../../features/admin/presentation/manager/admin_settings_cubit.dart'
    as _i918;
import '../../features/admin/presentation/manager/admin_users_cubit.dart'
    as _i32;
import '../../features/shared/auth/data/datasources/auth_local_data_source.dart'
    as _i517;
import '../../features/shared/auth/data/datasources/auth_remote_data_source.dart'
    as _i554;
import '../../features/shared/auth/data/repositories/auth_repository_impl.dart'
    as _i452;
import '../../features/shared/auth/domain/repositories/auth_repository.dart'
    as _i61;
import '../../features/shared/auth/domain/usecases/auth_usecases.dart' as _i174;
import '../../features/shared/auth/presentation/manager/auth_cubit.dart'
    as _i18;
import '../../features/user/address/data/datasources/address_remote_data_source.dart'
    as _i210;
import '../../features/user/address/data/repositories/address_repository_impl.dart'
    as _i1065;
import '../../features/user/address/domain/repositories/address_repository.dart'
    as _i525;
import '../../features/user/address/domain/usecases/address_usecases.dart'
    as _i91;
import '../../features/user/address/presentation/manager/address_cubit.dart'
    as _i858;
import '../../features/user/cart/data/datasources/cart_remote_data_source.dart'
    as _i609;
import '../../features/user/cart/data/repositories/cart_repository_impl.dart'
    as _i137;
import '../../features/user/cart/domain/repositories/cart_repository.dart'
    as _i687;
import '../../features/user/cart/presentation/manager/cart_cubit.dart' as _i865;
import '../../features/user/catalog/data/datasources/catalog_remote_data_source.dart'
    as _i607;
import '../../features/user/catalog/data/repositories/catalog_repository_impl.dart'
    as _i141;
import '../../features/user/catalog/domain/repositories/catalog_repository.dart'
    as _i507;
import '../../features/user/catalog/presentation/manager/catalog_cubit.dart'
    as _i402;
import '../../features/user/home/data/datasources/home_remote_data_source.dart'
    as _i707;
import '../../features/user/home/data/repositories/home_repository_impl.dart'
    as _i1055;
import '../../features/user/home/domain/repositories/home_repository.dart'
    as _i518;
import '../../features/user/home/domain/usecases/get_home_data.dart' as _i1042;
import '../../features/user/home/presentation/manager/home_cubit.dart' as _i881;
import '../../features/user/orders/data/datasources/order_remote_data_source.dart'
    as _i75;
import '../../features/user/orders/data/repositories/order_repository_impl.dart'
    as _i711;
import '../../features/user/orders/domain/repositories/order_repository.dart'
    as _i1006;
import '../../features/user/orders/presentation/manager/checkout_cubit.dart'
    as _i319;
import '../../features/user/orders/presentation/manager/order_cubit.dart'
    as _i31;
import '../../features/user/profile/data/datasources/highlight_remote_data_source.dart'
    as _i557;
import '../../features/user/profile/data/datasources/profile_remote_data_source.dart'
    as _i424;
import '../../features/user/profile/data/repositories/highlight_repository_impl.dart'
    as _i702;
import '../../features/user/profile/data/repositories/profile_repository_impl.dart'
    as _i655;
import '../../features/user/profile/domain/repositories/highlight_repository.dart'
    as _i917;
import '../../features/user/profile/domain/repositories/profile_repository.dart'
    as _i1002;
import '../../features/user/profile/presentation/manager/highlight_cubit.dart'
    as _i8;
import '../../features/user/profile/presentation/manager/profile_cubit.dart'
    as _i1066;
import '../../features/user/search/data/datasources/search_remote_data_source.dart'
    as _i461;
import '../../features/user/search/data/repositories/search_repository_impl.dart'
    as _i559;
import '../../features/user/search/domain/repositories/search_repository.dart'
    as _i389;
import '../../features/user/search/domain/usecases/search_usecases.dart'
    as _i25;
import '../../features/user/search/presentation/manager/search_cubit.dart'
    as _i118;
import '../app_cubit/app_cubit.dart' as _i962;
import '../network/network_info.dart' as _i932;
import 'register_module.dart' as _i291;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => registerModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => registerModule.secureStorage,
    );
    gh.lazySingleton<_i973.InternetConnectionChecker>(
      () => registerModule.connectionChecker,
    );
    gh.lazySingleton<_i517.AuthLocalDataSource>(
      () => _i517.AuthLocalDataSourceImpl(
        sharedPreferences: gh<_i460.SharedPreferences>(),
        secureStorage: gh<_i558.FlutterSecureStorage>(),
      ),
    );
    gh.lazySingleton<_i361.Dio>(
      () => registerModule.dio(
        gh<_i460.SharedPreferences>(),
        gh<_i558.FlutterSecureStorage>(),
      ),
    );
    gh.lazySingleton<_i932.NetworkInfo>(
      () => _i932.NetworkInfoImpl(gh<_i973.InternetConnectionChecker>()),
    );
    gh.lazySingleton<_i962.AppCubit>(
      () => _i962.AppCubit(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i609.CartRemoteDataSource>(
      () => _i609.CartRemoteDataSourceImpl(dio: gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i687.CartRepository>(
      () => _i137.CartRepositoryImpl(
        remoteDataSource: gh<_i609.CartRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i424.ProfileRemoteDataSource>(
      () => _i424.ProfileRemoteDataSourceImpl(dio: gh<_i361.Dio>()),
    );
    gh.factory<_i865.CartCubit>(
      () => _i865.CartCubit(repository: gh<_i687.CartRepository>()),
    );
    gh.lazySingleton<_i461.SearchRemoteDataSource>(
      () => _i461.SearchRemoteDataSourceImpl(dio: gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i554.AuthRemoteDataSource>(
      () => _i554.AuthRemoteDataSourceImpl(dio: gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i75.OrderRemoteDataSource>(
      () => _i75.OrderRemoteDataSourceImpl(dio: gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i707.HomeRemoteDataSource>(
      () => _i707.HomeRemoteDataSourceImpl(dio: gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i607.CatalogRemoteDataSource>(
      () => _i607.CatalogRemoteDataSourceImpl(dio: gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i518.HomeRepository>(
      () => _i1055.HomeRepositoryImpl(
        remoteDataSource: gh<_i707.HomeRemoteDataSource>(),
        networkInfo: gh<_i932.NetworkInfo>(),
      ),
    );
    gh.lazySingleton<_i517.AdminRemoteDataSource>(
      () => _i517.AdminRemoteDataSourceImpl(dio: gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i507.CatalogRepository>(
      () => _i141.CatalogRepositoryImpl(
        remoteDataSource: gh<_i607.CatalogRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i557.HighlightRemoteDataSource>(
      () => _i557.HighlightRemoteDataSourceImpl(dio: gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i210.AddressRemoteDataSource>(
      () => _i210.AddressRemoteDataSourceImpl(dio: gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i525.AddressRepository>(
      () => _i1065.AddressRepositoryImpl(
        remoteDataSource: gh<_i210.AddressRemoteDataSource>(),
      ),
    );
    gh.factory<_i402.CatalogCubit>(
      () => _i402.CatalogCubit(repository: gh<_i507.CatalogRepository>()),
    );
    gh.lazySingleton<_i1002.ProfileRepository>(
      () => _i655.ProfileRepositoryImpl(
        remoteDataSource: gh<_i424.ProfileRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i1042.GetHomeData>(
      () => _i1042.GetHomeData(gh<_i518.HomeRepository>()),
    );
    gh.lazySingleton<_i917.HighlightRepository>(
      () => _i702.HighlightRepositoryImpl(
        remoteDataSource: gh<_i557.HighlightRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i1006.OrderRepository>(
      () => _i711.OrderRepositoryImpl(
        remoteDataSource: gh<_i75.OrderRemoteDataSource>(),
      ),
    );
    gh.factory<_i1066.ProfileCubit>(
      () => _i1066.ProfileCubit(repository: gh<_i1002.ProfileRepository>()),
    );
    gh.lazySingleton<_i583.AdminRepository>(
      () => _i335.AdminRepositoryImpl(
        remoteDataSource: gh<_i517.AdminRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i389.SearchRepository>(
      () => _i559.SearchRepositoryImpl(
        remoteDataSource: gh<_i461.SearchRemoteDataSource>(),
      ),
    );
    gh.factory<_i881.HomeCubit>(
      () => _i881.HomeCubit(getHomeData: gh<_i1042.GetHomeData>()),
    );
    gh.factory<_i91.GetAddressesUseCase>(
      () => _i91.GetAddressesUseCase(gh<_i525.AddressRepository>()),
    );
    gh.factory<_i91.CreateAddressUseCase>(
      () => _i91.CreateAddressUseCase(gh<_i525.AddressRepository>()),
    );
    gh.factory<_i91.UpdateAddressUseCase>(
      () => _i91.UpdateAddressUseCase(gh<_i525.AddressRepository>()),
    );
    gh.factory<_i91.DeleteAddressUseCase>(
      () => _i91.DeleteAddressUseCase(gh<_i525.AddressRepository>()),
    );
    gh.factory<_i91.SetDefaultAddressUseCase>(
      () => _i91.SetDefaultAddressUseCase(gh<_i525.AddressRepository>()),
    );
    gh.factory<_i319.CheckoutCubit>(
      () => _i319.CheckoutCubit(repository: gh<_i1006.OrderRepository>()),
    );
    gh.factory<_i31.OrderCubit>(
      () => _i31.OrderCubit(repository: gh<_i1006.OrderRepository>()),
    );
    gh.lazySingleton<_i61.AuthRepository>(
      () => _i452.AuthRepositoryImpl(
        remoteDataSource: gh<_i554.AuthRemoteDataSource>(),
        localDataSource: gh<_i517.AuthLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i174.LoginUseCase>(
      () => _i174.LoginUseCase(gh<_i61.AuthRepository>()),
    );
    gh.lazySingleton<_i174.RegisterUseCase>(
      () => _i174.RegisterUseCase(gh<_i61.AuthRepository>()),
    );
    gh.lazySingleton<_i174.VerifyLoginOtpUseCase>(
      () => _i174.VerifyLoginOtpUseCase(gh<_i61.AuthRepository>()),
    );
    gh.lazySingleton<_i174.VerifyRegisterOtpUseCase>(
      () => _i174.VerifyRegisterOtpUseCase(gh<_i61.AuthRepository>()),
    );
    gh.lazySingleton<_i174.LogoutUseCase>(
      () => _i174.LogoutUseCase(gh<_i61.AuthRepository>()),
    );
    gh.lazySingleton<_i174.GetCachedUserUseCase>(
      () => _i174.GetCachedUserUseCase(gh<_i61.AuthRepository>()),
    );
    gh.lazySingleton<_i25.SearchProductsUseCase>(
      () => _i25.SearchProductsUseCase(gh<_i389.SearchRepository>()),
    );
    gh.lazySingleton<_i25.GetPopularSearchesUseCase>(
      () => _i25.GetPopularSearchesUseCase(gh<_i389.SearchRepository>()),
    );
    gh.factory<_i118.SearchCubit>(
      () => _i118.SearchCubit(
        gh<_i25.SearchProductsUseCase>(),
        gh<_i25.GetPopularSearchesUseCase>(),
      ),
    );
    gh.factory<_i18.AuthCubit>(
      () => _i18.AuthCubit(
        gh<_i174.LoginUseCase>(),
        gh<_i174.RegisterUseCase>(),
        gh<_i174.VerifyLoginOtpUseCase>(),
        gh<_i174.VerifyRegisterOtpUseCase>(),
        gh<_i174.LogoutUseCase>(),
        gh<_i174.GetCachedUserUseCase>(),
      ),
    );
    gh.factory<_i154.AdminBranchesCubit>(
      () => _i154.AdminBranchesCubit(gh<_i583.AdminRepository>()),
    );
    gh.factory<_i386.AdminPaymentsCubit>(
      () => _i386.AdminPaymentsCubit(gh<_i583.AdminRepository>()),
    );
    gh.factory<_i918.AdminSettingsCubit>(
      () => _i918.AdminSettingsCubit(gh<_i583.AdminRepository>()),
    );
    gh.factory<_i32.AdminUsersCubit>(
      () => _i32.AdminUsersCubit(gh<_i583.AdminRepository>()),
    );
    gh.factory<_i8.HighlightCubit>(
      () => _i8.HighlightCubit(repository: gh<_i917.HighlightRepository>()),
    );
    gh.factory<_i462.AdminCategoriesCubit>(
      () => _i462.AdminCategoriesCubit(repository: gh<_i583.AdminRepository>()),
    );
    gh.factory<_i528.AdminDashboardCubit>(
      () => _i528.AdminDashboardCubit(repository: gh<_i583.AdminRepository>()),
    );
    gh.factory<_i464.AdminMarketingCubit>(
      () => _i464.AdminMarketingCubit(repository: gh<_i583.AdminRepository>()),
    );
    gh.factory<_i969.AdminOptionsCubit>(
      () => _i969.AdminOptionsCubit(repository: gh<_i583.AdminRepository>()),
    );
    gh.factory<_i878.AdminOrdersCubit>(
      () => _i878.AdminOrdersCubit(repository: gh<_i583.AdminRepository>()),
    );
    gh.factory<_i533.AdminProductsCubit>(
      () => _i533.AdminProductsCubit(repository: gh<_i583.AdminRepository>()),
    );
    gh.factory<_i858.AddressCubit>(
      () => _i858.AddressCubit(
        getAddresses: gh<_i91.GetAddressesUseCase>(),
        createAddress: gh<_i91.CreateAddressUseCase>(),
        updateAddress: gh<_i91.UpdateAddressUseCase>(),
        deleteAddress: gh<_i91.DeleteAddressUseCase>(),
        setDefault: gh<_i91.SetDefaultAddressUseCase>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}
