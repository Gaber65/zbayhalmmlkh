import 'package:flutter_test/flutter_test.dart';
import 'package:dhabayih_lmamlaka/features/admin/presentation/manager/admin_settings_cubit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late FakeAdminRepository repository;

  setUp(() {
    repository = FakeAdminRepository();
  });

  group('AdminSettingsCubit Unit Tests (Loyalty Rules)', () {
    test('loadSettings emits [AdminSettingsLoading, AdminSettingsLoaded] on success', () async {
      final cubit = AdminSettingsCubit(repository);
      await cubit.loadSettings();

      expect(cubit.state, isA<AdminSettingsLoaded>());
      final loaded = cubit.state as AdminSettingsLoaded;
      expect(loaded.loyaltySettings.earningRate, 1.0);
      expect(loaded.loyaltySettings.redemptionRate, 100.0);
      expect(loaded.loyaltySettings.minRedemption, 500);
      expect(loaded.contactSettings, isNotNull);
      expect(loaded.contactSettings?.whatsappNumber, '+966500000000');
      expect(loaded.contactSettings?.whatsappEnabled, isTrue);
      expect(loaded.contactSettings?.supportPhone, '920000000');
    });

    test('loadSettings emits [AdminSettingsLoading, AdminSettingsError] on failure', () async {
      repository.shouldFail = true;
      repository.failureMessage = 'خطأ في استرجاع إعدادات المتجر';

      final cubit = AdminSettingsCubit(repository);
      await cubit.loadSettings();

      expect(cubit.state, isA<AdminSettingsError>());
      expect((cubit.state as AdminSettingsError).message, 'خطأ في استرجاع إعدادات المتجر');
    });

    test('updateLoyaltySettings updates rates and emits success state', () async {
      final cubit = AdminSettingsCubit(repository);
      await cubit.loadSettings();

      await cubit.updateLoyaltySettings(
        earningRate: 2.0,
        redemptionRate: 50.0,
        minRedemption: 200,
      );

      expect(repository.lastUpdatedLoyaltySettings?.earningRate, 2.0);
      expect(repository.lastUpdatedLoyaltySettings?.redemptionRate, 50.0);
      expect(repository.lastUpdatedLoyaltySettings?.minRedemption, 200);

      final state = cubit.state as AdminSettingsLoaded;
      expect(state.loyaltySettings.earningRate, 2.0);
      expect(state.successMessage, isNotNull);
    });

    test('updateLoyaltySettings emits AdminSettingsError on failure', () async {
      final cubit = AdminSettingsCubit(repository);
      await cubit.loadSettings();

      repository.shouldFail = true;
      repository.failureMessage = 'فشل في حفظ إعدادات أودو';

      await cubit.updateLoyaltySettings(
        earningRate: 3.0,
        redemptionRate: 75.0,
        minRedemption: 100,
      );

      expect(cubit.state, isA<AdminSettingsError>());
      expect((cubit.state as AdminSettingsError).message, 'فشل في حفظ إعدادات أودو');
    });

    test('updateContactSettings updates contact details and emits success state', () async {
      final cubit = AdminSettingsCubit(repository);
      await cubit.loadSettings();

      await cubit.updateContactSettings(
        whatsappNumber: '+966555111222',
        whatsappDefaultMessage: 'أود طلب ذبيحة نعيمي',
        whatsappEnabled: true,
        supportPhone: '800123456',
      );

      expect(repository.contactSettings.whatsappNumber, '+966555111222');
      expect(repository.contactSettings.whatsappDefaultMessage, 'أود طلب ذبيحة نعيمي');
      expect(repository.contactSettings.supportPhone, '800123456');

      final state = cubit.state as AdminSettingsLoaded;
      expect(state.contactSettings?.whatsappNumber, '+966555111222');
      expect(state.successMessage, contains('واتساب'));
    });

    test('updateContactSettings emits AdminSettingsError on failure', () async {
      final cubit = AdminSettingsCubit(repository);
      await cubit.loadSettings();

      repository.shouldFail = true;
      repository.failureMessage = 'فشل في تحديث إعدادات الواتساب';

      await cubit.updateContactSettings(
        whatsappNumber: '+966555000000',
        whatsappDefaultMessage: 'مرحبا',
        whatsappEnabled: false,
        supportPhone: '920000000',
      );

      expect(cubit.state, isA<AdminSettingsError>());
      expect((cubit.state as AdminSettingsError).message, 'فشل في تحديث إعدادات الواتساب');
    });
  });
}
