# D:\init-project.ps1
param (
    [string]$ProjectName = "my-new-app"
)

# 1. 定义模版仓库地址
$RepoUrl = "git+https://github.com/wanderer99176/sys-copier-templates.git"

# 2. 定义选项菜单
$Options = @(
    "py-fastapi-next  (Next.js + FastAPI)",
    "py-fastapi-react (React   + FastAPI)"
)

# 3. 让用户选择
Write-Host "🚀 欢迎使用全栈项目生成器！" -ForegroundColor Cyan
Write-Host "请选择模版架构:"
for ($i = 0; $i -lt $Options.Count; $i++) {
    Write-Host "  [$($i+1)] $($Options[$i])"
}

$Choice = Read-Host "请输入序号 (1-$($Options.Count))"

# 4. 根据选择设置子目录
switch ($Choice) {
    "1" { $SubDir = "templates/py-fastapi-next" }
    "2" { $SubDir = "templates/py-fastapi-react" }
    Default { 
        Write-Error "无效的选择！退出。"
        exit 1 
    }
}

# 5. 拼接最终命令并执行
# 语法：git+URL#subdirectory=PATH
$FullSource = "$RepoUrl#subdirectory=$SubDir"

Write-Host "`n⚡ 正在从云端拉取模版: $SubDir ..." -ForegroundColor Yellow
Write-Host "目标路径: $ProjectName" -ForegroundColor Gray

# 执行 Copier
copier copy --trust "$FullSource" "$ProjectName"