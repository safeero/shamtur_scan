name: Build Flutter App

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v4

    - name: Set up Java
      uses: actions/setup-java@v3
      with:
        distribution: 'zulu'
        java-version: '17'

    - name: Set up Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.24.3'
        channel: 'stable'

    - name: Build APK Clean
      run: |
        # التأكد من استخدام أوامر flutter الصحيحة حصرياً بدلاً من dart
        
        # 1. إزالة ملف القفل القديم لتجنب التعارض
        rm -f pubspec.lock
        
        # 2. استخدام flutter pub add حصرياً
        flutter pub add flutter_blue_plus:^2.3.14 shared_preferences:^2.5.3 printing:^5.14.3
        
        # 3. إعادة توليد مجلد الأندرويد نظيفاً في الجذر
        rm -rf android
        flutter create --platforms=android .
        
        # 4. جلب الحزم وبناء ملف الـ APK النهائي
        flutter pub get
        flutter build apk --release
