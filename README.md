# 🌐 MacTranslator - macOS 原生中英即时翻译与智能生词本

一款专门为 macOS (Apple Silicon M系列芯片) 精心打造的原生中英互译及单词高效记忆工具。基于纯 SwiftUI 与 SwiftData 现代框架开发，界面高雅精致，交互丝滑。

---

## ✨ 核心特色

* **⚡ 实时免点击翻译**：引入 Combine 防抖机制（Debounce）。输入框文字发生变化后，无需点击任何按钮，停止输入 0.5 秒后自动触发高准度中英双向互译。
* **🗣️ macOS 原生双语发音**：深度调用 macOS 底层 `NSSpeechSynthesizer` 语音合成引擎，支持纯正英音/美音及标准中文离线朗读，完全免费。
* **📖 智能生词自动归档**：算法自动识别输入内容。当判定输入为单字或单词（非长句子）且翻译成功时，**无需手动收藏**，系统会自动将其归档至生词本。
* **🗂️ 现代生词管理**：采用三栏/两栏原生极简布局，支持生词的关键词全局搜索、添加时间排序以及“已掌握”状态的快捷标记。
* **🔋 极致性能与低功耗**：专为 M 系列芯片优化，原生 Swift 编译，零内存泄露，支持系统级深色模式（Dark Mode）。

---

## 🛠️ 技术栈说明

* **UI 框架**：SwiftUI (适配 macOS 14+)
* **数据持久化**：SwiftData (苹果现代对象关系映射框架)
* **自动化管理**：Swift Package Manager (SPM 纯净项目结构)
* **发音支持**：AppKit / NSSpeechSynthesizer

---

## 🚀 简易安装与运行指南

### 对于普通用户（直接运行编译版）

1. 前往本仓库的 **Releases** 页面，下载最新的 `MacTranslator.zip` 并解压。
2. 将解压出的 `MacTranslator.app` 拖入你的 **应用程序 (Applications)** 文件夹。

> ⚠️ **重要：绕过 macOS 安全拦截（Gatekeeper）**
> 由于本应用属于个人独立开发，未向苹果官方支付 99 刀年费进行数字签名。当您首次双击打开提示“无法检查恶意软件”或“应用已损坏”时，请按以下方式解锁：
>
> * **方法 A**：在“应用程序”文件夹中，**按住键盘 `Control` 键不放**，同时右键点击应用图标，在弹出的菜单中选择 **“打开”**，并在之后的弹窗中点击 **“仍然打开”**。
> * **方法 B（终极命令）**：如果依然打不开，请打开 Mac 的“终端 (Terminal)”，复制并运行以下命令（输入电脑密码回车即可）：
>     ```bash
>     sudo xattr -r -d com.apple.quarantine /Applications/MacTranslator.app
>     ```

### 对于极客与开发者（本地源码编译）

本专案采用纯 SPM 结构，无需复杂的 `.xcodeproj` 引导。

```bash
# 1. 克隆本仓库到本地
git clone [https://github.com/JiWenxingSix/MacTranslator.git](https://github.com/JiWenxingSix/MacTranslator.git)
cd MacTranslator

# 2. 使用项目内置的自动化脚本编译并拉起应用
chmod +x script/build_and_run.sh
./script/build_and_run.sh
