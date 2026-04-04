# OAuth Reference

This file stays tracked, but it is intentionally kept free of live local OAuth values.

## Use the root docs

See:

- `../../docs/OAUTH_REFERENCE.md`
- `../../docs/OAUTH_AND_SECRETS.md`

## Local-only values

Keep exact local client IDs, SHA fingerprints, and downloaded credential files out of this tracked file.

Store them in:

- `../.local/OAUTH.local.md`
- `../../oauthClient/web/`
- `../../oauthClient/android/`

## Current tracked guidance

- Flutter web uses a `Web application` OAuth client
- Flutter Android uses an `Android` OAuth client
- the app package name is `com.miracleprayer.app`
- backend validates the token audience against `GOOGLE_CLIENT_IDS`
