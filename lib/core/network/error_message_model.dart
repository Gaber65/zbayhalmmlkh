import 'package:equatable/equatable.dart';

class ErrorMessageModel extends Equatable {
  final List<dynamic> errors;
  final String message;
  final int statusCode;
  final bool success;

  const ErrorMessageModel({
    required this.errors,
    required this.message,
    required this.success,
    required this.statusCode,
  });

  factory ErrorMessageModel.fromJson(Map<String, dynamic> json) {
    return ErrorMessageModel(
      errors: json['errors'] != null ? List<dynamic>.from(json['errors']) : [],
      message: json['message'] ?? 'Unknown error',
      success: json['success'] ?? false,
      statusCode: json['statusCode'] ?? 500,
    );
  }

  static Map<String, List<dynamic>> convertJsonToMap(
    Map<String, dynamic> json,
  ) {
    return json['errors'] != null ? Map<String, List<dynamic>>.from(json['errors']) : {};
  }

  @override
  List<Object?> get props => [errors, message, success, statusCode];

  Map<String, dynamic> toJson() {
    return {
      'errors': errors,
      'message': message,
      'success': success,
      'statusCode': statusCode,
    };
  } 
}
