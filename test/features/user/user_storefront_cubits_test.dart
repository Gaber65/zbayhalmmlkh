import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dhabayih_lmamlaka/core/error/failure.dart';
import 'package:dhabayih_lmamlaka/features/user/cart/domain/entities/cart.dart';
import 'package:dhabayih_lmamlaka/features/user/cart/domain/repositories/cart_repository.dart';
import 'package:dhabayih_lmamlaka/features/user/cart/presentation/manager/cart_cubit.dart';
import 'package:dhabayih_lmamlaka/features/user/cart/presentation/manager/cart_state.dart';
import 'package:dhabayih_lmamlaka/features/user/orders/domain/entities/order_entity.dart';
import 'package:dhabayih_lmamlaka/features/user/orders/domain/repositories/order_repository.dart';
import 'package:dhabayih_lmamlaka/features/user/orders/presentation/manager/order_cubit.dart';
import 'package:dhabayih_lmamlaka/features/user/orders/presentation/manager/order_state.dart';
import '../../helpers/test_helpers.dart';

class FakeCartRepository implements CartRepository {
  bool shouldFail = false;
  CartEntity currentCart = const CartEntity(
    id: 1,
    status: 'active',
    lines: [],
    subtotal: 0.0,
    total: 0.0,
    itemCount: 0,
  );

  @override
  Future<Either<Failure, CartEntity>> getCart() async {
    if (shouldFail) return Left(mockFailure('فشل في جلب السلة'));
    return Right(currentCart);
  }

  @override
  Future<Either<Failure, CartEntity>> addToCart({
    required int productId,
    required double quantity,
    int? cuttingOptionId,
    List<int>? packagingIds,
    List<int>? excludedPartIds,
    String? notes,
    int? sizeId,
  }) async {
    if (shouldFail) return Left(mockFailure('فشل في الإضافة للسلة'));
    currentCart = const CartEntity(
      id: 1,
      status: 'active',
      lines: [
        CartLineEntity(
          id: 10,
          productId: 101,
          productName: 'خروف نعيمي',
          priceUnit: 1350.0,
          quantity: 1,
          lineTotal: 1350.0,
        ),
      ],
      subtotal: 1350.0,
      total: 1552.5,
      itemCount: 1,
    );
    return Right(currentCart);
  }

  @override
  Future<Either<Failure, CartEntity>> updateCartItem({
    required int productId,
    required double quantity,
    int? cuttingOptionId,
    List<int>? packagingIds,
    List<int>? excludedPartIds,
    String? notes,
  }) async {
    if (shouldFail) return Left(mockFailure('فشل في تعديل الكمية'));
    return Right(currentCart);
  }

  @override
  Future<Either<Failure, CartEntity>> removeFromCart({required int productId}) async {
    if (shouldFail) return Left(mockFailure('فشل في حذف العنصر'));
    currentCart = const CartEntity(
      id: 1,
      status: 'active',
      lines: [],
      subtotal: 0.0,
      total: 0.0,
      itemCount: 0,
    );
    return Right(currentCart);
  }

  @override
  Future<Either<Failure, CartEntity>> clearCart() async {
    if (shouldFail) return Left(mockFailure('فشل في تفريغ السلة'));
    currentCart = const CartEntity(
      id: 1,
      status: 'active',
      lines: [],
      subtotal: 0.0,
      total: 0.0,
      itemCount: 0,
    );
    return Right(currentCart);
  }
}

class FakeOrderRepository implements OrderRepository {
  bool shouldFail = false;
  int? lastCancelledOrderId;
  int? lastReceivedOrderId;

  @override
  Future<Either<Failure, List<OrderListItemEntity>>> getOrders({
    String? state,
    int? limit,
    int? offset,
  }) async {
    if (shouldFail) return Left(mockFailure('فشل في تحميل الطلبات'));
    return const Right([
      OrderListItemEntity(
        id: 701,
        name: 'SO-USER-001',
        date: '2026-09-26',
        total: 1552.5,
        subtotal: 1350.0,
        discountAmount: 0.0,
        taxAmount: 202.5,
        paymentStatus: 'paid',
        itemCount: 1,
        state: 'confirmed',
      ),
    ]);
  }

  @override
  Future<Either<Failure, OrderDetailEntity>> getOrderDetail(int orderId) async {
    if (shouldFail) return Left(mockFailure('الطلب غير موجود'));
    return Right(OrderDetailEntity(
      id: orderId,
      name: 'SO-USER-001',
      date: '2026-09-26',
      total: 1552.5,
      subtotal: 1350.0,
      discountAmount: 0.0,
      pointsRedeemed: 0,
      loyaltyDiscountAmount: 0.0,
      taxAmount: 202.5,
      paymentStatus: 'paid',
      state: 'confirmed',
      lines: const [],
      timeline: const [],
    ));
  }

  @override
  Future<Either<Failure, void>> cancelOrder(int orderId) async {
    lastCancelledOrderId = orderId;
    if (shouldFail) return Left(mockFailure('لا يمكن إلغاء الطلب'));
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> receiveOrder(int orderId) async {
    lastReceivedOrderId = orderId;
    if (shouldFail) return Left(mockFailure('تعذر تأكيد الاستلام'));
    return const Right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('CartCubit Unit Tests (Cart Actions)', () {
    late FakeCartRepository cartRepo;
    late CartCubit cartCubit;

    setUp(() {
      cartRepo = FakeCartRepository();
      cartCubit = CartCubit(repository: cartRepo);
    });

    test('fetchCart emits [CartLoading, CartLoaded] on success', () async {
      final states = <CartState>[];
      cartCubit.stream.listen(states.add);

      await cartCubit.fetchCart();
      await pumpEventQueue();

      expect(states.length, 2);
      expect(states[0], isA<CartLoading>());
      expect(states[1], isA<CartLoaded>());
    });

    test('fetchCart emits [CartLoading, CartError] on failure', () async {
      cartRepo.shouldFail = true;
      final states = <CartState>[];
      cartCubit.stream.listen(states.add);

      await cartCubit.fetchCart();
      await pumpEventQueue();

      expect(states.length, 2);
      expect(states[0], isA<CartLoading>());
      expect(states[1], isA<CartError>());
    });

    test('addToCart emits [CartItemAdding, CartItemAdded] and updates items', () async {
      final states = <CartState>[];
      cartCubit.stream.listen(states.add);

      await cartCubit.addToCart(productId: 101, quantity: 1);
      await pumpEventQueue();

      expect(states.length, 2);
      expect(states[0], isA<CartItemAdding>());
      expect(states[1], isA<CartItemAdded>());
      final added = states[1] as CartItemAdded;
      expect(added.cart.lines.length, 1);
      expect(added.cart.total, 1552.5);
    });

    test('removeFromCart and clearCart empty the cart', () async {
      await cartCubit.addToCart(productId: 101, quantity: 1);
      await cartCubit.removeFromCart(productId: 101);

      expect(cartCubit.state, isA<CartLoaded>());
      final loaded = cartCubit.state as CartLoaded;
      expect(loaded.cart.lines, isEmpty);
    });
  });

  group('OrderCubit Unit Tests (Order Actions)', () {
    late FakeOrderRepository orderRepo;
    late OrderCubit orderCubit;

    setUp(() {
      orderRepo = FakeOrderRepository();
      orderCubit = OrderCubit(repository: orderRepo);
    });

    test('fetchOrders emits [OrderLoading, OrderListLoaded] on success', () async {
      final states = <OrderState>[];
      orderCubit.stream.listen(states.add);

      await orderCubit.fetchOrders();
      await pumpEventQueue();

      expect(states.length, 2);
      expect(states[0], isA<OrderLoading>());
      expect(states[1], isA<OrderListLoaded>());
      final loaded = states[1] as OrderListLoaded;
      expect(loaded.orders.length, 1);
      expect(loaded.orders.first.name, 'SO-USER-001');
    });

    test('cancelOrder emits [OrderCancelLoading, OrderCancelSuccess]', () async {
      final states = <OrderState>[];
      orderCubit.stream.listen(states.add);

      await orderCubit.cancelOrder(701);
      await pumpEventQueue();

      expect(states.length, 2);
      expect(states[0], isA<OrderCancelLoading>());
      expect(states[1], isA<OrderCancelSuccess>());
      expect(orderRepo.lastCancelledOrderId, 701);
    });

    test('receiveOrder emits [OrderReceiveLoading, OrderReceiveSuccess]', () async {
      final states = <OrderState>[];
      orderCubit.stream.listen(states.add);

      await orderCubit.receiveOrder(701);
      await pumpEventQueue();

      expect(states.length, 2);
      expect(states[0], isA<OrderReceiveLoading>());
      expect(states[1], isA<OrderReceiveSuccess>());
      expect(orderRepo.lastReceivedOrderId, 701);
    });
  });
}
