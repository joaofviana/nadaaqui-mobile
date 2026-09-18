# NadaAqui — instalar APK (Android)

## Artefatos desta branch (`feat/pool-theme`)

| Build | Caminho |
|-------|---------|
| Debug | `dist/nadaaqui-pool-theme-debug.apk` (também `build/app/outputs/flutter-apk/app-debug.apk`) |
| Release | `dist/nadaaqui-pool-theme-release.apk` (também `build/app/outputs/flutter-apk/app-release.apk`) |

Release usa assinatura **debug** (template Flutter) — só sideload / QA, não Play Store.

## Sideload no telefone

1. **Configurações → Segurança / Apps** → permita **Instalar apps desconhecidos** para Files/Chrome/Drive.
2. Copie o `.apk` para o telefone (USB, Drive, Telegram…).
3. Abra o arquivo → **Instalar** → abra **NadaAqui**.

### Via USB (`adb`)

```bash
adb install -r dist/nadaaqui-pool-theme-debug.apk
# ou
adb install -r dist/nadaaqui-pool-theme-release.apk
```

## Build local

Requer Android SDK 36 + JDK 17 (Temurin recomendado; OpenJDK Debian pode falhar no toolchain Gradle).

```bash
export ANDROID_HOME=/path/to/Android/Sdk
export JAVA_HOME=/path/to/jdk-17
export PATH="$JAVA_HOME/bin:$ANDROID_HOME/platform-tools:$PATH"
flutter config --android-sdk "$ANDROID_HOME"
flutter pub get
flutter analyze
flutter build apk --debug
flutter build apk --release
```

Tema padrão: **dark OLED**. Light pool-blue: `buildNadaAquiLightTheme()` / `ThemeMode.light`.
