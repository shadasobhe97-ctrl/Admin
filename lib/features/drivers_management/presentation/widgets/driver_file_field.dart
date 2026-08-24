import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/utils/admin_theme_context.dart';
import '../../../../core/utils/media_url.dart';
import '../../../../core/widgets/image_viewer_dialog.dart';
import '../../../../core/widgets/remote_image.dart';
import '../../data/models/update_driver_payload.dart';

/// حقل رفع ملف واحد داخل نموذج تعديل السائق.
///
/// يعرض معاينة الملف المختار حديثاً، أو الملف الحالي على الخادم إن وُجد،
/// ولا يُرسل شيئاً إلى الخادم ما لم يختر المستخدم ملفاً جديداً.
class DriverFileField extends StatelessWidget {
  final String label;

  /// رابط الملف الحالي على الخادم — يُعرض حين لا يوجد اختيار جديد.
  final String? currentUrl;

  final PickedUpload? picked;
  final VoidCallback onPick;
  final VoidCallback? onClear;

  const DriverFileField({
    super.key,
    required this.label,
    required this.currentUrl,
    required this.picked,
    required this.onPick,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final existing = MediaUrl.resolve(currentUrl);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.dividerLine),
      ),
      child: Row(
        children: [
          _Preview(picked: picked, existingUrl: existing, label: label),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  picked != null
                      ? picked!.fileName
                      : (existing != null
                          ? 'ملف مرفوع — اضغط المعاينة لعرضه'
                          : 'لم يُرفع ملف'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: context.textTertiary),
                ),
              ],
            ),
          ),
          if (onClear != null)
            IconButton(
              onPressed: onClear,
              tooltip: 'إلغاء الاختيار',
              icon: Icon(Icons.close_rounded, size: 17, color: context.dangerColor),
            ),
          TextButton.icon(
            onPressed: onPick,
            icon: const Icon(Icons.upload_rounded, size: 15),
            label: Text(picked != null ? 'تغيير' : 'اختيار'),
          ),
        ],
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  final PickedUpload? picked;
  final String? existingUrl;
  final String label;

  const _Preview({
    required this.picked,
    required this.existingUrl,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final box = BoxDecoration(
      color: context.primaryColor.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(8),
    );

    // الملف المختار يُعرض من الذاكرة مباشرة قبل رفعه.
    if (picked != null) {
      return Container(
        width: 42,
        height: 42,
        decoration: box,
        clipBehavior: Clip.antiAlias,
        child: Image.memory(
          Uint8List.fromList(picked!.bytes),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.insert_drive_file_rounded,
            size: 20,
            color: context.primaryColor,
          ),
        ),
      );
    }

    if (existingUrl != null) {
      return InkWell(
        onTap: () => ImageViewerDialog.show(
          context,
          title: label,
          rawUrl: existingUrl,
        ),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 42,
          height: 42,
          decoration: box,
          clipBehavior: Clip.antiAlias,
          child: RemoteImage(
            rawUrl: existingUrl,
            fallback: Icon(
              Icons.image_outlined,
              size: 20,
              color: context.primaryColor,
            ),
          ),
        ),
      );
    }

    return Container(
      width: 42,
      height: 42,
      decoration: box,
      child: Icon(
        Icons.add_photo_alternate_outlined,
        size: 20,
        color: context.textTertiary,
      ),
    );
  }
}
