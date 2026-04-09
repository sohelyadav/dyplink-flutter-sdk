/// Dyplink Flutter SDK — core library.
///
/// Provides the main [Dyplink] singleton, configuration, and public
/// model types. Import additional features from their dedicated
/// barrels:
///
/// - `package:dyplink/messages.dart` — in-app messages
/// - `package:dyplink/banners.dart` — in-app banners
library dyplink;

export 'src/dyplink.dart';
export 'src/dyplink_config.dart';
export 'src/models/deep_link_result.dart';
export 'src/models/deferred_match_result.dart';
export 'src/models/dyplink_error.dart';
export 'src/models/identify_params.dart';
export 'src/models/identify_result.dart';
export 'src/models/track_conversion_params.dart';
