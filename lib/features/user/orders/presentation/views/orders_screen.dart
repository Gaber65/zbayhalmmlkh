import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:dhabayih_lmamlaka/core/di/injection.dart';
import 'package:dhabayih_lmamlaka/core/routes/routes.dart';
import 'package:dhabayih_lmamlaka/core/theme/colors.dart';
import 'package:dhabayih_lmamlaka/generated/l10n.dart';
import '../manager/order_cubit.dart';
import '../manager/order_state.dart';
import 'package:dhabayih_lmamlaka/features/shared/auth/presentation/manager/auth_cubit.dart';
import 'package:dhabayih_lmamlaka/features/shared/auth/presentation/manager/auth_state.dart';
import 'package:dhabayih_lmamlaka/core/widgets/guest_prompt_widget.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final s = S.of(context);

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final bool isGuest = authState is! AuthAuthenticated;

        return DefaultTabController(
          length: isGuest ? 1 : 3,
          child: Scaffold(
            backgroundColor: cs.surface,
            appBar: AppBar(
              backgroundColor: cs.surface,
              elevation: 0,
              title: Text(
                s.orders_title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              centerTitle: true,
              bottom: isGuest
                  ? null
                  : TabBar(
                      indicatorColor: AppColors.primary,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: cs.onSurfaceVariant,
                      labelStyle: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      tabs: [
                        Tab(text: s.active_orders),
                        Tab(text: s.previous_orders),
                        Tab(text: s.cancelled_orders),
                      ],
                    ),
            ),
            body: isGuest
                ? const GuestPromptWidget()
                : const TabBarView(
                    children: [
                      OrdersListTab(stateFilter: 'active'),
                      OrdersListTab(stateFilter: 'previous'),
                      OrdersListTab(stateFilter: 'cancelled'),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class OrdersListTab extends StatefulWidget {
  final String stateFilter;

  const OrdersListTab({super.key, required this.stateFilter});

  @override
  State<OrdersListTab> createState() => _OrdersListTabState();
}

class _OrdersListTabState extends State<OrdersListTab> {
  late OrderCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<OrderCubit>();
    _loadOrders();
  }

  void _loadOrders() {
    _cubit.fetchOrders(state: widget.stateFilter);
  }

  String _getTranslatedState(String state, S s) {
    switch (state) {
      case 'draft':
        return s.order_status_draft;
      case 'pending_payment':
        return s.order_status_pending;
      case 'confirmed':
        return s.order_status_confirmed;
      case 'preparing':
        return s.order_status_preparing;
      case 'ready_pickup':
        return s.order_status_ready;
      case 'out_delivery':
        return s.order_status_out;
      case 'delivered':
        return s.order_status_delivered;
      case 'cancelled':
        return s.order_status_cancelled;
      case 'refunded':
        return s.order_status_refunded;
      default:
        return state;
    }
  }

  Color _getStatusColor(String state, ColorScheme cs) {
    switch (state) {
      case 'draft':
      case 'pending_payment':
        return Colors.amber;
      case 'confirmed':
      case 'preparing':
        return cs.primary;
      case 'ready_pickup':
      case 'out_delivery':
        return Colors.blue;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
      case 'refunded':
        return cs.error;
      default:
        return cs.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final s = S.of(context);

    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<OrderCubit, OrderState>(
        builder: (context, state) {
          if (state is OrderLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          } else if (state is OrderListLoaded) {
            final orders = state.orders;
            if (orders.isEmpty) {
              return RefreshIndicator(
                onRefresh: () async => _loadOrders(),
                color: AppColors.primary,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.assignment_rounded,
                              size: 64, color: cs.outlineVariant),
                          const SizedBox(height: 16),
                          Text(
                            s.no_orders,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async => _loadOrders(),
              color: AppColors.primary,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final statusColor = _getStatusColor(order.state, cs);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    color: cs.surfaceContainerLowest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: cs.outlineVariant.withOpacity(0.4),
                      ),
                    ),
                    elevation: 0,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        context.push(
                          Routes.orderDetails,
                          extra: order.id,
                        ).then((_) {
                          // Reload list after return in case order state changed
                          _loadOrders();
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  order.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _getTranslatedState(order.state, s),
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: statusColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${s.order_date}: ${order.date}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              s.items_count(order.itemCount),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  s.order_total,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${order.total.toStringAsFixed(2)} ${s.sar}',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: cs.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          } else if (state is OrderError) {
            return RefreshIndicator(
              onRefresh: () async => _loadOrders(),
              color: AppColors.primary,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(state.message),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadOrders,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cs.primary,
                            foregroundColor: cs.onPrimary,
                          ),
                          child: Text(s.error_retry),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
