// Bridge-only tests for the Dyplink Flutter plugin.
//
// Scope:
//   * Dart facade correctly forwards calls to the HostApi
//   * PlatformException -> DyplinkError rewrapping
//   * DyplinkConfigBuilder validation
//
// NOT in scope:
//   * Business logic (queue, retry, identity, session) — tested in the
//     native Android SDK's own test suite
//   * Round-trip serialization — exercised implicitly by facade tests

import 'package:dyplink/dyplink.dart';
import 'package:dyplink/src/dyplink_error.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

// We can't easily mock Pigeon's generated HostApi (no @GenerateMocks here
// to keep the test setup dead simple), so we reach into dyplink_core.dart
// via its @visibleForTesting hook. For now these tests focus on pure-Dart
// code paths that don't need a bound channel.

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DyplinkConfigBuilder', () {
    test('builds with only the three required fields', () {
      final config = DyplinkConfig.builder(
        baseUrl: 'https://api.dyplink.com',
        apiKey: 'k',
        projectId: 'p',
      ).build();

      expect(config.baseUrl, 'https://api.dyplink.com');
      expect(config.apiKey, 'k');
      expect(config.projectId, 'p');
      expect(config.logLevel, DyplinkLogLevel.none);
      expect(config.flushIntervalSeconds, 30);
      expect(config.maxQueueSize, 1000);
      expect(config.maxRetries, 3);
      expect(config.sessionTimeoutSeconds, 300);
      expect(config.enableAutoSessionTracking, isTrue);
      expect(config.enableAutoDeviceInfo, isTrue);
      expect(config.deepLinkHosts, isEmpty);
      expect(config.customScheme, isNull);
    });

    test('applies all optional fields', () {
      final config = DyplinkConfig.builder(
        baseUrl: 'https://api.dyplink.com',
        apiKey: 'k',
        projectId: 'p',
      )
          .logLevel(DyplinkLogLevel.debug)
          .flushInterval(const Duration(seconds: 60))
          .maxQueueSize(500)
          .maxRetries(5)
          .sessionTimeout(const Duration(minutes: 10))
          .enableAutoSessionTracking(false)
          .enableAutoDeviceInfo(false)
          .deepLinkHosts(const ['a.example.com', 'b.example.com'])
          .customScheme('myapp')
          .build();

      expect(config.logLevel, DyplinkLogLevel.debug);
      expect(config.flushIntervalSeconds, 60);
      expect(config.maxQueueSize, 500);
      expect(config.maxRetries, 5);
      expect(config.sessionTimeoutSeconds, 600);
      expect(config.enableAutoSessionTracking, isFalse);
      expect(config.enableAutoDeviceInfo, isFalse);
      expect(config.deepLinkHosts, ['a.example.com', 'b.example.com']);
      expect(config.customScheme, 'myapp');
    });

    test('rejects blank required fields', () {
      expect(
        () => DyplinkConfig.builder(baseUrl: '', apiKey: 'k', projectId: 'p')
            .build(),
        throwsArgumentError,
      );
      expect(
        () => DyplinkConfig.builder(
          baseUrl: 'https://api.dyplink.com',
          apiKey: '',
          projectId: 'p',
        ).build(),
        throwsArgumentError,
      );
      expect(
        () => DyplinkConfig.builder(
          baseUrl: 'https://api.dyplink.com',
          apiKey: 'k',
          projectId: '',
        ).build(),
        throwsArgumentError,
      );
    });

    test('rejects non-positive flushInterval / maxQueueSize', () {
      expect(
        () => DyplinkConfig.builder(
          baseUrl: 'https://api.dyplink.com',
          apiKey: 'k',
          projectId: 'p',
        ).flushInterval(Duration.zero).build(),
        throwsArgumentError,
      );
      expect(
        () => DyplinkConfig.builder(
          baseUrl: 'https://api.dyplink.com',
          apiKey: 'k',
          projectId: 'p',
        ).maxQueueSize(0).build(),
        throwsArgumentError,
      );
    });

    test('rejects negative maxRetries', () {
      expect(
        () => DyplinkConfig.builder(
          baseUrl: 'https://api.dyplink.com',
          apiKey: 'k',
          projectId: 'p',
        ).maxRetries(-1).build(),
        throwsArgumentError,
      );
    });

    test('toDto produces matching Pigeon DTO', () {
      final config = DyplinkConfig.builder(
        baseUrl: 'https://api.dyplink.com',
        apiKey: 'k',
        projectId: 'p',
      ).logLevel(DyplinkLogLevel.info).build();
      final dto = config.toDto();
      expect(dto.baseUrl, config.baseUrl);
      expect(dto.apiKey, config.apiKey);
      expect(dto.projectId, config.projectId);
      expect(dto.flushIntervalSeconds, 30);
    });
  });

  group('IdentifyParamsBuilder', () {
    test('fluently sets every field', () {
      final params = IdentifyParams.builder()
          .distinctId('anon-1')
          .externalUserId('user-1')
          .firstName('Jane')
          .lastName('Doe')
          .phone('+15551234567')
          .avatar('https://example.com/a.png')
          .locale('en_US')
          .language('en')
          .appVersion('1.0.0')
          .appBuild('42')
          .traits(const {'plan': 'pro', 'age': 34})
          .utmSource('google')
          .utmMedium('cpc')
          .utmCampaign('spring')
          .utmContent('banner_a')
          .utmTerm('shoes')
          .installSource('play_store')
          .installCampaign('launch')
          .emailOptIn(true)
          .smsOptIn(false)
          .pushOptIn(true)
          .gdprConsent(true)
          .doNotTrack(false)
          .build();
      final dto = params.toDto();

      expect(dto.distinctId, 'anon-1');
      expect(dto.externalUserId, 'user-1');
      expect(dto.firstName, 'Jane');
      expect(dto.lastName, 'Doe');
      expect(dto.phone, '+15551234567');
      expect(dto.traits!['plan'], 'pro');
      expect(dto.traits!['age'], 34);
      expect(dto.utmSource, 'google');
      expect(dto.emailOptIn, isTrue);
      expect(dto.smsOptIn, isFalse);
      expect(dto.pushOptIn, isTrue);
      expect(dto.gdprConsent, isTrue);
      expect(dto.doNotTrack, isFalse);
    });

    test('unset fields are null in the DTO', () {
      final dto = IdentifyParams.builder().externalUserId('only-me').build().toDto();
      expect(dto.externalUserId, 'only-me');
      expect(dto.distinctId, isNull);
      expect(dto.firstName, isNull);
      expect(dto.traits, isNull);
      expect(dto.emailOptIn, isNull);
    });
  });

  group('DyplinkError.fromPlatformException', () {
    test('NOT_INITIALIZED code -> DyplinkNotInitialized', () {
      final e = DyplinkError.fromPlatformException(
        PlatformException(code: 'NOT_INITIALIZED', message: 'nope'),
      );
      expect(e, isA<DyplinkNotInitialized>());
      expect(e.message, 'nope');
    });

    test('INVALID_CONFIG code -> DyplinkInvalidConfig', () {
      final e = DyplinkError.fromPlatformException(
        PlatformException(code: 'INVALID_CONFIG', message: 'bad baseUrl'),
      );
      expect(e, isA<DyplinkInvalidConfig>());
      expect(e.message, 'bad baseUrl');
    });

    test('INVALID_ARGUMENT code -> DyplinkInvalidConfig (same bucket)', () {
      final e = DyplinkError.fromPlatformException(
        PlatformException(code: 'INVALID_ARGUMENT', message: 'empty'),
      );
      expect(e, isA<DyplinkInvalidConfig>());
    });

    test('NETWORK_ERROR with status in details', () {
      final e = DyplinkError.fromPlatformException(
        PlatformException(
          code: 'NETWORK_ERROR',
          message: 'timeout',
          details: {'statusCode': 504},
        ),
      );
      expect(e, isA<DyplinkNetworkError>());
      final ne = e as DyplinkNetworkError;
      expect(ne.statusCode, 504);
    });

    test('API_ERROR:404 -> DyplinkApiError with parsed status', () {
      final e = DyplinkError.fromPlatformException(
        PlatformException(
          code: 'API_ERROR:404',
          message: 'not found',
          details: {'responseBody': '{"error":"not_found"}'},
        ),
      );
      expect(e, isA<DyplinkApiError>());
      final ae = e as DyplinkApiError;
      expect(ae.statusCode, 404);
      expect(ae.responseBody, '{"error":"not_found"}');
      expect(ae.code, 'API_ERROR:404');
    });

    test('unknown code -> DyplinkUnknownError preserves original code', () {
      final e = DyplinkError.fromPlatformException(
        PlatformException(code: 'SOMETHING_ODD', message: 'huh'),
      );
      expect(e, isA<DyplinkUnknownError>());
      final ue = e as DyplinkUnknownError;
      expect(ue.originalCode, 'SOMETHING_ODD');
      expect(ue.code, 'SOMETHING_ODD');
    });
  });

  group('runCatchingDyplink', () {
    test('passes through on success', () async {
      final result = await runCatchingDyplink(() async => 42);
      expect(result, 42);
    });

    test('rewraps PlatformException into the right DyplinkError subclass',
        () async {
      await expectLater(
        () => runCatchingDyplink<void>(() async {
          throw PlatformException(
            code: 'NOT_INITIALIZED',
            message: 'init first',
          );
        }),
        throwsA(isA<DyplinkNotInitialized>()),
      );
    });

    test('non-PlatformException exceptions pass through unchanged', () async {
      await expectLater(
        () => runCatchingDyplink<void>(() async {
          throw StateError('not a platform exception');
        }),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            'not a platform exception',
          ),
        ),
      );
    });
  });

  group('DeepLinkResult.fromEventMap', () {
    test('decodes a full map', () {
      final result = DeepLinkResult.fromEventMap({
        'url': 'https://example.dyplink.com/abc',
        'shortCode': 'abc',
        'params': {'utm_source': 'email'},
        'isDeferred': false,
        'linkId': 'link-1',
      });

      expect(result.url, 'https://example.dyplink.com/abc');
      expect(result.shortCode, 'abc');
      expect(result.params!['utm_source'], 'email');
      expect(result.isDeferred, isFalse);
      expect(result.linkId, 'link-1');
    });

    test('decodes with nulls for optional fields', () {
      final result = DeepLinkResult.fromEventMap({
        'url': 'dyplinkexample://home',
        'shortCode': null,
        'params': null,
        'isDeferred': true,
        'linkId': null,
      });
      expect(result.url, 'dyplinkexample://home');
      expect(result.shortCode, isNull);
      expect(result.params, isNull);
      expect(result.isDeferred, isTrue);
      expect(result.linkId, isNull);
    });
  });

  group('TrackConversionParams.toDto', () {
    test('forwards every field', () {
      const params = TrackConversionParams(
        eventType: 'purchase',
        shortCode: 'abc',
        linkId: 'link-1',
        externalUserId: 'user-1',
        metadata: {'cart_total': 42.50, 'currency': 'USD'},
      );
      final dto = params.toDto();
      expect(dto.eventType, 'purchase');
      expect(dto.shortCode, 'abc');
      expect(dto.linkId, 'link-1');
      expect(dto.externalUserId, 'user-1');
      expect(dto.metadata!['cart_total'], 42.50);
      expect(dto.metadata!['currency'], 'USD');
    });
  });

}
