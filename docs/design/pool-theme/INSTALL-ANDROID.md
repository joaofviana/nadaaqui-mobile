# NadaAqui — instalar APK (Android)

## Artefatos Supabase live (`feat/supabase-live`)

| Build | Caminho |
|-------|---------|
| Debug | `dist/nadaaqui-supabase-debug.apk` |
| Release | `dist/nadaaqui-supabase-release.apk` |

Também saem em `build/app/outputs/flutter-apk/app-debug.apk` / `app-release.apk`.

Release usa assinatura **debug** (template Flutter) — só sideload / QA, não Play Store.

### dart-defines obrigatórios (Supabase)

Não há chave no repositório. Passe no build:

```bash
--dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co
--dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

Opcional: `--dart-define=API_BASE_URL=...` (WireMock). Se `SUPABASE_URL` estiver setado, o app **prefere Supabase**.

## Artefatos pool-theme (WireMock / UI only)

| Build | Caminho |
|-------|---------|
| Debug | `dist/nadaaqui-pool-theme-debug.apk` |
| Release | `dist/nadaaqui-pool-theme-release.apk` |

## Sideload no telefone

1. **Configurações → Segurança / Apps** → permita **Instalar apps desconhecidos** para Files/Chrome/Drive.
2. Copie o `.apk` para o telefone (USB, Drive, Telegram…).
3. Abra o arquivo → **Instalar** → abra **NadaAqui**.

### Via USB (`adb`)

```bash
adb install -r dist/nadaaqui-supabase-debug.apk
# ou
adb install -r dist/nadaaqui-supabase-release.apk
```

## Build local (Supabase)

Requer Android SDK 36 + JDK 17 (Temurin recomendado).

```bash
export ANDROID_HOME=/path/to/Android/Sdk
export JAVA_HOME=/path/to/jdk-17
export PATH="$JAVA_HOME/bin:$ANDROID_HOME/platform-tools:$PATH"
flutter config --android-sdk "$ANDROID_HOME"
flutter pub get

flutter build apk --debug \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY"

flutter build apk --release \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY"

mkdir -p dist
cp build/app/outputs/flutter-apk/app-debug.apk dist/nadaaqui-supabase-debug.apk
cp build/app/outputs/flutter-apk/app-release.apk dist/nadaaqui-supabase-release.apk
```

Tema padrão: **dark OLED**. Light pool-blue: `buildNadaAquiLightTheme()` / `ThemeMode.light`.
