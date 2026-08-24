import 'package:flutter/material.dart';

import '../utils/media_url.dart';

/// صورة قادمة من الخادم، مضبوطة لتعمل على الويب وسطح المكتب معاً.
///
/// للمتصفّح مساران لتحميل الصورة، ولكل منهما عائق مختلف:
///
/// * **جلب البايتات مع الترويسات** — يتخطّى صفحة تنبيه localtunnel، لكنه
///   يخضع لـ CORS، فيفشل إن لم يسمح الخادم بـ `storage/*`.
/// * **وسم `img` بلا ترويسات** — لا يخضع لـ CORS إطلاقاً، لكنه يتلقّى صفحة
///   تنبيه النفق حين يكون الخادم خلف localtunnel.
///
/// لذلك يُجرَّب المساران بالترتيب: البايتات أولاً، ثم `img` عند الفشل.
/// هكذا تظهر الصورة في أي بيئة لا يعطّلها العائقان معاً.
class RemoteImage extends StatefulWidget {
  /// الرابط كما ورد من الخادم — يُحوَّل إلى مطلق داخلياً.
  final String? rawUrl;

  final double? width;
  final double? height;
  final BoxFit fit;

  /// البديل عند غياب الرابط أو فشل المسارين.
  final Widget fallback;

  /// المعروض أثناء التحميل — يعود إلى [fallback] عند عدم تمريره.
  final Widget? placeholder;

  const RemoteImage({
    super.key,
    required this.rawUrl,
    required this.fallback,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
  });

  @override
  State<RemoteImage> createState() => _RemoteImageState();
}

class _RemoteImageState extends State<RemoteImage> {
  /// `true` بعد فشل محاولة جلب البايتات، فيُنتقل إلى وسم `img`.
  bool _useHtmlElement = false;

  @override
  void didUpdateWidget(RemoteImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // رابط جديد يستحق محاولة كاملة من أول مسار.
    if (oldWidget.rawUrl != widget.rawUrl) _useHtmlElement = false;
  }

  Widget get _loading => widget.placeholder ?? widget.fallback;

  @override
  Widget build(BuildContext context) {
    final url = MediaUrl.resolve(widget.rawUrl);
    if (url == null || !MediaUrl.isImage(url)) return widget.fallback;

    if (_useHtmlElement) {
      // المسار الثاني: بلا ترويسات ليتمكّن Flutter من استخدام وسم `img`،
      // وهو غير خاضع لسياسة المصدر الواحد.
      return Image.network(
        url,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : _loading,
        errorBuilder: (context, error, stackTrace) => widget.fallback,
      );
    }

    return Image.network(
      url,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      headers: MediaUrl.imageHeaders,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : _loading,
      errorBuilder: (context, error, stackTrace) {
        // لا يجوز استدعاء setState أثناء البناء، فيؤجَّل إلى ما بعد الإطار.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_useHtmlElement) {
            setState(() => _useHtmlElement = true);
          }
        });
        return _loading;
      },
    );
  }
}
