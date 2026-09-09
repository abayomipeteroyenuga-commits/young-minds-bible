# Young Minds Bible v1.2 — Web App Index

Web support has been prepared with:

- `web/index.html` — branded Flutter web bootstrap page.
- `web/manifest.json` — installable PWA metadata.
- `web/favicon.png` and web icons generated from the new PastorAbayomi Bible Stories logo.
- Responsive startup screen showing the new logo while Flutter loads.
- Flutter first-frame splash removal.
- Mobile/Apple web app metadata.
- Codemagic `young-minds-bible-web` workflow that prepares and verifies the full KJV before running `flutter build web --release`.
- App version advanced to `1.2.0+3`.

## Deployment
Run the Codemagic Web workflow, then deploy the generated `build/web` directory to a static host such as Vercel, Netlify, Firebase Hosting, or a normal web server.

For a subdirectory deployment instead of a domain root, build with the appropriate Flutter `--base-href` value.
