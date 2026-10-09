import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/colors.dart';
import '../../core/admin_i18n.dart';
import '../manager/admin_settings_cubit.dart';

class AdminSettingsView extends StatelessWidget {
  const AdminSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminSettingsCubit>()..loadSettings(),
      child: const _AdminSettingsContent(),
    );
  }
}

class _AdminSettingsContent extends StatefulWidget {
  const _AdminSettingsContent();

  @override
  State<_AdminSettingsContent> createState() => _AdminSettingsContentState();
}

class _AdminSettingsContentState extends State<_AdminSettingsContent> {
  final TextEditingController _earningRateController = TextEditingController();
  final TextEditingController _redemptionRateController = TextEditingController();
  final TextEditingController _minRedeemController = TextEditingController();
  final TextEditingController _whatsappNumberController = TextEditingController();
  final TextEditingController _whatsappMessageController = TextEditingController();
  final TextEditingController _supportPhoneController = TextEditingController();
  bool _whatsappEnabled = true;
  bool _isInitialized = false;

  @override
  void dispose() {
    _earningRateController.dispose();
    _redemptionRateController.dispose();
    _minRedeemController.dispose();
    _whatsappNumberController.dispose();
    _whatsappMessageController.dispose();
    _supportPhoneController.dispose();
    super.dispose();
  }

  void _populateFields(AdminSettingsLoaded state) {
    if (!_isInitialized) {
      _earningRateController.text = state.loyaltySettings.earningRate.toStringAsFixed(2);
      _redemptionRateController.text = state.loyaltySettings.redemptionRate.toStringAsFixed(2);
      _minRedeemController.text = state.loyaltySettings.minRedemption.toString();
      if (state.contactSettings != null) {
        final cs = state.contactSettings!;
        _whatsappNumberController.text = cs.whatsappNumber;
        _whatsappMessageController.text = cs.whatsappDefaultMessage;
        _supportPhoneController.text = cs.supportPhone;
        _whatsappEnabled = cs.whatsappEnabled;
      }
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final i18n = AdminI18n.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          i18n.settingsTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _isInitialized = false;
              context.read<AdminSettingsCubit>().loadSettings();
            },
          ),
        ],
      ),
      body: BlocConsumer<AdminSettingsCubit, AdminSettingsState>(
        listener: (context, state) {
          if (state is AdminSettingsLoaded && state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: const Color(0xFF10B981),
              ),
            );
          }
          if (state is AdminSettingsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AdminSettingsLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (state is AdminSettingsLoaded) {
            _populateFields(state);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: isDark
                        ? const LinearGradient(
                            colors: [Color(0xFF1F1F23), Color(0xFF18181B)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.stars_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              i18n.settingsTitle,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              i18n.settingsSubtitle,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Loyalty Settings Form
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.grey.shade200,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        i18n.loyaltyRulesTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Earning Rate
                      Text(
                        i18n.earningRateTitle,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        i18n.earningRateFormula,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _earningRateController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          hintText: '1.00',
                          suffixText: i18n.isArabic ? 'نقطة / 1 ر.س' : 'pts / 1 SAR',
                          filled: true,
                          fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Redemption Rate
                      Text(
                        i18n.redemptionRateTitle,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        i18n.redemptionRateFormula,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _redemptionRateController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          hintText: '100.00',
                          suffixText: i18n.isArabic ? 'نقطة = 1 ر.س' : 'pts = 1 SAR',
                          filled: true,
                          fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Min Redemption Points
                      Text(
                        i18n.minRedeemTitle,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        i18n.isArabic
                            ? 'الحد الأدنى لرصيد نقاط الولاء المطلوب قبل أن يتمكن العميل من الاستبدال'
                            : 'Minimum loyalty points balance required before a customer can redeem',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _minRedeemController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '500',
                          suffixText: i18n.isArabic ? 'نقطة' : 'pts',
                          filled: true,
                          fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Save Loyalty Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: state.isSaving
                              ? null
                              : () {
                                  final earning = double.tryParse(_earningRateController.text) ?? 1.0;
                                  final redemption = double.tryParse(_redemptionRateController.text) ?? 100.0;
                                  final minRedeem = int.tryParse(_minRedeemController.text) ?? 500;

                                  context.read<AdminSettingsCubit>().updateLoyaltySettings(
                                        earningRate: earning,
                                        redemptionRate: redemption,
                                        minRedemption: minRedeem,
                                      );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: state.isSaving
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.save_outlined),
                                    const SizedBox(width: 8),
                                    Text(
                                      i18n.isArabic ? 'حفظ إعدادات الولاء في أودو' : 'Save Loyalty Settings in Odoo',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // WhatsApp & Customer Support Settings Form
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.grey.shade200,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF25D366).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.chat_outlined,
                              color: Color(0xFF25D366),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  i18n.contactSettingsTitle,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF25D366),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  i18n.isArabic
                                      ? 'تخصيص رقم الواتساب والرسالة الافتراضية وهاتف الدعم الموحد'
                                      : 'Customize WhatsApp number, default chat message and support phone',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // WhatsApp Enable Switch
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          i18n.enableWhatsappSupport,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        subtitle: Text(
                          i18n.isArabic
                              ? 'ظهور زر الواتساب العائم في المتجر وتطبيق العميل'
                              : 'Show floating WhatsApp button in customer storefront',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        value: _whatsappEnabled,
                        activeThumbColor: const Color(0xFF25D366),
                        onChanged: (val) => setState(() => _whatsappEnabled = val),
                      ),
                      const SizedBox(height: 12),

                      // WhatsApp Number
                      Text(
                        i18n.whatsappNumberTitle,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _whatsappNumberController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: '+966500000000',
                          prefixIcon: const Icon(Icons.phone_android, color: Color(0xFF25D366)),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Default WhatsApp Message
                      Text(
                        i18n.defaultWhatsappMsg,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _whatsappMessageController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: i18n.isArabic
                              ? 'مرحباً، أود الاستفسار عن ذبائح المملكة'
                              : 'Hello, I have an inquiry about Dhabayih Al-Mamlaka',
                          prefixIcon: const Icon(Icons.message_outlined, color: Colors.grey),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Customer Support Phone
                      Text(
                        i18n.phoneSupportTitle,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _supportPhoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: '920000000',
                          prefixIcon: const Icon(Icons.support_agent, color: AppColors.primary),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Save Contact Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: state.isSaving
                              ? null
                              : () {
                                  context.read<AdminSettingsCubit>().updateContactSettings(
                                        whatsappNumber: _whatsappNumberController.text.trim(),
                                        whatsappDefaultMessage: _whatsappMessageController.text.trim(),
                                        whatsappEnabled: _whatsappEnabled,
                                        supportPhone: _supportPhoneController.text.trim(),
                                      );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25D366),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: state.isSaving
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.check_circle_outline),
                                    const SizedBox(width: 8),
                                    Text(
                                      i18n.isArabic ? 'حفظ إعدادات التواصل والدعم' : 'Save Support & Contact Settings',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
