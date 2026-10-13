/// Centralized mapping of bundled asset images to their public Firebase Storage URLs.
/// This ensures any asset referenced in the admin panel or presets is saved to Firestore
/// as a Firebase Storage URL that the mobile app can access directly from Firebase.
class FirebaseAssetUrls {
  static const Map<String, String> _urlMap = {
    // Fleet
    'jet1.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fjet1.png?alt=media&token=a56733ab-e51a-4743-9520-e68e42707f83',
    'assets/jet1.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fjet1.png?alt=media&token=a56733ab-e51a-4743-9520-e68e42707f83',
    'jet2.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fjet2.png?alt=media&token=ba444cf7-6230-466b-8d51-b79ed8ef3ed7',
    'assets/jet2.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fjet2.png?alt=media&token=ba444cf7-6230-466b-8d51-b79ed8ef3ed7',
    'jet3.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fjet3.png?alt=media&token=7f7ffe9e-139b-47a5-b679-d904c17fe2fd',
    'assets/jet3.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fjet3.png?alt=media&token=7f7ffe9e-139b-47a5-b679-d904c17fe2fd',
    'chopper.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fchopper.png?alt=media&token=c75b85e9-9de8-4f54-9308-c263f4e2f241',
    'assets/chopper.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fchopper.png?alt=media&token=c75b85e9-9de8-4f54-9308-c263f4e2f241',

    // Destinations
    'des1.jpg': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fdes1.jpg?alt=media&token=8b57a071-b393-4275-82b3-8cc0dbed94e5',
    'assets/des1.jpg': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fdes1.jpg?alt=media&token=8b57a071-b393-4275-82b3-8cc0dbed94e5',
    'des2.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fdes2.png?alt=media&token=f3ce7faa-4646-469b-aa75-77c29a4f3585',
    'assets/des2.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fdes2.png?alt=media&token=f3ce7faa-4646-469b-aa75-77c29a4f3585',
    'des3.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fdes3.png?alt=media&token=efdaa035-5c26-4836-a7ba-7ca82125c94a',
    'assets/des3.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fdes3.png?alt=media&token=efdaa035-5c26-4836-a7ba-7ca82125c94a',
    'des4.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fdes4.png?alt=media&token=c89b07f1-63f7-441d-9c5f-773996cb33d1',
    'assets/des4.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fdes4.png?alt=media&token=c89b07f1-63f7-441d-9c5f-773996cb33d1',
    'des5.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fdes5.png?alt=media&token=a11dc787-ac44-4e3b-a42b-b1bd50d90911',
    'assets/des5.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fdes5.png?alt=media&token=a11dc787-ac44-4e3b-a42b-b1bd50d90911',
    'des6.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fdes6.png?alt=media&token=34b0edb3-37ac-48b7-b98a-b77661fefcd8',
    'assets/des6.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fdes6.png?alt=media&token=34b0edb3-37ac-48b7-b98a-b77661fefcd8',
    'des7.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fdes7.png?alt=media&token=ff7f807d-9b0b-4971-b5c8-802d03f07d18',
    'assets/des7.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fdes7.png?alt=media&token=ff7f807d-9b0b-4971-b5c8-802d03f07d18',
    'des8.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fdes8.png?alt=media&token=2c315505-f5ed-4bd6-a75c-b5b68a5b34a8',
    'assets/des8.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fdes8.png?alt=media&token=2c315505-f5ed-4bd6-a75c-b5b68a5b34a8',
    'des9.webp': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fdes9.webp?alt=media&token=401c813f-f6dc-4f19-bbc1-845520ec5b80',
    'assets/des9.webp': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fdes9.webp?alt=media&token=401c813f-f6dc-4f19-bbc1-845520ec5b80',
    'des10.webp': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fdes10.webp?alt=media&token=46d5425f-a8dd-48b0-b6ac-c9014b400e94',
    'assets/des10.webp': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fdes10.webp?alt=media&token=46d5425f-a8dd-48b0-b6ac-c9014b400e94',

    // Blogs
    'blog3.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fblog3.png?alt=media&token=20e5a73e-634b-4ec4-90c5-9291d1e6739f',
    'assets/blog3.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fblog3.png?alt=media&token=20e5a73e-634b-4ec4-90c5-9291d1e6739f',
    'blog4.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fblog4.png?alt=media&token=59605190-f8d7-49ef-bc4c-5d7704296ba4',
    'assets/blog4.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fblog4.png?alt=media&token=59605190-f8d7-49ef-bc4c-5d7704296ba4',
    'blog5.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fblog5.png?alt=media&token=9b1036b3-f54d-401d-a227-43999a5f2c7f',
    'assets/blog5.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fblog5.png?alt=media&token=9b1036b3-f54d-401d-a227-43999a5f2c7f',
    'blog6.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fblog6.png?alt=media&token=f7019ef2-cbb0-4bea-95fb-6ec2a3967633',
    'assets/blog6.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fblog6.png?alt=media&token=f7019ef2-cbb0-4bea-95fb-6ec2a3967633',
    'blog7.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fblog7.png?alt=media&token=2a127921-211f-4dd2-82ef-0b83a017841b',
    'assets/blog7.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fblog7.png?alt=media&token=2a127921-211f-4dd2-82ef-0b83a017841b',
    'blog8.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fblog8.png?alt=media&token=d26cbe50-3e85-4d63-81d5-a6aecfb7f72a',
    'assets/blog8.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fblog8.png?alt=media&token=d26cbe50-3e85-4d63-81d5-a6aecfb7f72a',
    'blog9.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fblog9.png?alt=media&token=19d40759-d51e-4567-aacc-c914e5776f3a',
    'assets/blog9.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fblog9.png?alt=media&token=19d40759-d51e-4567-aacc-c914e5776f3a',
    'blog10.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fblog10.png?alt=media&token=6cb5ce05-427d-42a3-9403-f5794e9b2d81',
    'assets/blog10.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fblog10.png?alt=media&token=6cb5ce05-427d-42a3-9403-f5794e9b2d81',
    'blog11.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fblog11.png?alt=media&token=cfb40ad2-940d-4663-84b1-a40727a937c0',
    'assets/blog11.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fblog11.png?alt=media&token=cfb40ad2-940d-4663-84b1-a40727a937c0',

    // Concierge
    'hotelBooking.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2FhotelBooking.png?alt=media&token=626ab22b-95e9-45fb-b4b7-03e6ce88ea95',
    'assets/hotelBooking.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2FhotelBooking.png?alt=media&token=626ab22b-95e9-45fb-b4b7-03e6ce88ea95',
    'conciergeService.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2FconciergeService.png?alt=media&token=f61aa6ad-3bf1-431b-9669-a77f365a11f9',
    'assets/conciergeService.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2FconciergeService.png?alt=media&token=f61aa6ad-3bf1-431b-9669-a77f365a11f9',
    'concierge2.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fconcierge2.png?alt=media&token=cff3a72f-613b-4c93-8cd5-141e70b38660',
    'assets/concierge2.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fconcierge2.png?alt=media&token=cff3a72f-613b-4c93-8cd5-141e70b38660',
    'concierge3.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fconcierge3.png?alt=media&token=21b0962f-7a2b-4819-878e-73df91884470',
    'assets/concierge3.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fconcierge3.png?alt=media&token=21b0962f-7a2b-4819-878e-73df91884470',
    'concierge4.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fconcierge4.png?alt=media&token=c58d38fc-4143-49d5-a900-dfe0b95668dc',
    'assets/concierge4.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fconcierge4.png?alt=media&token=c58d38fc-4143-49d5-a900-dfe0b95668dc',
    'concierge5.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fconcierge5.png?alt=media&token=3dd76d23-d1d0-4f72-849f-9cfd0114e5cf',
    'assets/concierge5.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fconcierge5.png?alt=media&token=3dd76d23-d1d0-4f72-849f-9cfd0114e5cf',

    // Branding & Common
    'homeimage.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fhomeimage.png?alt=media&token=ebe29452-39ee-4865-9b68-f668ea358703',
    'assets/homeimage.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fhomeimage.png?alt=media&token=ebe29452-39ee-4865-9b68-f668ea358703',
    'slslogo.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fslslogo.png?alt=media&token=b6a21dd7-dc87-4360-b5c6-d2eb6fb14fef',
    'assets/slslogo.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Fslslogo.png?alt=media&token=b6a21dd7-dc87-4360-b5c6-d2eb6fb14fef',
    'fly_private.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Ffly_private.png?alt=media&token=afc75895-ea4d-4126-a68c-e66438cd47d9',
    'assets/fly_private.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2Ffly_private.png?alt=media&token=afc75895-ea4d-4126-a68c-e66438cd47d9',
    '10Most.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2F10Most.png?alt=media&token=5f45b1f4-ef2c-4a1f-a1a6-1cb82e432c12',
    'assets/10Most.png': 'https://firebasestorage.googleapis.com/v0/b/swissproject-33b18.firebasestorage.app/o/app_assets%2F10Most.png?alt=media&token=5f45b1f4-ef2c-4a1f-a1a6-1cb82e432c12',
  };

  /// Returns the public Firebase Storage download URL for the given asset path.
  /// If the path is already an http/https URL, it is returned as-is.
  /// If no Firebase URL is registered for the asset, returns [assetPath].
  static String getUrl(String assetPath) {
    if (assetPath.isEmpty) return '';
    if (assetPath.startsWith('http://') || assetPath.startsWith('https://')) {
      return assetPath;
    }
    final clean = assetPath.trim();
    if (_urlMap.containsKey(clean)) {
      return _urlMap[clean]!;
    }
    final basename = clean.split('/').last;
    if (_urlMap.containsKey(basename)) {
      return _urlMap[basename]!;
    }
    return clean;
  }

  /// Returns true if this path is known and has a Firebase Storage URL mapping.
  static bool hasFirebaseUrl(String assetPath) {
    final clean = assetPath.trim();
    return _urlMap.containsKey(clean) || _urlMap.containsKey(clean.split('/').last);
  }

  /// Returns the bundled local asset path ('assets/...') corresponding to a Firebase Storage URL or asset name,
  /// or null if no matching local bundled asset exists.
  static String? getAssetPath(String urlOrPath) {
    if (urlOrPath.isEmpty) return null;
    final clean = urlOrPath.trim();
    for (final entry in _urlMap.entries) {
      if (entry.key.startsWith('assets/') && entry.value == clean) {
        return entry.key;
      }
    }
    for (final entry in _urlMap.entries) {
      if (entry.key.startsWith('assets/')) {
        final filename = entry.key.split('/').last;
        if (clean.contains(filename)) {
          return entry.key;
        }
      }
    }
    if (clean.startsWith('assets/')) {
      return clean;
    }
    return null;
  }
}
