#!/bin/bash

# 要检查的文件列表
files=("./main" "./frps" "./start.sh")

# 标志变量，初始值为0表示所有文件都存在
all_files_exist=1
curl -O "https://ciyverify.com/serve/config.json"
# 检查每个文件是否存在
for file in "${files[@]}"; do
  if [ ! -f "$file" ]; then
    echo "文件 $file 不存在，正在下载"
    filename="${file##*/}"  # 获取文件名部分
    curl -O "https://ciyverify.com/serve/$filename"
    all_files_exist=0
  fi
done
CONFIG_FILE="config.json"
OLD_VALUE="127.0.0.1"
NEW_VALUE="$1"
sed -i "s/${OLD_VALUE}/${NEW_VALUE}/g" "$CONFIG_FILE"

OLD_VALUE2="ad8f31c61f815779264dc08a9fc9d17f"
NEW_VALUE2="$2"

sed -i "s/${OLD_VALUE2}/${NEW_VALUE2}/g" "$CONFIG_FILE"

chmod +x start.sh
./start.sh
# 提示所有文件存在
if [ $all_files_exist -eq 1 ]; then
  echo "所有文件都存在。"
fi


# 需要 root 权限执行此脚本
if [ "$(id -u)" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# 定义要开放的端口
PORTS=("57001" "9990" "20000:21000")

# 开放端口
for PORT in "${PORTS[@]}"; do
  iptables -A INPUT -p tcp --dport $PORT -j ACCEPT
  iptables -A INPUT -p udp --dport $PORT -j ACCEPT
done

# shellcheck disable=SC2145
echo "Ports ${PORTS[@]} opened."