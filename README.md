# 校易圈 — 校园二手交易 · 失物招领平台

基于 HarmonyOS + 仓颉 (Cangjie) 开发的校园综合服务平台。

## 功能

- **二手交易** — 浏览、搜索、发布二手商品
- **失物招领** — 发布和查找失物信息
- **分类浏览** — 按类别筛选商品
- **商品详情** — 查看商品信息与图片

## 技术栈

| 层级 | 技术 |
|------|------|
| 语言 | [仓颉 (Cangjie)](https://cangjie-lang.cn) |
| 框架 | HarmonyOS ArkUI |
| 构建 | Hvigor + OHPM |
| 目标 | HarmonyOS 5.0.1+ (API 17) |

## 快速开始

```bash
# 克隆仓库
git clone https://github.com/elevenm0384-cmyk/Xyq.app.git
cd Xyq.app

# 安装依赖
ohpm install

# 使用 DevEco Studio 打开项目根目录，运行到模拟器或真机
```

## 项目结构

```
Xyq.app/
├── AppScope/                # 应用全局配置
├── entry/
│   ├── src/main/
│   │   ├── cangjie/         # 仓颉源码
│   │   ├── resources/       # 资源文件 (图片、字符串等)
│   │   └── module.json5     # 模块配置
│   ├── build-profile.json5  # 模块构建配置
│   └── hvigorfile.ts        # 模块构建脚本
├── hvigor/                  # Hvigor 构建工具配置
├── build-profile.json5      # 项目构建配置
├── hvigorfile.ts            # 项目构建脚本
└── oh-package.json5         # 包管理配置
```

## License

MIT
