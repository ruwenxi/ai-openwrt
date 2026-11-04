#!/usr/bin/env bash
# 在源码根目录执行，位于 feeds update 之后、feeds install 之前
# 用法: 01-custom-packages.sh <机型id: 360v6 | jdcloud-re-cs-02>
set -euo pipefail
ID="${1:?缺少机型 id}"

# 删除 feeds 里的同名包，避免和第三方版本冲突
for n in luci-theme-aurora luci-app-openclash luci-app-ddns-go ddns-go \
         luci-app-openlist2 openlist2 luci-app-athena-led athena-led; do
  find feeds -maxdepth 4 -type d -name "$n" -prune -exec rm -rf {} + || true
done

mkdir -p package/custom

# grab <仓库> <包名...> : 从仓库里找到对应目录复制到 package/custom
grab() {
  local repo=$1; shift
  local d; d=$(mktemp -d)
  git clone --depth 1 "$repo" "$d"
  for n in "$@"; do
    local src
    src=$(find "$d" -maxdepth 2 -type d -name "$n" -not -path '*/.git/*' | head -1)
    if [ -n "$src" ]; then
      cp -r "$src" package/custom/
    elif [ $# -eq 1 ] && [ -f "$d/Makefile" ]; then
      mkdir -p "package/custom/$n"
      cp -r "$d"/. "package/custom/$n/"
      rm -rf "package/custom/$n/.git"
    else
      echo "::error::在 $repo 中找不到包 $n"; exit 1
    fi
  done
}

# ---- 共用 ----
grab https://github.com/eamonxg/luci-theme-aurora   luci-theme-aurora
grab https://github.com/vernesong/OpenClash         luci-app-openclash
grab https://github.com/sirpdboy/luci-app-ddns-go   luci-app-ddns-go ddns-go

# ---- 仅京东云 RE-CS-02 ----
if [ "$ID" = "jdcloud-re-cs-02" ]; then
  grab https://github.com/sbwml/luci-app-openlist2     luci-app-openlist2 openlist2
  grab https://github.com/NONG-DD/luci-app-athena-led  luci-app-athena-led athena-led
fi

echo "自定义包已加入:"; ls package/custom
