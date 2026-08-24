import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/admin_theme_context.dart';
import '../utils/media_url.dart';
import 'remote_image.dart';

/// عارض صور عام: يفتح الصورة بالحجم الكامل مع تكبير وتحريك.
///
/// يُستخدم لوثائق السائق وصورة المركبة وصورة الحساب الشخصية، فلا يتكرر
/// منطق العرض ولا معالجة الروابط النسبية والصيغ غير المدعومة.
class ImageViewerDialog extends StatelessWidget {
  final String title;
  final String? subtitle;

  /// الرابط كما ورد من الخادم — يُحوَّل إلى رابط مطلق داخلياً.
  final String? rawUrl;

  /// شارة تُعرض بجوار العنوان (حالة الوثيقة مثلاً).
  final Widget? badge;

  /// ملاحظة تُعرض أسفل الصورة (ملاحظات المراجع مثلاً).
  final String? note;

  const ImageViewerDialog({
    super.key,
    required this.title,
    required this.rawUrl,
    this.subtitle,
    this.badge,
    this.note,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String? rawUrl,
    String? subtitle,
    Widget? badge,
    String? note,
  }) {
    return showDialog(
      context: context,
      builder: (_) => ImageViewerDialog(
        title: title,
        rawUrl: rawUrl,
        subtitle: subtitle,
        badge: badge,
        note: note,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final url = MediaUrl.resolve(rawUrl);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: context.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760, maxHeight: 720),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Header(title: title, subtitle: subtitle, badge: badge),
              Divider(height: 1, color: context.dividerLine),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: url == null
                      ? const ImageViewerMessage(
                          icon: Icons.link_off_rounded,
                          message: 'لا يوجد ملف مرفوع لعرضه.',
                        )
                      : _Body(url: url),
                ),
              ),
              if (note != null && note!.trim().isNotEmpty)
                _NoteBar(note: note!.trim()),
              Divider(height: 1, color: context.dividerLine),
              _Footer(url: url),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? badge;

  const _Header({required this.title, this.subtitle, this.badge});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
      child: Row(
        children: [
          Icon(Icons.image_outlined, size: 22, color: context.primaryColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(fontSize: 12, color: context.textTertiary),
                  ),
                ],
              ],
            ),
          ),
          if (badge != null) badge!,
          IconButton(
            icon: const Icon(Icons.close_rounded),
            tooltip: 'إغلاق',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

/// الصورة قابلة للتكبير، أو بديل واضح لبقيّة الصيغ.
class _Body extends StatelessWidget {
  final String url;

  const _Body({required this.url});

  @override
  Widget build(BuildContext context) {
    if (MediaUrl.isPdf(url)) {
      return const ImageViewerMessage(
        icon: Icons.picture_as_pdf_rounded,
        message: 'الملف بصيغة PDF ولا يمكن عرضه داخل اللوحة.\n'
            'انسخ الرابط وافتحه في المتصفح للاطلاع عليه.',
      );
    }

    if (!MediaUrl.isImage(url)) {
      return const ImageViewerMessage(
        icon: Icons.insert_drive_file_rounded,
        message: 'صيغة الملف غير مدعومة للعرض المباشر.\n'
            'انسخ الرابط وافتحه في المتصفح للاطلاع عليه.',
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: context.isDarkMode
            ? const Color(0xFF0F172A)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.dividerLine),
      ),
      clipBehavior: Clip.antiAlias,
      child: InteractiveViewer(
        minScale: 0.8,
        maxScale: 5,
        child: Center(
          child: RemoteImage(
            rawUrl: url,
            fit: BoxFit.contain,
            placeholder: SizedBox(
              height: 320,
              child: Center(
                child: CircularProgressIndicator(color: context.primaryColor),
              ),
            ),
            fallback: const ImageViewerMessage(
              icon: Icons.broken_image_rounded,
              message: 'تعذّر تحميل الصورة من الخادم.\n'
                  'انسخ الرابط وافتحه في المتصفح للاطلاع عليها.',
            ),
          ),
        ),
      ),
    );
  }
}

class ImageViewerMessage extends StatelessWidget {
  final IconData icon;
  final String message;

  const ImageViewerMessage({
    super.key,
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 46, color: context.textTertiary),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.6,
                color: context.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoteBar extends StatelessWidget {
  final String note;

  const _NoteBar({required this.note});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.infoBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: context.infoBorder),
        ),
        child: Text(
          note,
          style: TextStyle(fontSize: 12, height: 1.5, color: context.infoColor),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final String? url;

  const _Footer({required this.url});

  @override
  Widget build(BuildContext context) {
    final link = url;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              link ?? 'لا يوجد رابط',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 11, color: context.textTertiary),
            ),
          ),
          const SizedBox(width: 12),
          if (link != null)
            OutlinedButton.icon(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                await Clipboard.setData(ClipboardData(text: link));
                messenger.showSnackBar(
                  const SnackBar(content: Text('تم نسخ الرابط.')),
                );
              },
              icon: const Icon(Icons.copy_rounded, size: 15),
              label: const Text('نسخ الرابط'),
            ),
        ],
      ),
    );
  }
}
