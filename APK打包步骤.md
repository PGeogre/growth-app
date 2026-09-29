# 个人成长 App —— Android APK 打包步骤

## 一、环境（本次已全部装好）

| 组件 | 路径 |
|------|------|
| Flutter SDK | `D:\flutter` |
| JDK 17 | `C:\Program Files\Microsoft\jdk-17.0.20.101-hotspot` |
| Android SDK | `D:\android-sdk` |

已配置的用户环境变量：`PATH`（含 `D:\flutter\bin`）、`JAVA_HOME`、`ANDROID_HOME`、`ANDROID_SDK_ROOT`。

> 若换了新终端窗口环境变量不生效，重启终端或手动执行一次：
> ```bat
> set PATH=%PATH%;D:\flutter\bin
> set JAVA_HOME=C:\Program Files\Microsoft\jdk-17.0.20.101-hotspot
> set ANDROID_HOME=D:\android-sdk
> set ANDROID_SDK_ROOT=D:\android-sdk
> ```

## 二、打包命令

```bat
cd /d E:\AISpace\qoder_workspace\english-coach
flutter build apk --release
```

产出文件：`build\app\outputs\flutter-apk\app-release.apk`

## 三、常用变体

| 命令 | 说明 |
|------|------|
| `flutter build apk --release` | 正式版（默认，已混淆+精简） |
| `flutter build apk --debug` | 调试版（可 adb 安装调试） |
| `flutter build apk --split-per-abi` | 按 CPU 架构拆分（更小，3 个包） |
| `flutter build appbundle` | 生成 AAB（上架 Google Play 用，本 App 不上架可忽略） |

## 四、真机安装

1. 手机开启「开发者选项 → USB 调试」。
2. USB 连接电脑，确认设备：`flutter devices` 或 `adb devices`。
3. 安装：`adb install build\app\outputs\flutter-apk\app-release.apk`
4. 或直接 `flutter run`（热重载调试）。

## 五、若后续换机器 / 重装环境

```bat
:: 1. 装 Flutter
git clone --depth 1 -b stable https://github.com/flutter/flutter.git D:\flutter

:: 2. 装 JDK17（winget）
winget install -e --id Microsoft.OpenJDK.17

:: 3. 装 Android cmdline-tools + SDK 组件
::   下载 commandlinetools-win-*.zip 解压到 D:\android-sdk\cmdline-tools\latest
sdkmanager --licenses
sdkmanager "platform-tools" "platforms;android-35" "build-tools;35.0.0"

:: 4. 验证
flutter doctor
```

## 六、常见问题

- **`Unable to locate Android SDK`**：确认 `ANDROID_HOME` 指向 `D:\android-sdk`。
- **Gradle 下载慢**：首次构建需联网下载 Gradle + 依赖，耐心等待；可配置国内镜像（阿里云 maven）加速。
- **签名**：默认用 debug 签名也能安装到真机；若要正式签名，用 `keytool` 生成 keystore 并配置 `android/app/build.gradle`。

## 七、v2 新增依赖说明

- `image_picker`：拍照/相册选图（饮食/心情/运动/便签附图）。
- `path_provider`：获取 App 私有目录，图片复制到 `getApplicationDocumentsDirectory()/images/`，卸载 App 会一并清除。
- 图片仅存本地路径到数据库，不存二进制。若需备份，需连同图片目录一起导出。

