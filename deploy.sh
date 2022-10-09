#!/usr/bin/env sh

# 发生错误时终止
set -e

# 构建
npm run build


# git init
# git checkout -b main
git add -A
git commit -m 'deploy'

# git push origin master

# 如果你要部署在 https://<USERNAME>.github.io
# git push -f git@github.com:<USERNAME>/<USERNAME>.github.io.git main

# 如果你要部署在 https://<USERNAME>.github.io/<REPO>
git push -f git@github.com:j172993563/poker-game.git main

cd -