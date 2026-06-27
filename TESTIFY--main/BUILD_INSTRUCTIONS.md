# Building Testify into an APK

This project was missing the native `android/` platform folder, and `lib/main.dart`
had a broken import (`dashboard_screen.dart` didn't exist — fixed to use the real
`HomeScreen` from `home_screen.dart`). A GitHub Actions workflow has been added that
builds the APK for you automatically, since building requires the Flutter SDK,
Android SDK, and internet access that this chat environment doesn't have.

## Option A — Let GitHub build it for you (no local setup needed)

1. Create a new repo on GitHub and push this folder to it:
   ```
   git init
   git add .
   git commit -m "Initial commit"
   git branch -M main
   git remote add origin https://github.com/<you>/<repo>.git
   git push -u origin main
   ```
2. Go to the **Actions** tab on your GitHub repo. The "Build APK" workflow
   runs automatically on push (takes ~3-5 minutes).
3. Once it finishes (green check), click into the run → scroll to
   **Artifacts** → download **testify-apk**. Unzip it to get `app-release.apk`.
4. Transfer the APK to your Android phone and tap it to install
   (you may need to allow "install unknown apps" for your file manager/browser).

You can also trigger a build manually anytime from the Actions tab using
"Run workflow" (workflow_dispatch).

## Option B — Build locally (if you install Flutter)

```
flutter create --platforms=android --org com.testify .
flutter pub get
flutter build apk --release
```
The APK will be at `build/app/outputs/flutter-apk/app-release.apk`.

## Note

Since there's no Flutter SDK available in this chat environment, the
Dart code itself hasn't been compile-checked beyond fixing the one
broken import found above. If the GitHub Actions build fails, check the
Actions log — it'll point to the exact file/line of any remaining error,
and you're welcome to paste that log back here for help fixing it.
