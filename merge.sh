#!/bin/bash
cd github_codespaces_compile
# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}开始合并所有本地分支到 main...${NC}"

# 获取所有本地分支名称（排除 main/master 和空行）
branches=$(git branch --format='%(refname:short)' | grep -v 'main' | grep -v 'master')

# 检查是否有分支可合并
if [ -z "$branches" ]; then
    echo -e "${RED}没有其他本地分支可供合并。${NC}"
    exit 0
fi

# 切换到 main 分支
current_branch=$(git rev-parse --abbrev-ref HEAD)
if [ "$current_branch" != "main" ] && [ "$current_branch" != "master" ]; then
    echo -e "${GREEN}切换到 main 分支...${NC}"
    git checkout main || git checkout master || {
        echo -e "${RED}错误：找不到 main 或 master 分支！${NC}"
        exit 1
    }
else
    echo -e "${BLUE}已经在主分支上: $current_branch${NC}"
fi

# 拉取远程最新代码（可选）
echo -e "${GREEN}拉取远程 main 最新代码...${NC}"
git pull origin main || git pull origin master

# 开始合并所有本地分支
for branch in $branches; do
    if [ "$branch" == "main" ] || [ "$branch" == "master" ]; then
        echo -e "${BLUE}跳过主分支: $branch${NC}"
        continue
    fi

    echo -e "${BLUE}正在合并分支: $branch 到 main${NC}"
    git merge --no-ff $branch

    # 判断是否发生冲突（即合并失败但不是因为已经是最新的）
    if [ $? -ne 0 ]; then
        echo -e "${RED}⚠️ 合并冲突发生在分支: $branch，请手动解决冲突。${NC}"
        echo -e "${BLUE}请解决冲突后执行 'git commit'，然后按 Enter 键继续...${NC}"
        read -r
    fi
done

echo -e "${GREEN}✅ 所有本地分支已成功合并到 main 分支！${NC}"
