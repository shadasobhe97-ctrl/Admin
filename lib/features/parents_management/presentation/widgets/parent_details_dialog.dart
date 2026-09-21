import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../../../core/widgets/remote_circle_avatar.dart';
import '../../data/models/parent_model.dart';
import '../../logic/cubit/parents_cubit.dart';
import '../../logic/cubit/parents_state.dart';

class ParentDetailsDialog extends StatefulWidget {
  final ParentModel initialParent;

  const ParentDetailsDialog({super.key, required this.initialParent});

  static void show(BuildContext context, ParentModel parent, {required ParentsCubit cubit}) {
    showDialog(
      context: context,
      builder: (dialogCtx) => BlocProvider.value(
        value: cubit..fetchParentDetails(parent.id),
        child: ParentDetailsDialog(initialParent: parent),
      ),
    );
  }

  @override
  State<ParentDetailsDialog> createState() => _ParentDetailsDialogState();
}

class _ParentDetailsDialogState extends State<ParentDetailsDialog> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocConsumer<ParentsCubit, ParentsState>(
        listener: (context, state) {
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: context.dangerColor,
              ),
            );
          }
          if (state.successMessage != null && state.successMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: context.successColor,
              ),
            );
          }
        },
        builder: (context, state) {
          final parent = state.selectedParent ?? widget.initialParent;
          final isLoadingDetails = state.isDetailsLoading;

          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: context.cardColor,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 680, maxHeight: 820),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dialog Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: context.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.family_restroom_rounded,
                                color: context.primaryColor, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'تفاصيل حساب ولي الأمر',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: context.textPrimary,
                                ),
                              ),
                              Text(
                                'معرف الحساب: #${parent.id}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  if (isLoadingDetails)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Banner Card
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: context.surfaceVariant,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: theme.dividerColor),
                              ),
                              child: Row(
                                children: [
                                  RemoteCircleAvatar(
                                    rawUrl: parent.avatarUrl,
                                    radius: 36,
                                    initials: parent.fullName.isNotEmpty
                                        ? parent.fullName[0]
                                        : 'و',
                                    foregroundColor: context.primaryColor,
                                    backgroundColor:
                                        context.primaryColor.withValues(alpha: 0.15),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          parent.fullName,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: context.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 6,
                                          children: [
                                            _buildStatusChip(
                                              label: parent.isActive ? 'حساب نشط' : 'حساب معطل',
                                              color: parent.isActive
                                                  ? context.successColor
                                                  : context.dangerColor,
                                              icon: parent.isActive
                                                  ? Icons.check_circle_rounded
                                                  : Icons.pause_circle_rounded,
                                            ),
                                            if (parent.isTrusted)
                                              _buildStatusChip(
                                                label: 'حساب موثوق',
                                                color: context.primaryColor,
                                                icon: Icons.verified_rounded,
                                              ),
                                            if (parent.phoneVerified)
                                              _buildStatusChip(
                                                label: 'هاتف محقق',
                                                color: Colors.teal,
                                                icon: Icons.phone_locked_rounded,
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (!parent.isActive)
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: context.successColor,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                      onPressed: state.isActionLoading
                                          ? null
                                          : () => context
                                              .read<ParentsCubit>()
                                              .activateParent(parent.id),
                                      icon: const Icon(Icons.bolt_rounded, size: 18),
                                      label: const Text('تفعيل الحساب'),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Personal & Contact Info Grid
                            Text(
                              'معلومات الاتصال والحساب',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: context.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: context.cardColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: theme.dividerColor),
                              ),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final isWide = constraints.maxWidth > 400;
                                  return GridView.count(
                                    crossAxisCount: isWide ? 2 : 1,
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    childAspectRatio: isWide ? 3.5 : 4.5,
                                    mainAxisSpacing: 10,
                                    crossAxisSpacing: 10,
                                    children: [
                                      _buildInfoTile(
                                        icon: Icons.phone_android_rounded,
                                        title: 'رقم الهاتف الأساسي',
                                        value: parent.phoneNumber,
                                      ),
                                      _buildInfoTile(
                                        icon: Icons.phone_callback_rounded,
                                        title: 'رقم الهاتف البديل',
                                        value: parent.alternativePhone ?? 'غير محدد',
                                      ),
                                      _buildInfoTile(
                                        icon: Icons.email_outlined,
                                        title: 'البريد الإلكتروني',
                                        value: parent.email ?? 'غير محدد',
                                      ),
                                      _buildInfoTile(
                                        icon: Icons.wc_rounded,
                                        title: 'الجنس',
                                        value: parent.gender == 'male'
                                            ? 'ذكر'
                                            : (parent.gender == 'female'
                                                ? 'أنثى'
                                                : 'غير محدد'),
                                      ),
                                      _buildInfoTile(
                                        icon: Icons.login_rounded,
                                        title: 'آخر تسجيل دخول',
                                        value: parent.lastLoginAt ?? 'لم يدخل بعد',
                                      ),
                                      _buildInfoTile(
                                        icon: Icons.calendar_today_rounded,
                                        title: 'تاريخ إنشاء الحساب',
                                        value: parent.createdAt ?? 'غير محدد',
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Address Info Section
                            Text(
                              'العنوان الافتراضي',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: context.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: context.surfaceVariant,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: theme.dividerColor),
                              ),
                              child: parent.defaultAddress != null
                                  ? Row(
                                      children: [
                                        Icon(Icons.location_on_rounded,
                                            color: context.primaryColor, size: 22),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                parent.defaultAddress!.label,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: context.textPrimary,
                                                ),
                                              ),
                                              if (parent.defaultAddress!.lat != null &&
                                                  parent.defaultAddress!.lng != null)
                                                Text(
                                                  'الإحداثيات الجغرافية: ${parent.defaultAddress!.lat}, ${parent.defaultAddress!.lng}',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: context.textTertiary,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                  : Row(
                                      children: [
                                        Icon(Icons.location_off_rounded,
                                            color: context.textTertiary, size: 20),
                                        const SizedBox(width: 10),
                                        Text(
                                          'لم يحدد ولي الأمر أي عنوان افتراضي حتى الآن',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: context.textTertiary,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                            const SizedBox(height: 20),

                            // Children List Section
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'الأبناء المسجلون (${parent.children.length})',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: context.textPrimary,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: context.primaryColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${parent.childrenCount} طفل مسجل',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: context.primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            if (parent.children.isEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: context.surfaceVariant,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: theme.dividerColor),
                                ),
                                child: Column(
                                  children: [
                                    Icon(Icons.child_care_rounded,
                                        size: 32, color: context.textTertiary),
                                    const SizedBox(height: 8),
                                    Text(
                                      'لا يوجد أطفال مسجلين تحت هذا الحساب حالياً',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: context.textTertiary,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: parent.children.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final child = parent.children[index];
                                  return Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: context.cardColor,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: theme.dividerColor),
                                    ),
                                    child: Row(
                                      children: [
                                        RemoteCircleAvatar(
                                          rawUrl: child.photoUrl,
                                          radius: 22,
                                          initials: child.fullName.isNotEmpty
                                              ? child.fullName[0]
                                              : 'ط',
                                          foregroundColor: context.primaryColor,
                                          backgroundColor: context.primaryColor
                                              .withValues(alpha: 0.12),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      child.fullName,
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.bold,
                                                        color: context.textPrimary,
                                                      ),
                                                    ),
                                                  ),
                                                  if (child.age != null)
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                              horizontal: 6,
                                                              vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: context.surfaceVariant,
                                                        borderRadius:
                                                            BorderRadius.circular(6),
                                                      ),
                                                      child: Text(
                                                        'العمر: ${child.age} سنة',
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight: FontWeight.bold,
                                                          color: context.textSecondary,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'المدرسة: ${child.schoolName ?? 'غير محددة'} • المرحلة: ${child.schoolStage ?? 'أساسي'} • الصف: ${child.grade ?? 'غير محدد'}',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: context.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('إغلاق النافذة'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusChip({
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Builder(builder: (context) {
      return Row(
        children: [
          Icon(icon, size: 16, color: context.textTertiary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 10, color: context.textTertiary),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
