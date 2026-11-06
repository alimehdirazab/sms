import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_constants.dart';
import '../models/parent_fee_api_model.dart';

class ParentFeeRepository {
  final ApiClient apiClient;

  ParentFeeRepository({required this.apiClient});

  /// 1. GET /parent/fees?studentId={{studentId}}
  Future<ParentFeeDataModel> getFeeDetails(String studentId) async {
    try {
      final response = await apiClient.dio.get(
        ApiConstants.parentFees,
        queryParameters: {'studentId': studentId},
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final innerData = data['data'] is Map<String, dynamic>
            ? data['data'] as Map<String, dynamic>
            : data;
        return ParentFeeDataModel.fromJson(innerData);
      }
      throw Exception('Unexpected response format from fees endpoint');
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Failed to fetch fee details'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// 2. GET /school/bank-details
  Future<SchoolBankDetailsModel> getBankDetails() async {
    try {
      final response = await apiClient.dio.get(ApiConstants.bankDetails);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final innerData = data['data'] is Map<String, dynamic>
            ? data['data'] as Map<String, dynamic>
            : data;
        return SchoolBankDetailsModel.fromJson(innerData);
      }
      throw Exception('Unexpected response format from bank details endpoint');
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Failed to fetch bank details'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// 3. POST /parent/fees/submit-payment
  /// Submits fee payment verification with amount, paymentMethod, transactionId, attachment (base64 string or url), notes
  Future<LatestPaymentSubmissionModel> submitPaymentVerification({
    required String studentId,
    required double amount,
    required String paymentMethod,
    required String transactionId,
    String? attachment,
    String? notes,
  }) async {
    try {
      final payload = <String, dynamic>{
        'studentId': studentId,
        'amount': amount,
        'paymentMethod': paymentMethod,
        'transactionId': transactionId,
        if (attachment != null && attachment.isNotEmpty)
          'attachment': attachment,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      };

      final response = await apiClient.dio.post(
        ApiConstants.submitFeePayment,
        data: payload,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final innerData = data['data'] is Map<String, dynamic>
            ? data['data'] as Map<String, dynamic>
            : data;
        return LatestPaymentSubmissionModel.fromJson(innerData);
      }
      throw Exception('Unexpected response format from payment verification');
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Failed to submit payment verification'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  String _extractErrorMessage(DioException e, String fallback) {
    if (e.response?.data is Map<String, dynamic>) {
      final data = e.response!.data as Map<String, dynamic>;
      return data['message']?.toString() ??
          data['error']?.toString() ??
          fallback;
    }
    return e.message ?? fallback;
  }
}

