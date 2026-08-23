import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/admin_theme_context.dart';
import '../../../../core/utils/media_url.dart';
import '../../data/models/driver_document_model.dart';
import 'driver_status_badge.dart';

/// عارض الوثائق الرسمية للسائق.
///
/// يعمل في كل حالات السائق (قيد الانتظار، مقبول، مرفوض، في رحلة، موقوف…)
/// لأن الاطلاع على الوثيقة عملية قراءة لا علاقة لها بحالة الاعتماد.
class DocumentViewerDialog extends StatelessWidget {
  final DriverDocumentModel document;
  final String driverName;

  const DocumentViewerDialog({
    super.key,
    required this.document,
    required this.driverName,
  });

  static Future<void> show(
    BuildContext context, {
    required DriverDocumentModel document,
    required String driverName,
  }) {
    return showDialog(
      context: context,
      builder: (_) => DocumentViewerDialog(
        document: document,
        driverName: driverName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final url = MediaUrl.resolve(document.fileUrl);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: context.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720, maxHeight: 700),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Header(document: document, driverName: driverName),
              Divider(height: 1, color: context.dividerLine),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: url == null
                      ? const _DocumentMessage(
                          icon: Icons.link_off_rounded,
                          message: 'لا يوجد ملف مرفوع لهذه الوثيقة.',
                        )
                      : _DocumentBody(url: url),
                ),
              ),
              if (document.notes != null && document.notes!.trim().isNotEmpty)
                _NotesBar(notes: document.notes!.trim()),
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
  final DriverDocumentModel document;
  final String driverName;

  const _Header({required this.document, required this.driverName});

  @override
  Widget build(BuildContext context) {
    final expiry = document.expiryDate;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
      child: Row(
        children: [
          Icon(Icons.description_rounded, size: 22, color: context.primaryColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  document.translatedType,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  expiry == null || expiry.isEmpty
                      ? driverName
                      : '$driverName • تنتهي في $expiry',
                  style: TextStyle(fontSize: 12, color: context.textTertiary),
                ),
              ],
            ),
          ),
          DriverStatusBadge(status: document.status),
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

/// محتوى الوثيقة: صورة قابلة للتكبير، أو بديل واضح لبقيّة الصيغ.
class _DocumentBody extends StatelessWidget {
  final String url;

  const _DocumentBody({required this.url});

  @override
  Widget build(BuildContext context) {
    if (MediaUrl.isPdf(url)) {
      return const _DocumentMessage(
        icon: Icons.picture_as_pdf_rounded,
        message: 'الوثيقة بصيغة PDF ولا يمكن عرضها داخل اللوحة.\n'
            'انسخ الرابط وافتحه في المتصفح للاطلاع عليها.',
      );
    }

    if (!MediaUrl.isImage(url)) {
      return const _DocumentMessage(
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
          child: Image.network(
            url,
            headers: MediaUrl.authHeaders,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              final expected = progress.expectedTotalBytes;
              return SizedBox(
                height: 320,
                child: Center(
                  child: CircularProgressIndicator(
                    color: context.primaryColor,
                    value: expected == null
                        ? null
                        : progress.cumulativeBytesLoaded / expected,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) =>
                const _DocumentMessage(
              icon: Icons.broken_image_rounded,
              message: 'تعذّر تحميل صورة الوثيقة من الخادم.\n'
                  'تأكد من الرابط أو انسخه وافتحه في المتصفح.',
            ),
          ),
        ),
      ),
    );
  }
}

class _DocumentMessage extends StatelessWidget {
  final IconData icon;
  final String message;

  const _DocumentMessage({required this.icon, required this.message});

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

class _NotesBar extends StatelessWidget {
  final String notes;

  const _NotesBar({required this.notes});

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
          'ملاحظات: $notes',
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
              link ?? 'لا يوجد رابط لهذه الوثيقة',
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
                  const SnackBar(content: Text('تم نسخ رابط الوثيقة.')),
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
