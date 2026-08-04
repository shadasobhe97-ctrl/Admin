import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class SidebarItemData {
  final String title;
  final IconData icon;
  final int? badgeCount;

  SidebarItemData({required this.title, required this.icon, this.badgeCount});
}

class SidebarWidget extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  SidebarWidget({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  final List<SidebarItemData> menuItems = [
    SidebarItemData(title: 'الرئيسية والمتابعة الحية', icon: Icons.grid_view_rounded),
    SidebarItemData(title: 'طلبات تسجيل السائقين', icon: Icons.person_add_alt_1_outlined, badgeCount: 2),
    SidebarItemData(title: 'طلبات تعديل البيانات', icon: Icons.published_with_changes_rounded, badgeCount: 1),
    SidebarItemData(title: 'مركز الشكاوى والبلاغات', icon: Icons.warning_amber_rounded, badgeCount: 2),
    SidebarItemData(title: 'الإدارة المالية والسحب', icon: Icons.account_balance_wallet_outlined, badgeCount: 2),
    SidebarItemData(title: 'إدارة موظفي الإدارة', icon: Icons.shield_outlined),
    SidebarItemData(title: 'التقارير والإحصائيات العامة', icon: Icons.insert_drive_file_outlined),
    SidebarItemData(title: 'الملف الشخصي وتعديل البيانات', icon: Icons.person_outline_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      color: AppColors.sidebarBackground,
      child: Column(
        children: [
          // 1. الهيدر (الشعار)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.sidebarActiveItem,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.directions_car_filled_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'دربي Derbi',
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'منظومة الربط الآمن طرابلس',
                      style: GoogleFonts.cairo(
                        color: AppColors.sidebarInactiveText,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 2. قائمة العناصر
          Expanded(
            child: ListView.builder(
              itemCount: menuItems.length,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemBuilder: (context, index) {
                final item = menuItems[index];
                final isSelected = selectedIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: InkWell(
                    onTap: () => onItemSelected(index),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.sidebarActiveItem : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item.icon,
                            color: isSelected ? Colors.white : AppColors.sidebarInactiveText,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.title,
                              style: GoogleFonts.cairo(
                                color: isSelected ? Colors.white : AppColors.sidebarInactiveText,
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          ),
                          if (item.badgeCount != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white.withAlpha(50) : AppColors.badgeBackground,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${item.badgeCount}',
                                style: GoogleFonts.cairo(
                                  color: isSelected ? Colors.white : AppColors.badgeText,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 3. الجزء السفلي (المستخدم وتدشين الخروج)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.sidebarBorder, width: 1)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color(0xFF1E293B),
                      child: Text(
                        'م',
                        style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'مسؤول النظام',
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'مدير الإدارة العامة',
                            style: GoogleFonts.cairo(
                              color: AppColors.sidebarInactiveText,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.badgeBackground),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.logout, color: AppColors.badgeText, size: 16),
                    label: Text(
                      'تسجيل الخروج',
                      style: GoogleFonts.cairo(
                        color: AppColors.badgeText,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
