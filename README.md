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
cd D:\tools

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

