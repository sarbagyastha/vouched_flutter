import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../../vouched_flutter.dart';
import '../src/model/card_detail_result.dart';
import '../src/model/job_response.dart';

typedef _ProgressIndicatorCallback = Widget Function(BuildContext, bool);

const _eventChannel = EventChannel('com.acmesoftware.vouched/event');

class VouchedScanner extends StatefulWidget {
  const VouchedScanner({
    Key? key,
    required this.onResponse,
    this.apiKey,
    this.borderRadius,
    this.onCardDetailResult,
    this.onError,
    this.loadingBuilder,
  }) : super(key: key);

  final ValueChanged<JobResponse> onResponse;
  final String? apiKey;
  final BorderRadius? borderRadius;
  final ValueChanged<CardDetailResult>? onCardDetailResult;
  final ValueChanged<String>? onError;
  final _ProgressIndicatorCallback? loadingBuilder;

  @override
  State<VouchedScanner> createState() => _VouchedScannerState();
}

class _VouchedScannerState extends State<VouchedScanner> {
  final Map<String, dynamic> creationParams = {};
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);

  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    creationParams['api_key'] = _apiKey;
    Vouched.channel.setMethodCallHandler(
      (call) async {
        _isLoading.value = false;
        final data = call.arguments as String;
        switch (call.method) {
          case 'success':
            try {
              widget.onResponse(JobResponse.fromJson(data));
            } catch (e, s) {
              const errorName = 'JobResponseParseError';
              log(e.toString(), name: errorName, error: e, stackTrace: s);
            }
            break;
          case 'error':
            widget.onError?.call(data);
            break;
        }
      },
    );
  }

  @override
  void didUpdateWidget(VouchedScanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.apiKey != widget.apiKey) {
      creationParams['api_key'] = _apiKey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = ColoredBox(
      color: Colors.black,
      child: AnimatedOpacity(
        opacity: _subscription == null ? 0 : 1,
        duration: const Duration(milliseconds: 200),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _PlatformView(
              creationParams: creationParams,
              onViewCreated: () {
                if (_subscription == null) {
                  final _eventStream = _eventChannel.receiveBroadcastStream();
                  _subscription = _eventStream.listen(_onCardDetectResult);
                  setState(() {});
                }
              },
            ),
            _ProgressIndicator(
              loadingNotifier: _isLoading,
              loadingBuilder: widget.loadingBuilder,
            ),
          ],
        ),
      ),
    );

    if (widget.borderRadius == null) return child;

    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: child,
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _isLoading.dispose();
    super.dispose();
  }

  void _onCardDetectResult(dynamic rawResult) {
    final result = CardDetailResult.fromMap(Map.from(rawResult));
    if (result.step == CardDetailStep.postable) _isLoading.value = true;

    widget.onCardDetailResult?.call(result);
  }

  String get _apiKey {
    const envKey = 'VOUCHED_API_KEY';
    final _apiKey = widget.apiKey ?? const String.fromEnvironment(envKey);
    assert(
      _apiKey.isNotEmpty,
      'Either pass API Key or provide an dart define named "$envKey"',
    );
    return _apiKey;
  }
}

class _PlatformView extends StatelessWidget {
  const _PlatformView({
    Key? key,
    required this.creationParams,
    required this.onViewCreated,
  }) : super(key: key);

  final Map<String, dynamic> creationParams;
  final VoidCallback onViewCreated;

  final String viewType = 'com.acmesoftware.vouched/detector';

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: viewType,
        layoutDirection: TextDirection.ltr,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: (_) => Future.microtask(onViewCreated),
      );
    }

    return PlatformViewLink(
      viewType: viewType,
      surfaceFactory: (context, controller) {
        return AndroidViewSurface(
          controller: controller as AndroidViewController,
          gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        );
      },
      onCreatePlatformView: (params) {
        Future.microtask(onViewCreated);
        return PlatformViewsService.initSurfaceAndroidView(
          id: params.id,
          viewType: viewType,
          layoutDirection: TextDirection.ltr,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
          onFocus: () => params.onFocusChanged(true),
        )
          ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
          ..create();
      },
    );
  }
}

class _ProgressIndicator extends StatelessWidget {
  const _ProgressIndicator({
    Key? key,
    required this.loadingNotifier,
    required this.loadingBuilder,
  }) : super(key: key);

  final ValueNotifier<bool> loadingNotifier;
  final _ProgressIndicatorCallback? loadingBuilder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: loadingNotifier,
      builder: (context, isLoading, loader) {
        if (loadingBuilder != null) return loadingBuilder!(context, isLoading);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          color: isLoading ? Colors.black.withOpacity(0.6) : Colors.transparent,
          child: isLoading ? loader : null,
        );
      },
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        ),
      ),
    );
  }
}
