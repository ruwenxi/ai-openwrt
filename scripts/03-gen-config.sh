#!/usr/bin/env bash
# 在源码根目录执行：seed + config/common.config + config/<id>.config -> .config，并校验
# 用法: 03-gen-config.sh <机型id>
set -euo pipefail
ID="${1:?缺少机型 id}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
COMMON="$ROOT/config/common.config"
DEV_CFG="$ROOT/config/$ID.config"
[ -f "$DEV_CFG" ] || { echo "::error::找不到 $DEV_CFG"; exit 1; }

cp nss-setup/config-nss.seed .config
# 清掉 seed 里的机型选择，只保留当前这台
sed -i -E '/^(# )?CONFIG_TARGET_(qualcommax|DEVICE_qualcommax|MULTI_PROFILE|PER_DEVICE_ROOTFS)/d' .config

# 合并：同一符号先删旧行再追加，保证以我们的配置为准
merge() {
  local line sym esc
  while IFS= read -r line || [ -n "$line" ]; do
    line="${line%$'\r'}"
    if   [[ $line =~ ^(CONFIG_[A-Za-z0-9_+.-]+)= ]]; then sym="${BASH_REMATCH[1]}"
    elif [[ $line =~ ^#\ (CONFIG_[A-Za-z0-9_+.-]+)\ is\ not\ set$ ]]; then sym="${BASH_REMATCH[1]}"
    else continue; fi
    esc=$(printf '%s' "$sym" | sed 's/[][\.*^$+?(){}|/]/\\&/g')
    sed -i -E "/^(# )?${esc}([= ]|$)/d" .config
    echo "$line" >> .config
  done < "$1"
}
merge "$COMMON"
merge "$DEV_CFG"

make defconfig

echo "===== 校验 ====="
fail=0
while IFS= read -r line; do
  line="${line%$'\r'}"
  [[ $line =~ ^(CONFIG_[A-Za-z0-9_+.-]+)=y$ ]] || continue
  sym="${BASH_REMATCH[1]}"
  if grep -q "^${sym}=y" .config; then continue; fi
  case "$sym" in
    CONFIG_PACKAGE_luci-i18n-*|CONFIG_KERNEL_*|CONFIG_LUCI_LANG_*)
      echo "::warning::未生效(可能该版本没有此选项/语言包): $sym" ;;
    *)
      echo "::error::未生效: $sym  (包名或设备名可能不对)"; fail=1 ;;
  esac
done < <(cat "$COMMON" "$DEV_CFG")

n=$(grep -cE '^CONFIG_PACKAGE_.*nss.*=y' .config || true)
echo "NSS 相关已启用包数量: $n"
[ "$n" -gt 0 ] || { echo "::error::没有启用任何 NSS 包"; fail=1; }

echo "----- 最终启用的 LuCI 应用 -----"
grep -E '^CONFIG_PACKAGE_luci-app-.*=y' .config || true
exit $fail
