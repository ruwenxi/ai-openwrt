#!/bin/bash
# 设备专属排除：在 wrt 目录下执行
#   Excludes.sh apply  —— make defconfig 之前：清掉旧设置并写入 "is not set"
#   Excludes.sh check  —— make defconfig 之后：确认最终 .config 里确实没有，否则报错并列出谁依赖它

EXCLUDE_PKGS=()
case "${WRT_CONFIG^^}" in
*360V6*)
	EXCLUDE_PKGS+=(
		luci-app-openlist2 openlist2 luci-i18n-openlist2-zh-cn
		luci-app-aria2 aria2 luci-i18n-aria2-zh-cn
		luci-app-timecontrol luci-i18n-timecontrol-zh-cn
	)
	;;
*JD6600* | *IPQ807X*)
	# 雅典娜 / MX4300 / HomeWRK 内存大，不需要 zram（只有 360V6 开启）
	EXCLUDE_PKGS+=(zram-swap)
	;;
esac

[ ${#EXCLUDE_PKGS[@]} -eq 0 ] && { echo "No device excludes for $WRT_CONFIG"; exit 0; }

case "$1" in
apply)
	for PKG in "${EXCLUDE_PKGS[@]}"; do
		sed -i "/^\(# \)\?CONFIG_PACKAGE_${PKG}\(=\| is not set\)/d" ./.config
		echo "# CONFIG_PACKAGE_${PKG} is not set" >> ./.config
		echo "Exclude for $WRT_CONFIG: $PKG"
	done
	;;
check)
	FAIL=0
	for PKG in "${EXCLUDE_PKGS[@]}"; do
		if grep -qE "^CONFIG_PACKAGE_${PKG}=(y|m)" ./.config; then
			FAIL=1
			echo "::error::$PKG 被重新启用了（defconfig 之后仍为 y/m）"
			echo "---- 可能依赖/选中 $PKG 的包 ----"
			grep -rIn --include=Makefile -E "(\+|select |PACKAGE_)${PKG}([^A-Za-z0-9_-]|$)" ./package ./feeds 2>/dev/null \
				| grep -v "/${PKG}/Makefile" | head -20
			echo "---------------------------------"
		fi
	done
	[ "$FAIL" -eq 0 ] && echo "Device excludes verified for $WRT_CONFIG" || exit 1
	;;
*)
	echo "usage: $0 apply|check"; exit 2
	;;
esac
