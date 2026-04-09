# dyplink

Flutter SDK for [Dyplink](https://dyplink.com) — deep linking, attribution, in-app messages, and banners.

Mirrors the Android SDK (`dyplink-android-sdk`) API surface so multi-platform apps can share a single integration contract.

## Installation

```yaml
dependencies:
  dyplink:
    git:
      url: https://github.com/dyplink/dyplink-flutter-sdk.git
```

## Quick start

```dart
import 'package:dyplink/dyplink.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Dyplink.instance.init(
    const DyplinkConfig(
      baseUrl: 'https://api.dyplink.com',
      apiKey: 'your-api-key',
      projectId: 'your-project-id',
    ),
  );

  runApp(const MyApp());
}
```

### Identify a user

```dart
await Dyplink.instance.identify(
  IdentifyParams(
    externalUserId: 'user-123',
    firstName: 'Jane',
    traits: {'plan': 'pro'},
  ),
);
```

### Track events and conversions

```dart
Dyplink.instance.track('button_click', {'screen': 'home'});

await Dyplink.instance.trackConversion(
  TrackConversionParams(eventType: 'signup'),
);
```

### Deferred deep links

```dart
final result = await Dyplink.instance.matchDeferredDeepLink();
if (result.matched) {
  // Route the user using result.shortCode / result.params
}
```

### In-app messages

```dart
import 'package:dyplink/messages.dart';

// In your root widget
DyplinkMessages.instance.onAppOpen(context);

// On navigation
DyplinkMessages.instance.onScreenView(context, 'HomeScreen');

// On event
DyplinkMessages.instance.onEvent(context, 'purchase_complete');
```

### Banners

```dart
import 'package:dyplink/banners.dart';

DyplinkBannerCarousel(
  categoryId: 'home_banner',
  onBannerTap: (banner) => print('tapped ${banner.id}'),
);
```
