# System Copier Templates (Full Stack)

🚀 **个人全栈开发模版集合** | 基于 Python FastAPI, React/Next.js, Docker, uv 和 Just 构建。

这是一个 Mono-repo（单仓库多模版）仓库，包含了我常用的生产级全栈项目脚手架。

---

## 📂 可用模版列表

| 模版路径 | 技术栈 | 说明 | 适用场景 |
| :--- | :--- | :--- | :--- |
| **\py-fastapi-react\** | **FastAPI** + **React (Vite)** | SPA 架构，极致的开发体验，前后端分离 | 管理后台、SaaS、内部工具 |
| **\py-fastapi-next\** | **FastAPI** + **Next.js** | SSR/RSC 架构，SEO 友好，全栈能力强 | 官网、C端应用、复杂内容站 |

---

## 🛠️ 前置要求 (Prerequisites)

在使用此模版生成项目前，请确保您的环境已安装以下工具：

| 工具 | 安装命令 (Windows/PowerShell) | 作用 |
| :--- | :--- | :--- |
| **Python 3.12+** | \mise install python@3.12\ | 后端运行时 |
| **Node.js 20+** | \mise install node@lts\ | 前端运行时 |
| **uv** | \pipx install uv\ | 极速 Python 包管理器 |
| **Copier** | \pipx install copier\ | 项目生成工具 |
| **Just** | \pipx install just\ | 任务运行器 (Makefile 替代品) |
| **Docker** | (请安装 Docker Desktop) | 数据库和部署容器化 |

---

## 🚀 使用指南 (Usage)

### 方式 A：直接从 GitHub 生成 (推荐)

使用 \subdirectory\ 参数指定要使用的模版。

**生成 React 版：**
\\\ash
copier copy --trust "gh:wanderer99176/sys-copier-templates" ./my-react-app --data subdirectory="templates/py-fastapi-react"
\\\

**生成 Next.js 版：**
\\\ash
copier copy --trust "gh:wanderer99176/sys-copier-templates" ./my-next-app --data subdirectory="templates/py-fastapi-next"
\\\

> **注意**：如果上述命令因网络或版本问题失败，请使用 **方式 B**。

---

### 方式 B：克隆到本地使用 (最稳妥/开发用)

如果你需要频繁生成项目，或者网络连接 GitHub 不稳定，建议将此仓库克隆到本地。

1. **克隆仓库**：
   \\\ash
   git clone https://github.com/wanderer99176/sys-copier-templates.git D:/sys-copier-templates
   \\\

2. **从本地生成**：
   \\\ash
   # React 版
   copier copy --trust "D:/sys-copier-templates/templates/py-fastapi-react" ./my-new-project

   # Next.js 版
   copier copy --trust "D:/sys-copier-templates/templates/py-fastapi-next" ./my-new-project
   \\\

---

## 🏗️ 生成后的项目结构

无论选择哪个模版，生成的项目都遵循以下标准结构：

\\\	ext
my-awesome-app/
├── backend/                # Python FastAPI 后端
│   ├── src/                # 源码
│   ├── tests/              # 测试
│   └── pyproject.toml      # 后端依赖 (uv)
├── frontend/               # 前端 (React 或 Next.js)
│   ├── src/                # 前端源码
│   └── package.json        # 前端依赖 (npm)
├── docker/                 # Docker Compose 配置
├── docs/                   # 项目文档
├── justfile                # 常用命令入口 (Setup, Dev, Test)
├── pyproject.toml          # 根项目配置 (Workspace)
└── README.md               # 项目说明书
\\\

## ⚡ 常用命令 (Justfile)

生成项目后，进入目录即可使用以下命令：

- **\just setup\**: 初始化环境（安装 uv 依赖、npm 依赖、Git 钩子）。
- **\just dev\**: 一键启动全栈开发环境（前端 + 后端 + 数据库）。
- **\just test\**: 运行后端测试。
- **\just clean\**: 清理缓存和虚拟环境。

---

## 📝 贡献与扩展

1. 在 \	emplates/\ 目录下创建新的文件夹（如 \go-gin-vue\）。
2. 在其中添加 \copier.yml\ 和模版文件。
3. 提交到 Git 即可。

