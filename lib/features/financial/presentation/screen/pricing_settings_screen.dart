import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../data/models/pricing_settings_model.dart';
import '../../logic/cubit/financial_cubit.dart';
import '../../logic/state/financial_state.dart';
import '../../../../core/widgets/admin_ui.dart';

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

  final _discountOneChildController = TextEditingController();
  final _discountTwoChildrenController = TextEditingController();
  final _discountThreePlusChildrenController = TextEditingController();
  final _platformCommissionRateController = TextEditingController();
  final _pricePerKmAcController = TextEditingController();
  final _pricePerKmNonAcController = TextEditingController();

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
  }

  String? _validateNumeric(String? value, String fieldName) {
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
                                  hint: 'مثال: 0.10',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildNumberFormField(
                                  controller: _discountTwoChildrenController,
                                  label: 'خصم طفلين',
                                  hint: 'مثال: 0.15',
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
                                  label: 'خصم ثلاثة أطفال أو أكثر',
                                  hint: 'مثال: 0.20',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildNumberFormField(
                                  controller:
                                      _platformCommissionRateController,
                                  label: 'نسبة عمولة المنصة (%)',
                                  hint: 'مثال: 15.0',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
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
                                  label: 'سعر الكيلومتر - مكيف (د.ل)',
                                  hint: 'مثال: 2.50',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildNumberFormField(
                                  controller: _pricePerKmNonAcController,
                                  label: 'سعر الكيلومتر - غير مكيف (د.ل)',
                                  hint: 'مثال: 2.00',
                                ),
                              ),
                            ],
                          ),
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

  Widget _buildNumberFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
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
      validator: (val) => _validateNumeric(val, label),
    );
  }
}
