# Firestore Schema - Laws And Legals Admin

## Collections

### `posts/{postId}`
- title (string)
- excerpt (string)
- content (string, plain text/simple HTML paragraphs)
- imageUrl (string, Storage download URL)
- author (string)
- categoryId (string, references categories/{id})
- categoryName (string, denormalized for fast reads)
- tags (array<string>)
- publishedAt (timestamp)
- updatedAt (timestamp)
- status ('published' | 'draft')

### `categories/{categoryId}`
- name (string)
- order (number) - controls nav/section order

### `banners/{bannerId}`
- imageUrl (string)
- destinationUrl (string)
- position (string: 'home_top' | 'home_middle' | 'post_bottom' | ...)
- priority (number)
- isEnabled (bool)
- isVisible (bool)

### `pages/{slug}`  (doc id IS the slug: about, contact, advertise, privacy, terms, or custom)
- title (string)
- content (string, plain text/simple HTML)
- updatedAt (timestamp)

### `homeSections/{sectionId}`
- title (string)
- categoryId (string)
- bannerPosition ('above' | 'below' | 'none')
- order (number)
- isEnabled (bool)

### `theme/config` (single document)
- primaryColor (string, hex)
- secondaryColor (string, hex)
- accentColor (string, hex)
- backgroundColor (string, hex)

### `splash/config` (single document)
- logoUrl (string)
- backgroundColor (string, hex)
- durationMs (number)
- text (string)

### `youtube/config` (single document)
- channelId (string)
- videos (array of {videoId, title, thumbnailUrl})

## Auth
Only signed-in Firebase Auth users (added manually by you in the Firebase
Console > Authentication > Users) can read/write via the Admin Panel.
The Android app reads with public read-only rules (see storage.rules /
firestore.rules) and never writes.
