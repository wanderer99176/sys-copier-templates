创建 `sys-copier-templates` 仓库结构并同步云端** 的执行指南。

# 第 1 步：构建 Mono-repo 地基 (sys-copier-templates)

这一步的目标是创建一个空的“容器”仓库，用来存放未来所有的模版。

## 1.1 创建目录结构与基础文件

在 PowerShell 中执行以下命令：

```PowerShell
# 1. 创建并进入总仓库目录
cd D:
mkdir sys-copier-templates; cd sys-copier-templates

# 2. 初始化 Git
git init

# 3. 创建存放所有模版的子目录 (templates)
mkdir templates

# 4. 创建全局忽略文件 (.gitignore)
# 注意：这里配置的是整个仓库通用的忽略规则
@"
.DS_Store
**/.venv/
**/node_modules/
**/__pycache__/
**/.next/
**/.git/
test-output/
*.pyc
"@ | Out-File -Encoding utf8 .gitignore

# 5. 创建全局说明文档 (README.md)
# 先写个简单的框架，后续步骤6再来完善详细的使用说明
@"
# System Copier Templates (Mono-repo)

这是我的个人全栈开发模版集合仓库。

## 目录结构

- templates/
  - py-fastapi-react/  (FastAPI + React Vite)
  - py-fastapi-next/   (FastAPI + Next.js)

## 使用方法 (预览)

使用 Copier 的 \`--sub-project\` (或 \`-s\`) 参数来指定使用哪个模版。

# 示例
copier copy --trust -s templates/py-fastapi-react gh:your-username/sys-copier-templates ./my-project

"@ | Out-File -Encoding utf8 README.md
```

## 1.2 提交并创建云端仓库

```PowerShell
# 1. 提交初始地基代码
git add .
git commit -m "chore: Initialize mono-repo structure"

# 2. 使用 GitHub CLI 创建远程仓库
# 注意：名字是 sys-copier-templates，设为公有(public)方便调用
gh repo create sys-copier-templates --public --source=. --remote=origin

# 3. 推送主分支到云端
git push -u origin main
```

---

**✅ 第 1 步完成标准：**

1. 您在 GitHub 上能看到名为 `sys-copier-templates` 的仓库。
    
2. 仓库里有一个空的 `templates/` 文件夹（或者因为空文件夹 Git 不上传，可能只看到 README 和 .gitignore，这没关系，下一步放入模版后就会出现）。
    
3. 本地 `sys-copier-templates` 文件夹已准备好接收模版。


好的，明白了。您是希望将**详细的构建步骤**剥离出来，分别放入对应的子页面（`[[py-fastapi-react模版]]` 和 `[[py-fastapi-next模版]]`），而主教程 A 只保留流程大纲和这两个链接。

# **第 2 步：依据需求创建本地模版** 的详细执行内容。

为了方便您直接复制到 Obsidian 的子页面中，我将这两个模版的创建脚本分开放置。请确保您当前已经在 PowerShell 中进入了 **第 1 步创建的 `sys-copier-templates` 根目录**。

```PowerShell
# 确保位于总仓库根目录
cd D:\sys-copier-templates
```

---

## 2.1 全站模版：

1. 模版：py-fastapi-react模版：[[v10.1 Copier 子模版1制作指南 (py-fastapi-react)]]
此脚本将在 `templates/py-fastapi-react` 目录下构建 **FastAPI + React (Vite)** 模版。

2. 模版：py-fastapi-next模版：[[v10.1 Copier 子模版2制作指南 (py-fastapi-next)]]
此脚本将在 `templates/py-fastapi-next` 目录下构建 **FastAPI + Next.js** 模版。


---

# 第 3 步：更新全局 README 并推送 (最终稳健版)

请在 PowerShell 中执行以下命令，将 README 更新为 **Clone & Run** 模式：

## 3.1 更新总仓库 README.md

````powershell
cd D:\sys-copier-templates
$readmeContent = @'
# 🛠️ System Copier Templates

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python: 3.12+](https://img.shields.io/badge/Python-3.12+-blue.svg)](https://www.python.org/downloads/)
[![Node: 20+](https://img.shields.io/badge/Node-20+-green.svg)](https://nodejs.org/)

> **现代化全栈开发模版集合**。基于 **FastAPI** + **Next.js/React** 的高度工程化方案，集成 **UV** 与 **Copier**。采用 **Mono-repo** 架构，推荐本地克隆后使用。

---

## 📦 模版矩阵 (Template Matrix)

| 模版 ID (路径) | 技术栈 (Frontend + Backend) | 适用场景 |
| :--- | :--- | :--- |
| **`py-fastapi-react`** | `React 18 (Vite)` + `FastAPI` | 管理系统、SaaS Dashboard、轻量级 SPA |
| **`py-fastapi-next`** | `Next.js 15 (App)` + `FastAPI` | SEO 友好型官网、复杂内容平台 (SSR/ISR) |

---

## ⚙️ 环境要求 (Prerequisites)

请确保系统已安装：
* **[Pipx](https://github.com/pypa/pipx)** & **[Copier](https://copier.readthedocs.io/)**: `pip install pipx; pipx install copier`
* **[UV](https://github.com/astral-sh/uv)**: `pip install uv`
* **Docker Desktop**: (必须启动，用于数据库)

---

## 🚀 使用指南 (Usage Guide)

由于 Copier 对远程仓库子目录的支持存在限制，我们采用最稳健的 **"克隆 -> 本地引用"** 模式。

### 第一步：克隆模版库 (仅需一次)

建议将模版库克隆到一个固定的工具目录（例如 `D:`），方便长期复用和更新。

```bash
# 1. 进入你的工具目录
cd D：

# 2. 克隆仓库
git clone [https://github.com/wanderer99176/sys-copier-templates.git](https://github.com/wanderer99176/sys-copier-templates.git)
```

> **💡 提示**：日后若要获取模版更新，只需在该目录下执行 `git pull`。

---

### 第二步：生成项目

在你的工作区（例如 `D:\Projects`）执行命令，将路径指向你本地克隆的模版目录。

#### 👉 方案 A：生成 React + FastAPI 项目

```Bash
# 假设模版库在 D:\sys-copier-templates
copier copy --trust "D:\sys-copier-templates\templates\py-fastapi-react" ./my-react-app
```

#### 👉 方案 B：生成 Next.js + FastAPI 项目

```Bash
copier copy --trust "D:\sys-copier-templates\templates\py-fastapi-next" ./my-next-app
```

> [!IMPORTANT]
> 
> **关于 `--trust` 参数**：生成过程中会运行 `git init`、`uv sync` 等自动化初始化脚本，因此**必须**添加该标志。

---

## 📂 生成后的项目结构

```Plaintext
my-app/
├── 📂 backend/                # Python FastAPI 核心
│   ├── 🐍 pyproject.toml      # UV 依赖管理
│   └── 📂 src/                # 业务逻辑
├── 📂 frontend/               # 前端应用 (React/Next)
│   ├── 📦 package.json        # Node 依赖
│   └── 📂 src/                # 页面与组件
├── 📂 docker/                 # 基础设施
│   └── 🐳 docker-compose.yml  # 预置 Postgres
├── 📜 justfile                # ⚡ 快捷命令入口
└── ⚙️ .pre-commit-config.yaml # 代码质量检查
```

---

## ⌨️ 常用开发命令 (Justfile)

进入生成的项目目录后：

|**命令**|**说明**|
|---|---|
|`just setup`|**一键初始化** (安装依赖、设置 Git Hooks)|
|`just dev`|**一键启动** (Docker DB + 后端 + 前端)|
|`just test`|运行后端单元测试|
|`just clean`|清理缓存与虚拟环境|

---

## 📝 License

[MIT](https://opensource.org/licenses/MIT) © [wanderer](mailto:gbk2667503771@gmail.com)

'@

# 写入文件

$readmeContent | Set-Content -Path "D:\sys-copier-templates\README.md" -Encoding utf8
````

## 3.2 提交并推送

```bash
cd D:\sys-copier-templates
git add README.md
git commit -m "Docs: Update usage guide to robust Clone-First strategy"
git push origin main
````
- 其他更新通用，上传整个文件
```shell
# 为避免 HTTPS 认证问题，建议永久切换远程地址到 SSH：（可选）
git remote set-url origin git@github.com:wanderer99176/sys-copier-templates.git
```

```bash
cd D:\sys-copier-templates
git add .
git commit -m "add all $(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss')"
git push origin main
```

---

## 3.3 测试效果 (Final Verification)

现在，您已经拥有了最稳健的本地模版源。请使用您验证过的命令进行最后一次“验收测试”：

```PowerShell
# 1. 确保在任意工作目录 (例如 D:\)
cd D:\

# 2. 清理旧测试项目
Remove-Item -Recurse -Force my-nextjs-test -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force my-react-test -ErrorAction SilentlyContinue

# 3. 测试 Next.js 模版 (指向本地路径)
copier copy --trust "./sys-copier-templates/templates/py-fastapi-next" ./my-nextjs-test

# 4. 测试 React 模版 (指向本地路径)
copier copy --trust "./sys-copier-templates/templates/py-fastapi-react" ./my-react-test
```

## 3.4 通过网站流程测试效果

打开 https://github.com/wanderer99176/sys-copier-templates 测试生成的最终效果

