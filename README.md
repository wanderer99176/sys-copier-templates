# 🛠️ System Copier Templates

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python: 3.12+](https://img.shields.io/badge/Python-3.12+-blue.svg)](https://www.python.org/downloads/)
[![Node: 20+](https://img.shields.io/badge/Node-20+-green.svg)](https://nodejs.org/)

> **现代化全栈开发模版集合**。基于 **FastAPI** + **Next.js/React** 的高度工程化方案，集成 **UV** 与 **Copier**，实现秒级项目初始化。

---

## 📦 模版矩阵 (Template Matrix)

| 模版 ID | 技术栈 (Frontend + Backend) | 适用场景 |
| :--- | :--- | :--- |
| **`py-fastapi-react`** | `React 18 (Vite)` + `FastAPI` | 管理系统、SaaS Dashboard、轻量级 SPA |
| **`py-fastapi-next`** | `Next.js 15 (App)` + `FastAPI` | SEO 友好型官网、复杂内容平台 (SSR/ISR) |

---

## ⚙️ 环境要求 (Prerequisites)

在开始之前，请确保你的系统环境已就绪：

### 1. 核心工具 (CLI)
* **[Pipx](https://github.com/pypa/pipx)**: `pip install pipx` (推荐用于隔离安装 CLI)
* **[Copier](https://copier.readthedocs.io/)**: `pipx install copier` (核心生成器)
* **[UV](https://github.com/astral-sh/uv)**: `pip install uv` (极速 Python 包管理)

### 2. 运行时与基础设施
* **Python**: 3.12+
* **Node.js**: 20+ (LTS)
* **Docker Desktop**: 必须启动 (用于 PostgreSQL 容器)
* **[Just](https://github.com/casey/just)**: `pipx install rust-just` (命令运行器)

---

## 🚀 快速开始 (Quick Start)

### 方式 A：云端生成 (推荐)
无需下载本仓库，直接通过 GitHub 远程模版生成项目。

**React + FastAPI:**
```bash
copier copy --trust -s templates/py-fastapi-react gh:wanderer99176/sys-copier-templates ./my-app

```

**Next.js + FastAPI:**

```bash
copier copy --trust -s templates/py-fastapi-next gh:wanderer99176/sys-copier-templates ./my-app

```

> [!IMPORTANT]
> **关于 `--trust` 参数**：生成过程中会运行 `git init`、`uv sync` 等自动化初始化脚本，因此**必须**添加该标志。

---

## 📂 项目结构概览

生成后的项目遵循 **Standardized Project Layout**:

```text
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
├── 🔒 uv.lock                 # Python 锁定文件
└── ⚙️ .pre-commit-config.yaml  # 代码质量检查

```

---

## ⌨️ 常用开发命令 (Justfile)

| 命令 | 说明 |
| --- | --- |
| `just setup` | **一键初始化** (安装依赖、设置 Git Hooks) |
| `just dev` | **一键启动** (Docker DB + 后端 + 前端) |
| `just test` | 运行后端单元测试 |
| `just clean` | 清理缓存与虚拟环境 |

---

## 📝 License

[MIT](https://opensource.org/licenses/MIT) © [wanderer](mailto:gbk2667503771@gmail.com)
