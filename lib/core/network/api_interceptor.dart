import 'dart:async';

import 'package:dio/dio.dart';

typedef RetryEvaluator = FutureOr<bool> Function(
  DioException error,
  int attempt,
);

/// An interceptor that will try to send failed request again
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this.dio,
    this.logPrint,
    this.retries = 3,
    this.retryDelays = const [
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 3),
    ],
    RetryEvaluator? retryEvaluator,
    this.ignoreRetryEvaluatorExceptions = false,
    this.retriableExtraStatuses = const {},
  }) : _retryEvaluator =
           retryEvaluator ??
           DefaultRetryEvaluator({
             ...defaultRetriableStatuses,
             ...retriableExtraStatuses,
           }).evaluate {
    if (retryEvaluator != null && retriableExtraStatuses.isNotEmpty) {
      throw ArgumentError(
        '[retriableExtraStatuses] works only if [retryEvaluator] is null.'
            ' Set either [retriableExtraStatuses] or [retryEvaluator].'
            ' Not both.',
        'retriableExtraStatuses',
      );
    }
    if (retries < 0) {
      throw ArgumentError('[retries] cannot be less than 0', 'retries');
    }
  }

  /// The original dio
  final Dio dio;

  /// For logging purpose
  final void Function(String message)? logPrint;

  /// The number of retry in case of an error
  final int retries;

  /// Ignore exception if [_retryEvaluator] throws it (not recommend)
  final bool ignoreRetryEvaluatorExceptions;

  /// The delays between attempts.
  /// Empty [retryDelays] means no delay.
  ///
  /// If [retries] count more than [retryDelays] count,
  ///   the last element value of [retryDelays] will be used.
  final List<Duration> retryDelays;

  /// Evaluating if a retry is necessary.regarding the error.
  ///
  /// It can be a good candidate for additional operations too, like
  ///   upfeatures authentication token in case of a unauthorized error
  ///   (be careful with concurrency though).
  ///
  /// Defaults to [DefaultRetryEvaluator.evaluate]
  ///   with [defaultRetriableStatuses].
  final RetryEvaluator _retryEvaluator;

  /// Specifies an extra retriable statuses,
  ///   which will be taken into account with [defaultRetriableStatuses]
  /// IMPORTANT: THIS SETTING WORKS ONLY IF [_retryEvaluator] is null
  final Set<int> retriableExtraStatuses;

  /// Redirects to [DefaultRetryEvaluator.evaluate]
  ///   with [defaultRetriableStatuses]
  static final FutureOr<bool> Function(DioException error, int attempt)
  defaultRetryEvaluator = DefaultRetryEvaluator(defaultRetriableStatuses)
      .evaluate;

  Future<bool> _shouldRetry(DioException error, int attempt) async {
    try {
      return await _retryEvaluator(error, attempt);
    } catch (e) {
      logPrint?.call('There was an exception in _retryEvaluator: $e');
      if (!ignoreRetryEvaluatorExceptions) {
        rethrow;
      }
    }
    return true;
  }

  @override
  Future<dynamic> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.requestOptions.disableRetry) {
      return super.onError(err, handler);
    }
    bool isRequestCancelled() =>
        err.requestOptions.cancelToken?.isCancelled ?? false;

    final attempt = err.requestOptions._attempt + 1;
    final shouldRetry = attempt <= retries && await _shouldRetry(err, attempt);

    if (!shouldRetry) {
      return super.onError(err, handler);
    }

    err.requestOptions._attempt = attempt;
    final delay = _getDelay(attempt);
    logPrint?.call(
      '[${err.requestOptions.path}] An error occurred during request, '
      'trying again '
      '(attempt: $attempt/$retries, '
      'wait ${delay.inMilliseconds} ms, '
      'error: ${err.error ?? err})',
    );

    var requestOptions = err.requestOptions;
    if (requestOptions.data is FormData) {
      requestOptions = _recreateOptions(err.requestOptions);
    }

    if (delay != Duration.zero) {
      await Future<void>.delayed(delay);
    }
    if (isRequestCancelled()) {
      logPrint?.call('Request was cancelled. Cancel retrying.');
      return super.onError(err, handler);
    }

    try {
      await dio
          .fetch<void>(requestOptions)
          .then((value) => handler.resolve(value));
    } on DioException catch (e) {
      super.onError(e, handler);
    }
  }

  Duration _getDelay(int attempt) {
    if (retryDelays.isEmpty) return Duration.zero;
    return attempt - 1 < retryDelays.length
        ? retryDelays[attempt - 1]
        : retryDelays.last;
  }

  RequestOptions _recreateOptions(RequestOptions options) {
    if (options.data is! FormData) {
      throw ArgumentError(
        'requestOptions.data is not FormData',
        'requestOptions',
      );
    }
    final formData = options.data as FormData;
    final newFormData = formData.clone();
    return options.copyWith(data: newFormData);
  }
}

const _kDisableRetryKey = 'ro_disable_retry';

extension RequestOptionsX on RequestOptions {
  static const _kAttemptKey = 'ro_attempt';

  int get attempt => _attempt;

  bool get disableRetry => (extra[_kDisableRetryKey] as bool?) ?? false;

  set disableRetry(bool value) => extra[_kDisableRetryKey] = value;

  int get _attempt => (extra[_kAttemptKey] as int?) ?? 0;

  set _attempt(int value) => extra[_kAttemptKey] = value;
}

extension OptionsX on Options {
  bool get disableRetry => (extra?[_kDisableRetryKey] as bool?) ?? false;

  set disableRetry(bool value) {
    extra = Map.of(extra ??= <String, dynamic>{});
    extra![_kDisableRetryKey] = value;
  }
}

class DefaultRetryEvaluator {
  DefaultRetryEvaluator(this._retriableStatuses);

  final Set<int> _retriableStatuses;
  int currentAttempt = 0;

  /// Returns true only if the response hasn't been cancelled
  ///   or got a bad status code.
  FutureOr<bool> evaluate(DioException error, int attempt) {
    bool shouldRetry;
    if (error.type == DioExceptionType.badResponse) {
      final statusCode = error.response?.statusCode;
      if (statusCode != null) {
        shouldRetry = isRetriable(statusCode);
      } else {
        shouldRetry = true;
      }
    } else {
      shouldRetry =
          error.type != DioExceptionType.cancel &&
          error.error is! FormatException;
    }
    currentAttempt = attempt;
    return shouldRetry;
  }

  bool isRetriable(int statusCode) => _retriableStatuses.contains(statusCode);
}

const status100Continue = 100;
const status101SwitchingProtocols = 101;
const status102Processing = 102;

const status200OK = 200;
const status201Created = 201;
const status202Accepted = 202;
const status203NonAuthoritative = 203;
const status204NoContent = 204;
const status205ResetContent = 205;
const status206PartialContent = 206;
const status207Multistatus = 207;
const status208AlreadyReported = 208;
const status226IMUsed = 226;

const status300MultipleChoices = 300;
const status301MovedPermanently = 301;
const status302Found = 302;
const status303SeeOther = 303;
const status304NotModified = 304;
const status305UseProxy = 305;
const status306SwitchProxy = 306; // RFC 2616, removed
const status307TemporaryRedirect = 307;
const status308PermanentRedirect = 308;

const status400BadRequest = 400;
const status401Unauthorized = 401;
const status402PaymentRequired = 402;
const status403Forbidden = 403;
const status404NotFound = 404;
const status405MethodNotAllowed = 405;
const status406NotAcceptable = 406;
const status407ProxyAuthenticationRequired = 407;
const status408RequestTimeout = 408;
const status409Conflict = 409;
const status410Gone = 410;
const status411LengthRequired = 411;
const status412PreconditionFailed = 412;
const status413RequestEntityTooLarge = 413; // RFC 2616, renamed
const status413PayloadTooLarge = 413; // RFC 7231
const status414RequestUriTooLong = 414; // RFC 2616, renamed
const status414UriTooLong = 414; // RFC 7231
const status415UnsupportedMediaType = 415;
const status416RequestedRangeNotSatisfiable = 416; // RFC 2616, renamed
const status416RangeNotSatisfiable = 416; // RFC 7233
const status417ExpectationFailed = 417;
const status418ImATeapot = 418;
const status419AuthenticationTimeout = 419; // Not defined in any RFC
const status421MisdirectedRequest = 421;
const status422UnprocessableEntity = 422;
const status423Locked = 423;
const status424FailedDependency = 424;
const status426UpgradeRequired = 426;
const status428PreconditionRequired = 428;
const status429TooManyRequests = 429;
const status431RequestHeaderFieldsTooLarge = 431;
const status451UnavailableForLegalReasons = 451;

const status500InternalServerError = 500;
const status501NotImplemented = 501;
const status502BadGateway = 502;
const status503ServiceUnavailable = 503;
const status504GatewayTimeout = 504;
const status505HttpVersionNotSupported = 505;
const status506VariantAlsoNegotiates = 506;
const status507InsufficientStorage = 507;
const status508LoopDetected = 508;
const status510NotExtended = 510;
const status511NetworkAuthenticationRequired = 511;

// Cloudflare Statuses
const status520WebServerReturnedUnknownError = 520;
const status521WebServerIsDown = 521;
const status522ConnectionTimedOut = 522;
const status523OriginIsUnreachable = 523;
const status524TimeoutOccurred = 524;
const status525SSLHandshakeFailed = 525;
const status526InvalidSSLCertificate = 526;
const status527RailgunError = 527;

// Not in RFC:
const status598NetworkReadTimeoutError = 598;
const status599NetworkConnectTimeoutError = 599;

/// From IIS
const status440LoginTimeout = 440;

const status499ClientClosedRequest = 499;

/// From AWS Elastic Load Balancer
const status460ClientClosedRequest = 460;

const defaultRetriableStatuses = <int>{
  status408RequestTimeout,
  status429TooManyRequests,
  status500InternalServerError,
  status502BadGateway,
  status503ServiceUnavailable,
  status504GatewayTimeout,
  status440LoginTimeout,
  status499ClientClosedRequest,
  status460ClientClosedRequest,
  status598NetworkReadTimeoutError,
  status599NetworkConnectTimeoutError,
  status520WebServerReturnedUnknownError,
  status521WebServerIsDown,
  status522ConnectionTimedOut,
  status523OriginIsUnreachable,
  status524TimeoutOccurred,
  status525SSLHandshakeFailed,
  status527RailgunError,
};

bool isRetriable(int statusCode) {
  return defaultRetriableStatuses.contains(statusCode);
}
