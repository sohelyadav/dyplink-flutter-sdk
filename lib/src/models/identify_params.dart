/// Parameters for the `identify` API call.
///
/// All fields are optional — omit anything you don't need to update.
class IdentifyParams {
  const IdentifyParams({
    this.distinctId,
    this.externalUserId,
    this.firstName,
    this.lastName,
    this.phone,
    this.avatar,
    this.locale,
    this.language,
    this.appVersion,
    this.appBuild,
    this.traits,
    this.utmSource,
    this.utmMedium,
    this.utmCampaign,
    this.utmContent,
    this.utmTerm,
    this.installSource,
    this.installCampaign,
    this.emailOptIn,
    this.smsOptIn,
    this.pushOptIn,
    this.gdprConsent,
    this.doNotTrack,
  });

  final String? distinctId;
  final String? externalUserId;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? avatar;
  final String? locale;
  final String? language;
  final String? appVersion;
  final String? appBuild;
  final Map<String, dynamic>? traits;
  final String? utmSource;
  final String? utmMedium;
  final String? utmCampaign;
  final String? utmContent;
  final String? utmTerm;
  final String? installSource;
  final String? installCampaign;
  final bool? emailOptIn;
  final bool? smsOptIn;
  final bool? pushOptIn;
  final bool? gdprConsent;
  final bool? doNotTrack;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    void put(String key, dynamic value) {
      if (value != null) map[key] = value;
    }

    put('distinctId', distinctId);
    put('externalUserId', externalUserId);
    put('firstName', firstName);
    put('lastName', lastName);
    put('phone', phone);
    put('avatar', avatar);
    put('locale', locale);
    put('language', language);
    put('appVersion', appVersion);
    put('appBuild', appBuild);
    put('traits', traits);
    put('utmSource', utmSource);
    put('utmMedium', utmMedium);
    put('utmCampaign', utmCampaign);
    put('utmContent', utmContent);
    put('utmTerm', utmTerm);
    put('installSource', installSource);
    put('installCampaign', installCampaign);
    put('emailOptIn', emailOptIn);
    put('smsOptIn', smsOptIn);
    put('pushOptIn', pushOptIn);
    put('gdprConsent', gdprConsent);
    put('doNotTrack', doNotTrack);
    return map;
  }
}
