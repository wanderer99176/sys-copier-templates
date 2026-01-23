这是一个完全对齐 **v8.0 黄金版 SOP** 架构的 **Next.js 子模版制作指南 (v10.0)**。

它已经针对 Mono-repo 结构进行了适配，修复了之前所有的路径嵌套问题，并同步了最新的 Windows 兼容性补丁（Justfile、Emoji 移除、Lifespan 等）。

---

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

# --- A. pyproject.toml (Workspace 修复版) ---
$pyprojectContent = @'
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[project]
name = "{{ project_slug }}-workspace"
version = "0.1.0"
description = "Next.js + FastAPI project managed by uv"
readme = "README.md"
requires-python = ">=3.12"
# [关键] 显式依赖后端包
dependencies = [
    "{{ package_name }}",
]

[tool.hatch.build.targets.wheel]
packages = ["src/{{ package_name }}"]

[tool.uv]
package = true

[tool.uv.workspace]
members = ["backend"]

# [关键] 告诉 uv 去 workspace 里找后端包
[tool.uv.sources]
"{{ package_name }}" = { workspace = true }

# --- Typos & Format 配置 ---
[tool.typos.default]
locale = "en"
[tool.typos.files]
extend-exclude = ["*.json", "*.lock", "uv.lock", "node_modules", ".venv", ".next"]

[tool.taplo]
include = ["pyproject.toml"]
exclude = ["uv.lock"]

[tool.pyright]
typeCheckingMode = "standard"
venvPath = "."
venv = ".venv"

[tool.ruff]
line-length = 88
target-version = "py312"
exclude = [".git", ".venv", "node_modules", ".next"]
'@
$pyprojectContent | Out-File -Encoding utf8 "pyproject.toml.jinja"

# --- B. .pre-commit-config.yaml ---
$preCommitContent = @'
fail_fast: true
default_install_hook_types: [pre-commit, commit-msg]
exclude: '(?x)^(uv\.lock|package-lock\.json|node_modules/.*|\.next/.*)$'

repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: "v5.0.0"
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files

  - repo: https://github.com/abravalheri/validate-pyproject
    rev: "v0.23"
    hooks:
      - id: validate-pyproject

  - repo: https://github.com/ComPWA/taplo-pre-commit
    rev: "v0.9.3"
    hooks:
      - id: taplo-format

  - repo: https://github.com/pre-commit/mirrors-prettier
    rev: "v3.1.0"
    hooks:
      - id: prettier

  - repo: https://github.com/astral-sh/uv-pre-commit
    rev: "0.5.21"
    hooks:
      - id: uv-lock

  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: "v0.9.3"
    hooks:
      - id: ruff
        args: [--fix]
      - id: ruff-format
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

default:
    @just --list

setup:
    @echo "📦 Installing dependencies..."
    uv sync
    cd frontend; npm install
    pre-commit install

dev:
    @echo "🚀 Starting Next.js Full Stack..."
    docker compose -f docker/docker-compose.yml up -d db
    npx concurrently -k -n "NEXT,FASTAPI" -c "white,green" \
        "npm run dev --prefix frontend" \
        "uv run uvicorn src.{{ package_name }}.main:app --app-dir backend --host 0.0.0.0 --port 8000 --reload"

test:
    uv run pytest backend/tests

clean:
    @echo "🧹 Cleaning up..."
    uv clean
    @if [ "$OS" = "Windows_NT" ]; then \
        powershell -c "Remove-Item -Recurse -Force .venv, frontend/node_modules, frontend/.next -ErrorAction SilentlyContinue"; \
    else \
        rm -rf .venv frontend/node_modules frontend/.next; \
    fi
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

# 5. Backend pyproject.toml
$backendToml = @"
[project]
name = "{{ package_name }}"
version = "0.1.0"
requires-python = ">=3.12"
dependencies = [
    "fastapi>=0.109.0",
    "uvicorn[standard]>=0.27.0",
    "pydantic-settings>=2.1.0",
]
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"
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

# 4. 环境变量 (Next.js 使用 NEXT_PUBLIC_ 前缀)
"NEXT_PUBLIC_API_URL=http://localhost:8000" | Out-File -Encoding utf8 "frontend/.env.development"

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
cd my-nextjs-test/my-next-app
# ⚠️ 请确保 Docker Desktop 已运行
just dev

```

**预期结果**：

* 后端：`http://localhost:8000/docs` (Swagger)
* 前端：`http://localhost:3000` (Next.js 页面)