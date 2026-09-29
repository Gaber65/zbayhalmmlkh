import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconly/iconly.dart';
import '../../../../core/theme/colors.dart';
import '../../core/admin_i18n.dart';
import '../manager/admin_orders_cubit.dart';
import '../widgets/admin_order_card.dart';

class AdminOrdersView extends StatefulWidget {
  final Function(int orderId) onOpenOrderDetail;

  const AdminOrdersView({super.key, required this.onOpenOrderDetail});

  @override
  State<AdminOrdersView> createState() => _AdminOrdersViewState();
}

class _AdminOrdersViewState extends State<AdminOrdersView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> _statusKeys = [
    'all',
    'pending',
    'confirmed',
    'preparing',
    'ready_pickup',
    'out_delivery',
    'delivered',
    'cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusKeys.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        final key = _statusKeys[_tabController.index];
        context.read<AdminOrdersCubit>().setFilter(key);
      }
    });
    _scrollController.addListener(_onScroll);
    if (context.read<AdminOrdersCubit>().state is AdminOrdersInitial) {
      context.read<AdminOrdersCubit>().loadOrders();
    }
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
      context.read<AdminOrdersCubit>().loadMoreOrders();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _getTabLabel(String key, AdminI18n i18n) {
    switch (key) {
      case 'pending':
        return i18n.filterNew;
      case 'confirmed':
        return i18n.filterConfirmed;
      case 'preparing':
        return i18n.filterProcessing;
      case 'ready_pickup':
        return i18n.filterReadyPickup;
      case 'out_delivery':
        return i18n.filterDelivering;
      case 'delivered':
        return i18n.filterCompleted;
      case 'cancelled':
        return i18n.filterCancelled;
      default:
        return i18n.filterAll;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final i18n = AdminI18n.of(context);

    return Column(
      children: [
        // ── Search & Filter Bar ──────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E24) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => context.read<AdminOrdersCubit>().search(val),
              decoration: InputDecoration(
                hintText: i18n.searchOrdersHint,
                hintStyle: TextStyle(fontSize: 12.5, color: isDark ? Colors.white38 : Colors.black38),
                prefixIcon: const Icon(IconlyLight.search, color: AppColors.primary, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          context.read<AdminOrdersCubit>().search('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              ),
            ),
          ),
        ),

        // ── Status Filter Tab Bar ─────────────────────────────────────────
        Container(
          height: 46,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelColor: AppColors.primary,
            unselectedLabelColor: isDark ? Colors.white60 : AppColors.secondary,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12.5),
            tabs: _statusKeys.map((key) => Tab(text: _getTabLabel(key, i18n))).toList(),
          ),
        ),

        const Divider(height: 1),

        // ── Orders List ───────────────────────────────────────────────────
        Expanded(
          child: BlocBuilder<AdminOrdersCubit, AdminOrdersState>(
            builder: (context, state) {
              if (state is AdminOrdersLoading) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }

              if (state is AdminOrdersError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(IconlyLight.danger, size: 48, color: Colors.red),
                      const SizedBox(height: 12),
                      Text(state.message),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => context.read<AdminOrdersCubit>().loadOrders(),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                        child: Text(
                          i18n.isArabic ? 'إعادة المحاولة' : 'Retry',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (state is AdminOrdersLoaded) {
                final orders = state.orders;

                if (orders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E1E24) : Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(IconlyLight.bag, size: 48, color: Colors.grey),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          i18n.noOrdersFound,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => context.read<AdminOrdersCubit>().loadOrders(silent: true),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: orders.length + (state.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= orders.length) {
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
                      final order = orders[index];
                      return AdminOrderCard(
                        order: order,
                        onTap: () => widget.onOpenOrderDetail(order.id),
                        onStatusChange: (newStatus) async {
                          final success = await context.read<AdminOrdersCubit>().updateOrderStatus(order.id, newStatus);
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  i18n.isArabic
                                      ? 'تم تحديث حالة الطلب ${order.name} بنجاح'
                                      : 'Order ${order.name} status updated successfully',
                                ),
                                backgroundColor: const Color(0xFF10B981),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}
