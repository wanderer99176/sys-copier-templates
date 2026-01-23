# System Copier Templates (Mono-repo)

这是一个现代化的全栈开发模版集合仓库，采用 Mono-repo 架构管理。所有模版均基于 **Python (FastAPI)** 和 **TypeScript** 现代技术栈构建，并预置了最佳实践配置。

## 📦 可用模版列表

| 模版 ID (Sub-project) | 技术栈概览 | 适用场景 |
| :--- | :--- | :--- |
| **`py-fastapi-react`** | 🐍 **FastAPI** + ⚛️ **React (Vite)** | 高性能单页应用 (SPA)，适合后台管理系统、SaaS 仪表盘。 |
| **`py-fastapi-next`** | 🐍 **FastAPI** + ▲ **Next.js 15** | 服务端渲染 (SSR) 全栈应用，适合 SEO 敏感型官网、复杂内容平台。 |

---

## 🛠️ 环境要求 (Prerequisites)

在使用模版生成项目前，请确保您的系统已安装以下工具：

1.  **包管理器**:
    * **Pipx**: `pip install pipx` (推荐用于安装 CLI 工具)
    * **Copier**: `pipx install copier` (核心生成器)
    * **UV**: `pipx install uv` (极速 Python 包管理)
    
2.  **运行环境**:
    * **Python**: 3.12+
    * **Node.js**: 20+ (LTS)
    * **Docker Desktop**: (必须启动，用于运行 PostgreSQL 数据库)

3.  **辅助工具 (可选)**:
    * **Just**: `pipx install rust-just` (命令运行器，模版默认包含 `justfile`)

---

## 🚀 快速开始 (Quick Start)

### 方式 A：直接从 GitHub 生成 (推荐)

无需下载本仓库，直接通过云端模版生成新项目。

#### 1. 生成 React + FastAPI 项目
```bash
copier copy --trust -s templates/py-fastapi-react gh:wanderer99176/sys-copier-templates ./my-react-app

```

#### 2. 生成 Next.js + FastAPI 项目

```bash
copier copy --trust -s templates/py-fastapi-next gh:wanderer99176/sys-copier-templates ./my-next-app

```

> **参数说明**:
> * `--trust`: **必须**。允许模版运行 `git init`、`uv sync` 和 `npm install` 等初始化脚本。
> * `-s <path>` / `--sub-project <path>`: 指定仓库内的子模版路径。
> 
> 

---

### 方式 B：本地开发与调试 (Local Dev)

如果您克隆了本仓库 (`sys-copier-templates`) 并修改了模版代码，可以使用本地路径进行测试。

```bash
# 假设您在 sys-copier-templates 根目录下
# 测试 React 模版
copier copy --trust "./templates/py-fastapi-react" ../my-test-react

# 测试 Next.js 模版
copier copy --trust "./templates/py-fastapi-next" ../my-test-next

```

---

## 📂 生成后的项目结构

无论选择哪个前端框架，生成的项目都遵循统一的 **标准化结构**：

```text
my-awesome-app/
├── 📂 backend/             # Python FastAPI 后端
│   ├── 🐍 pyproject.toml   # 后端依赖管理
│   └── 📂 src/             # 业务逻辑代码
├── 📂 frontend/            # 前端应用 (React 或 Next.js)
│   ├── 📦 package.json     # 前端依赖
│   └── 📂 src/             # 页面与组件
├── 📂 docker/              # 容器化配置
│   └── 🐳 docker-compose.yml (Postgres)
├── 📜 justfile             # 项目命令快捷入口 (Setup, Dev, Test)
├── 🔒 uv.lock              # Python 锁定文件
└── ⚙️ .pre-commit-config.yaml # 代码质量检查钩子

```

## ⌨️ 常用开发命令 (Justfile)

进入生成后的项目目录：

* **`just setup`**: 初始化环境（安装依赖、设置 Git 钩子）。
* **`just dev`**: 一键启动全栈环境（Docker DB + 后端 + 前端）。
* **`just test`**: 运行后端测试。
* **`just clean`**: 清理缓存和虚拟环境。

---

## 📝 License

MIT
