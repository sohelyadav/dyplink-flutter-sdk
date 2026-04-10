import Flutter
import UIKit

/// iOS stub for the Dyplink Flutter plugin.
///
/// The Dyplink iOS native SDK is not yet implemented. This file registers
/// the Pigeon HostApi handlers so that Dart calls don't silently hang —
/// every method throws a `PigeonError(code: "UNIMPLEMENTED")` which the
/// Dart facade catches and rewraps as `DyplinkUnknownError`.
///
/// When the iOS SDK is ready:
///   1. Replace each `throw PigeonError(...)` with a real forwarding call
///      into the iOS SDK (the way `DyplinkPlugin.kt` forwards to the
///      Android SDK).
///   2. Wire up the three EventChannels (deep_links, push_tokens,
///      message_events).
///   3. Register a PlatformViewFactory for "com.dyplink.dyplink/banner_carousel".
///   4. Remove the `Platform.isAndroid` guards in the Dart facade.
public class DyplinkPlugin: NSObject, FlutterPlugin,
  DyplinkHostApi, DyplinkPushHostApi, DyplinkBannersHostApi, DyplinkMessagesHostApi
{

  public static func register(with registrar: FlutterPluginRegistrar) {
    let messenger = registrar.messenger()
    let instance = DyplinkPlugin()
    DyplinkHostApiSetup.setUp(binaryMessenger: messenger, api: instance)
    DyplinkPushHostApiSetup.setUp(binaryMessenger: messenger, api: instance)
    DyplinkBannersHostApiSetup.setUp(binaryMessenger: messenger, api: instance)
    DyplinkMessagesHostApiSetup.setUp(binaryMessenger: messenger, api: instance)
  }

  // MARK: - DyplinkHostApi

  func initialize(config: DyplinkConfigDto) throws {
    throw Self.unimplemented("Dyplink.initialize")
  }

  func isInitialized() throws -> Bool {
    // Report false so callers can do feature detection without exploding.
    return false
  }

  func distinctId() throws -> String {
    throw Self.unimplemented("Dyplink.distinctId")
  }

  func deviceFingerprint() throws -> String {
    throw Self.unimplemented("Dyplink.deviceFingerprint")
  }

  func identify(
    params: IdentifyParamsDto,
    completion: @escaping (Result<IdentifyResultDto, Error>) -> Void
  ) {
    completion(.failure(Self.unimplemented("Dyplink.identify")))
  }

  func track(eventName: String, properties: [String?: Any?]?) throws {
    throw Self.unimplemented("Dyplink.track")
  }

  func trackConversion(params: TrackConversionParamsDto) throws {
    throw Self.unimplemented("Dyplink.trackConversion")
  }

  func trackRevenue(amount: Double, currency: String) throws {
    throw Self.unimplemented("Dyplink.trackRevenue")
  }

  func matchDeferredDeepLink(
    completion: @escaping (Result<DeferredMatchResultDto, Error>) -> Void
  ) {
    completion(.failure(Self.unimplemented("Dyplink.matchDeferredDeepLink")))
  }

  func getAttributedShortCode() throws -> String? {
    return nil
  }

  func getAttributedLinkId() throws -> String? {
    return nil
  }

  func reset() throws {
    throw Self.unimplemented("Dyplink.reset")
  }

  func flush(completion: @escaping (Result<Void, Error>) -> Void) {
    completion(.failure(Self.unimplemented("Dyplink.flush")))
  }

  func startDeepLinkStream() throws {
    // No-op on iOS stub. The Dart side subscribes via EventChannel which
    // simply never emits; no error is surfaced.
  }

  func stopDeepLinkStream() throws {
    // No-op on iOS stub.
  }

  // MARK: - DyplinkPushHostApi

  // Note: this `initialize()` satisfies DyplinkPushHostApi (distinct from the
  // DyplinkHostApi.initialize(config:) above by signature).
  func initialize() throws {
    throw Self.unimplemented("DyplinkPush.initialize")
  }

  func isRegistered() throws -> Bool {
    return false
  }

  func registerToken(token: String, completion: @escaping (Result<Void, Error>) -> Void) {
    completion(.failure(Self.unimplemented("DyplinkPush.registerToken")))
  }

  func unregisterToken(completion: @escaping (Result<Void, Error>) -> Void) {
    completion(.failure(Self.unimplemented("DyplinkPush.unregisterToken")))
  }

  func startTokenStream() throws {
    // No-op.
  }

  func stopTokenStream() throws {
    // No-op.
  }

  // MARK: - DyplinkBannersHostApi

  func loadBanners(
    categoryId: String,
    completion: @escaping (Result<BannerCategoryDto, Error>) -> Void
  ) {
    completion(.failure(Self.unimplemented("DyplinkBanners.loadBanners")))
  }

  func clearCache() throws {
    // No-op on iOS stub.
  }

  // MARK: - DyplinkMessagesHostApi

  func onAppOpen() throws {
    throw Self.unimplemented("DyplinkMessages.onAppOpen")
  }

  func onScreenView(screen: String) throws {
    throw Self.unimplemented("DyplinkMessages.onScreenView")
  }

  func onEvent(event: String) throws {
    throw Self.unimplemented("DyplinkMessages.onEvent")
  }

  func startMessageEventStream() throws {
    // No-op.
  }

  func stopMessageEventStream() throws {
    // No-op.
  }

  // MARK: - Helpers

  private static func unimplemented(_ method: String) -> PigeonError {
    return PigeonError(
      code: "UNIMPLEMENTED",
      message:
        "\(method) is not yet implemented on iOS. The Dyplink iOS native SDK is still under development.",
      details: nil
    )
  }
}
