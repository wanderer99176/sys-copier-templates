好的，根据您最新的需求，我们将放弃之前“每个模版一个独立仓库”的做法，转而在 **Mono-repo (单仓库)** `sys-copier-templates` 的 `templates/` 目录下直接构建子模版。

这意味着所有的 `git init`、`git commit` 等操作都只需在 **根目录** (`D:\sys-copier-templates`) 进行一次，子模版目录里不需要（也不能）再初始化 Git。

以下是为您量身定制的 **py-fastapi-react 子模版构建指南 (Mono-repo 版)**。

---

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

# --- A. pyproject.toml (Workspace 修复版) ---
$pyprojectContent = @'
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[project]
name = "{{ project_slug }}-workspace"
version = "0.1.0"
description = "FastAPI + React project managed by uv"
readme = "README.md"
requires-python = ">=3.12"
dependencies = [
    "{{ package_name }}",
]

[tool.hatch.build.targets.wheel]
packages = ["src/{{ package_name }}"]

[tool.uv]
package = true

[tool.uv.workspace]
members = ["backend"]

[tool.uv.sources]
"{{ package_name }}" = { workspace = true }

# --- Typos & Format 配置 ---
[tool.typos.default]
locale = "en"
[tool.typos.files]
extend-exclude = ["*.json", "*.lock", "uv.lock", "node_modules", ".venv"]

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
exclude = [".git", ".venv", "node_modules"]
'@
$pyprojectContent | Out-File -Encoding utf8 "pyproject.toml.jinja"

# --- B. .pre-commit-config.yaml ---
$preCommitContent = @'
fail_fast: true
default_install_hook_types: [pre-commit, commit-msg]
exclude: '(?x)^(uv\.lock|package-lock\.json|node_modules/.*)$'

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

# 3. 环境变量
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

# 3. 启动docker(后端前提)
& "C:\Program Files\Docker\Docker\Docker Desktop.exe"

# 4. 启动验证
cd my-react-test/my-awesome-app
just dev
```

**预期结果**：

- 后端：`http://localhost:8000/docs` (Swagger)
- 前端：`http://localhost:5173` (Vite React 页面)