#!/bin/bash
#
# deploy.sh - 把本项目托管到 GitHub 的辅助脚本
#
# 用法:
#   ./deploy.sh <github用户名> [仓库名]
#
# 仓库名默认是 xray (脚本内 is_sh_repo=$author/$is_core, is_core=xray, 建议保持 xray)
# 执行后:
#   1. 自动替换 install.sh / src/init.sh 中的 author 为你的用户名
#   2. 打包 release 用的 code.zip (内容: xray.sh + src/)
#   3. 打印: 建仓库 / push / 打 release / 一键安装 命令
#
# 前提: 本机已配置 GitHub 认证 (gh auth login 或 GITHUB_TOKEN 或 ssh key)

set -e

AUTHOR="${1:?用法: ./deploy.sh <github用户名> [仓库名]}"
REPO="${2:-xray}"
ROOT=$(cd "$(dirname "$0")" && pwd)

echo "==> 1/4 替换 author: 233boy -> $AUTHOR"
sed -i "s/^author=233boy$/author=$AUTHOR/" "$ROOT/install.sh" "$ROOT/src/init.sh"
grep -n "^author=" "$ROOT/install.sh" "$ROOT/src/init.sh"

echo "==> 2/4 打包 release 用的 code.zip"
cd "$ROOT"
rm -f code.zip
zip -qr code.zip xray.sh src/
echo "打包完成: $ROOT/code.zip ($(du -h code.zip | cut -f1))"

echo "==> 3/4 生成托管命令 (在项目目录执行)"
cat <<EOF

--------------------------------------------------------------------------
 推送代码到 GitHub ($AUTHOR/$REPO):
--------------------------------------------------------------------------
  cd $ROOT
  git init -b main
  git add -A
  git commit -m "add VLESS-Encryption feature (ML-KEM-768 + X25519)"
  # 方式A: 用 gh CLI
  gh repo create $AUTHOR/$REPO --public --source . --push
  # 方式B: 手动建仓后
  git remote add origin https://github.com/$AUTHOR/$REPO.git
  git push -u origin main

--------------------------------------------------------------------------
 打 release (必须! 一键安装依赖 releases/latest/download/code.zip):
--------------------------------------------------------------------------
  # 方式A: gh CLI
  gh release create v1.0 code.zip --repo $AUTHOR/$REPO --title "v1.0" --notes "VLESS-Encryption 一键脚本"
  # 方式B: 网页操作
  #   1. 打开 https://github.com/$AUTHOR/$REPO/releases/new
  #   2. 填 tag: v1.0, 标题: v1.0
  #   3. 上传 code.zip 作为 asset (必须叫 code.zip)
  #   4. 发布

EOF

echo "==> 4/4 一键安装命令 (给用户用)"
cat <<EOF

--------------------------------------------------------------------------
 一键安装:
--------------------------------------------------------------------------
  bash <(curl -L https://raw.githubusercontent.com/$AUTHOR/$REPO/main/install.sh) @ install

 或 (国内/网络问题可加代理参数):
  bash <(curl -L https://raw.githubusercontent.com/$AUTHOR/$REPO/main/install.sh) @ install -p http://127.0.0.1:2333

 安装后命令: xray
 帮助: xray help
 添加 VLESS-Encryption: xray add vlessenc
--------------------------------------------------------------------------
EOF
echo "部署准备完成!"
