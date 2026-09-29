# Growth App · 个人成长

一款**离线优先、数据本地存储、无需登录**的个人成长提升 App。

不上架、不依赖服务器、不接云数据库，所有数据保存在手机本地 SQLite 中，适合长期个人使用。

## ✨ 功能

| 模块 | 说明 |
|------|------|
| 🏠 首页 | 今日概览 + 今日时间线 + 便签入口 + 打卡热力图 + 成就徽章 |
| ❤️ 健康 | 饮食记录（三餐+加餐）、睡眠记录（时长自动计算+趋势图）、运动记录（类型/时长/强度统计） |
| 📖 英语 | 每日单词（内置精选词库）、学习打卡（连续天数）、进度统计、周打卡图 |
| 🌱 成长 | 习惯追踪、目标管理（进度条）、心情记录（emoji+附图） |
| 📝 便签 | 彩色便签墙、置顶、搜索、图文便签 |
| 👤 我的 | 数据总览、主题切换（浅色/暗色/跟随系统）、成就统计 |

## 🎨 特性

- **离线优先**：全部数据本地存储，无网络也能用
- **图片支持**：饮食/心情/运动/便签可拍照或相册选图，存本地私有目录
- **坚持可视化**：GitHub 风格打卡热力图 + 连续天数成就徽章（3/7/15/30/100 天）
- **双主题**：柔和配色的浅色 + 暗色主题，可跟随系统
- **无登录**：不接入第三方账号，数据完全私有

## 🛠 技术栈

- **Flutter** 3.x（Material 3）
- **sqflite**（SQLite 本地存储）
- **flutter_riverpod**（状态管理）
- **fl_chart**（图表）
- **image_picker** + **path_provider**（图片选择与本地存储）
- **intl**（日期处理）

## 📁 目录结构

```
lib/
├─ main.dart              # 入口
├─ app.dart               # 根组件 + 5 Tab 导航 + 主题
├─ core/
│  ├─ theme/              # 浅/暗双主题
│  ├─ db/                 # SQLite 初始化 + 数据访问层
│  └─ utils/              # 日期工具
├─ models/                # 数据模型
├─ providers/             # Riverpod 状态管理
├─ features/
│  ├─ home/               # 首页（概览/时间线/热力图/徽章）
│  ├─ health/             # 健康（饮食/睡眠/运动）
│  ├─ english/            # 英语学习
│  ├─ growth/             # 成长中心（习惯/目标/心情）
│  ├─ notes/              # 便签
│  └─ profile/            # 我的
└─ shared/
   └─ widgets/            # 通用组件/图表/热力图/徽章/图片
```

## 🗄 数据库表

`words`（词库）、`daily_words`（每日单词计划）、`checkins`（打卡）、`habits` + `habit_logs`（习惯）、`goals`（目标）、`moods`（心情）、`meals`（饮食）、`sleeps`（睡眠）、`workouts`（运动）、`notes`（便签）、`app_settings`（设置）

## 🚀 构建

```bash
# 安装依赖
flutter pub get

# 运行（调试）
flutter run

# 打包 release APK
flutter build apk --release
# 产物：build/app/outputs/flutter-apk/app-release.apk
```

详见 `APK打包步骤.md`。

## 📱 环境要求

- Flutter SDK ≥ 3.x
- Android SDK（compileSdk 35）
- JDK 17

## 📄 许可

个人项目，自用为主。
