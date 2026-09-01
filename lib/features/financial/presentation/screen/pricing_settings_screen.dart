import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../../../core/widgets/admin_ui.dart';
import '../../data/models/location_change_fee_tier_model.dart';
import '../../data/models/pricing_settings_model.dart';
import '../../logic/cubit/financial_cubit.dart';
import '../../logic/state/financial_state.dart';

/// شاشة إعدادات التسعير الموحدة داخل الإدارة المالية.
/// GET|POST|PUT /api/admin/financial/pricing-settings
class PricingSettingsScreen extends StatelessWidget {
  const PricingSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FinancialCubit>(
      create: (_) => sl<FinancialCubit>()..loadPricingSettings(),
      child: const _PricingSettingsView(),
    );
  }
}

class _PricingSettingsView extends StatefulWidget {
  const _PricingSettingsView();

  @override
  State<_PricingSettingsView> createState() => _PricingSettingsViewState();
}

class _PricingSettingsViewState extends State<_PricingSettingsView> {
  final _formKey = GlobalKey<FormState>();

  // الحقول القديمة الستة (أساسية وثابتة)
  final _discountOneChildController = TextEditingController();
  final _discountTwoChildrenController = TextEditingController();
  final _discountThreePlusChildrenController = TextEditingController();
  final _platformCommissionRateController = TextEditingController();
  final _pricePerKmAcController = TextEditingController();
  final _pricePerKmNonAcController = TextEditingController();

  // الحقول الجديدة لرسوم تغيير الموقع (اختيارية في Validation لضمان التوافقية)
  final _locationChangeFeeController = TextEditingController();
  final _locationChangeFeeUnder2KmController = TextEditingController();
  final _locationChangeFee2To6KmController = TextEditingController();
  final _locationChangeFee6To10KmController = TextEditingController();
  final _maxLocationChangeDistanceKmController = TextEditingController();

  List<LocationChangeFeeTierModel>? _currentTiers;
  String _currency = 'د.ل';

  bool _isExisting = true;
  bool _initialized = false;

  @override
  void dispose() {
    _discountOneChildController.dispose();
    _discountTwoChildrenController.dispose();
    _discountThreePlusChildrenController.dispose();
    _platformCommissionRateController.dispose();
    _pricePerKmAcController.dispose();
    _pricePerKmNonAcController.dispose();
    _locationChangeFeeController.dispose();
    _locationChangeFeeUnder2KmController.dispose();
    _locationChangeFee2To6KmController.dispose();
    _locationChangeFee6To10KmController.dispose();
    _maxLocationChangeDistanceKmController.dispose();
    super.dispose();
  }

  void _populateForm(PricingSettingsModel settings, {required bool isExisting}) {
    _isExisting = isExisting;
    _discountOneChildController.text = settings.discountOneChild.toString();
    _discountTwoChildrenController.text = settings.discountTwoChildren.toString();
    _discountThreePlusChildrenController.text =
        settings.discountThreePlusChildren.toString();
    _platformCommissionRateController.text =
        settings.platformCommissionRate.toString();
    _pricePerKmAcController.text = settings.pricePerKmAc.toString();
    _pricePerKmNonAcController.text = settings.pricePerKmNonAc.toString();

    // تعبئة الحقول الجديدة إن وجدت
    if (settings.locationChangeFee != null) {
      _locationChangeFeeController.text = settings.locationChangeFee.toString();
    }
    if (settings.locationChangeFeeUnder2Km != null) {
      _locationChangeFeeUnder2KmController.text =
          settings.locationChangeFeeUnder2Km.toString();
    }
    if (settings.locationChangeFee2To6Km != null) {
      _locationChangeFee2To6KmController.text =
          settings.locationChangeFee2To6Km.toString();
    }
    if (settings.locationChangeFee6To10Km != null) {
      _locationChangeFee6To10KmController.text =
          settings.locationChangeFee6To10Km.toString();
    }
    if (settings.maxLocationChangeDistanceKm != null) {
      _maxLocationChangeDistanceKmController.text =
          settings.maxLocationChangeDistanceKm.toString();
    }

    _currentTiers = settings.locationChangeFeeTiers;
    if (settings.currency != null && settings.currency!.trim().isNotEmpty) {
      _currency = settings.currency!;
    }
  }

  String? _validateNumeric(String? value, String fieldName, {bool isOptional = false}) {
    if (isOptional && (value == null || value.trim().isEmpty)) {
      return null;
    }
    if (value == null || value.trim().isEmpty) {
      return 'حقل $fieldName مطلوب.';
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null) {
      return 'يرجى إدخال رقم صحيح أو عشري مقبول في $fieldName.';
    }
    return null;
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final settings = PricingSettingsModel(
      discountOneChild:
          double.parse(_discountOneChildController.text.trim()),
      discountTwoChildren:
          double.parse(_discountTwoChildrenController.text.trim()),
      discountThreePlusChildren:
          double.parse(_discountThreePlusChildrenController.text.trim()),
      platformCommissionRate:
          double.parse(_platformCommissionRateController.text.trim()),
      pricePerKmAc: double.parse(_pricePerKmAcController.text.trim()),
      pricePerKmNonAc:
          double.parse(_pricePerKmNonAcController.text.trim()),

      // الحقول الجديدة الحساسة للتغيير
      locationChangeFee: _locationChangeFeeController.text.trim().isNotEmpty
          ? double.tryParse(_locationChangeFeeController.text.trim())
          : null,
      locationChangeFeeUnder2Km:
          _locationChangeFeeUnder2KmController.text.trim().isNotEmpty
              ? double.tryParse(_locationChangeFeeUnder2KmController.text.trim())
              : null,
      locationChangeFee2To6Km:
          _locationChangeFee2To6KmController.text.trim().isNotEmpty
              ? double.tryParse(_locationChangeFee2To6KmController.text.trim())
              : null,
      locationChangeFee6To10Km:
          _locationChangeFee6To10KmController.text.trim().isNotEmpty
              ? double.tryParse(_locationChangeFee6To10KmController.text.trim())
              : null,
      maxLocationChangeDistanceKm:
          _maxLocationChangeDistanceKmController.text.trim().isNotEmpty
              ? double.tryParse(
                  _maxLocationChangeDistanceKmController.text.trim())
              : null,
      locationChangeFeeTiers: _currentTiers,
      currency: _currency,
    );

    final cubit = context.read<FinancialCubit>();
    if (_isExisting) {
      cubit.updatePricingSettings(settings);
    } else {
      cubit.createPricingSettings(settings);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إعدادات التسعير الموحدة'),
          actions: [
            IconButton(
              tooltip: 'تحديث البيانات',
              onPressed: () {
                _initialized = false;
                context.read<FinancialCubit>().loadPricingSettings();
              },
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        body: BlocConsumer<FinancialCubit, FinancialState>(
          listener: (context, state) {
            if (state is PricingSettingsSaveSuccess) {
              showAdminSnackBar(context, state.message, isError: false);
            } else if (state is PricingSettingsError) {
              showAdminSnackBar(context, state.message, isError: true);
            } else if (state is PricingSettingsLoaded) {
              if (!_initialized) {
                _populateForm(state.settings, isExisting: state.isExisting);
                _initialized = true;
              }
            }
          },
          builder: (context, state) {
            if (state is PricingSettingsLoading || state is FinancialInitial) {
              return const AdminLoadingView(
                message: 'جارٍ جلب إعدادات التسعير من الخادم...',
              );
            }

            if (state is PricingSettingsError && !_initialized) {
              return AdminErrorView(
                message: state.message,
                onRetry: () =>
                    context.read<FinancialCubit>().loadPricingSettings(),
              );
            }

            final isSaving =
                state is PricingSettingsLoaded && state.isSaving;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // القسم 1: خصومات الأطفال وعمولة المنصة
                    AdminPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'خصومات الأطفال وعمولة المنصة',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: context.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildNumberFormField(
                                  controller: _discountOneChildController,
                                  label: 'خصم طفل واحد',
                                  hint: 'مثال: 0',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildNumberFormField(
                                  controller: _discountTwoChildrenController,
                                  label: 'خصم طفلين (%)',
                                  hint: 'مثال: 10',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildNumberFormField(
                                  controller:
                                      _discountThreePlusChildrenController,
                                  label: 'خصم ثلاثة أطفال أو أكثر (%)',
                                  hint: 'مثال: 15',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildNumberFormField(
                                  controller:
                                      _platformCommissionRateController,
                                  label: 'نسبة عمولة المنصة (%)',
                                  hint: 'مثال: 8.0',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // القسم 2: تسعير الكيلومتر
                    AdminPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'تسعير الكيلومتر (تكييف / بدون تكييف)',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: context.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildNumberFormField(
                                  controller: _pricePerKmAcController,
                                  label: 'سعر الكيلومتر - مكيف ($nullSafeCurrency)',
                                  hint: 'مثال: 1.00',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildNumberFormField(
                                  controller: _pricePerKmNonAcController,
                                  label: 'سعر الكيلومتر - غير مكيف ($nullSafeCurrency)',
                                  hint: 'مثال: 0.50',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // القسم 3 (جديد): رسوم وتكلفة تغيير الموقع
                    AdminPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'رسوم وتكلفة تغيير الموقع',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: context.textPrimary,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: context.infoBg,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: context.infoBorder),
                                ),
                                child: Text(
                                  'العملة: $nullSafeCurrency',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: context.infoColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildNumberFormField(
                                  controller: _locationChangeFeeController,
                                  label: 'رسوم تغيير الموقع الإجمالية ($nullSafeCurrency)',
                                  hint: 'مثال: 5.00',
                                  isOptional: true,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildNumberFormField(
                                  controller: _maxLocationChangeDistanceKmController,
                                  label: 'الحد الأقصى لمسافة تغيير الموقع (كم)',
                                  hint: 'مثال: 10',
                                  isOptional: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildNumberFormField(
                                  controller: _locationChangeFeeUnder2KmController,
                                  label: 'رسوم أقل من 2 كم ($nullSafeCurrency)',
                                  hint: 'مثال: 5.00',
                                  isOptional: true,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildNumberFormField(
                                  controller: _locationChangeFee2To6KmController,
                                  label: 'رسوم من 2 إلى 6 كم ($nullSafeCurrency)',
                                  hint: 'مثال: 10.00',
                                  isOptional: true,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildNumberFormField(
                                  controller: _locationChangeFee6To10KmController,
                                  label: 'رسوم أكثر من 6 إلى 10 كم ($nullSafeCurrency)',
                                  hint: 'مثال: 15.00',
                                  isOptional: true,
                                ),
                              ),
                            ],
                          ),

                          // عرض الشرائح الديناميكية (Dynamic Tiers) من الخادم إن توفرت
                          if (_currentTiers != null && _currentTiers!.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            const Divider(),
                            const SizedBox(height: 12),
                            Text(
                              'شرائح المسافات والرسوم المعتمدة (من الخادم):',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: context.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 12,
                              runSpacing: 10,
                              children: _currentTiers!.map((tier) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: context.surfaceVariant,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: context.borderSoft),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tier.label ?? tier.tier ?? 'شريحة مسافة',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: context.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'المسافة: ${tier.minKm ?? 0} كم ⬅ ${tier.maxKm ?? 0} كم',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: context.textMuted,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'الرسوم: ${tier.fee ?? 0} $nullSafeCurrency',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: context.primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton.icon(
                        onPressed: isSaving ? null : _onSave,
                        icon: isSaving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save_rounded, size: 18),
                        label: Text(
                          isSaving
                              ? 'جارٍ الحفظ...'
                              : (_isExisting ? 'تحديث الإعدادات (PUT)' : 'إنشاء الإعدادات (POST)'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String get nullSafeCurrency => _currency.trim().isNotEmpty ? _currency : 'د.ل';

  Widget _buildNumberFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isOptional = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: TextStyle(fontSize: 13, color: context.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        isDense: true,
      ),
      validator: (val) => _validateNumeric(val, label, isOptional: isOptional),
    );
  }
}
