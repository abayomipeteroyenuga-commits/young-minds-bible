# Young Minds Bible — Strict Web App

This package is a standalone HTML/CSS/JavaScript web application. It does **not** require Flutter, Android, Codemagic, Gradle or an APK/AAB.

## Deploy
Upload the contents of this folder to a static host (Vercel, Netlify, GitHub Pages or normal web hosting). `index.html` is at the root and is the app entry point.

## Features
- PastorAbayomi Bible Stories logo included
- 66-book browser and chapter selector
- King James Bible reading
- Scripture search
- Bookmarks and personal notes stored in the browser
- Light/dark theme
- Responsive mobile/desktop interface
- Installable PWA manifest and service worker

## Bible text
The app loads the public KJV dataset from:
`https://raw.githubusercontent.com/midvash/bible-data/main/versions/en/kjv/kjv.json`

The app itself is static. The first Bible-text load therefore requires an internet connection. Site assets are cached by the service worker; browser/network caching may keep the KJV response available later depending on the browser.

For a completely self-contained offline deployment, place the verified 66-book KJV file at `assets/data/kjv.json` and change `DATA_URL` in `app.js` to `./assets/data/kjv.json`.
