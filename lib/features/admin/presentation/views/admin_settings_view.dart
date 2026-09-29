import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/colors.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'إعدادات النظام وبرنامج الولاء',
          style: TextStyle(fontWeight: FontWeight.bold),
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
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'إعدادات النظام وبرنامج الولاء',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'تحكم في قواعد اكتساب واستبدال النقاط وحوافز العملاء والتواصل',
                              style: TextStyle(
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
                      const Text(
                        'قواعد النقاط والاستبدال',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Earning Rate
                      const Text(
                        'معدل الاكتساب (Earning Rate)',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'المعادلة: النقاط المكتسبة = إجمالي الطلب (ر.س) * معدل الاكتساب',
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
                          suffixText: 'نقطة / 1 ر.س',
                          filled: true,
                          fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Redemption Rate
                      const Text(
                        'معدل الاستبدال (Redemption Rate)',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'المعادلة: الخصم (ر.س) = النقاط / معدل الاستبدال (مثال: 100 نقطة = 1 ر.س)',
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
                          suffixText: 'نقطة = 1 ر.س',
                          filled: true,
                          fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Min Redemption Points
                      const Text(
                        'الحد الأدنى للاستبدال (Min Redeem Points)',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'الحد الأدنى لرصيد نقاط الولاء المطلوب قبل أن يتمكن العميل من الاستبدال',
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
                          suffixText: 'نقطة',
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
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.save_outlined),
                                    SizedBox(width: 8),
                                    Text(
                                      'حفظ إعدادات الولاء في أودو',
                                      style: TextStyle(
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
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'إعدادات التواصل والدعم الفني',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF25D366),
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'تخصيص رقم الواتساب والرسالة الافتراضية وهاتف الدعم الموحد',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
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
                        title: const Text(
                          'تفعيل التواصل عبر واتساب',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        subtitle: const Text(
                          'ظهور زر الواتساب العائم في المتجر وتطبيق العميل',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        value: _whatsappEnabled,
                        activeThumbColor: const Color(0xFF25D366),
                        onChanged: (val) => setState(() => _whatsappEnabled = val),
                      ),
                      const SizedBox(height: 12),

                      // WhatsApp Number
                      const Text(
                        'رقم الواتساب الرسمي (مع المفتاح الدولي)',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
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
                      const Text(
                        'الرسالة الافتراضية لبدء المحادثة',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _whatsappMessageController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'مرحباً، أود الاستفسار عن ذبائح المملكة',
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
                      const Text(
                        'هاتف الدعم الموحد (Customer Support Phone)',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
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
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_circle_outline),
                                    SizedBox(width: 8),
                                    Text(
                                      'حفظ إعدادات التواصل والدعم',
                                      style: TextStyle(
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
