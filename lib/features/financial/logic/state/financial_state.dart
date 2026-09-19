import '../../data/models/escrow_summary_model.dart';
import '../../data/models/financial_invoice_model.dart';
import '../../data/models/financial_summary_model.dart';
import '../../data/models/ledger_entry_model.dart';
import '../../../../core/models/paginated_result.dart';
import '../../../../core/models/pagination_meta_model.dart';
import '../../data/models/payment_method_model.dart';
import '../../data/models/pricing_settings_model.dart';
import '../../data/models/recharge_model.dart';
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

// ── Previews (Trip Cancellation) ─────────────────────────────────────────────

class PreviewLoading extends FinancialState {
  const PreviewLoading();
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

// ── Pricing Settings ────────────────────────────────────────────────────────

class PricingSettingsLoading extends FinancialState {
  const PricingSettingsLoading();
}

class PricingSettingsLoaded extends FinancialState {
  final PricingSettingsModel settings;
  final bool isSaving;
  final bool isExisting;

  const PricingSettingsLoaded(
    this.settings, {
    this.isSaving = false,
    this.isExisting = true,
  });

  PricingSettingsLoaded copyWith({
    PricingSettingsModel? settings,
    bool? isSaving,
    bool? isExisting,
  }) {
    return PricingSettingsLoaded(
      settings ?? this.settings,
      isSaving: isSaving ?? this.isSaving,
      isExisting: isExisting ?? this.isExisting,
    );
  }
}

class PricingSettingsSaveSuccess extends FinancialState {
  final String message;
  const PricingSettingsSaveSuccess(this.message);
}

class PricingSettingsError extends FinancialState {
  final String message;
  const PricingSettingsError(this.message);
}

// ── Payment Methods ─────────────────────────────────────────────────────────

class PaymentMethodsLoading extends FinancialState {
  const PaymentMethodsLoading();
}

class PaymentMethodsLoaded extends FinancialState {
  final List<PaymentMethodModel> methods;
  final PaginationMetaModel meta;
  final int? actionMethodId;

  const PaymentMethodsLoaded(
    this.methods, {
    this.meta = const PaginationMetaModel(),
    this.actionMethodId,
  });

  PaymentMethodsLoaded copyWith({
    List<PaymentMethodModel>? methods,
    PaginationMetaModel? meta,
    int? actionMethodId,
    bool clearAction = false,
  }) {
    return PaymentMethodsLoaded(
      methods ?? this.methods,
      meta: meta ?? this.meta,
      actionMethodId:
          clearAction ? null : (actionMethodId ?? this.actionMethodId),
    );
  }
}

class PaymentMethodActionSuccess extends FinancialState {
  final String message;
  const PaymentMethodActionSuccess(this.message);
}

class PaymentMethodsError extends FinancialState {
  final String message;
  const PaymentMethodsError(this.message);
}
