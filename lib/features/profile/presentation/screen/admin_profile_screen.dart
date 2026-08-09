import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../data/models/admin_profile_model.dart';
import '../../logic/cubit/profile_cubit.dart';
import '../../logic/state/profile_state.dart';
import '../widget/profile_edit_form.dart';
import '../widget/profile_header.dart';
import '../widget/profile_info_card.dart';

class AdminProfileScreen extends StatelessWidget {
  final String? adminName;
  final ValueChanged<String>? onNameChanged;

  const AdminProfileScreen({
    super.key,
    this.adminName,
    this.onNameChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileCubit>(
      create: (_) => sl<ProfileCubit>()..fetchProfile(),
      child: AdminProfileViewContent(
        onNameChanged: onNameChanged,
      ),
    );
  }
}

/// backward-compatible widget wrapper for main layout
class AdminProfileView extends StatelessWidget {
  final String? adminName;
  final ValueChanged<String>? onNameChanged;

  const AdminProfileView({
    super.key,
    this.adminName,
    this.onNameChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AdminProfileScreen(
      adminName: adminName,
      onNameChanged: onNameChanged,
    );
  }
}

class AdminProfileViewContent extends StatefulWidget {
  final ValueChanged<String>? onNameChanged;

  const AdminProfileViewContent({
    super.key,
    this.onNameChanged,
  });

  @override
  State<AdminProfileViewContent> createState() => _AdminProfileViewContentState();
}

class _AdminProfileViewContentState extends State<AdminProfileViewContent> {
  bool _isEditing = false;

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? theme.colorScheme.error : theme.colorScheme.secondary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdateSuccess) {
          _showSnack(state.message, isError: false);
          widget.onNameChanged?.call(state.profile.fullName);
          setState(() {
            _isEditing = false;
          });
        } else if (state is ProfileUpdateError) {
          _showSnack(state.message, isError: true);
        }
      },
      builder: (context, state) {
        if (state is ProfileLoading || state is ProfileInitial) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: theme.colorScheme.primary),
                const SizedBox(height: 16),
                Text(
                  'جاري تحميل بيانات البروفايل...',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        if (state is ProfileError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 56,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'تعذر جلب بيانات الملف الشخصي',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.read<ProfileCubit>().fetchProfile(),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            ),
          );
        }

        AdminProfileModel? currentProfile;
        bool isSaving = false;

        if (state is ProfileLoaded) {
          currentProfile = state.profile;
        } else if (state is ProfileUpdating) {
          currentProfile = state.currentProfile;
          isSaving = true;
        } else if (state is ProfileUpdateSuccess) {
          currentProfile = state.profile;
        } else if (state is ProfileUpdateError) {
          currentProfile = state.currentProfile;
        }

        if (currentProfile == null) {
          return const SizedBox.shrink();
        }

        final profile = currentProfile;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              ProfileHeader(
                profile: profile,
                isEditing: _isEditing,
                onToggleEdit: () {
                  setState(() {
                    _isEditing = !_isEditing;
                  });
                },
              ),
              const SizedBox(height: 20),
              _isEditing
                  ? ProfileEditForm(
                      profile: profile,
                      isSaving: isSaving,
                      onCancel: () => setState(() => _isEditing = false),
                      onSave: (changedFields) {
                        context.read<ProfileCubit>().updateProfile(
                              adminId: profile.id,
                              changedFields: changedFields,
                              currentProfile: profile,
                            );
                      },
                    )
                  : ProfileInfoCard(profile: profile),
              const SizedBox(height: 20),
              if (!_isEditing) _buildSessionCard(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSessionCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.security_rounded,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'الجلسة الحالية والأمان',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: theme.colorScheme.outlineVariant),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.laptop_mac_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
            title: Text(
              'لوحة التحكم الإدارية – جلسة الويب',
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'جلسة نشطة • محمية برمز مصادقة آمن',
              style: theme.textTheme.bodySmall,
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                'متصل',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.secondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
