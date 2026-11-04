#!/usr/bin/env bash
# 在源码根目录执行，位于 feeds update 之后、feeds install 之前
# 用法: 01-custom-packages.sh <机型id: 360v6 | jdcloud-re-cs-02>
set -euo pipefail
ID="${1:?缺少机型 id}"
export GIT_TERMINAL_PROMPT=0   # 仓库不存在时直接失败，不要卡在要账号密码

# 删除 feeds 里的同名包，避免和第三方版本冲突
for n in luci-theme-aurora luci-app-openclash luci-app-ddns-go ddns-go \
         luci-app-openlist2 openlist2 luci-app-athena-led athena-led; do
  find feeds -maxdepth 4 -type d -name "$n" -prune -exec rm -rf {} + || true
done

mkdir -p package/custom

# grab "<仓库1> [仓库2 ...]" <包名...>
#   仓库按顺序尝试，第一个能克隆的生效 (用于原仓库失效时的备用地址)
#   包名后加 ? 表示可选，找不到只警告
grab() {
  local repos=$1; shift
  local d; d="$(mktemp -d)/r"
  local ok=0 u
  for u in $repos; do
    if git clone --depth 1 "$u" "$d" 2>/dev/null; then echo "已克隆 $u"; ok=1; break; fi
    echo "::warning::克隆失败: $u"; rm -rf "$d"
  done
  [ "$ok" -eq 1 ] || { echo "::error::所有仓库地址都无法克隆: $repos"; exit 1; }

  local required=0 n
  for n in "$@"; do [[ $n == *\? ]] || required=$((required+1)); done

  for n in "$@"; do
    local opt=0
    if [[ $n == *\? ]]; then opt=1; n="${n%\?}"; fi
    local src
    src=$(find "$d" -maxdepth 2 -type d -name "$n" -not -path '*/.git/*' | head -1)
    if [ -n "$src" ]; then
      cp -r "$src" package/custom/
    elif [ "$opt" -eq 0 ] && [ "$required" -eq 1 ] && [ -f "$d/Makefile" ]; then
      mkdir -p "package/custom/$n"
      cp -r "$d"/. "package/custom/$n/"
      rm -rf "package/custom/$n/.git"
    elif [ "$opt" -eq 1 ]; then
      echo "::warning::可选包 $n 不在 $repos 中"
    else
      echo "::error::在 $repos 中找不到包 $n"; exit 1
    fi
  done
}

# ---- 共用 ----
grab "https://github.com/eamonxg/luci-theme-aurora"   luci-theme-aurora
grab "https://github.com/vernesong/OpenClash"         luci-app-openclash
grab "https://github.com/sirpdboy/luci-app-ddns-go"   luci-app-ddns-go ddns-go

# ---- 仅京东云 RE-CS-02 ----
if [ "$ID" = "jdcloud-re-cs-02" ]; then
  grab "https://github.com/sbwml/luci-app-openlist2"   luci-app-openlist2 openlist2
  # 原作者 NONGFAH；原仓库失效时回退到 YiHooong 的 fork
  grab "https://github.com/NONGFAH/luci-app-athena-led https://github.com/YiHooong/luci-app-athena-led" \
       luci-app-athena-led 'athena-led?'
  [ -d package/custom/athena-led ] || \
    echo "::warning::未找到 athena-led 后端包；若后面校验提示 luci-app-athena-led 未生效，说明它依赖的包缺失"
fi

echo "自定义包已加入:"; ls package/custom
