# SpendSmart - Deployment Guide

Complete guide for deploying SpendSmart to production.

## 🎯 Pre-Deployment Checklist

### ✅ Code Quality
- [ ] All features working correctly
- [ ] No console errors or warnings
- [ ] All forms validated properly
- [ ] Error handling in place
- [ ] Loading states implemented
- [ ] Empty states designed
- [ ] Code linted and formatted

### ✅ Database
- [ ] Supabase project created
- [ ] Database schema deployed
- [ ] RLS policies configured
- [ ] Indexes created
- [ ] Sample data tested
- [ ] Backup strategy in place

### ✅ Configuration
- [ ] Supabase credentials configured
- [ ] Environment variables set
- [ ] API keys secured
- [ ] App name and branding updated
- [ ] Icons and splash screens added

### ✅ Testing
- [ ] Manual testing completed
- [ ] All screens tested
- [ ] Forms validated
- [ ] Charts displaying correctly
- [ ] Navigation working
- [ ] Error scenarios tested

## 🌐 Web Deployment

### Option 1: Firebase Hosting (Recommended)

**Step 1: Install Firebase CLI**
```bash
npm install -g firebase-tools
```

**Step 2: Login to Firebase**
```bash
firebase login
```

**Step 3: Initialize Firebase**
```bash
firebase init hosting
```

**Step 4: Build for Web**
```bash
flutter build web --release
```

**Step 5: Deploy**
```bash
firebase deploy --only hosting
```

**Your app is live!** 🎉

### Option 2: Netlify

**Step 1: Build**
```bash
flutter build web --release
```

**Step 2: Deploy**
1. Go to [netlify.com](https://netlify.com)
2. Drag and drop `build/web` folder
3. Done!

### Option 3: Vercel

**Step 1: Install Vercel CLI**
```bash
npm install -g vercel
```

**Step 2: Build**
```bash
flutter build web --release
```

**Step 3: Deploy**
```bash
cd build/web
vercel
```

## 📱 Android Deployment

### Build APK

**Debug APK:**
```bash
flutter build apk --debug
```

**Release APK:**
```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Build App Bundle (for Play Store)

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### Google Play Store Deployment

**Step 1: Create Developer Account**
- Go to [play.google.com/console](https://play.google.com/console)
- Pay $25 one-time fee
- Complete registration

**Step 2: Create App**
1. Click "Create app"
2. Fill in app details:
   - App name: SpendSmart
   - Default language: English
   - App type: App
   - Free or paid: Free

**Step 3: Setup App Content**
1. Privacy Policy (required)
2. App category: Finance
3. Content rating questionnaire
4. Target audience
5. Store listing:
   - Short description
   - Full description
   - Screenshots (required)
   - Feature graphic
   - App icon

**Step 4: Upload App Bundle**
1. Go to "Production" → "Create new release"
2. Upload `app-release.aab`
3. Add release notes
4. Review and rollout

**Step 5: Submit for Review**
- Review all sections
- Submit for review
- Wait for approval (1-3 days)

## 🍎 iOS Deployment (macOS only)

### Build IPA

```bash
flutter build ios --release
```

### App Store Deployment

**Step 1: Apple Developer Account**
- Enroll at [developer.apple.com](https://developer.apple.com)
- Pay $99/year

**Step 2: Configure Xcode**
1. Open `ios/Runner.xcworkspace`
2. Select development team
3. Configure bundle identifier
4. Set version and build number

**Step 3: Create App in App Store Connect**
1. Go to [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. Click "My Apps" → "+"
3. Fill in app information

**Step 4: Archive and Upload**
1. In Xcode: Product → Archive
2. Click "Distribute App"
3. Select "App Store Connect"
4. Upload

**Step 5: Submit for Review**
- Add screenshots
- Write description
- Set pricing
- Submit for review
- Wait for approval (1-3 days)

## 🔒 Production Security

### Supabase RLS (Row Level Security)

**Update RLS policies for production:**

```sql
-- Remove demo policy
DROP POLICY "Allow all operations" ON expenses;

-- Add user-specific policies (with authentication)
CREATE POLICY "Users can view own expenses" ON expenses
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own expenses" ON expenses
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own expenses" ON expenses
  FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own expenses" ON expenses
  FOR DELETE
  USING (auth.uid() = user_id);
```

### Environment Variables

**Create `.env` file:**
```
SUPABASE_URL=your_production_url
SUPABASE_ANON_KEY=your_production_key
```

**Load in app:**
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

await dotenv.load();
final url = dotenv.env['SUPABASE_URL']!;
final key = dotenv.env['SUPABASE_ANON_KEY']!;
```

### API Key Security

- Never commit API keys to Git
- Use environment variables
- Rotate keys regularly
- Use different keys for dev/prod

## 📊 Analytics Setup (Optional)

### Google Analytics

**Step 1: Add dependency**
```yaml
dependencies:
  firebase_analytics: ^10.7.0
```

**Step 2: Initialize**
```dart
import 'package:firebase_analytics/firebase_analytics.dart';

final analytics = FirebaseAnalytics.instance;
```

**Step 3: Track events**
```dart
await analytics.logEvent(
  name: 'expense_added',
  parameters: {
    'category': category,
    'amount': amount,
  },
);
```

## 🔔 Push Notifications (Optional)

### Firebase Cloud Messaging

**Step 1: Add dependency**
```yaml
dependencies:
  firebase_messaging: ^14.7.0
```

**Step 2: Setup**
```dart
final messaging = FirebaseMessaging.instance;
await messaging.requestPermission();
```

## 🚀 Performance Optimization

### Web Optimization

**Enable caching:**
```bash
flutter build web --release --web-renderer canvaskit
```

**Optimize images:**
- Use WebP format
- Compress images
- Lazy load images

### App Optimization

**Reduce app size:**
```bash
flutter build apk --release --split-per-abi
```

**Enable obfuscation:**
```bash
flutter build apk --release --obfuscate --split-debug-info=build/debug-info
```

## 📈 Monitoring

### Sentry (Error Tracking)

**Step 1: Add dependency**
```yaml
dependencies:
  sentry_flutter: ^7.14.0
```

**Step 2: Initialize**
```dart
await SentryFlutter.init(
  (options) {
    options.dsn = 'your_sentry_dsn';
  },
  appRunner: () => runApp(MyApp()),
);
```

### Crashlytics

**Step 1: Add Firebase Crashlytics**
```yaml
dependencies:
  firebase_crashlytics: ^3.4.0
```

**Step 2: Initialize**
```dart
FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
```

## 🔄 CI/CD Setup (Optional)

### GitHub Actions

**Create `.github/workflows/deploy.yml`:**
```yaml
name: Deploy

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test
      - run: flutter build web --release
      - uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: '${{ secrets.GITHUB_TOKEN }}'
          firebaseServiceAccount: '${{ secrets.FIREBASE_SERVICE_ACCOUNT }}'
```

## 📝 Post-Deployment

### Monitor
- [ ] Check error logs
- [ ] Monitor performance
- [ ] Track user analytics
- [ ] Review crash reports

### Update
- [ ] Fix bugs promptly
- [ ] Add new features
- [ ] Update dependencies
- [ ] Improve performance

### Marketing
- [ ] Create landing page
- [ ] Social media presence
- [ ] App Store optimization
- [ ] User feedback collection

## 🎯 Production URLs

After deployment, update these:

**Web:**
- Production URL: `https://your-app.web.app`
- Staging URL: `https://staging.your-app.web.app`

**Android:**
- Play Store: `https://play.google.com/store/apps/details?id=com.example.spend_smart`

**iOS:**
- App Store: `https://apps.apple.com/app/spendsmart/id123456789`

## 🆘 Troubleshooting

### Build Failures

**Clean and rebuild:**
```bash
flutter clean
flutter pub get
flutter build [platform] --release
```

### Deployment Issues

**Check logs:**
```bash
firebase hosting:channel:deploy preview
```

### Performance Issues

**Profile the app:**
```bash
flutter run --profile
```

## 📚 Resources

- [Flutter Deployment Docs](https://flutter.dev/docs/deployment)
- [Firebase Hosting](https://firebase.google.com/docs/hosting)
- [Play Store Guidelines](https://play.google.com/console/about/guides/)
- [App Store Guidelines](https://developer.apple.com/app-store/review/guidelines/)

---

**Your app is ready for the world! 🌍🚀**
