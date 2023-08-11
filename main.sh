#!/bin/bash

# ANSI 转义码
orange_color="\033[0;33m"
bold_text="\033[1m"
reset_color="\033[0m"

# 配置文件路径
config_file="./mbu.conf"

# 检查配置文件是否存在，如果不存在则创建并询问用户配置信息
if [ ! -f "$config_file" ]; then
    echo -e "${bold_text}${orange_color}欢迎使用CQMub MC存档备份！${reset_color}"
    sleep 1

    #获取配置信息
    read -p "请输入Minecraft服务器目录路径（绝对路径）： " minecraft_dir
    read -p "请输入备份包存放目录路径（绝对路径）： " backup_dir
    read -p "请输入地图名称(若未修改过则名称为world)： " world_name

    #写入配置
    echo "# Minecraft服务器根目录" > "$config_file"
    echo "minecraft_dir=\"${minecraft_dir}\"" >> "$config_file"

    echo "# 备份包存放目录" >> "$config_file"
    echo "backup_dir=\"${backup_dir}\"" >> "$config_file"

    echo "# Minecraft服务器目录内的存档名称" >> "$config_file"
    echo "# 若未修改过则为world" >> "$config_file"
    echo "world_name=\"${world_name}\"" >> "$config_file"

    #提示信息
    echo -e "${bold_text}${orange_color}配置信息已导入！${reset_color}"
    sleep 1
    echo -e "${bold_text}${orange_color}若要修改信息${reset_color}"
    echo -e "${bold_text}${orange_color}请修改当前目录中的mbu.conf配置文件\n${reset_color}"

fi

# 配置文件路径
config_file="./mbu.conf"


# 导入配置信息
source "$config_file"

# 定义合法文件名的正则表达式
valid_backup_name_regex='^[a-zA-Z0-9_-]{1,255}$'

# 询问存档名称并判断存档名称是否合法
while true; do
  # 获取文件名
  read -p "设定当前备份包名称（直接回车则名称为当前时间）: " backup_name

  # 检查是否为空
  if [ -z "$backup_name" ]; then
    # 直接回车，视为空文件名
    break
  fi

  # 检查是否合法
  if [[ "$backup_name" =~ $valid_backup_name_regex ]]; then
    break  # 文件名合法，退出循环
  else
    echo "ERROR——备份包名称不合法，请只使用字母、数字、下划线和连字符(-)，字符少于256个"
  fi
done

read -p "设定当前备份包介绍(默认无介绍)：" backup_introduction

# 获取当前时间（精确到分钟）
if [ -z "$backup_name" ]; then
  backup_name=$(date +"%Y%m%d_%H%M")
fi

# 输出开始备份信息
echo -e "${bold_text}${orange_color}当前备份包名称：mbu_${backup_name}.tar.gz${reset_color}"

# 判断介绍内容存在后显示介绍内容
if [ -n "$backup_introduction" ]; then
    echo -e "${bold_text}${orange_color}存档介绍内容：${backup_introduction}${reset_color}"
fi

sleep 1
echo -e "${bold_text}${orange_color}\n地图已开始备份，请耐心等待...${reset_color}"

# 创建临时目录用于备份
echo "创建临时目录"
temp_backup_dir=$(mktemp -d)

# 复制三个地图存档文件到临时备份目录
echo "正在复制文件"
mkdir -p "$temp_backup_dir/world_all"
cp -r "$minecraft_dir/$world_name" "$temp_backup_dir/world_all"
cp -r "$minecraft_dir/${world_name}_nether" "$temp_backup_dir/world_all"
cp -r "$minecraft_dir/${world_name}_the_end" "$temp_backup_dir/world_all"

# 判断介绍内容存在后写入存档介绍
if [ -n "$backup_introduction" ]; then
    echo "$backup_introduction" > ${temp_backup_dir}/world_all/introduction.txt
fi

# 将临时备份目录打包成压缩文件，并保存在备份目录
echo "正在压缩文件"
tar -czf "$backup_dir/mbu_$backup_name.tar.gz" -C "$temp_backup_dir" world_all

# 删除临时备份目录
rm -rf "$temp_backup_dir"

# 输出备份完成信息
echo -e "${bold_text}${orange_color}\n地图备份已完成！${reset_color}"
echo -e "${bold_text}${orange_color}备份文件位于：$backup_dir/mbu_$backup_name.tar.gz${reset_color}"
