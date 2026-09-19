import '../datasources/financial_remote_datasource.dart';
import '../models/escrow_summary_model.dart';
import '../models/financial_action_result.dart';
import '../models/financial_invoice_model.dart';
import '../models/financial_summary_model.dart';
import '../models/ledger_entry_model.dart';
import '../../../../core/models/paginated_result.dart';
import '../models/payment_method_model.dart';
import '../models/pricing_settings_model.dart';
import '../models/recharge_model.dart';
import '../models/trip_cancellation_preview_model.dart';
import '../models/withdrawal_model.dart';

/// عقد طبقة البيانات كما تراه طبقة المنطق.
/// لا يعرف الـ Cubit ولا الشاشات أي شيء عن Dio أو مسارات الـ API.
abstract class FinancialRepository {
  Future<FinancialSummaryModel> getFinancialSummary();

  Future<PaginatedResult<LedgerEntryModel>> getLedger(LedgerFilters filters);

  Future<PaginatedResult<WithdrawalModel>> getWithdrawals({
    String? status,
    String? search,
    String? dateFrom,
    String? dateTo,
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
    String? search,
    String? dateFrom,
    String? dateTo,
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

  Future<TripCancellationPreviewModel> getTripCancellationPreview(
    int tripId, {
    required String cancelledBy,
  });

  Future<FinancialActionResult> cancelTripWithMatrix(
    int tripId, {
    required String cancelledBy,
  });

  Future<PaginatedResult<FinancialInvoiceModel>> getInvoices({
    String? status,
    int page,
    int perPage,
  });

  Future<FinancialInvoiceModel> getInvoiceDetails(int id);

  Future<PricingSettingsModel> getPricingSettings();

  Future<FinancialActionResult> createPricingSettings(
      PricingSettingsModel settings);

  Future<FinancialActionResult> updatePricingSettings(
      PricingSettingsModel settings);

  Future<PaginatedResult<PaymentMethodModel>> getPaymentMethods({
    int page,
    int perPage,
  });

  Future<FinancialActionResult> createPaymentMethod(PaymentMethodModel method);

  Future<FinancialActionResult> updatePaymentMethod(
    int id,
    PaymentMethodModel method,
    PaymentMethodModel original,
  );

  Future<FinancialActionResult> togglePaymentMethodStatus(int id);

  Future<FinancialActionResult> deletePaymentMethod(int id);
}

class FinancialRepositoryImpl implements FinancialRepository {
  final FinancialRemoteDataSource _remoteDataSource;

  FinancialRepositoryImpl(this._remoteDataSource);

  @override
  Future<FinancialSummaryModel> getFinancialSummary() =>
      _remoteDataSource.getFinancialSummary();

  @override
  Future<PaginatedResult<LedgerEntryModel>> getLedger(LedgerFilters filters) =>
      _remoteDataSource.getLedger(filters);

  @override
  Future<PaginatedResult<WithdrawalModel>> getWithdrawals({
    String? status,
    String? search,
    String? dateFrom,
    String? dateTo,
    int page = 1,
    int perPage = 20,
  }) =>
      _remoteDataSource.getWithdrawals(
        status: status,
        search: search,
        dateFrom: dateFrom,
        dateTo: dateTo,
        page: page,
        perPage: perPage,
      );

  @override
  Future<WithdrawalModel> getWithdrawalDetails(int id) =>
      _remoteDataSource.getWithdrawalDetails(id);

  @override
  Future<FinancialActionResult> processWithdrawal(
    int id, {
    required String action,
    String? rejectionReason,
  }) =>
      _remoteDataSource.processWithdrawal(
        id,
        action: action,
        rejectionReason: rejectionReason,
      );

  @override
  Future<PaginatedResult<RechargeModel>> getRecharges({
    String? status,
    String? search,
    String? dateFrom,
    String? dateTo,
    int page = 1,
    int perPage = 20,
  }) =>
      _remoteDataSource.getRecharges(
        status: status,
        search: search,
        dateFrom: dateFrom,
        dateTo: dateTo,
        page: page,
        perPage: perPage,
      );

  @override
  Future<RechargeModel> getRechargeDetails(int id) =>
      _remoteDataSource.getRechargeDetails(id);

  @override
  Future<FinancialActionResult> processRecharge(
    int id, {
    required String action,
    String? reason,
  }) =>
      _remoteDataSource.processRecharge(id, action: action, reason: reason);

  @override
  Future<EscrowSummaryModel> getEscrows() => _remoteDataSource.getEscrows();

  @override
  Future<FinancialActionResult> releaseEscrows() =>
      _remoteDataSource.releaseEscrows();

  @override
  Future<TripCancellationPreviewModel> getTripCancellationPreview(
    int tripId, {
    required String cancelledBy,
  }) =>
      _remoteDataSource.getTripCancellationPreview(
        tripId,
        cancelledBy: cancelledBy,
      );

  @override
  Future<FinancialActionResult> cancelTripWithMatrix(
    int tripId, {
    required String cancelledBy,
  }) =>
      _remoteDataSource.cancelTripWithMatrix(tripId, cancelledBy: cancelledBy);

  @override
  Future<PaginatedResult<FinancialInvoiceModel>> getInvoices({
    String? status,
    int page = 1,
    int perPage = 20,
  }) =>
      _remoteDataSource.getInvoices(
        status: status,
        page: page,
        perPage: perPage,
      );

  @override
  Future<FinancialInvoiceModel> getInvoiceDetails(int id) =>
      _remoteDataSource.getInvoiceDetails(id);

  @override
  Future<PricingSettingsModel> getPricingSettings() =>
      _remoteDataSource.getPricingSettings();

  @override
  Future<FinancialActionResult> createPricingSettings(
          PricingSettingsModel settings) =>
      _remoteDataSource.createPricingSettings(settings);

  @override
  Future<FinancialActionResult> updatePricingSettings(
          PricingSettingsModel settings) =>
      _remoteDataSource.updatePricingSettings(settings);

  @override
  Future<PaginatedResult<PaymentMethodModel>> getPaymentMethods({
    int page = 1,
    int perPage = 15,
  }) =>
      _remoteDataSource.getPaymentMethods(page: page, perPage: perPage);

  @override
  Future<FinancialActionResult> createPaymentMethod(
          PaymentMethodModel method) =>
      _remoteDataSource.createPaymentMethod(method);

  @override
  Future<FinancialActionResult> updatePaymentMethod(
    int id,
    PaymentMethodModel method,
    PaymentMethodModel original,
  ) =>
      _remoteDataSource.updatePaymentMethod(id, method, original);

  @override
  Future<FinancialActionResult> togglePaymentMethodStatus(int id) =>
      _remoteDataSource.togglePaymentMethodStatus(id);

  @override
  Future<FinancialActionResult> deletePaymentMethod(int id) =>
      _remoteDataSource.deletePaymentMethod(id);
}
