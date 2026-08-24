import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../services/image_loader_service.dart';
import '../utils/media_url.dart';

/// صورة قادمة من الخادم، تضمن العرض اللحظي عبر الكاش المباشر في الرام (RAM Cache)
/// وجلب بايتات الصور عبر Dio لتخطي حظر النفق (Localtunnel 511) وتجاوز قيود الـ CORS.
class RemoteImage extends StatefulWidget {
  final String? rawUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  /// البديل عند غياب الرابط أو فشل التحميل.
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
  Uint8List? _bytes;
  bool _isLoading = false;
  bool _hasError = false;
  String? _currentUrl;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(RemoteImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rawUrl != widget.rawUrl) {
      _loadImage();
    }
  }

  void _loadImage() {
    final url = MediaUrl.resolve(widget.rawUrl);
    _currentUrl = url;

    if (url == null || !MediaUrl.isImage(url)) {
      setState(() {
        _bytes = null;
        _isLoading = false;
        _hasError = false;
      });
      return;
    }

    // 1. فحص وجود الصورة في كاش الذاكرة (RAM Cache) للعرض الفوري اللحظي
    final cached = ImageLoaderService.instance.getCachedBytes(url);
    if (cached != null) {
      setState(() {
        _bytes = cached;
        _isLoading = false;
        _hasError = false;
      });
      return;
    }

    // 2. البدء بجلب بايتات الصورة عبر الشبكة
    setState(() {
      _bytes = null;
      _isLoading = true;
      _hasError = false;
    });

    ImageLoaderService.instance.fetchImageBytes(url).then((bytes) {
      if (!mounted || _currentUrl != url) return;
      if (bytes != null && bytes.isNotEmpty) {
        setState(() {
          _bytes = bytes;
          _isLoading = false;
          _hasError = false;
        });
      } else {
        setState(() {
          _bytes = null;
          _isLoading = false;
          _hasError = true;
        });
      }
    }).catchError((_) {
      if (!mounted || _currentUrl != url) return;
      setState(() {
        _bytes = null;
        _isLoading = false;
        _hasError = true;
      });
    });
  }

  Widget get _loadingWidget => widget.placeholder ?? widget.fallback;

  @override
  Widget build(BuildContext context) {
    final url = MediaUrl.resolve(widget.rawUrl);
    if (url == null || !MediaUrl.isImage(url)) return widget.fallback;

    if (_bytes != null) {
      return Image.memory(
        _bytes!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) => widget.fallback,
      );
    }

    if (_hasError) {
      return widget.fallback;
    }

    if (_isLoading) {
      return _loadingWidget;
    }

    return _loadingWidget;
  }
}
