# Copier 子模版制作指南 (py-fastapi-react)

**目标**：在 `sys-copier-templates` 仓库中，构建一个 **Vite (React) + FastAPI** 的全栈模版。

**位置**：`templates/py-fastapi-react/`

## 1. 创建子模版目录结构

我们不再初始化 Git，直接在现有仓库中创建目录。

```PowerShell
# 1. 进入总仓库的 templates 目录
cd D:\sys-copier-templates\templates

# 2. 创建并进入子模版目录
mkdir py-fastapi-react; cd py-fastapi-react
```

## 2. Copier 配置 (`copier.yml`)

这是该子模版的独立配置文件。注意：虽然我们在子目录下，但 `_tasks` 中的路径依然是相对于**生成后的项目根目录**的，所以配置逻辑与单仓库版完全一致，无需修改路径。

```PowerShell
$copierContent = @"
_min_copier_version: "9.0.0"

project_name:
  type: str
  help: "项目名称"
  default: "My Awesome App"

project_slug:
  type: str
  help: "文件夹名称/Slug"
  default: "{{ project_name | lower | replace(' ', '-') | replace('_', '-') }}"

package_name:
  type: str
  help: "Python包名"
  default: "{{ project_slug | replace('-', '_') }}"

_tasks:
  # 1. 初始化 Git (这是在用户生成的项目里执行，不是在模版库里)
  - "cd {{ project_slug }} && git init"
  
  # 2. 安装 Python 依赖
  - "cd {{ project_slug }} && uv sync --all-extras"
  
  # 3. 安装前端依赖
  - "cd {{ project_slug }}/frontend && npm install"

  # 4. 安装钩子
  - "cd {{ project_slug }} && pre-commit install"

  # 5. 预跑代码修复
  - "cd {{ project_slug }} && git add . && pre-commit run --all-files || git add ."

  # 6. 首次提交
  - "cd {{ project_slug }} && git commit -m \"Initial commit from React template\" --no-verify"

_exclude:
  - "copier.yml"
  - ".git"
  - ".git/*"
  - "frontend/node_modules"
  - "frontend/dist"
  - ".venv"
  - "__pycache__"
"@

$copierContent | Out-File -Encoding utf8 "copier.yml"
```

---

## 3. 核心配置 (Root Configs)

构建模版内容。所有文件都放在 `{{ project_slug }}` 文件夹下。

```PowerShell
# 1. 创建项目 slug 目录
mkdir "{{ project_slug }}" -Force
cd "{{ project_slug }}"

# --- A. pyproject.toml (融合黄金标准版) ---
$pyprojectContent = @'
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[project]
name = "{{ project_slug }}-workspace"
version = "0.1.0"
description = "Modern Monorepo managed by uv"
readme = "README.md"
requires-python = ">=3.12"
dependencies = [
    "{{ package_name }}",
]

# === 架构核心 (保留模版逻辑) ===
[tool.hatch.build.targets.wheel]
packages = ["src/{{ package_name }}"]

[tool.uv]
package = true

[tool.uv.workspace]
members = ["backend"]

[tool.uv.sources]
"{{ package_name }}" = { workspace = true }

# === 工具链配置 (融入黄金标准) ===

# --- 1. Typos 拼写检查 ---
[tool.typos.default]
locale = "en"
[tool.typos.default.extend-words]
# 常用白名单
crate = "crate"
nd = "nd"
str = "str"
ser = "ser"
out = "out"
[tool.typos.files]
extend-exclude = ["*.json", "*.lock", "uv.lock", "node_modules", ".venv", ".next", "dist", "build"]

# --- 2. TOML 格式化 ---
[tool.taplo]
include = ["pyproject.toml"]
exclude = ["uv.lock"]

# --- 3. Pyright 类型检查 ---
[tool.pyright]
typeCheckingMode = "standard"
venvPath = "."
venv = ".venv"
# 忽略前端和构建目录
exclude = ["**/node_modules", "**/__pycache__", ".venv", "build", "dist", "frontend"]

# --- 4. Pytest 测试配置 ---
[tool.pytest.ini_options]
minversion = "7.0"
addopts = "-ra -q --strict-markers --import-mode=importlib"
testpaths = ["backend/tests"]
pythonpath = ["backend/src"]
filterwarnings = [
    "error",
    "ignore::DeprecationWarning",
    "ignore::ResourceWarning",
]

# --- 5. Ruff 核心配置 (Copier 模版中只写通用规则) ---
[tool.ruff]
src = ["backend/src"]
line-length = 88
target-version = "py312"
exclude = [
    ".git", ".venv", "node_modules", ".next", "dist",
    "**/__pycache__"
]

[tool.ruff.format]
quote-style = "double"
indent-style = "space"

[tool.ruff.lint]
# 启用全套规则 (来自旧版黄金标准)
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

# [关键] 保护开发体验，防止自动删除未使用的变量
unfixable = ["F401", "F841"]

[tool.ruff.lint.isort]
combine-as-imports = true
force-sort-within-sections = true
section-order = ["future", "standard-library", "third-party", "first-party", "local-folder"]

[tool.ruff.lint.pydocstyle]
convention = "google"

# 针对特定文件的豁免
[tool.ruff.lint.per-file-ignores]
"**/*.ipynb" = ["E402", "B018", "T201", "ERA001", "PD901"]
"**/tests/*" = ["S101", "SLF001", "T201", "PT011", "ERA001", "TRY", "PLR", "D", "ANN"]
"**/__init__.py" = ["F401", "F403"]
'@
$pyprojectContent | Out-File -Encoding utf8 "pyproject.toml.jinja"

# --- B. .pre-commit-config.yaml (融合黄金标准版) ---
$preCommitContent = @'
fail_fast: true
default_install_hook_types: [pre-commit, commit-msg]

# [全局排除] 排除锁文件、构建产物和前端依赖
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
        build/.*|
        dist/.*|
        node_modules/.*|
        frontend/node_modules/.*
    )$

repos:
  # --- Stage 0: 基础语法与元数据 ---
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
      - id: detect-private-key  # [融合] 救命钩子
      - id: check-merge-conflict
      - id: check-case-conflict

  # --- Stage 1: 项目配置校验 ---
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

  # --- Stage 3: 依赖锁定 ---
  - repo: https://github.com/astral-sh/uv-pre-commit
    rev: 0.5.21
    hooks:
      - id: uv-lock

  # --- Stage 4: 深度检查 (Linters) ---
  - repo: https://github.com/crate-ci/typos
    rev: v1.29.4
    hooks:
      - id: typos
        args: [--write-changes, --force-exclude]

  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.9.3
    hooks:
      - id: ruff
        # 只要有自动修复就报错，强迫开发者 review 修改
        args: [--fix, --exit-non-zero-on-fix]
        types_or: [python, pyi, jupyter]
'@
$preCommitContent | Out-File -Encoding utf8 ".pre-commit-config.yaml.jinja"

# --- C. 基础文件 ---
New-Item -Path "docs" -ItemType Directory -Force
"React Project Documentation" | Out-File -Encoding utf8 "docs/index.md"

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

default:
    @just --list

setup:
    @echo "📦 Installing dependencies..."
    uv sync
    cd frontend; npm install
    pre-commit install

dev:
    @echo "🚀 Starting React Full Stack..."
    docker compose -f docker/docker-compose.yml up -d db
    npx concurrently -k -n "FRONT,BACK" -c "cyan,green" \
        "npm run dev --prefix frontend" \
        "uv run uvicorn src.{{ package_name }}.main:app --app-dir backend --host 0.0.0.0 --port 8000 --reload"

test:
    uv run pytest backend/tests

clean:
    @echo "🧹 Cleaning up..."
    uv clean
    @if [ "$OS" = "Windows_NT" ]; then \
        powershell -c "Remove-Item -Recurse -Force .venv, frontend/node_modules -ErrorAction SilentlyContinue"; \
    else \
        rm -rf .venv frontend/node_modules; \
    fi
'@
$justfileContent | Out-File -Encoding utf8 "justfile.jinja"
```

---

## 4. 后端模块 (Backend)

**注意**：使用相对路径创建目录，因为我们已经在 `{{ project_slug }}` 里面了。

```PowerShell
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

# 2. Config
$configPy = @"
from pydantic_settings import BaseSettings
class Settings(BaseSettings):
    PROJECT_NAME: str = "{{ project_name }}"
    API_V1_STR: str = "/api/v1"
    BACKEND_CORS_ORIGINS: list[str] = ["http://localhost:5173", "http://localhost:8000"]
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
    return {"message": "Hello from FastAPI"}
"@
$apiMain | Out-File -Encoding utf8 "backend/src/{{ package_name }}/api/main.py"

# 4. Main Entry (Jinja)
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

# 5. Backend pyproject.toml (Monorepo 专用瘦身版)
$backendToml = @"
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[project]
name = "{{ package_name }}"
version = "0.1.0"
description = "Backend service for {{ project_name }}"
readme = "README.md"
# [关键] 必须与根目录保持一致或兼容
requires-python = ">=3.12"

# [关键] 只列出运行时依赖 (开发工具如 ruff 放在根目录)
dependencies = [
    "fastapi>=0.109.0",
    "uvicorn[standard]>=0.27.0",
    "pydantic-settings>=2.1.0",
    # 如果有数据库，可以在这里加 "sqlalchemy", "alembic" 等
]

# [架构核心] 告诉构建工具去哪里找源码
[tool.hatch.build.targets.wheel]
packages = ["src/{{ package_name }}"]

# [可选] 如果你想让这个包被当作一个库引用，可以加这行，但在微服务里通常不需要
# [tool.uv]
# package = true
"@
$backendToml | Out-File -Encoding utf8 "backend/pyproject.toml.jinja"

# 6. Placeholders
"" | Out-File -Encoding utf8 "backend/src/{{ package_name }}/core/security.py"
"{}" | Out-File -Encoding utf8 "backend/pyrightconfig.json"
```

---

## 5. 前端模块 (Vite + React)

```PowerShell
# 1. 生成 Vite 项目
# (注意：npx 会在当前目录生成 temp-frontend)
npm create vite@latest temp-frontend -- --template react-ts
# (交互时全选 No)

# 2. 移动到模版内
# 现在的当前目录是 D:\sys-copier-templates\templates\py-fastapi-react\{{ project_slug }}
New-Item -Path "frontend" -ItemType Directory -Force
Move-Item -Path "temp-frontend/*" -Destination "frontend/" -Force
Move-Item -Path "temp-frontend/.*" -Destination "frontend/" -Force -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force temp-frontend

# 强制注入 Prettier 到 package.json
# 目的：确保生成的项目 package.json 中包含 "prettier": "^3.x.x"
cd frontend
# 3.1 安装 Prettier (这会自动更新 package.json)
npm install --save-dev prettier
# 3.2 【关键】删除生成的 node_modules
# 原因：我们只需要 package.json 里的记录，不需要模版里留着几百兆的依赖包
Remove-Item -Recurse -Force node_modules -ErrorAction SilentlyContinue
cd ..


# 4. 环境变量
"VITE_API_URL=http://localhost:8000" | Out-File -Encoding utf8 "frontend/.env.development"
```

---

## 6. README 与 Docker

```PowerShell
# 1. README
$readmeContent = @"
# {{ project_name }} (React + FastAPI)

A modern full-stack application with React (Vite) and Python FastAPI.

## Quick Start

1. Install dependencies:
   \`\`\`bash
   just setup
   \`\`\`

2. Run development server:
   \`\`\`bash
   just dev
   \`\`\`

- Frontend: http://localhost:5173
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

现在我们回到根目录提交更改，并测试这个子模版。

### 7.1 提交代码

```PowerShell
# 1. 回到总仓库根目录
cd D:\sys-copier-templates\templates

# 2. 提交
git add py-fastapi-react
git commit -m "Feat: Add py-fastapi-react template"

# 3. 推送
git push origin main
```

### 7.2 本地验证 (使用 -s 参数)

关键点：测试时使用 `-s` (sub-project) 指向我们刚才创建的子目录。

```PowerShell
# 1. 清理测试区
cd D:\
Remove-Item -Recurse -Force my-react-test -ErrorAction SilentlyContinue

# 2. 【核心修正】直接指向 templates 下的子文件夹
# 既然我们是本地测试，直接把源路径写深一层到模版所在的目录
copier copy --trust "./sys-copier-templates/templates/py-fastapi-react" ./my-react-test

# 3. 启动docker(后端前提)（等待5s启动建议）
& "C:\Program Files\Docker\Docker\Docker Desktop.exe"

# 4. 启动验证
cd D:\my-react-app\my-awesome-app
just dev
```

**预期结果**：

- 后端： http://localhost:8000/docs
	- (Swagger)
- 前端： http://localhost:5173
	- (Vite React 页面)