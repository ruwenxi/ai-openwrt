# NSS 固件云编译 (360 V6 / 京东云 RE-CS-02)

源码：https://github.com/Gaojianli/immortalwrt-ipq

## 目录结构
```
.github/workflows/build-nss.yml   工作流 (唯一的 yml)
config/
  common.config                   两台共用：插件、zram、瘦身
  360v6.config                    360 V6 机型
  jdcloud-re-cs-02.config         RE-CS-02 机型 + 专属插件
scripts/
  01-custom-packages.sh           拉取第三方插件 (aurora/openclash/ddns-go/openlist2/athena-led)
  02-default-settings.sh          默认 IP(10.1.1.1)、默认主题、OpenClash 内核
  03-gen-config.sh                合并 config 并校验
```

## 使用
1. 把整个目录内容上传到你自己的 GitHub 仓库根目录 (注意 .github 是隐藏文件夹，要一起上传)。
2. Actions → Build NSS Firmware → Run workflow。
3. 在运行页面底部的 Artifacts 下载固件。

## 常改的地方
- 改默认 IP：运行时填 `lan_ip`，或改 `scripts/02-default-settings.sh` 里的 `NEW_IP`。
- 加/删插件：改 `config/*.config`。格式只认 `CONFIG_xxx=y` 和 `# CONFIG_xxx is not set`，注释用 `##`。
- 换第三方插件仓库：改 `scripts/01-custom-packages.sh`。

## 注意
- 使用 NSS 请关闭 packet steering / flow offloading，不要用桥接 VLAN 过滤。
- 默认 IP 只在全新配置时生效；保留配置升级不会改动原 IP。
