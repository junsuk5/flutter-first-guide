# Flutter First Guide 마이그레이션 가이드

작성일: 2026-06-07  
확인 환경: Flutter 3.44.1 stable, Dart 3.12.1, macOS arm64

이 문서는 오래된 Flutter 프로젝트를 최신 Flutter/Dart 환경으로 일괄 마이그레이션하기 위한 절차다. 인공지능 API에게 반복 수정 작업을 맡겨도 동일한 기준으로 수행되도록, 명령 순서와 수정 패턴을 구체적으로 정리했다. 파일은 전체 재작성보다 diff 기반으로 최소 수정한다.

## 현재 상태 요약

루트에는 9개 Flutter 프로젝트가 있다.

| 프로젝트 | 현재 SDK 제약 | 주요 의존성 | 상태 |
|---|---:|---|---|
| `first_flutter_app` | `>=2.17.6 <3.0.0` | `cupertino_icons` | `analysis_options.yaml`은 `flutter_lints`를 include하지만 pubspec에 `flutter_lints`가 없음 |
| `stop_watch` | `>=2.17.6 <3.0.0` | `cupertino_icons`, `flutter_lints` | 단순 앱, 코드 수정량 작음 |
| `tilt_sensor` | `>=2.18.1 <3.0.0` | `sensors_plus` | `sensors_plus` 대규모 상향 필요 |
| `my_gallery` | `>=2.18.1 <3.0.0` | `image_picker`, `carousel_slider`, `transparent_image` | 실제 코드에서 `carousel_slider`, `transparent_image` 미사용 |
| `gps_map` | `>=2.18.0 <3.0.0` | `google_maps_flutter`, `geolocator` | Android/iOS 최소 버전과 권한 설정 확인 필요 |
| `todolist` | `>=2.18.4 <3.0.0` | `hive`, `hive_flutter`, `intl`, `hive_generator`, `build_runner` | `build_runner` 최신 2.15.0은 `hive_generator`와 충돌 |
| `xylophone` | `>=2.18.1 <3.0.0` | `soundpool` | `soundpool`은 discontinued로 표시됨. `audioplayers` 대체 권장 |
| `bmi_calculator` | `>=3.0.0 <4.0.0` | `shared_preferences` | 가장 최근에 일부 마이그레이션된 프로젝트 |
| `my_web_browser` | `^3.0.0` | `webview_flutter` | WebView 4.x 구조는 이미 반영되어 있음. `PopScope.onPopInvoked`만 최신 API로 교체 |

모든 기존 `pubspec.lock`에는 Flutter SDK 패키지 `sky_engine 0.0.99`가 기록되어 있다. 최신 Flutter 3.44.1에서는 `sky_engine 0.0.0`으로 해석되므로 `flutter pub outdated`가 바로 실패할 수 있다. 이 경우 먼저 `pubspec.yaml`을 마이그레이션하고 `flutter pub upgrade`로 lockfile을 새로 만든다.

## 공통 마이그레이션 원칙

1. 프로젝트별로 독립적으로 처리한다. 루트에 workspace 설정이 없으므로 한 번에 전체를 묶지 않는다.
2. `pubspec.yaml`은 먼저 Dart SDK 제약을 올린다.
3. 의존성 버전은 `flutter pub upgrade --major-versions --dry-run` 출력과 pub.dev 최신 버전을 같이 본다.
4. `pubspec.lock`은 앱 프로젝트이므로 최종적으로 커밋한다. 단, 오래된 lockfile 때문에 명령이 깨지면 lockfile을 재생성한다.
5. 코드 수정은 `dart fix --apply`, `dart format .`, `flutter analyze`, `flutter test` 순서로 검증한다.
6. Android/iOS 러너 파일은 오래된 Groovy/Gradle 구조가 많으므로, 가능하면 최신 Flutter 템플릿으로 재생성하고 앱별 설정만 이식한다.

## 공통 명령 순서

각 프로젝트에서 다음 순서로 처리한다.

```bash
cd <project>
flutter --version
flutter pub upgrade --major-versions --dry-run
```

`pubspec.yaml`을 수정한 뒤:

```bash
flutter clean
rm -rf .dart_tool build
flutter pub get
flutter pub outdated --no-transitive
dart fix --dry-run
dart fix --apply
dart format .
flutter analyze
flutter test
```

빌드까지 보여줄 프로젝트는 다음도 실행한다.

```bash
flutter build apk --debug
flutter build ios --no-codesign
```

`flutter pub outdated`가 `sky_engine 0.0.99` 오류로 실패하면:

```bash
flutter pub upgrade --major-versions --dry-run
rm pubspec.lock
flutter pub get
flutter pub outdated --no-transitive
```

`rm pubspec.lock` 전에는 반드시 git diff 또는 백업을 남긴다.

## 공통 pubspec 기준

모든 프로젝트의 SDK 제약은 다음으로 통일한다.

```yaml
environment:
  sdk: ">=3.10.0 <4.0.0"
```

이 기준은 현재 최신 직접 의존성 중 `google_maps_flutter 2.17.1`이 Dart `^3.10.0`을 요구하기 때문에 잡은 값이다. 현재 확인한 Flutter 3.44.1에는 Dart 3.12.1이 포함되어 있어 충족된다.

공통으로 권장하는 dev dependency:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
```

## 프로젝트별 pubspec 목표

### first_flutter_app

```yaml
environment:
  sdk: ">=3.10.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.9

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
```

`analysis_options.yaml`이 이미 `package:flutter_lints/flutter.yaml`을 include하므로 `flutter_lints`를 반드시 추가한다.

### stop_watch

```yaml
environment:
  sdk: ">=3.10.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.9

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
```

### tilt_sensor

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.9
  sensors_plus: ^7.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
```

`sensors_plus` 최신 문서는 Android에서 센서 미지원 오류를 받을 수 있으므로 stream에 `onError` 처리를 권장한다. 현재 코드의 `accelerometerEvents`는 아직 제공되지만, 새 함수형 API를 쓰려면 다음처럼 바꾼다.

```dart
StreamBuilder<AccelerometerEvent>(
  stream: accelerometerEventStream(),
  builder: (context, snapshot) {
    // 기존 로직 유지
  },
)
```

iOS에서는 `ios/Runner/Info.plist`에 다음 키를 추가한다.

```xml
<key>NSMotionUsageDescription</key>
<string>기울기 센서 값을 사용하기 위해 필요합니다.</string>
```

### my_gallery

현재 코드에서는 `carousel_slider`, `transparent_image`를 사용하지 않는다. 최소 수정 기준으로는 제거한다.

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.9
  image_picker: ^1.2.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
```

만약 강의 흐름상 carousel을 유지해야 한다면 `carousel_slider: ^5.1.2`를 사용하고 실제 코드에 `CarouselSlider`를 적용한다. `transparent_image`는 미사용이므로 제거한다.

iOS `ios/Runner/Info.plist`에는 최소 다음을 추가한다.

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>사진을 선택하기 위해 사진 보관함 접근이 필요합니다.</string>
<key>NSCameraUsageDescription</key>
<string>사진 촬영을 위해 카메라 접근이 필요합니다.</string>
<key>NSMicrophoneUsageDescription</key>
<string>동영상 촬영 시 마이크 접근이 필요합니다.</string>
```

`image_picker 1.2.2`는 Android SDK 24+를 지원 대상으로 안내하므로 Android `minSdk`도 24 이상으로 맞춘다.

### gps_map

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.9
  google_maps_flutter: ^2.17.1
  geolocator: ^14.0.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
```

`google_maps_flutter 2.17.1`은 Android SDK 24+, iOS 14+를 지원 대상으로 안내한다. Android `minSdk`를 24 이상으로, iOS deployment target을 14.0 이상으로 맞춘다.

Android `AndroidManifest.xml`에는 위치 권한과 Google Maps API key를 확인한다.

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY" />
```

iOS `Info.plist`에는 다음을 확인한다.

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>현재 위치를 지도에 표시하기 위해 필요합니다.</string>
<key>io.flutter.embedded_views_preview</key>
<true/>
```

### todolist

최소 비용 마이그레이션은 Hive를 유지한다. 단, `build_runner`는 최신 `2.15.0`으로 올리지 않는다. 임시 검증 결과 `hive_generator 2.0.1`은 `build ^2` 계열에 묶여 있고 `build_runner >=2.9.0`은 `build ^4.0.0`을 요구해 충돌한다.

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.9
  hive_flutter: ^1.1.0
  hive: ^2.2.3
  intl: ^0.20.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  hive_generator: ^2.0.1
  build_runner: ^2.4.13
```

adapter 재생성:

```bash
dart run build_runner build --delete-conflicting-outputs
```

장기 유지보수까지 보여주려면 Hive 유지 대신 `drift` 또는 `objectbox`로 저장소를 바꾸는 별도 콘텐츠로 분리한다. 이 영상의 “가성비 일괄 마이그레이션” 목적에는 Hive 유지가 더 적합하다.

### xylophone

`soundpool`은 dry-run에서 discontinued로 표시된다. 최소 수정으로는 `soundpool: ^2.4.1`도 가능하지만, 최신 유지보수 관점에서는 `audioplayers`로 교체한다.

권장 pubspec:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.9
  audioplayers: ^6.7.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
```

코드 변경 패턴:

```dart
import 'package:audioplayers/audioplayers.dart';

late final List<AudioPool> _pools;

Future<void> initSoundPool() async {
  const assetNames = [
    'do1.wav',
    're.wav',
    'mi.wav',
    'fa.wav',
    'sol.wav',
    'la.wav',
    'si.wav',
    'do2.wav',
  ];

  _pools = [
    for (final assetName in assetNames)
      await AudioPool.createFromAsset(
        path: assetName,
        maxPlayers: 1,
        playerMode: PlayerMode.lowLatency,
      ),
  ];

  if (!mounted) return;
  setState(() {
    _isLoading = false;
  });
}

@override
void dispose() {
  for (final pool in _pools) {
    pool.dispose();
  }
  super.dispose();
}
```

버튼 탭은 `pool.play(soundId)` 대신 해당 index의 pool을 실행한다.

```dart
onTap: () {
  _pools[index].start();
}
```

### bmi_calculator

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.9
  shared_preferences: ^2.5.5

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
```

`shared_preferences`는 기존 `SharedPreferences.getInstance()` API가 아직 동작한다. 더 최신 스타일을 보여주려면 `SharedPreferencesAsync`로 바꾼다.

```dart
final prefs = SharedPreferencesAsync();
await prefs.setDouble('height', height);
final height = await prefs.getDouble('height');
```

단, 기존 저장 데이터 마이그레이션까지 다루려면 `legacy_to_async_migration_util`을 사용해야 하므로 영상에서는 최소 마이그레이션과 개선 마이그레이션을 분리한다.

### my_web_browser

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.9
  webview_flutter: ^4.13.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
```

현재 `WebViewController`와 `WebViewWidget` 구조는 이미 4.x 방식이다. 수정할 부분은 다음이다.

1. `dart:io` import 제거: 현재 파일에서 사용하지 않는다.
2. `PopScope.onPopInvoked`는 deprecated이므로 `onPopInvokedWithResult`로 교체한다.

```dart
PopScope(
  canPop: false,
  onPopInvokedWithResult: (didPop, result) async {
    if (didPop) return;
    if (await _webViewController.canGoBack()) {
      await _webViewController.goBack();
    }
  },
  child: WebViewWidget(controller: _webViewController),
)
```

`webview_flutter 4.13.1`은 Android SDK 24+, iOS 13+를 지원 대상으로 안내한다.

## 공통 Dart 코드 수정 패턴

### ThemeData

기존:

```dart
theme: ThemeData(
  primarySwatch: Colors.blue,
),
```

권장:

```dart
theme: ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
),
```

Material 2 화면을 유지하는 것이 영상 비교에 필요하면 임시로 다음처럼 둔다.

```dart
theme: ThemeData(
  useMaterial3: false,
  primarySwatch: Colors.blue,
),
```

단, Flutter 문서는 Material 3 전환을 권장하고 `useMaterial3` opt-out은 임시 수단이라고 설명한다.

### Key 전달

기존:

```dart
const MyWidget({Key? key}) : super(key: key);
```

권장:

```dart
const MyWidget({super.key});
```

### print

기존:

```dart
print(value);
```

권장:

```dart
debugPrint(value);
```

또는 로그가 필요 없는 강의 예제라면 제거한다.

### 비동기 후 setState/context

기존:

```dart
await save();
Navigator.push(context, route);
```

권장:

```dart
await save();
if (!context.mounted) return;
Navigator.push(context, route);
```

`State` 내부에서 비동기 작업 후 `setState`를 호출할 때:

```dart
if (!mounted) return;
setState(() {});
```

### Timer/StreamSubscription 정리

`Timer.periodic`, `Geolocator.getPositionStream().listen`, sensor stream 등을 직접 만들면 `dispose()`에서 cancel한다.

```dart
Timer? _timer;
StreamSubscription<Position>? _positionSubscription;

@override
void dispose() {
  _timer?.cancel();
  _positionSubscription?.cancel();
  super.dispose();
}
```

### lint로 잡히는 const

`flutter_lints 6.0.0` 적용 후 `prefer_const_constructors`, `prefer_final_fields`, `avoid_print`, `use_build_context_synchronously` 같은 경고가 늘어난다. 반복 작업용 인공지능 API에는 analyzer 출력의 파일/라인을 기준으로 하나씩 고치게 한다.

## Android/iOS 러너 마이그레이션

Flutter 3.44.1의 새 템플릿은 Android Gradle Kotlin DSL을 생성한다.

확인한 최신 템플릿 값:

| 항목 | Flutter 3.44.1 템플릿 |
|---|---|
| Android Gradle Plugin | `9.0.1` |
| Kotlin Gradle Plugin | `2.3.20` |
| Gradle wrapper | `9.1.0-all` |
| Android build file | `build.gradle.kts` |
| iOS deployment target | `13.0` |

기존 프로젝트 대부분은 Groovy `build.gradle`, `apply from: "$flutterRoot/packages/flutter_tools/gradle/flutter.gradle"`, Kotlin `1.6.10`, Gradle `7.4` 구조다. 이 구조는 최신 Flutter에서 점점 깨지기 쉽다.

권장 절차:

```bash
cd <project>
cp -R android android.before-migration
cp -R ios ios.before-migration
flutter create --platforms=android,ios .
```

그 다음 기존 설정을 새 러너에 이식한다.

1. Android `applicationId`
2. Android/iOS 권한
3. Google Maps API key
4. iOS `Info.plist` usage description
5. 앱 아이콘/LaunchScreen을 커스텀했다면 해당 리소스

앱별 최소 플랫폼:

| 프로젝트 | Android minSdk | iOS target |
|---|---:|---:|
| 기본 앱, stopwatch, bmi | Flutter 기본값 또는 23 이상 | 13.0 이상 |
| `my_gallery` | 24 이상 | 13.0 이상 |
| `gps_map` | 24 이상 | 14.0 이상 |
| `my_web_browser` | 24 이상 | 13.0 이상 |
| `tilt_sensor` | Flutter 기본값 또는 plugin 요구값 | 12.0 이상 |

## 인공지능 API 반복 작업용 프롬프트

아래 프롬프트를 프로젝트별로 하나씩 넣는다. 외부 도구 사용을 전제로 하지 않고, 제공된 파일과 명령 출력만 기준으로 반복 수정하게 한다.

```text
너는 Flutter 마이그레이션 작업자다. 제공된 파일 내용과 명령 출력만 기준으로 diff 기반 최소 수정만 수행해라.

목표:
- Flutter 3.44.1 / Dart 3.12.1 기준으로 프로젝트를 마이그레이션한다.
- pubspec.yaml의 environment sdk는 ">=3.10.0 <4.0.0"로 맞춘다.
- 의존성은 이 가이드의 프로젝트별 목표 버전으로 맞춘다.
- 전체 파일 재작성 금지. 필요한 줄만 수정한다.
- 수정 후 dart format, dart fix, flutter analyze 결과를 기준으로 추가 수정한다.

작업 순서:
1. pubspec.yaml만 먼저 수정한다.
2. flutter clean && rm -rf .dart_tool build && flutter pub get 실행 결과를 확인한다.
3. pub get이 의존성 충돌로 실패하면 pubspec만 다시 최소 수정한다.
4. dart fix --dry-run 후 dart fix --apply를 실행한다.
5. dart format . 실행.
6. flutter analyze 실행.
7. analyzer 오류와 경고를 파일/라인 기준으로 고친다.
8. flutter test 실행.
9. 가능한 경우 flutter build apk --debug 실행.

중요 규칙:
- 기존 기능을 바꾸지 않는다.
- print는 debugPrint로 바꾸거나 불필요하면 제거한다.
- async 이후 context 또는 setState 사용 전 mounted/context.mounted를 확인한다.
- Timer, StreamSubscription, AudioPool/AudioPlayer는 dispose에서 정리한다.
- Deprecated API는 최신 API로 교체한다.
- my_web_browser의 PopScope.onPopInvoked는 onPopInvokedWithResult로 바꾼다.
- xylophone은 soundpool 대신 audioplayers AudioPool 사용을 우선한다.
- todolist는 Hive를 유지하고 build_runner는 ^2.4.13으로 둔다. ^2.15.0으로 올리지 않는다.

완료 조건:
- flutter pub get 성공
- dart format . 성공
- flutter analyze 오류 0개
- flutter test 성공
- 변경 diff 요약 제출
```

## 참고 링크

- Dart `pub outdated`: https://dart.dev/tools/pub/cmd/pub-outdated
- Dart `pub upgrade`: https://dart.dev/tools/pub/cmd/pub-upgrade
- Flutter upgrade: https://docs.flutter.dev/install/upgrade
- Flutter breaking changes: https://docs.flutter.dev/release/breaking-changes
- Material 3 migration: https://docs.flutter.dev/release/breaking-changes/material-3-migration
- `PopScope.onPopInvoked` deprecation: https://api.flutter.dev/flutter/widgets/PopScope/onPopInvoked.html
- `image_picker`: https://pub.dev/packages/image_picker
- `sensors_plus`: https://pub.dev/packages/sensors_plus
- `google_maps_flutter`: https://pub.dev/packages/google_maps_flutter
- `webview_flutter`: https://pub.dev/packages/webview_flutter
- `audioplayers`: https://pub.dev/packages/audioplayers
- `shared_preferences`: https://pub.dev/packages/shared_preferences
