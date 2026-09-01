import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/models/financial_summary_model.dart';
import '../../data/models/ledger_entry_model.dart';
import '../../data/models/payment_method_model.dart';
import '../../data/models/pricing_settings_model.dart';
import '../../data/repositories/financial_repository_impl.dart';
import '../state/financial_state.dart';

/// كل منطق الميزة المالية. الشاشات لا تنفّذ أي استدعاء شبكة بنفسها.
///
/// مُسجَّل كـ `Factory` في الـ Service Locator، فتحصل كل شاشة على نسخة مستقلة
/// تستدعي الدوال التي تخصّها فقط.
class FinancialCubit extends Cubit<FinancialState> {
  final FinancialRepository _repository;

  FinancialCubit(this._repository) : super(const FinancialInitial());

  // ── حالة داخلية للحفاظ على الفلاتر بين عمليات إعادة التحميل ────────────────
  LedgerFilters _ledgerFilters = const LedgerFilters();
  String? _auditSearch;
  int _auditPage = 1;
  String? _withdrawalsStatus;
  String? _withdrawalsSearch;
  String? _withdrawalsDateFrom;
  String? _withdrawalsDateTo;
  int _withdrawalsPage = 1;

  String? _rechargesStatus;
  String? _rechargesSearch;
  String? _rechargesDateFrom;
  String? _rechargesDateTo;
  int _rechargesPage = 1;
  String? _disputesStatus;
  int _disputesPage = 1;
  int _settlementsPage = 1;
  String? _invoicesStatus;
  int _invoicesPage = 1;

  LedgerFilters get ledgerFilters => _ledgerFilters;

  /// رسالة الخادم تُعرض كما هي (مع تفاصيل `errors` عند وجودها).
  String _messageOf(Object error) {
    if (error is ApiException) return error.detailedMessage;
    return error.toString().replaceAll('Exception: ', '');
  }

  void _emitIfOpen(FinancialState state) {
    if (!isClosed) emit(state);
  }

  // ── 1. Dashboard Summary ──────────────────────────────────────────────────

  Future<void> loadSummary() async {
    _emitIfOpen(const FinancialLoading());
    try {
      final summary = await _repository.getFinancialSummary();
      _emitIfOpen(FinancialLoaded(summary));
    } catch (error) {
      _emitIfOpen(FinancialError(_messageOf(error)));
    }
  }

  // ── 2. Ledger ─────────────────────────────────────────────────────────────

  Future<void> loadLedger({LedgerFilters? filters}) async {
    if (filters != null) _ledgerFilters = filters;
    _emitIfOpen(const LedgerLoading());
    try {
      final result = await _repository.getLedger(_ledgerFilters);
      if (result.isEmpty) {
        _emitIfOpen(LedgerEmpty(_ledgerFilters));
      } else {
        _emitIfOpen(LedgerLoaded(result, _ledgerFilters));
      }
    } catch (error) {
      _emitIfOpen(LedgerError(_messageOf(error)));
    }
  }

  Future<void> changeLedgerPage(int page) =>
      loadLedger(filters: _ledgerFilters.copyWith(page: page));

  Future<void> resetLedgerFilters() =>
      loadLedger(filters: const LedgerFilters());

  // ── 3. Audit Logs ─────────────────────────────────────────────────────────

  Future<void> loadAuditLogs({int? page, String? search}) async {
    _auditPage = page ?? 1;
    if (search != null) _auditSearch = search.trim().isEmpty ? null : search.trim();

    _emitIfOpen(const AuditLogsLoading());
    try {
      final result = await _repository.getAuditLogs(
        page: _auditPage,
        perPage: 20,
        search: _auditSearch,
      );
      if (result.isEmpty) {
        _emitIfOpen(AuditLogsEmpty(search: _auditSearch));
      } else {
        _emitIfOpen(AuditLogsLoaded(result, search: _auditSearch));
      }
    } catch (error) {
      _emitIfOpen(AuditLogsError(_messageOf(error)));
    }
  }

  void clearAuditSearch() {
    _auditSearch = null;
    loadAuditLogs(page: 1);
  }

  // ── 4. Withdrawals ────────────────────────────────────────────────────────

  Future<void> loadWithdrawals({
    String? status,
    String? search,
    String? dateFrom,
    String? dateTo,
    int page = 1,
  }) async {
    _withdrawalsStatus = status;
    _withdrawalsSearch = search;
    _withdrawalsDateFrom = dateFrom;
    _withdrawalsDateTo = dateTo;
    _withdrawalsPage = page;

    _emitIfOpen(const WithdrawalsLoading());
    try {
      final result = await _repository.getWithdrawals(
        status: _withdrawalsStatus,
        search: _withdrawalsSearch,
        dateFrom: _withdrawalsDateFrom,
        dateTo: _withdrawalsDateTo,
        page: _withdrawalsPage,
        perPage: 20,
      );
      if (result.isEmpty) {
        _emitIfOpen(WithdrawalsEmpty(status: _withdrawalsStatus));
      } else {
        _emitIfOpen(WithdrawalsLoaded(result, status: _withdrawalsStatus));
      }
    } catch (error) {
      _emitIfOpen(WithdrawalError(_messageOf(error)));
    }
  }

  Future<void> refreshWithdrawals() => loadWithdrawals(
        status: _withdrawalsStatus,
        search: _withdrawalsSearch,
        dateFrom: _withdrawalsDateFrom,
        dateTo: _withdrawalsDateTo,
        page: _withdrawalsPage,
      );

  Future<void> loadWithdrawalDetails(int id) async {
    _emitIfOpen(const WithdrawalDetailsLoading());
    try {
      final withdrawal = await _repository.getWithdrawalDetails(id);
      _emitIfOpen(WithdrawalDetailsLoaded(withdrawal));
    } catch (error) {
      _emitIfOpen(WithdrawalError(_messageOf(error)));
    }
  }

  /// يعالج طلب السحب ثم يعيد جلب التفاصيل من الخادم.
  /// يُرفض الاستدعاء إن كانت هناك عملية جارية بالفعل (منع الضغط المتكرر).
  Future<void> processWithdrawal(
    int id, {
    required String action,
    String? rejectionReason,
  }) async {
    final current = state;
    if (current is WithdrawalDetailsLoaded) {
      if (current.isProcessing) return;
      _emitIfOpen(WithdrawalDetailsLoaded(current.withdrawal, isProcessing: true));
    }

    try {
      final result = await _repository.processWithdrawal(
        id,
        action: action,
        rejectionReason: rejectionReason,
      );
      _emitIfOpen(WithdrawalProcessSuccess(result.message));
      await loadWithdrawalDetails(id);
    } catch (error) {
      _emitIfOpen(WithdrawalError(_messageOf(error)));
      // إعادة عرض التفاصيل المحدّثة من الخادم حتى بعد الفشل،
      // لأن 422 قد يعني أن الطلب عولج مسبقاً وتغيّرت حالته فعلياً.
      await loadWithdrawalDetails(id);
    }
  }

  // ── 5. Recharges ──────────────────────────────────────────────────────────

  Future<void> loadRecharges({
    String? status,
    String? search,
    String? dateFrom,
    String? dateTo,
    int page = 1,
  }) async {
    _rechargesStatus = status;
    _rechargesSearch = search;
    _rechargesDateFrom = dateFrom;
    _rechargesDateTo = dateTo;
    _rechargesPage = page;

    _emitIfOpen(const RechargesLoading());
    try {
      final result = await _repository.getRecharges(
        status: _rechargesStatus,
        search: _rechargesSearch,
        dateFrom: _rechargesDateFrom,
        dateTo: _rechargesDateTo,
        page: _rechargesPage,
        perPage: 20,
      );
      if (result.isEmpty) {
        _emitIfOpen(RechargesEmpty(status: _rechargesStatus));
      } else {
        _emitIfOpen(RechargesLoaded(result, status: _rechargesStatus));
      }
    } catch (error) {
      _emitIfOpen(RechargeError(_messageOf(error)));
    }
  }

  Future<void> refreshRecharges() => loadRecharges(
        status: _rechargesStatus,
        search: _rechargesSearch,
        dateFrom: _rechargesDateFrom,
        dateTo: _rechargesDateTo,
        page: _rechargesPage,
      );

  Future<void> loadRechargeDetails(int id) async {
    _emitIfOpen(const RechargeDetailsLoading());
    try {
      final recharge = await _repository.getRechargeDetails(id);
      _emitIfOpen(RechargeDetailsLoaded(recharge));
    } catch (error) {
      _emitIfOpen(RechargeError(_messageOf(error)));
    }
  }

  Future<void> processRecharge(
    int id, {
    required String action,
    String? reason,
  }) async {
    final current = state;
    if (current is RechargeDetailsLoaded) {
      if (current.isProcessing) return;
      _emitIfOpen(RechargeDetailsLoaded(current.recharge, isProcessing: true));
    }

    try {
      final result =
          await _repository.processRecharge(id, action: action, reason: reason);
      _emitIfOpen(RechargeProcessSuccess(result.message));
      await loadRechargeDetails(id);
    } catch (error) {
      _emitIfOpen(RechargeError(_messageOf(error)));
      await loadRechargeDetails(id);
    }
  }

  // ── 6. Escrows ────────────────────────────────────────────────────────────

  Future<void> loadEscrows() async {
    _emitIfOpen(const EscrowsLoading());
    try {
      final escrows = await _repository.getEscrows();
      final summary = await _loadSummaryQuietly();
      _emitIfOpen(EscrowsLoaded(escrows, summary: summary));
    } catch (error) {
      _emitIfOpen(EscrowError(_messageOf(error)));
    }
  }

  /// يجلب الملخّص كمعلومة مساندة؛ فشله لا يُسقِط شاشة الأمانات.
  Future<FinancialSummaryModel?> _loadSummaryQuietly() async {
    try {
      return await _repository.getFinancialSummary();
    } catch (_) {
      return null;
    }
  }

  /// تُنفَّذ فقط بعد تأكيد المستخدم في الواجهة.
  Future<void> releaseEscrows() async {
    final current = state;
    if (current is EscrowsLoaded) {
      if (current.isReleasing) return;
      _emitIfOpen(current.copyWith(isReleasing: true));
    }

    try {
      final result = await _repository.releaseEscrows();
      _emitIfOpen(EscrowReleaseSuccess(result.message));
      await loadEscrows();
    } catch (error) {
      _emitIfOpen(EscrowError(_messageOf(error)));
      await loadEscrows();
    }
  }

  // ── 7. Disputes ───────────────────────────────────────────────────────────

  Future<void> loadDisputes({String? status, int page = 1}) async {
    _disputesStatus = status;
    _disputesPage = page;

    _emitIfOpen(const DisputesLoading());
    try {
      final result = await _repository.getDisputes(
        status: _disputesStatus,
        page: _disputesPage,
        perPage: 20,
      );
      if (result.isEmpty) {
        _emitIfOpen(DisputesEmpty(status: _disputesStatus));
      } else {
        _emitIfOpen(DisputesLoaded(result, status: _disputesStatus));
      }
    } catch (error) {
      _emitIfOpen(DisputeError(_messageOf(error)));
    }
  }

  Future<void> refreshDisputes() =>
      loadDisputes(status: _disputesStatus, page: _disputesPage);

  Future<void> loadDisputeDetails(int id) async {
    _emitIfOpen(const DisputeDetailsLoading());
    try {
      final dispute = await _repository.getDisputeDetails(id);
      _emitIfOpen(DisputeDetailsLoaded(dispute));
    } catch (error) {
      _emitIfOpen(DisputeError(_messageOf(error)));
    }
  }

  Future<void> resolveDispute(
    int disputeId, {
    required String resolution,
    String? notes,
  }) async {
    final current = state;
    if (current is DisputeDetailsLoaded) {
      if (current.isResolving) return;
      _emitIfOpen(DisputeDetailsLoaded(current.dispute, isResolving: true));
    }

    try {
      final result = await _repository.resolveDispute(
        disputeId,
        resolution: resolution,
        notes: notes,
      );
      _emitIfOpen(DisputeResolved(result.message));
      await loadDisputeDetails(disputeId);
    } catch (error) {
      _emitIfOpen(DisputeError(_messageOf(error)));
      await loadDisputeDetails(disputeId);
    }
  }

  // ── 8. Settlements ────────────────────────────────────────────────────────

  Future<void> loadPendingSettlements({int page = 1}) async {
    _settlementsPage = page;
    _emitIfOpen(const SettlementsLoading());
    try {
      final result = await _repository.getPendingSettlements(
        page: _settlementsPage,
        perPage: 15,
      );
      if (result.isEmpty) {
        _emitIfOpen(const SettlementsEmpty());
      } else {
        _emitIfOpen(SettlementsLoaded(result));
      }
    } catch (error) {
      _emitIfOpen(SettlementError(_messageOf(error)));
    }
  }

  /// لا تُستدعى عند فتح الشاشة — فقط بعد تأكيد المستخدم صراحةً.
  Future<void> settleMonthly(int contractId) async {
    final current = state;
    if (current is SettlementsLoaded) {
      if (current.processingContractId != null) return;
      _emitIfOpen(current.copyWith(processingContractId: contractId));
    }

    try {
      final result = await _repository.settleMonthly(contractId);
      _emitIfOpen(
        SettlementSuccess(
          'تمت تسوية العقد ${result.contractNumber} بنجاح.',
          result,
        ),
      );
      await loadPendingSettlements(page: _settlementsPage);
    } catch (error) {
      _emitIfOpen(SettlementError(_messageOf(error)));
      await loadPendingSettlements(page: _settlementsPage);
    }
  }

  // ── 9. Contract Termination ───────────────────────────────────────────────

  Future<void> loadTerminationPreview(
    int contractId, {
    required String terminatedBy,
    required bool isArbitraryParent,
  }) async {
    _emitIfOpen(const PreviewLoading());
    try {
      final preview = await _repository.getTerminationPreview(
        contractId,
        terminatedBy: terminatedBy,
        isArbitraryParent: isArbitraryParent,
      );
      _emitIfOpen(
        TerminationPreviewLoaded(
          preview,
          terminatedBy: terminatedBy,
          isArbitraryParent: isArbitraryParent,
        ),
      );
    } catch (error) {
      _emitIfOpen(PreviewError(_messageOf(error)));
    }
  }

  /// ينفّذ الإنهاء الفعلي عبر Endpoint منفصل عن المعاينة.
  Future<void> terminateMidMonth(int contractId) async {
    final current = state;
    if (current is! TerminationPreviewLoaded || current.isExecuting) return;

    _emitIfOpen(current.copyWith(isExecuting: true));
    try {
      final result = await _repository.terminateMidMonth(
        contractId,
        terminatedBy: current.terminatedBy,
        isArbitraryParent: current.isArbitraryParent,
      );
      _emitIfOpen(TerminationExecuted(result.message));
      await loadTerminationPreview(
        contractId,
        terminatedBy: current.terminatedBy,
        isArbitraryParent: current.isArbitraryParent,
      );
    } catch (error) {
      _emitIfOpen(PreviewError(_messageOf(error)));
      _emitIfOpen(current.copyWith(isExecuting: false));
    }
  }

  // ── 10. Trip Cancellation ─────────────────────────────────────────────────

  Future<void> loadTripCancellationPreview(
    int tripId, {
    required String cancelledBy,
  }) async {
    _emitIfOpen(const PreviewLoading());
    try {
      final preview = await _repository.getTripCancellationPreview(
        tripId,
        cancelledBy: cancelledBy,
      );
      _emitIfOpen(
        TripCancellationPreviewLoaded(preview, cancelledBy: cancelledBy),
      );
    } catch (error) {
      _emitIfOpen(PreviewError(_messageOf(error)));
    }
  }

  Future<void> cancelTripWithMatrix(int tripId) async {
    final current = state;
    if (current is! TripCancellationPreviewLoaded || current.isExecuting) return;

    _emitIfOpen(current.copyWith(isExecuting: true));
    try {
      final result = await _repository.cancelTripWithMatrix(
        tripId,
        cancelledBy: current.cancelledBy,
      );
      _emitIfOpen(TripCancellationExecuted(result.message));
      await loadTripCancellationPreview(
        tripId,
        cancelledBy: current.cancelledBy,
      );
    } catch (error) {
      _emitIfOpen(PreviewError(_messageOf(error)));
      _emitIfOpen(current.copyWith(isExecuting: false));
    }
  }

  // ── 11. Solvency ──────────────────────────────────────────────────────────

  Future<void> loadSolvencyCheck() async {
    _emitIfOpen(const SolvencyLoading());
    try {
      final solvency = await _repository.getSolvencyCheck();
      _emitIfOpen(SolvencyLoaded(solvency));
    } catch (error) {
      _emitIfOpen(SolvencyError(_messageOf(error)));
    }
  }

  // ── 12. Invoices ──────────────────────────────────────────────────────────

  Future<void> loadInvoices({String? status, int page = 1}) async {
    _invoicesStatus = status;
    _invoicesPage = page;

    _emitIfOpen(const InvoicesLoading());
    try {
      final result = await _repository.getInvoices(
        status: _invoicesStatus,
        page: _invoicesPage,
        perPage: 20,
      );
      if (result.isEmpty) {
        _emitIfOpen(InvoicesEmpty(status: _invoicesStatus));
      } else {
        _emitIfOpen(InvoicesLoaded(result, status: _invoicesStatus));
      }
    } catch (error) {
      _emitIfOpen(InvoicesError(_messageOf(error)));
    }
  }

  Future<void> loadInvoiceDetails(int id) async {
    _emitIfOpen(const InvoiceDetailsLoading());
    try {
      final invoice = await _repository.getInvoiceDetails(id);
      _emitIfOpen(InvoiceDetailsLoaded(invoice));
    } catch (error) {
      _emitIfOpen(InvoicesError(_messageOf(error)));
    }
  }

  // ── 13. Pricing Settings ──────────────────────────────────────────────────

  Future<void> loadPricingSettings() async {
    _emitIfOpen(const PricingSettingsLoading());
    try {
      final settings = await _repository.getPricingSettings();
      _emitIfOpen(PricingSettingsLoaded(settings, isExisting: true));
    } catch (error) {
      _emitIfOpen(PricingSettingsError(_messageOf(error)));
    }
  }

  Future<void> createPricingSettings(PricingSettingsModel settings) async {
    final current = state;
    if (current is PricingSettingsLoaded) {
      if (current.isSaving) return;
      _emitIfOpen(current.copyWith(isSaving: true));
    }

    try {
      final result = await _repository.createPricingSettings(settings);
      _emitIfOpen(PricingSettingsSaveSuccess(result.message));
      await loadPricingSettings();
    } catch (error) {
      _emitIfOpen(PricingSettingsError(_messageOf(error)));
      if (current is PricingSettingsLoaded) {
        _emitIfOpen(current.copyWith(isSaving: false));
      }
    }
  }

  Future<void> updatePricingSettings(PricingSettingsModel settings) async {
    final current = state;
    if (current is PricingSettingsLoaded) {
      if (current.isSaving) return;
      _emitIfOpen(current.copyWith(isSaving: true));
    }

    try {
      final result = await _repository.updatePricingSettings(settings);
      _emitIfOpen(PricingSettingsSaveSuccess(result.message));
      await loadPricingSettings();
    } catch (error) {
      _emitIfOpen(PricingSettingsError(_messageOf(error)));
      if (current is PricingSettingsLoaded) {
        _emitIfOpen(current.copyWith(isSaving: false));
      }
    }
  }

  // ── 14. Payment Methods ───────────────────────────────────────────────────

  Future<void> loadPaymentMethods() async {
    _emitIfOpen(const PaymentMethodsLoading());
    try {
      final methods = await _repository.getPaymentMethods();
      _emitIfOpen(PaymentMethodsLoaded(methods));
    } catch (error) {
      _emitIfOpen(PaymentMethodsError(_messageOf(error)));
    }
  }

  Future<void> createPaymentMethod(PaymentMethodModel method) async {
    try {
      final result = await _repository.createPaymentMethod(method);
      _emitIfOpen(PaymentMethodActionSuccess(result.message));
      await loadPaymentMethods();
    } catch (error) {
      _emitIfOpen(PaymentMethodsError(_messageOf(error)));
    }
  }

  Future<void> updatePaymentMethod(int id, PaymentMethodModel method) async {
    try {
      final result = await _repository.updatePaymentMethod(id, method);
      _emitIfOpen(PaymentMethodActionSuccess(result.message));
      await loadPaymentMethods();
    } catch (error) {
      _emitIfOpen(PaymentMethodsError(_messageOf(error)));
    }
  }

  Future<void> togglePaymentMethodStatus(int id) async {
    final current = state;
    if (current is PaymentMethodsLoaded) {
      _emitIfOpen(current.copyWith(actionMethodId: id));
    }

    try {
      final result = await _repository.togglePaymentMethodStatus(id);
      _emitIfOpen(PaymentMethodActionSuccess(result.message));
      await loadPaymentMethods();
    } catch (error) {
      _emitIfOpen(PaymentMethodsError(_messageOf(error)));
      if (current is PaymentMethodsLoaded) {
        _emitIfOpen(current.copyWith(clearAction: true));
      }
    }
  }

  Future<void> deletePaymentMethod(int id) async {
    final current = state;
    if (current is PaymentMethodsLoaded) {
      _emitIfOpen(current.copyWith(actionMethodId: id));
    }

    try {
      final result = await _repository.deletePaymentMethod(id);
      _emitIfOpen(PaymentMethodActionSuccess(result.message));
      await loadPaymentMethods();
    } catch (error) {
      _emitIfOpen(PaymentMethodsError(_messageOf(error)));
      if (current is PaymentMethodsLoaded) {
        _emitIfOpen(current.copyWith(clearAction: true));
      }
    }
  }
}
