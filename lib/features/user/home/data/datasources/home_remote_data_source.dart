import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:dhabayih_lmamlaka/core/api/server_strings.dart';
import 'package:dhabayih_lmamlaka/core/error/exceptions.dart';

import '../models/home_response_model.dart';

abstract class HomeRemoteDataSource {
  Future<HomeResponseModel> getHomeData();
}

@LazySingleton(as: HomeRemoteDataSource)
class HomeRemoteDataSourceImpl
    with DioErrorHandler
    implements HomeRemoteDataSource {
  final Dio dio;

  HomeRemoteDataSourceImpl({required this.dio});

  @override
  Future<HomeResponseModel> getHomeData() async {
    try {
      final response = await dio.get('/api/v1/home');
      final rawRoot = response.data is Map<String, dynamic>
          ? Map<String, dynamic>.from(response.data as Map<String, dynamic>)
          : <String, dynamic>{};

      // Enrich user_highlight with real loyalty_points / balance from /api/v1/me
      // and /api/v1/loyalty/summary when /api/v1/home returns 0 or omits points.
      if (rawRoot['data'] is Map) {
        final dataMap = Map<String, dynamic>.from(rawRoot['data'] as Map);
        final rawHighlight = dataMap['user_highlight'];
        if (rawHighlight is Map) {
          final highlightMap = Map<String, dynamic>.from(rawHighlight);
          int pts = _extractInt(
            highlightMap['loyalty_points'] ??
                highlightMap['points'] ??
                highlightMap['current_points'] ??
                highlightMap['total_points'],
          );
          double bal = _extractDouble(
            highlightMap['balance'] ?? highlightMap['wallet_balance'],
          );

          if (pts <= 0) {
            final fetched = await _fetchLiveUserPointsAndBalance();
            if (fetched.points > 0) pts = fetched.points;
            if (bal <= 0 && fetched.balance > 0) bal = fetched.balance;
          }

          if (pts > 0) {
            highlightMap['loyalty_points'] = pts;
          }
          if (bal <= 0 && pts > 0) {
            highlightMap['balance'] = pts.toDouble();
          } else if (bal > 0) {
            highlightMap['balance'] = bal;
          }

          dataMap['user_highlight'] = highlightMap;
          rawRoot['data'] = dataMap;
        }
      }

      return HomeResponseModel.fromJson(rawRoot);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  Future<({int points, double balance})> _fetchLiveUserPointsAndBalance() async {
    int points = 0;
    double balance = 0.0;

    // 1. Try /api/v1/me (Profile endpoint — returns loyalty_points)
    try {
      final meRes = await dio.get(ServerStrings.profile);
      if (meRes.statusCode == 200 && meRes.data != null) {
        final d = (meRes.data is Map ? (meRes.data['data'] ?? meRes.data) : null);
        if (d is Map) {
          final p = _extractInt(
            d['loyalty_points'] ??
                d['points'] ??
                d['current_points'] ??
                d['total_points'],
          );
          final b = _extractDouble(d['balance'] ?? d['wallet_balance']);
          if (p > 0) points = p;
          if (b > 0) balance = b;
        }
      }
    } catch (_) {}

    // 2. Try /api/v1/loyalty/summary if points are still 0
    if (points <= 0) {
      try {
        final loyRes = await dio.get(ServerStrings.loyaltySummary);
        if (loyRes.statusCode == 200 && loyRes.data != null) {
          final d =
              (loyRes.data is Map ? (loyRes.data['data'] ?? loyRes.data) : null);
          if (d is Map) {
            final p = _extractInt(
              d['loyalty_points'] ??
                  d['points'] ??
                  d['current_points'] ??
                  d['total_points'] ??
                  d['balance'],
            );
            final b = _extractDouble(
              d['monetary_value'] ??
                  d['redemption_value'] ??
                  d['cash_value'] ??
                  d['wallet_balance'],
            );
            if (p > 0) points = p;
            if (balance <= 0 && b > 0) balance = b;
          }
        }
      } catch (_) {}
    }

    return (points: points, balance: balance);
  }

  static int _extractInt(dynamic v) {
    if (v == null || v is bool) return 0;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ??
        double.tryParse(v.toString())?.round() ??
        0;
  }

  static double _extractDouble(dynamic v) {
    if (v == null || v is bool) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }
}
