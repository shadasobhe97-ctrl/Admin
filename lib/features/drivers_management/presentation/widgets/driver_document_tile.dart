import 'package:flutter/material.dart';

import '../../../../core/utils/admin_theme_context.dart';
import '../../../../core/utils/media_url.dart';
import '../../data/models/driver_document_model.dart';
import 'document_viewer_dialog.dart';
import 'driver_status_badge.dart';

/// صف وثيقة واحدة داخل تفاصيل السائق.
///
/// الضغط عليه يفتح [DocumentViewerDialog] مهما كانت حالة السائق أو الوثيقة،
/// لأن الاطلاع على المستند مطلوب في المراجعة والتدقيق اللاحق على حدّ سواء.
class DriverDocumentTile extends StatelessWidget {
  final DriverDocumentModel document;
  final String driverName;

  const DriverDocumentTile({
    super.key,
    required this.document,
    required this.driverName,
  });

  @override
  Widget build(BuildContext context) {
    final url = MediaUrl.resolve(document.fileUrl);
    final hasFile = url != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: context.isDarkMode ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.dividerLine),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: hasFile
              ? () => DocumentViewerDialog.show(
                    context,
                    document: document,
                    driverName: driverName,
                  )
              : null,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _Thumbnail(url: url),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        document.translatedType,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasFile
                            ? (document.expiryDate == null ||
                                    document.expiryDate!.isEmpty
                                ? 'اضغط لعرض الوثيقة'
                                : 'تاريخ الانتهاء: ${document.expiryDate}')
                            : 'لا يوجد ملف مرفوع',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                DriverStatusBadge(status: document.status),
                const SizedBox(width: 8),
                Icon(
                  hasFile
                      ? Icons.visibility_outlined
                      : Icons.image_not_supported_outlined,
                  size: 19,
                  color: hasFile ? context.primaryColor : context.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// مصغّرة الوثيقة — صورة عند توفّرها، وإلا أيقونة تدل على نوع الملف.
class _Thumbnail extends StatelessWidget {
  final String? url;

  const _Thumbnail({required this.url});

  @override
  Widget build(BuildContext context) {
    final link = url;
    final showImage = link != null && MediaUrl.isImage(link);

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: context.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(9),
      ),
      clipBehavior: Clip.antiAlias,
      child: showImage
          ? Image.network(
              link,
              fit: BoxFit.cover,
              headers: MediaUrl.authHeaders,
              errorBuilder: (context, error, stackTrace) =>
                  _FallbackIcon(url: link),
            )
          : _FallbackIcon(url: link),
    );
  }
}

class _FallbackIcon extends StatelessWidget {
  final String? url;

  const _FallbackIcon({required this.url});

  @override
  Widget build(BuildContext context) {
    final link = url;
    final icon = link == null
        ? Icons.description_outlined
        : (MediaUrl.isPdf(link)
            ? Icons.picture_as_pdf_rounded
            : Icons.insert_drive_file_rounded);

    return Icon(icon, size: 22, color: context.primaryColor);
  }
}
