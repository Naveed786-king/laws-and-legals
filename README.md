# Laws And Legals - Android News App (Demo Mode)

A Flutter/Android news application for lawsandlegals.com, built entirely in
**Demo Mode** with no live WordPress connection. Every WordPress integration
point is a configurable field in Settings > Configure Everything, defaulting
to "Not Configured" until filled in.

## Stack

- Flutter (Android only for now; iOS later)
- Material 3, Clean Architecture-inspired layout (core / data / domain / features)
- Riverpod for state management
- Hive for offline-first local storage (bookmarks, config, search history, theme)
- Dio + Firebase (Core/Messaging) wired in but inert until configured
- GitHub Actions builds APK (debug, installable) and AAB (release, for future Play Store) automatically

## What's implemented so far

- Theme Manager (single source of brand colors/typography, light + dark mode)
- Optional login screen (Google/Email disabled until configured, Skip always works)
- Home with dynamic, unlimited sections pulled from a category list, each with
  a lead card + list + configurable banner position (above/below/none)
- Categories grid + per-category post list
- Post detail: featured image, title, author, date, share, bookmark, related
  posts, top/bottom banner slots
- Search: recent searches (persisted) + trending searches
- Offline bookmarks (Hive-backed, cloud-sync ready)
- Custom Pages list + detail (About, Contact, Advertise, Privacy, Terms)
- YouTube module (demo videos, links out to the YouTube app/browser)
- Settings: dark/light/system theme, cache clear, developer mode toggle, app
  version, and the full **Configure Everything** panel covering all 15
  WordPress integration points (Website URL, REST API, Firebase, Notifications,
  Banner/Splash/WooCommerce/YouTube/Logo/Theme/Pages/Menu/Category/Post/Image APIs)

## Still to build (next iteration)

- Firebase Cloud Messaging permission request + token registration flow
- Advertisement Manager is modeled (BannerAd entity) but only demo banners
  are wired up - the real endpoint will populate the same widgets once
  configured
- Beginner-friendly full documentation (separate DOCS.md) explaining Flutter,
  WordPress REST API, and Firebase setup step by step
- WooCommerce membership/subscription screens (future-ready per spec, not
  active yet)

## Suggested categories to add in the Admin Panel

To match the reference site's information architecture, create these categories
under Admin Panel > Home Sections (order doesn't matter, just add them once):

टॉप स्टोरीज, राष्ट्रीय, रिपोर्टेबल जजमेंट, लॉज एंड लीगल्स, कानून, बार व बेंच,
आर्ट एंड जस्टिस, लीगल सर्विस, लीगल एज्यूकेशन, परिचर्चा

Then add a Home Section for each one you want to appear on the home page.
This is just a starting taxonomy - add, rename, or remove categories anytime
from the Admin Panel with no app rebuild needed.

## Building the APK/AAB

Every push to `main` triggers `.github/workflows/build.yml`, which:
1. Sets up Flutter on GitHub's cloud runner (no local install needed)
2. Generates the Android platform folder fresh (`flutter create --platforms=android`)
   so Gradle/Kotlin versions always match the Flutter SDK version used
3. Builds a debug APK (directly installable) and a release AAB (for future Play Store)
4. Publishes both as a GitHub Release - download the APK directly from the
   repo's **Releases** page, no zip extraction needed

## Demo Mode -> Live

Everything reads through `ContentRepository`. Flip `demo_mode_enabled` to
false (done automatically by "Configure Everything" once Website URL and
REST API URL validate) and the same screens start reading from your live
WordPress site - no rebuild required for content, only for deeper structural
changes.
