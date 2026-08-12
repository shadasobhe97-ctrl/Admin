import '../../data/models/escrow_summary_model.dart';
import '../../data/models/financial_audit_log_model.dart';
import '../../data/models/financial_dispute_model.dart';
import '../../data/models/financial_invoice_model.dart';
import '../../data/models/financial_summary_model.dart';
import '../../data/models/ledger_entry_model.dart';
import '../../../../core/models/paginated_result.dart';
import '../../data/models/recharge_model.dart';
import '../../data/models/settlement_contract_model.dart';
import '../../data/models/solvency_check_model.dart';
import '../../data/models/termination_preview_model.dart';
import '../../data/models/trip_cancellation_preview_model.dart';
import '../../data/models/withdrawal_model.dart';

abstract class FinancialState {
  const FinancialState();
}

class FinancialInitial extends FinancialState {
  const FinancialInitial();
}

// ── Dashboard Summary ────────────────────────────────────────────────────────

class FinancialLoading extends FinancialState {
  const FinancialLoading();
}

class FinancialLoaded extends FinancialState {
  final FinancialSummaryModel summary;
  const FinancialLoaded(this.summary);
}

class FinancialError extends FinancialState {
  final String message;
  const FinancialError(this.message);
}

// ── Ledger ───────────────────────────────────────────────────────────────────

class LedgerLoading extends FinancialState {
  const LedgerLoading();
}

class LedgerLoaded extends FinancialState {
  final PaginatedResult<LedgerEntryModel> result;
  final LedgerFilters filters;
  const LedgerLoaded(this.result, this.filters);
}

class LedgerEmpty extends FinancialState {
  final LedgerFilters filters;
  const LedgerEmpty(this.filters);
}

class LedgerError extends FinancialState {
  final String message;
  const LedgerError(this.message);
}

// ── Audit Logs ───────────────────────────────────────────────────────────────

class AuditLogsLoading extends FinancialState {
  const AuditLogsLoading();
}

class AuditLogsLoaded extends FinancialState {
  final PaginatedResult<FinancialAuditLogModel> result;
  final String? search;
  const AuditLogsLoaded(this.result, {this.search});
}

class AuditLogsEmpty extends FinancialState {
  final String? search;
  const AuditLogsEmpty({this.search});
}

class AuditLogsError extends FinancialState {
  final String message;
  const AuditLogsError(this.message);
}

// ── Withdrawals ──────────────────────────────────────────────────────────────

class WithdrawalsLoading extends FinancialState {
  const WithdrawalsLoading();
}

class WithdrawalsLoaded extends FinancialState {
  final PaginatedResult<WithdrawalModel> result;
  final String? status;
  const WithdrawalsLoaded(this.result, {this.status});
}

class WithdrawalsEmpty extends FinancialState {
  final String? status;
  const WithdrawalsEmpty({this.status});
}

class WithdrawalDetailsLoading extends FinancialState {
  const WithdrawalDetailsLoading();
}

class WithdrawalDetailsLoaded extends FinancialState {
  final WithdrawalModel withdrawal;

  /// يمنع الضغط المتكرر على أزرار المعالجة أثناء تنفيذ العملية.
  final bool isProcessing;

  const WithdrawalDetailsLoaded(this.withdrawal, {this.isProcessing = false});
}

class WithdrawalProcessSuccess extends FinancialState {
  final String message;
  const WithdrawalProcessSuccess(this.message);
}

class WithdrawalError extends FinancialState {
  final String message;
  const WithdrawalError(this.message);
}

// ── Recharges ────────────────────────────────────────────────────────────────

class RechargesLoading extends FinancialState {
  const RechargesLoading();
}

class RechargesLoaded extends FinancialState {
  final PaginatedResult<RechargeModel> result;
  final String? status;
  const RechargesLoaded(this.result, {this.status});
}

class RechargesEmpty extends FinancialState {
  final String? status;
  const RechargesEmpty({this.status});
}

class RechargeDetailsLoading extends FinancialState {
  const RechargeDetailsLoading();
}

class RechargeDetailsLoaded extends FinancialState {
  final RechargeModel recharge;
  final bool isProcessing;
  const RechargeDetailsLoaded(this.recharge, {this.isProcessing = false});
}

class RechargeProcessSuccess extends FinancialState {
  final String message;
  const RechargeProcessSuccess(this.message);
}

class RechargeError extends FinancialState {
  final String message;
  const RechargeError(this.message);
}

// ── Escrows ──────────────────────────────────────────────────────────────────

class EscrowsLoading extends FinancialState {
  const EscrowsLoading();
}

class EscrowsLoaded extends FinancialState {
  final EscrowSummaryModel escrows;
  final FinancialSummaryModel? summary;
  final bool isReleasing;

  const EscrowsLoaded(
    this.escrows, {
    this.summary,
    this.isReleasing = false,
  });

  EscrowsLoaded copyWith({
    EscrowSummaryModel? escrows,
    FinancialSummaryModel? summary,
    bool? isReleasing,
  }) {
    return EscrowsLoaded(
      escrows ?? this.escrows,
      summary: summary ?? this.summary,
      isReleasing: isReleasing ?? this.isReleasing,
    );
  }
}

class EscrowReleaseSuccess extends FinancialState {
  final String message;
  const EscrowReleaseSuccess(this.message);
}

class EscrowError extends FinancialState {
  final String message;
  const EscrowError(this.message);
}

// ── Disputes ─────────────────────────────────────────────────────────────────

class DisputesLoading extends FinancialState {
  const DisputesLoading();
}

class DisputesLoaded extends FinancialState {
  final PaginatedResult<FinancialDisputeModel> result;
  final String? status;
  const DisputesLoaded(this.result, {this.status});
}

class DisputesEmpty extends FinancialState {
  final String? status;
  const DisputesEmpty({this.status});
}

class DisputeDetailsLoading extends FinancialState {
  const DisputeDetailsLoading();
}

class DisputeDetailsLoaded extends FinancialState {
  final FinancialDisputeModel dispute;
  final bool isResolving;
  const DisputeDetailsLoaded(this.dispute, {this.isResolving = false});
}

class DisputeResolved extends FinancialState {
  final String message;
  const DisputeResolved(this.message);
}

class DisputeError extends FinancialState {
  final String message;
  const DisputeError(this.message);
}

// ── Settlements ──────────────────────────────────────────────────────────────

class SettlementsLoading extends FinancialState {
  const SettlementsLoading();
}

class SettlementsLoaded extends FinancialState {
  final PaginatedResult<SettlementContractModel> result;

  /// معرّف العقد الجاري تسويته حالياً (لتعطيل زره فقط دون بقية الصفحة).
  final int? processingContractId;

  const SettlementsLoaded(this.result, {this.processingContractId});

  SettlementsLoaded copyWith({
    PaginatedResult<SettlementContractModel>? result,
    int? processingContractId,
    bool clearProcessing = false,
  }) {
    return SettlementsLoaded(
      result ?? this.result,
      processingContractId:
          clearProcessing ? null : (processingContractId ?? this.processingContractId),
    );
  }
}

class SettlementsEmpty extends FinancialState {
  const SettlementsEmpty();
}

class SettlementSuccess extends FinancialState {
  final String message;
  final MonthlySettlementResultModel result;
  const SettlementSuccess(this.message, this.result);
}

class SettlementError extends FinancialState {
  final String message;
  const SettlementError(this.message);
}

// ── Previews (Termination / Trip Cancellation) ───────────────────────────────

class PreviewLoading extends FinancialState {
  const PreviewLoading();
}

class TerminationPreviewLoaded extends FinancialState {
  final TerminationPreviewModel preview;
  final String terminatedBy;
  final bool isArbitraryParent;
  final bool isExecuting;

  const TerminationPreviewLoaded(
    this.preview, {
    required this.terminatedBy,
    required this.isArbitraryParent,
    this.isExecuting = false,
  });

  TerminationPreviewLoaded copyWith({bool? isExecuting}) {
    return TerminationPreviewLoaded(
      preview,
      terminatedBy: terminatedBy,
      isArbitraryParent: isArbitraryParent,
      isExecuting: isExecuting ?? this.isExecuting,
    );
  }
}

class TerminationExecuted extends FinancialState {
  final String message;
  const TerminationExecuted(this.message);
}

class TripCancellationPreviewLoaded extends FinancialState {
  final TripCancellationPreviewModel preview;
  final String cancelledBy;
  final bool isExecuting;

  const TripCancellationPreviewLoaded(
    this.preview, {
    required this.cancelledBy,
    this.isExecuting = false,
  });

  TripCancellationPreviewLoaded copyWith({bool? isExecuting}) {
    return TripCancellationPreviewLoaded(
      preview,
      cancelledBy: cancelledBy,
      isExecuting: isExecuting ?? this.isExecuting,
    );
  }
}

class TripCancellationExecuted extends FinancialState {
  final String message;
  const TripCancellationExecuted(this.message);
}

class PreviewError extends FinancialState {
  final String message;
  const PreviewError(this.message);
}

// ── Solvency ─────────────────────────────────────────────────────────────────

class SolvencyLoading extends FinancialState {
  const SolvencyLoading();
}

class SolvencyLoaded extends FinancialState {
  final SolvencyCheckModel solvency;
  const SolvencyLoaded(this.solvency);
}

class SolvencyError extends FinancialState {
  final String message;
  const SolvencyError(this.message);
}

// ── Invoices ─────────────────────────────────────────────────────────────────

class InvoicesLoading extends FinancialState {
  const InvoicesLoading();
}

class InvoicesLoaded extends FinancialState {
  final PaginatedResult<FinancialInvoiceModel> result;
  final String? status;
  const InvoicesLoaded(this.result, {this.status});
}

class InvoicesEmpty extends FinancialState {
  final String? status;
  const InvoicesEmpty({this.status});
}

class InvoiceDetailsLoading extends FinancialState {
  const InvoiceDetailsLoading();
}

class InvoiceDetailsLoaded extends FinancialState {
  final FinancialInvoiceModel invoice;
  const InvoiceDetailsLoaded(this.invoice);
}

class InvoicesError extends FinancialState {
  final String message;
  const InvoicesError(this.message);
}
