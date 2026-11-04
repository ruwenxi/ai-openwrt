#!/usr/bin/env bash
# 在源码根目录执行，位于 feeds install 之后
# 可用环境变量:
#   NEW_IP             默认 LAN IP，默认 10.1.1.1
#   BUNDLE_CLASH_CORE  true 时把 OpenClash Meta 内核打进固件
set -euo pipefail
NEW_IP="${NEW_IP:-10.1.1.1}"

# ---------- 1. 修改默认 IP ----------
CG=package/base-files/files/bin/config_generate
sed -i "s/192\.168\.1\.1/${NEW_IP}/g; s/192\.168\.6\.1/${NEW_IP}/g" "$CG"
if grep -q "$NEW_IP" "$CG"; then
  echo "默认 IP 已改为 $NEW_IP:"; grep -n "$NEW_IP" "$CG"
else
  echo "::error::未能在 $CG 中改 IP，请查看该文件里默认地址的写法"; grep -n "ipad\|ipaddr" "$CG" || true; exit 1
fi

# ---------- 2. 默认主题设为 Aurora ----------
mkdir -p files/etc/uci-defaults
cat > files/etc/uci-defaults/99-default-theme <<'EOT'
#!/bin/sh
if [ -d /www/luci-static/aurora ]; then
  uci set luci.main.mediaurlbase='/luci-static/aurora'
  uci commit luci
fi
exit 0
EOT
chmod +x files/etc/uci-defaults/99-default-theme

# ---------- 3. 打包 OpenClash Meta 内核 (可选) ----------
if [ "${BUNDLE_CLASH_CORE:-false}" = "true" ]; then
  mkdir -p files/etc/openclash/core
  if curl -fL --retry 3 \
      https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-arm64.tar.gz \
      | tar -xz -C files/etc/openclash/core; then
    [ -f files/etc/openclash/core/clash ] && mv files/etc/openclash/core/clash files/etc/openclash/core/clash_meta
    chmod +x files/etc/openclash/core/clash_meta
    ls -lh files/etc/openclash/core
  else
    echo "::warning::下载 Meta 内核失败，固件内不带内核，请在路由器里手动更新"
    rm -rf files/etc/openclash
  fi
fi
