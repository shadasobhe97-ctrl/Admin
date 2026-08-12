import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/models/pagination_meta_model.dart';
import '../models/escrow_summary_model.dart';
import '../models/financial_action_result.dart';
import '../models/financial_audit_log_model.dart';
import '../models/financial_dispute_model.dart';
import '../models/financial_invoice_model.dart';
import '../models/financial_summary_model.dart';
import '../../../../core/utils/json_parsers.dart';
import '../models/ledger_entry_model.dart';
import '../../../../core/models/paginated_result.dart';
import '../models/recharge_model.dart';
import '../models/settlement_contract_model.dart';
import '../models/solvency_check_model.dart';
import '../models/termination_preview_model.dart';
import '../models/trip_cancellation_preview_model.dart';
import '../models/withdrawal_model.dart';

/// المصدر الوحيد لطلبات الميزة المالية.
/// يتصل بـ [ApiClient] مباشرة (Bearer Token يُضاف تلقائياً عبر الـ Interceptor)
/// ولا يستعمل أي بيانات افتراضية أو تجريبية — أي فشل يُرفع كـ [ApiException].
abstract class FinancialRemoteDataSource {
  Future<FinancialSummaryModel> getFinancialSummary();

  Future<PaginatedResult<LedgerEntryModel>> getLedger(LedgerFilters filters);

  Future<PaginatedResult<FinancialAuditLogModel>> getAuditLogs({
    int page,
    int perPage,
    String? search,
  });

  Future<PaginatedResult<WithdrawalModel>> getWithdrawals({
    String? status,
    int page,
    int perPage,
  });

  Future<WithdrawalModel> getWithdrawalDetails(int id);

  Future<FinancialActionResult> processWithdrawal(
    int id, {
    required String action,
    String? rejectionReason,
  });

  Future<PaginatedResult<RechargeModel>> getRecharges({
    String? status,
    int page,
    int perPage,
  });

  Future<RechargeModel> getRechargeDetails(int id);

  Future<FinancialActionResult> processRecharge(
    int id, {
    required String action,
    String? reason,
  });

  Future<EscrowSummaryModel> getEscrows();

  Future<FinancialActionResult> releaseEscrows();

  Future<PaginatedResult<FinancialDisputeModel>> getDisputes({
    String? status,
    int page,
    int perPage,
  });

  Future<FinancialDisputeModel> getDisputeDetails(int id);

  Future<FinancialActionResult> resolveDispute(
    int disputeId, {
    required String resolution,
    String? notes,
  });

  Future<PaginatedResult<SettlementContractModel>> getPendingSettlements({
    int page,
    int perPage,
  });

  Future<MonthlySettlementResultModel> settleMonthly(int contractId);

  Future<TerminationPreviewModel> getTerminationPreview(
    int contractId, {
    required String terminatedBy,
    bool? isArbitraryParent,
  });

  Future<FinancialActionResult> terminateMidMonth(
    int contractId, {
    required String terminatedBy,
    required bool isArbitraryParent,
  });

  Future<TripCancellationPreviewModel> getTripCancellationPreview(
    int tripId, {
    required String cancelledBy,
  });

  Future<FinancialActionResult> cancelTripWithMatrix(
    int tripId, {
    required String cancelledBy,
  });

  Future<SolvencyCheckModel> getSolvencyCheck();

  Future<PaginatedResult<FinancialInvoiceModel>> getInvoices({
    String? status,
    int page,
    int perPage,
  });

  Future<FinancialInvoiceModel> getInvoiceDetails(int id);
}

class FinancialRemoteDataSourceImpl implements FinancialRemoteDataSource {
  final ApiClient _apiClient;

  FinancialRemoteDataSourceImpl(this._apiClient);

  // ── أدوات داخلية مشتركة ────────────────────────────────────────────────────

  void _log(String method, String endpoint, Object error) {
    if (error is DioException) {
      debugPrint(
        '[FINANCIAL API] $method $endpoint | '
        'Status: ${error.response?.statusCode} | Data: ${error.response?.data}',
      );
    } else {
      debugPrint('[FINANCIAL API] $method $endpoint | Error: $error');
    }
  }

  Never _fail(String method, String endpoint, Object error, String fallback) {
    _log(method, endpoint, error);
    throw ApiErrorMapper.map(error, fallbackMessage: fallback);
  }

  /// طلب GET يعيد كائناً واحداً من `data`.
  Future<T> _getObject<T>(
    String endpoint, {
    Map<String, dynamic>? query,
    required T Function(Map<String, dynamic> json, dynamic body) parser,
    required String fallbackMessage,
  }) async {
    try {
      final response = await _apiClient.get(endpoint, queryParameters: query);
      final object = JsonParsers.extractObject(response.data);
      if (object == null) {
        throw ApiException(
          JsonParsers.extractMessage(response.data) ??
              'استجابة غير متوافقة من الخادم.',
          statusCode: response.statusCode,
        );
      }
      return parser(object, response.data);
    } catch (error) {
      _fail('GET', endpoint, error, fallbackMessage);
    }
  }

  /// طلب GET يعيد قائمة مُصفّحة.
  Future<PaginatedResult<T>> _getList<T>(
    String endpoint, {
    Map<String, dynamic>? query,
    required T Function(Map<String, dynamic> json) parser,
    required String fallbackMessage,
  }) async {
    try {
      final response = await _apiClient.get(endpoint, queryParameters: query);
      final items = JsonParsers.extractList(response.data).map(parser).toList();
      return PaginatedResult<T>(
        items: items,
        meta: PaginationMetaModel.fromJson(
          JsonParsers.extractMeta(response.data),
        ),
      );
    } catch (error) {
      _fail('GET', endpoint, error, fallbackMessage);
    }
  }

  /// طلب POST يعيد رسالة الخادم ونتيجته.
  Future<FinancialActionResult> _post(
    String endpoint, {
    Map<String, dynamic> body = const {},
    required String fallbackMessage,
    required String errorMessage,
  }) async {
    try {
      final response = await _apiClient.post(endpoint, data: body);
      return FinancialActionResult.fromResponse(
        response.data,
        fallbackMessage: fallbackMessage,
      );
    } catch (error) {
      _fail('POST', endpoint, error, errorMessage);
    }
  }

  Map<String, dynamic> _listQuery({
    String? status,
    required int page,
    required int perPage,
  }) {
    return <String, dynamic>{
      'page': page,
      'per_page': perPage,
      if (status != null && status.isNotEmpty) 'status': status,
    };
  }

  // ── 1. Summary ─────────────────────────────────────────────────────────────

  @override
  Future<FinancialSummaryModel> getFinancialSummary() {
    return _getObject(
      ApiEndpoints.financialSummary,
      parser: (json, _) => FinancialSummaryModel.fromJson(json),
      fallbackMessage: 'تعذّر جلب الملخّص المالي.',
    );
  }

  // ── 2. Ledger ──────────────────────────────────────────────────────────────

  @override
  Future<PaginatedResult<LedgerEntryModel>> getLedger(LedgerFilters filters) {
    return _getList(
      ApiEndpoints.ledger,
      query: filters.toQuery(),
      parser: LedgerEntryModel.fromJson,
      fallbackMessage: 'تعذّر جلب سجل الحركات المالية.',
    );
  }

  // ── 3. Audit Logs ──────────────────────────────────────────────────────────

  @override
  Future<PaginatedResult<FinancialAuditLogModel>> getAuditLogs({
    int page = 1,
    int perPage = 20,
    String? search,
  }) {
    return _getList(
      ApiEndpoints.financialAuditLogs,
      query: <String, dynamic>{
        'page': page,
        'per_page': perPage,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
      parser: FinancialAuditLogModel.fromJson,
      fallbackMessage: 'تعذّر جلب سجل عمليات المشرفين.',
    );
  }

  // ── 4. Withdrawals ─────────────────────────────────────────────────────────

  @override
  Future<PaginatedResult<WithdrawalModel>> getWithdrawals({
    String? status,
    int page = 1,
    int perPage = 20,
  }) {
    return _getList(
      ApiEndpoints.withdrawals,
      query: _listQuery(status: status, page: page, perPage: perPage),
      parser: WithdrawalModel.fromJson,
      fallbackMessage: 'تعذّر جلب طلبات سحب الأرباح.',
    );
  }

  @override
  Future<WithdrawalModel> getWithdrawalDetails(int id) {
    return _getObject(
      ApiEndpoints.withdrawalDetails(id),
      parser: (json, _) => WithdrawalModel.fromJson(json),
      fallbackMessage: 'تعذّر جلب تفاصيل طلب السحب.',
    );
  }

  @override
  Future<FinancialActionResult> processWithdrawal(
    int id, {
    required String action,
    String? rejectionReason,
  }) {
    return _post(
      ApiEndpoints.withdrawalProcess(id),
      body: <String, dynamic>{
        'action': action,
        // `rejection_reason` يُرسل فقط مع الرفض كما يحدّد العقد.
        if (action == 'reject' &&
            rejectionReason != null &&
            rejectionReason.trim().isNotEmpty)
          'rejection_reason': rejectionReason.trim(),
      },
      fallbackMessage: 'تمت معالجة طلب السحب.',
      errorMessage: 'تعذّرت معالجة طلب السحب.',
    );
  }

  // ── 5. Recharges ───────────────────────────────────────────────────────────

  @override
  Future<PaginatedResult<RechargeModel>> getRecharges({
    String? status,
    int page = 1,
    int perPage = 20,
  }) {
    return _getList(
      ApiEndpoints.recharges,
      query: _listQuery(status: status, page: page, perPage: perPage),
      parser: RechargeModel.fromJson,
      fallbackMessage: 'تعذّر جلب طلبات شحن المحافظ.',
    );
  }

  @override
  Future<RechargeModel> getRechargeDetails(int id) {
    return _getObject(
      ApiEndpoints.rechargeDetails(id),
      parser: (json, _) => RechargeModel.fromJson(json),
      fallbackMessage: 'تعذّر جلب تفاصيل عملية الشحن.',
    );
  }

  @override
  Future<FinancialActionResult> processRecharge(
    int id, {
    required String action,
    String? reason,
  }) {
    return _post(
      ApiEndpoints.rechargeProcess(id),
      body: <String, dynamic>{
        'action': action,
        // `reason` يُرسل فقط مع الإخفاق كما يحدّد العقد.
        if (action == 'fail' && reason != null && reason.trim().isNotEmpty)
          'reason': reason.trim(),
      },
      fallbackMessage: 'تمت معالجة عملية الشحن.',
      errorMessage: 'تعذّرت معالجة عملية الشحن.',
    );
  }

  // ── 6. Escrows ─────────────────────────────────────────────────────────────

  @override
  Future<EscrowSummaryModel> getEscrows() {
    return _getObject(
      ApiEndpoints.escrows,
      parser: (json, _) => EscrowSummaryModel.fromJson(json),
      fallbackMessage: 'تعذّر جلب بيانات الأمانات.',
    );
  }

  @override
  Future<FinancialActionResult> releaseEscrows() {
    return _post(
      ApiEndpoints.releaseEscrows,
      fallbackMessage: 'تم تنفيذ عملية تحرير الأمانات.',
      errorMessage: 'تعذّر تحرير الأمانات.',
    );
  }

  // ── 7. Disputes ────────────────────────────────────────────────────────────

  @override
  Future<PaginatedResult<FinancialDisputeModel>> getDisputes({
    String? status,
    int page = 1,
    int perPage = 20,
  }) {
    return _getList(
      ApiEndpoints.disputes,
      query: _listQuery(status: status, page: page, perPage: perPage),
      parser: FinancialDisputeModel.fromJson,
      fallbackMessage: 'تعذّر جلب النزاعات المالية.',
    );
  }

  @override
  Future<FinancialDisputeModel> getDisputeDetails(int id) {
    return _getObject(
      ApiEndpoints.disputeDetails(id),
      parser: (json, _) => FinancialDisputeModel.fromJson(json),
      fallbackMessage: 'تعذّر جلب تفاصيل النزاع.',
    );
  }

  @override
  Future<FinancialActionResult> resolveDispute(
    int disputeId, {
    required String resolution,
    String? notes,
  }) {
    return _post(
      ApiEndpoints.disputeResolve(disputeId),
      body: <String, dynamic>{
        'resolution': resolution,
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      },
      fallbackMessage: 'تم حل النزاع.',
      errorMessage: 'تعذّر حل النزاع.',
    );
  }

  // ── 8. Settlements ─────────────────────────────────────────────────────────

  @override
  Future<PaginatedResult<SettlementContractModel>> getPendingSettlements({
    int page = 1,
    int perPage = 15,
  }) {
    return _getList(
      ApiEndpoints.pendingSettlements,
      query: <String, dynamic>{'page': page, 'per_page': perPage},
      parser: SettlementContractModel.fromJson,
      fallbackMessage: 'تعذّر جلب العقود الجاهزة للتسوية.',
    );
  }

  @override
  Future<MonthlySettlementResultModel> settleMonthly(int contractId) async {
    final endpoint = ApiEndpoints.contractSettleMonthly(contractId);
    try {
      final response = await _apiClient.post(endpoint, data: const {});
      final object = JsonParsers.extractObject(response.data);
      if (object == null) {
        throw ApiException(
          JsonParsers.extractMessage(response.data) ??
              'استجابة غير متوافقة من الخادم عند تنفيذ التسوية.',
          statusCode: response.statusCode,
        );
      }
      return MonthlySettlementResultModel.fromJson(object);
    } catch (error) {
      _fail('POST', endpoint, error, 'تعذّر تنفيذ التسوية الشهرية.');
    }
  }

  // ── 9. Contract Termination ────────────────────────────────────────────────

  @override
  Future<TerminationPreviewModel> getTerminationPreview(
    int contractId, {
    required String terminatedBy,
    bool? isArbitraryParent,
  }) {
    return _getObject(
      ApiEndpoints.contractTerminationPreview(contractId),
      query: <String, dynamic>{
        'terminated_by': terminatedBy,
        if (isArbitraryParent != null)
          'is_arbitrary_parent': isArbitraryParent.toString(),
      },
      parser: (json, _) => TerminationPreviewModel.fromJson(json),
      fallbackMessage: 'تعذّر جلب معاينة إنهاء العقد.',
    );
  }

  @override
  Future<FinancialActionResult> terminateMidMonth(
    int contractId, {
    required String terminatedBy,
    required bool isArbitraryParent,
  }) {
    return _post(
      ApiEndpoints.contractTerminateMidMonth(contractId),
      body: <String, dynamic>{
        'terminated_by': terminatedBy,
        'is_arbitrary_parent': isArbitraryParent,
      },
      fallbackMessage: 'تم تنفيذ إنهاء العقد.',
      errorMessage: 'تعذّر تنفيذ إنهاء العقد.',
    );
  }

  // ── 10. Trip Cancellation ──────────────────────────────────────────────────

  @override
  Future<TripCancellationPreviewModel> getTripCancellationPreview(
    int tripId, {
    required String cancelledBy,
  }) {
    return _getObject(
      ApiEndpoints.tripCancelPreview(tripId),
      query: <String, dynamic>{'cancelled_by': cancelledBy},
      parser: (json, _) => TripCancellationPreviewModel.fromJson(json),
      fallbackMessage: 'تعذّر جلب معاينة إلغاء الرحلة.',
    );
  }

  @override
  Future<FinancialActionResult> cancelTripWithMatrix(
    int tripId, {
    required String cancelledBy,
  }) {
    return _post(
      ApiEndpoints.tripCancelWithMatrix(tripId),
      body: <String, dynamic>{'cancelled_by': cancelledBy},
      fallbackMessage: 'تم تنفيذ إلغاء الرحلة.',
      errorMessage: 'تعذّر تنفيذ إلغاء الرحلة.',
    );
  }

  // ── 11. Solvency ───────────────────────────────────────────────────────────

  @override
  Future<SolvencyCheckModel> getSolvencyCheck() {
    return _getObject(
      ApiEndpoints.solvencyCheck,
      parser: (json, body) => SolvencyCheckModel.fromJson(
        json,
        message: JsonParsers.extractMessage(body),
      ),
      fallbackMessage: 'تعذّر تنفيذ فحص الملاءة المالية.',
    );
  }

  // ── 12. Invoices ───────────────────────────────────────────────────────────

  @override
  Future<PaginatedResult<FinancialInvoiceModel>> getInvoices({
    String? status,
    int page = 1,
    int perPage = 20,
  }) {
    return _getList(
      ApiEndpoints.invoices,
      query: _listQuery(status: status, page: page, perPage: perPage),
      parser: FinancialInvoiceModel.fromJson,
      fallbackMessage: 'تعذّر جلب الفواتير.',
    );
  }

  @override
  Future<FinancialInvoiceModel> getInvoiceDetails(int id) {
    return _getObject(
      ApiEndpoints.invoiceDetails(id),
      parser: (json, _) => FinancialInvoiceModel.fromJson(json),
      fallbackMessage: 'تعذّر جلب تفاصيل الفاتورة.',
    );
  }
}
