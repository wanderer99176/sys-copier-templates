# Copier 子模版2 制作指南 (py-fastapi-next)

**目标**：在 `sys-copier-templates` 单仓库中，构建 **Next.js (App Router) + FastAPI** 全栈模版。
**位置**：`templates/py-fastapi-next/`

## 1. 创建子模版目录

我们直接在总仓库的 `templates` 目录下创建。

在 PowerShell 中执行：

```powershell
# 1. 进入总仓库的 templates 目录
cd D:\sys-copier-templates\templates

# 2. 创建并进入子模版目录
mkdir py-fastapi-next; cd py-fastapi-next

```

## 2. Copier 配置 (`copier.yml`)

注意：这里的 `project_name` 默认值改为 "My Next App"。

```powershell
$copierContent = @"
_min_copier_version: "9.0.0"

project_name:
  type: str
  help: "项目名称"
  default: "My Next App"

project_slug:
  type: str
  help: "文件夹名称/Slug"
  default: "{{ project_name | lower | replace(' ', '-') | replace('_', '-') }}"

package_name:
  type: str
  help: "Python包名"
  default: "{{ project_slug | replace('-', '_') }}"

_tasks:
  # 1. 初始化 Git
  - "cd {{ project_slug }} && git init"
  
  # 2. 安装 Python 依赖
  - "cd {{ project_slug }} && uv sync --all-extras"
  
  # 3. 安装前端依赖
  - "cd {{ project_slug }}/frontend && npm install"

  # 4. 安装钩子
  - "cd {{ project_slug }} && pre-commit install"

  # 5. 预跑代码修复
  - "cd {{ project_slug }} && git add . && pre-commit run --all-files || git add ."

  # 6. 首次提交 (关键：强制提交)
  - "cd {{ project_slug }} && git commit -m \"Initial commit from Next.js template\" --no-verify"

_exclude:
  - "copier.yml"
  - ".git"
  - ".git/*"
  - "frontend/node_modules"
  - "frontend/.next"
  - ".venv"
  - "__pycache__"
"@

$copierContent | Out-File -Encoding utf8 "copier.yml"

```

---

## 3. 核心配置 (Root Configs)

构建模版内容。所有文件都放在 `{{ project_slug }}` 文件夹下。

```powershell
# 1. 创建项目 slug 目录
mkdir "{{ project_slug }}" -Force
cd "{{ project_slug }}"

# --- A. pyproject.toml (Next.js 黄金标准版) ---
$pyprojectContent = @'
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[project]
name = "{{ project_slug }}-workspace"
version = "0.1.0"
description = "Next.js + FastAPI Monorepo managed by uv"
readme = "README.md"
requires-python = ">=3.12"
dependencies = [
    "{{ package_name }}",
]

# === 架构核心 ===
[tool.hatch.build.targets.wheel]
packages = ["src/{{ package_name }}"]

[tool.uv]
package = true

[tool.uv.workspace]
members = ["backend"]

[tool.uv.sources]
"{{ package_name }}" = { workspace = true }

# === 工具链配置 (黄金标准) ===

# --- 1. Typos 拼写检查 (适配 Next.js) ---
[tool.typos.default]
locale = "en"
[tool.typos.default.extend-words]
crate = "crate"
nd = "nd"
str = "str"
ser = "ser"
out = "out"  # Next.js 静态导出目录
[tool.typos.files]
# [关键] 排除 .next 目录
extend-exclude = ["*.json", "*.lock", "uv.lock", "node_modules", ".venv", ".next", "out", "build"]

# --- 2. TOML 格式化 ---
[tool.taplo]
include = ["pyproject.toml"]
exclude = ["uv.lock"]

# --- 3. Pyright 类型检查 ---
[tool.pyright]
typeCheckingMode = "standard"
venvPath = "."
venv = ".venv"
exclude = ["**/node_modules", "**/__pycache__", ".venv", ".next", "out", "frontend"]

# --- 4. Ruff 核心配置 ---
[tool.ruff]
src = ["backend/src"]
line-length = 88
target-version = "py312"
exclude = [
    ".git", ".venv", "node_modules", 
    ".next", "out",  # [关键] Next.js 构建产物
    "**/__pycache__"
]

[tool.ruff.format]
quote-style = "double"
indent-style = "space"

[tool.ruff.lint]
# 黄金标准规则集
select = [
    "E", "W", "F", "I", "UP", "B", "SIM", "N", "C4", "A",
    "RUF", "T20", "S", "PT", "LOG", "ERA", "T10", "PGH", "TID",
    "G", "D", "FURB", "PERF", "TRY", "FLY",
    "TC", "NPY", "PD", "DTZ", "ICN", "PIE", "ASYNC", "FIX", "FA"
]
ignore = [
    "SIM105", "N806", "A003", "S311", "TRY003", "TRY300", "TRY400",
    "D100", "D101", "D102", "D103", "D104", "D105", "D106", "D107",
    "ISC001", "COM812", "RUF001", "RUF002", "RUF003", "FIX002",
    "TC001", "TC002", "TC003"
]

# 开发保护
unfixable = ["F401", "F841"]

[tool.ruff.lint.isort]
combine-as-imports = true
force-sort-within-sections = true
section-order = ["future", "standard-library", "third-party", "first-party", "local-folder"]

[tool.ruff.lint.pydocstyle]
convention = "google"

[tool.ruff.lint.per-file-ignores]
"**/*.ipynb" = ["E402", "B018", "T201", "ERA001", "PD901"]
"**/tests/*" = ["S101", "SLF001", "T201", "PT011", "ERA001", "TRY", "PLR", "D", "ANN"]
"**/__init__.py" = ["F401", "F403"]
'@
$pyprojectContent | Out-File -Encoding utf8 "pyproject.toml.jinja"

# --- B. .pre-commit-config.yaml (Next.js 黄金标准版) ---
$preCommitContent = @'
fail_fast: true
default_install_hook_types: [pre-commit, commit-msg]

# [全局排除] 排除 Next.js 构建产物 (.next)
exclude: |
    (?x)^(
        uv\.lock|
        package-lock\.json|
        pnpm-lock\.yaml|
        yarn\.lock|
        \.vscode/.*|
        \.idea/.*|
        \.git/.*|
        \.tox/.*|
        \.venv/.*|
        \.next/.*|
        out/.*|
        build/.*|
        dist/.*|
        node_modules/.*|
        frontend/node_modules/.*
    )$

repos:
  # --- Stage 0: 基础清洗 ---
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v5.0.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-toml
      - id: check-json
      - id: check-added-large-files
        args: ['--maxkb=2000']
      - id: detect-private-key # 救命钩子
      - id: check-merge-conflict
      - id: check-case-conflict

  # --- Stage 1: 配置校验 ---
  - repo: https://github.com/abravalheri/validate-pyproject
    rev: v0.23
    hooks:
      - id: validate-pyproject
        files: ^pyproject\.toml$

  # --- Stage 2: 格式化 (Formatters) ---
  # 为了适配 pre-commit 而维护的镜像
  - repo: https://github.com/ComPWA/taplo-pre-commit
    rev: v0.9.3
    hooks:
      - id: taplo-format
        args: ["--option", "reorder_keys=true"]

  # [优化] 使用本地 Prettier (Local System Hook)
  # 优势：速度快、无需下载、与 package.json 版本一致
  - repo: local
    hooks:
      - id: prettier
        name: Prettier (Local)
        # 使用 npx 自动调用项目 node_modules 里的 prettier
        entry: npx prettier --write --ignore-unknown
        language: system
        types_or: [javascript, jsx, ts, tsx, css, html, json, yaml, markdown]
        # 排除后端和锁文件，防止从根目录扫描太慢
        exclude: |
            (?x)^(
                uv\.lock|
                package-lock\.json|
                pnpm-lock\.yaml|
                yarn\.lock|
                backend/.*|
                docker/.*
            )$

  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.9.3
    hooks:
      - id: ruff-format
        types_or: [python, pyi, jupyter]

  # --- Stage 3: 锁定 ---
  - repo: https://github.com/astral-sh/uv-pre-commit
    rev: 0.5.21
    hooks:
      - id: uv-lock

  # --- Stage 4: 深度检查 ---
  - repo: https://github.com/crate-ci/typos
    rev: v1.29.4
    hooks:
      - id: typos
        args: [--write-changes, --force-exclude]

  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.9.3
    hooks:
      - id: ruff
        args: [--fix, --exit-non-zero-on-fix]
        types_or: [python, pyi, jupyter]
'@
$preCommitContent | Out-File -Encoding utf8 ".pre-commit-config.yaml.jinja"

# --- C. 基础文件 ---
New-Item -Path "docs" -ItemType Directory -Force
"Next.js Project Documentation" | Out-File -Encoding utf8 "docs/index.md"

$editorconfig = @"
root = true
[*]
charset = utf-8
end_of_line = lf
indent_style = space
indent_size = 4
insert_final_newline = true
trim_trailing_whitespace = true
[*.{json,yaml,yml,md,js,ts,tsx,jsx}]
indent_size = 2
"@
$editorconfig | Out-File -Encoding utf8 ".editorconfig"

$gitignore = @"
.venv/
__pycache__/
*.pyc
.DS_Store
.env
.env.*
!.env.example
node_modules/
.next/
out/
build/
dist/
coverage/
.pytest_cache/
.ruff_cache/
"@
$gitignore | Out-File -Encoding utf8 ".gitignore"

# --- D. Justfile (Windows 兼容) ---
$justfileContent = @'
set windows-shell := ["powershell.exe", "-NoLogo", "-Command"]
set shell := ["sh", "-c"]
set dotenv-load

# 默认执行 listing
default:
    @just --list

# =================================================================
# 🛠️ 初始化与环境 (Setup)
# =================================================================

setup:
    @echo "📦 正在初始化环境 (Installing dependencies)..."
    # 1. 检查 Docker (兼容 PowerShell 和 Sh)
    @if (Get-Command docker -ErrorAction SilentlyContinue) { docker info > $null 2>&1; if ($LASTEXITCODE -ne 0) { echo "⚠️ Docker is NOT running!"; exit 1 } else { echo "✅ Docker is running" } }
    # 2. 安装后端依赖
    uv sync
    # 3. 安装前端依赖
    cd frontend; npm install
    # 4. 安装 Git 钩子
    pre-commit install
    @echo "🎉 环境初始化完成! 请运行 'just dev' 启动项目。"

# =================================================================
# 🚀 核心命令 (Core)
# =================================================================

# 🚀 启动：一键跑起前后端
dev:
    @echo "🚀 正在启动全栈开发环境..."
    # 1. 后台启动 Docker 数据库
    docker compose -f docker/docker-compose.yml up -d db
    # 2. 并行启动：前端(Vite/React) + 后端(FastAPI/Uvicorn)
    # 注意：backend 目录下的 main:app
    npx concurrently -k -n "FRONT,BACK" -c "cyan,green" \
        "npm run dev --prefix frontend" \
        "uv run uvicorn src.{{ package_name }}.main:app --app-dir backend --host 0.0.0.0 --port 8000 --reload"

# 🧪 测试：运行后端 pytest
test:
    @echo "🧪 正在运行后端测试..."
    uv run pytest backend/tests

# 🧹 清理：删掉环境和依赖
# [优化] 使用 Python 进行跨平台删除，避免 Shell/PowerShell 语法冲突
clean:
    @echo "🧹 正在清理环境..."
    uv clean
    uv run python -c "import shutil, os; targets=['.venv', 'frontend/node_modules']; [shutil.rmtree(t, ignore_errors=True) for t in targets]; print('✅ Cleaned')"

# =================================================================
# 🧹 代码质量 (Quality Assurance)
# =================================================================

# 格式化代码 (后端 Ruff + 前端 Prettier)
fmt:
    uv run ruff format backend/src
    uv run ruff check --select I --fix backend/src
    cd frontend; npx prettier --write . --ignore-unknown

# 代码检查 (不自动修复)
lint:
    uv run ruff check backend/src
    cd frontend; npm run lint

# 更新所有依赖 (每周维护用)
update:
    @echo "🔄 Updating dependencies..."
    uv lock --upgrade
    uv sync
    pre-commit autoupdate
    @echo "✅ Dependencies updated!"

# =================================================================
# 🏗️ 日常开发工作流 (V2.0 Pro)
# 注意: 下面的 {% raw %} 是为了保护 just 变量不被 Copier 误解析
# =================================================================
{% raw %}

# [快存] 新建提交 (自动格式化 + 提交)
# 用法: just save "feat: add login api"
save message: fmt
    @echo "💾 [New] 正在存档..."
    git add .
    git commit -m "{{message}}"

# [修正] 追加提交 (合并到上一次 commit，不产生新记录)
# 用法: just amend
# 场景: 刚才提交了，但发现漏改了一行代码，或者 typo
amend: fmt
    @echo "🩹 [Fix] 正在修正上一次提交..."
    git add .
    git commit --amend --no-edit

# [发版] 全量检查 + 推送 (质量守门员)
# 用法: just ship
ship: lint test
    @echo "🚢 正在发版 (Lint + Test + Push)..."
    git push
    @echo "✅ 代码已推送到云端!"

# [数据库] 生成迁移脚本 (当修改了 models.py 后)
# 用法: just db-gen "add user age column"
# [优化] 先 cd backend 确保能找到 alembic.ini
db-gen message:
    @echo "🐘 生成数据库版本文件..."
    cd backend; uv run alembic revision --autogenerate -m "{{message}}"

# [数据库] 应用变更 (升级数据库到最新)
# [优化] 先 cd backend 确保能找到 alembic.ini
db-up:
    @echo "🐘 正在升级数据库结构..."
    cd backend; uv run alembic upgrade head

# [测试] 监听模式 (保存文件即运行测试)
# 需安装 pytest-watch (ptw)
test-watch:
    uv run ptw backend/tests

{% endraw %}
'@
$justfileContent | Out-File -Encoding utf8 "justfile.jinja"
```

---

## 4. 后端模块 (Backend)

**关键修正**：同步 React 模版的 `lifespan` 和 `Safe Encoding` 修复。

```powershell
# 1. 创建目录
mkdir "backend/src/{{ package_name }}/api" -Force
mkdir "backend/src/{{ package_name }}/core" -Force
mkdir "backend/tests" -Force

# 1.5 [增强] 创建详细的 Backend README (中文版)
$backendReadme = @"
# {{ package_name }} (Backend Service)

这是 **{{ project_name }}** 的后端 API 服务，基于 [FastAPI](https://fastapi.tiangolo.com/) 构建。

## 📂 目录结构说明

| 路径 | 说明 |
| :--- | :--- |
| \`src/{{ package_name }}/api\` | **API 路由层**：定义 URL 路径和请求处理逻辑 |
| \`src/{{ package_name }}/core\` | **核心配置**：环境变量 (Config)、安全设置 (Security) |
| \`src/{{ package_name }}/models\` | **数据库模型**：SQLAlchemy / SQLModel 定义 (如有) |
| \`src/{{ package_name }}/schemas\` | **Pydantic 模型**：数据验证与序列化 (DTO) |
| \`tests/\` | **单元测试**：基于 Pytest 的测试用例 |

## 🚀 开发指南 (Usage)

本项目采用 **Monorepo (UV Workspace)** 架构。虽然这是一个独立的包，但建议在**项目根目录**使用 \`just\` 命令进行管理。

### 常用命令

\`\`\`bash
# 启动后端服务 (热重载模式)
just dev-backend

# 运行后端测试
just test

# 代码格式化与检查
just fmt
just lint
\`\`\`

### 📦 依赖管理

由于是 Workspace 模式，添加依赖时需要指定 \`--package\` 参数，否则会装到根目录去。

\`\`\`bash
# 正确：给后端添加 requests 库
uv add requests --package {{ package_name }}

# 正确：给后端添加开发依赖 (如 pytest-asyncio)
uv add --dev pytest-asyncio --package {{ package_name }}
\`\`\`

## ⚙️ 配置 (Configuration)

配置管理使用 \`pydantic-settings\`。
服务启动时会自动读取**项目根目录**下的 \`.env\` 文件。

关键配置项：
- \`PROJECT_NAME\`: 项目名称
- \`API_V1_STR\`: API 前缀 (默认 /api/v1)
- \`BACKEND_CORS_ORIGINS\`: 允许跨域的前端地址
"@

$backendReadme | Out-File -Encoding utf8 "backend/README.md.jinja"

# 2. Config (注意：Next.js 端口是 3000)
$configPy = @"
from pydantic_settings import BaseSettings
class Settings(BaseSettings):
    PROJECT_NAME: str = "{{ project_name }}"
    API_V1_STR: str = "/api/v1"
    BACKEND_CORS_ORIGINS: list[str] = ["http://localhost:3000", "http://localhost:8000"]
    class Config:
        env_file = ".env"
settings = Settings()
"@
$configPy | Out-File -Encoding utf8 "backend/src/{{ package_name }}/core/config.py.jinja"

# 3. API Route
$apiMain = @"
from fastapi import APIRouter
api_router = APIRouter()
@api_router.get("/hello")
def hello_world():
    return {"message": "Hello from FastAPI (Next.js Edition)"}
"@
$apiMain | Out-File -Encoding utf8 "backend/src/{{ package_name }}/api/main.py"

# 4. Main Entry (Lifespan + Safe Encoding)
$mainContent = @'
from contextlib import asynccontextmanager
from fastapi import FastAPI
from src.{{ package_name }}.api.main import api_router
from src.{{ package_name }}.core.config import settings

# 定义生命周期管理器
@asynccontextmanager
async def lifespan(app: FastAPI):
    # 启动时打印显眼的文档链接 (使用安全字符)
    print(f"\n>>> API Docs: http://localhost:8000/docs\n")
    yield
    # 关闭时的逻辑写在这里 (如有)

app = FastAPI(title=settings.PROJECT_NAME, lifespan=lifespan)

# 注册路由
app.include_router(api_router, prefix=settings.API_V1_STR)

@app.get("/")
def root():
    return {"message": "Welcome to {{ project_name }} API"}
'@
$mainContent | Out-File -Encoding utf8 "backend/src/{{ package_name }}/main.py.jinja"

# 5. Backend pyproject.toml (保持纯净)
$backendToml = @"
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[project]
name = "{{ package_name }}"
version = "0.1.0"
description = "Backend service for {{ project_name }}"
readme = "README.md"
requires-python = ">=3.12"
dependencies = [
    "fastapi>=0.109.0",
    "uvicorn[standard]>=0.27.0",
    "pydantic-settings>=2.1.0",
]

[tool.hatch.build.targets.wheel]
packages = ["src/{{ package_name }}"]
"@
$backendToml | Out-File -Encoding utf8 "backend/pyproject.toml.jinja"

# 6. Placeholders
"" | Out-File -Encoding utf8 "backend/src/{{ package_name }}/core/security.py"
"{}" | Out-File -Encoding utf8 "backend/pyrightconfig.json"

```

---

## 5. 前端模块 (Next.js)

**关键**：使用 `create-next-app` 并清理生成的垃圾文件。

```powershell
# 1. 生成 Next.js 项目 (到临时目录)
npx create-next-app@latest temp-frontend --typescript --tailwind --eslint --app --src-dir --import-alias "@/*" --use-npm --no-git --yes

# 2. 清理 Next.js 内部
cd temp-frontend
Remove-Item -Recurse -Force node_modules -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force .next -ErrorAction SilentlyContinue
Remove-Item .gitignore -ErrorAction SilentlyContinue
Remove-Item README.md -ErrorAction SilentlyContinue
cd ..

# 3. 移动到模版内 (backend 同级)
New-Item -Path "frontend" -ItemType Directory -Force
Move-Item -Path "temp-frontend/*" -Destination "frontend/" -Force
Move-Item -Path "temp-frontend/.*" -Destination "frontend/" -Force -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force temp-frontend

# 4. [新增] 注入 Prettier
cd frontend
npm install --save-dev prettier
Remove-Item -Recurse -Force node_modules -ErrorAction SilentlyContinue
cd ..

# 5. 环境变量 (Next.js 使用 NEXT_PUBLIC_ 前缀)
"NEXT_PUBLIC_API_URL=http://localhost:8000" | Out-File -Encoding utf8 "frontend/.env.development"

# 生成.prettierignore
# 防止`just fmt` 时，Prettier 去格式化第三方代码
$ignoreContent = @'
# Dependencies
node_modules
.pnp
.pnp.js

# Build Output
dist
build
out
coverage
.next/

# Lock files
package-lock.json
pnpm-lock.yaml
yarn.lock

# Configs
.env
.env.*
*.log
public/
'@
# 写入 React 模版 (注意路径中的 {{ project_slug }})
$ignoreContent | Out-File -Encoding utf8 "frontend\.prettierignore"

```

---

## 6. README 与 Docker

```powershell
# 1. README
$readmeContent = @"
# {{ project_name }} (Next.js + FastAPI)

A modern full-stack application with Next.js App Router and Python FastAPI.

## Quick Start

1. Install dependencies:
   \`\`\`bash
   just setup
   \`\`\`

2. Run development server:
   \`\`\`bash
   just dev
   \`\`\`

- Frontend: http://localhost:3000
- Backend Docs: http://localhost:8000/docs
"@
$readmeContent | Out-File -Encoding utf8 "README.md.jinja"

# 2. Docker
mkdir "docker" -Force
$compose = @"
services:
  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
      POSTGRES_DB: app_db
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
volumes:
  postgres_data:
"@
$compose | Out-File -Encoding utf8 "docker/docker-compose.yml"

```

---

## 7. 提交与验证 (Mono-repo 流程)

### 7.1 提交代码

```powershell
# 1. 回到总仓库根目录
cd D:\sys-copier-templates

# 2. 提交
git add templates/py-fastapi-next
git commit -m "Feat: Add py-fastapi-next template"

# 3. 推送
git push origin main

```

### 7.2 本地验证 (使用 -s 参数)

关键点：测试时使用 `-s` (sub-project) 指向我们刚才创建的子目录。

```powershell
# 1. 清理测试区
cd D:\
Remove-Item -Recurse -Force my-nextjs-test -ErrorAction SilentlyContinue

# 2. 生成 (指向本地子目录)
copier copy --trust "./sys-copier-templates/templates/py-fastapi-next" ./my-nextjs-test

# 3. 启动验证
cd D:\my-nextjs-test\my-next-app
# ⚠️ 请确保 Docker Desktop 已运行
just dev

```

**预期结果**：

* 后端： http://localhost:8000/docs
	* (Swagger)
* 前端： http://localhost:3000 
	* (Next.js 页面)