import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconly/iconly.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/colors.dart';
import '../../domain/entities/admin_entities.dart';
import '../manager/admin_payments_cubit.dart';

class AdminPaymentsView extends StatelessWidget {
  const AdminPaymentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminPaymentsCubit>()..loadPaymentsData(),
      child: const _AdminPaymentsContent(),
    );
  }
}

class _AdminPaymentsContent extends StatefulWidget {
  const _AdminPaymentsContent();

  @override
  State<_AdminPaymentsContent> createState() => _AdminPaymentsContentState();
}

class _AdminPaymentsContentState extends State<_AdminPaymentsContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _paymentsScrollController = ScrollController();
  final ScrollController _loyaltyScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _paymentsScrollController.addListener(_onPaymentsScroll);
    _loyaltyScrollController.addListener(_onLoyaltyScroll);
  }

  void _onPaymentsScroll() {
    if (_paymentsScrollController.hasClients &&
        _paymentsScrollController.position.pixels >=
            _paymentsScrollController.position.maxScrollExtent - 200) {
      context.read<AdminPaymentsCubit>().loadMorePayments();
    }
  }

  void _onLoyaltyScroll() {
    if (_loyaltyScrollController.hasClients &&
        _loyaltyScrollController.position.pixels >=
            _loyaltyScrollController.position.maxScrollExtent - 200) {
      context.read<AdminPaymentsCubit>().loadMoreLoyalty();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _paymentsScrollController.dispose();
    _loyaltyScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'المدفوعات والمعاملات',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AdminPaymentsCubit>().loadPaymentsData();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
          tabs: const [
            Tab(
              icon: Icon(Icons.payment_outlined),
              text: 'معاملات الدفع',
            ),
            Tab(
              icon: Icon(Icons.stars_outlined),
              text: 'سجل حركات الولاء',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPaymentsTab(isDark),
          _buildLoyaltyTab(isDark),
        ],
      ),
    );
  }

  Widget _buildPaymentsTab(bool isDark) {
    return BlocBuilder<AdminPaymentsCubit, AdminPaymentsState>(
      builder: (context, state) {
        if (state is AdminPaymentsLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (state is AdminPaymentsError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                  const SizedBox(height: 12),
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<AdminPaymentsCubit>().loadPaymentsData(),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is AdminPaymentsLoaded) {
          final payments = state.filteredPayments;

          return RefreshIndicator(
            onRefresh: () => context.read<AdminPaymentsCubit>().loadPaymentsData(),
            child: ListView(
              controller: _paymentsScrollController,
              padding: const EdgeInsets.all(16),
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'بحث برقم الطلب، العميل، أو المرجع...',
                    prefixIcon: Icon(IconlyLight.search, color: AppColors.primary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              context.read<AdminPaymentsCubit>().search('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (val) => context.read<AdminPaymentsCubit>().search(val),
                ),
                const SizedBox(height: 12),

                // Method Filters
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        label: 'الكل',
                        isSelected: state.methodFilter == null || state.methodFilter == 'all',
                        onTap: () => context.read<AdminPaymentsCubit>().filterMethod('all'),
                      ),
                      _buildFilterChip(
                        label: 'Mada / Visa',
                        isSelected: state.methodFilter == 'card' || state.methodFilter == 'visa',
                        onTap: () => context.read<AdminPaymentsCubit>().filterMethod('visa'),
                      ),
                      _buildFilterChip(
                        label: 'Apple Pay',
                        isSelected: state.methodFilter == 'apple',
                        onTap: () => context.read<AdminPaymentsCubit>().filterMethod('apple'),
                      ),
                      _buildFilterChip(
                        label: 'Tabby / Tamara',
                        isSelected: state.methodFilter == 'tabby' || state.methodFilter == 'tamara',
                        onTap: () => context.read<AdminPaymentsCubit>().filterMethod('tabby'),
                      ),
                      _buildFilterChip(
                        label: 'الدفع عند الاستلام',
                        isSelected: state.methodFilter == 'delivery' || state.methodFilter == 'cash',
                        onTap: () => context.read<AdminPaymentsCubit>().filterMethod('cash'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                if (payments.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40.0),
                      child: Column(
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 60, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            'لا توجد معاملات مطابقة للبحث',
                            style: TextStyle(
                              color: isDark ? Colors.white60 : Colors.black54,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  ...payments.map((tx) => _buildPaymentCard(tx, isDark)),
                  if (state.isLoadingMorePayments)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildPaymentCard(AdminPaymentTransactionEntity tx, bool isDark) {
    Color statusColor;
    String statusText;
    switch (tx.status.toLowerCase()) {
      case 'paid':
        statusColor = const Color(0xFF10B981);
        statusText = 'مدفوع';
        break;
      case 'pending':
        statusColor = const Color(0xFFF59E0B);
        statusText = 'قيد المعالجة';
        break;
      case 'cancelled':
        statusColor = const Color(0xFFEF4444);
        statusText = 'ملغي';
        break;
      case 'authorized':
        statusColor = const Color(0xFF3B82F6);
        statusText = 'معتمد';
        break;
      default:
        statusColor = Colors.grey;
        statusText = tx.status;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.payment, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx.orderName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        tx.customerName,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${tx.amount.toStringAsFixed(2)} ر.س',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.credit_card, size: 14, color: isDark ? Colors.white54 : Colors.black45),
                  const SizedBox(width: 4),
                  Text(
                    tx.paymentMethod,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (tx.isInstallment && tx.installmentProvider != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.purple.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'تقسيط (${tx.installmentProvider})',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (tx.paidDate != null && tx.paidDate!.isNotEmpty)
                Text(
                  tx.paidDate!.length >= 10 ? tx.paidDate!.substring(0, 10) : tx.paidDate!,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
            ],
          ),
          if (tx.transactionReference != null && tx.transactionReference!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'المرجع: ${tx.transactionReference}',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white38 : Colors.black38,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoyaltyTab(bool isDark) {
    return BlocBuilder<AdminPaymentsCubit, AdminPaymentsState>(
      builder: (context, state) {
        if (state is AdminPaymentsLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (state is AdminPaymentsLoaded) {
          final transactions = state.loyaltyTransactions;

          if (transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.stars_outlined, size: 60, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    'لا توجد حركات نقاط ولاء مسجلة',
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.black54,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<AdminPaymentsCubit>().loadPaymentsData(),
            child: ListView.separated(
              controller: _loyaltyScrollController,
              padding: const EdgeInsets.all(16),
              itemCount: transactions.length + (state.isLoadingMoreLoyalty ? 1 : 0),
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                if (index >= transactions.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  );
                }
                final item = transactions[index];
                final isPositive = item.points >= 0;

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.grey.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                              .withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isPositive ? Icons.add : Icons.remove,
                          color: isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.customerName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.description.isNotEmpty ? item.description : 'حركة نقاط ولاء',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                            if (item.orderName != null && item.orderName!.isNotEmpty)
                              Text(
                                'الطلب: ${item.orderName}',
                                style: const TextStyle(fontSize: 11, color: AppColors.primary),
                              ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${isPositive ? '+' : ''}${item.points} نقطة',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'الرصيد: ${item.balanceAfter}',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.white54 : Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary.withValues(alpha: 0.15),
        checkmarkColor: AppColors.primary,
        labelStyle: TextStyle(
          fontSize: 12,
          color: isSelected ? AppColors.primary : null,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
