# 高质量<免费>交流群

[IPQ技术讨论群](https://qm.qq.com/q/v7nMhzB4oU)

# 高质量<付费>中转站

[LiBwrt-Ai](https://api.zipimg.cn/register?aff=FFPS3UMJ8HJD)

# 本地编译器

https://github.com/VIKINGYFY/OWRT-Tools.git

# 自用修改版插件

https://github.com/VIKINGYFY/packages.git

# OpenWRT-CI

官方版：

https://github.com/immortalwrt/immortalwrt.git

自用版：

https://github.com/VIKINGYFY/immortalwrt.git

# U-BOOT

高通版-沉心：

https://github.com/chenxin527/uboot-qsdk12.5-build.git

高通版-小猪：

https://github.com/1980490718/u-boot-2016.git

联发科-全新版：

https://github.com/VIKINGYFY/UBOOT-CI/releases

联发科-官方版：

https://drive.wrt.moe/uboot/mediatek

# 固件简要说明

固件每天早上5点自动编译。

固件信息里的时间为编译开始的时间，方便核对上游源码提交时间。

MEDIATEK系列、QUALCOMMAX系列、ROCKCHIP系列、X86系列。

# 目录简要说明

workflows——自定义CI配置

Scripts——自定义脚本

Config——自定义配置

## Star History

<a href="https://www.star-history.com/?repos=vikingyfy%2Fopenwrt-ci&type=date&legend=top-left">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/chart?repos=vikingyfy/openwrt-ci&type=date&theme=dark&legend=top-left" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/chart?repos=vikingyfy/openwrt-ci&type=date&legend=top-left" />
   <img alt="Star History Chart" src="https://api.star-history.com/chart?repos=vikingyfy/openwrt-ci&type=date&legend=top-left" />
 </picture>
</a>

# 本仓库设备与插件说明

| 流程 | 配置 | 设备 | 说明 |
| --- | --- | --- | --- |
| `360V6-JD6600.yml` | `360V6` / `JD6600` | 360 V6、京东云雅典娜 AX6600 | 源码分支 `owrt` |
| `360V6-JD6600-nss.yml` | `360V6` / `JD6600` | 360 V6、京东云雅典娜 AX6600 | 源码分支 `main`（NSS） |
| `linksys-homewrt-OWRT-.yml`（流程名 `IPQ807X-nss`） | `IPQ807X` | Linksys MX4300、Linksys HomeWRK | 源码分支 `main`（NSS） |

- 通用插件在 `Config/GENERAL.txt`，所有设备共用：OpenClash、OpenList2、Aria2、DDNS-Go、USB/存储相关、`luci-theme-argon`（另有默认主题 aurora，可在 LuCI「系统 → 外观」切换）。
- **zram 只给 360V6**：写在 `Config/360V6.txt`；`Scripts/Excludes.sh` 额外保证雅典娜、MX4300、HomeWRK 不会带上 zram。
- **LED 灯插件只给雅典娜 AX6600**：写在 `Config/JD6600.txt`。
- 360V6 另外在 `Scripts/Excludes.sh` 里排除了 OpenList2、Aria2、timecontrol（内存小）。
- 设备专属的增减：加在对应的 `Config/设备.txt`；需要强制排除的，加在 `Scripts/Excludes.sh`。
