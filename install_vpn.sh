#!/bin/bash

# --- 一键部署多IP V2Ray VPN 包含：安装、批量添加、单IP添加、管理工具安装、二维码支持 ---

# 颜色函数
info() { echo -e "\033[1;32m[INFO]\033[0m $1"; }
error() { echo -e "\033[1;31m[ERROR]\033[0m $1"; }

# 1. 安装 V2Ray（官方脚本）
info "安装 V2Ray..."
bash <(curl -s -L https://git.io/v2ray.sh)

# 2. 安装依赖工具（qrencode 和 jq）
info "安装依赖工具 qrencode 和 jq..."
if command -v yum &>/dev/null; then
  yum install -y qrencode jq
elif command -v apt &>/dev/null; then
  apt update && apt install -y qrencode jq
else
  error "不支持的系统，请手动安装 qrencode 和 jq"
  exit 1
fi

# 3. 下载脚本文件
SCRIPTS=("add_multiip.sh" "add_user.sh" "list_users.sh" "delete_user.sh")
for script in "${SCRIPTS[@]}"; do
  info "下载脚本 $script..."
  curl -o "/root/$script" "https://raw.githubusercontent.com/ajcdn008/v2ray-multiip-manager-ajcdn/main/$script"
  chmod +x "/root/$script"
done

# 4. 执行批量添加用户
info "为所有公网 IP 批量添加初始用户..."
bash /root/add_multiip.sh | tee /root/vmess_links.txt

# 5. 生成二维码图片
info "生成二维码图片..."
grep -oE 'vmess://[a-zA-Z0-9+/=]+' /root/vmess_links.txt | while read -r line; do
  qrencode -o "/root/$(echo $line | cut -c 9-20).png" "$line"
done

info "✅ 安装完成！可使用如下命令管理："
echo "  🔁 添加新用户：bash /root/add_user.sh 公网IP"
echo "  📄 查看所有用户：bash /root/list_users.sh"
echo "  ❌ 删除指定端口：bash /root/delete_user.sh"
echo "  🖼️ 所有二维码已保存在 /root/*.png 文件中"
