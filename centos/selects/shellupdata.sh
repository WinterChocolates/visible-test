#!/bin/bash

source /visible/globals.sh

while true; do
    OPTION=$(whiptail \
        --title "《Manage》" \
        --menu "$SYSTEM_VERSION" \
        20 70 10 \
        "1" "工具更新 Update" \
        "2" "工具卸载 Uninstall" \
        3>&1 1>&2 2>&3)

    feedback=$?
    if [ $feedback = 0 ]; then
        # 更新
        if [ $OPTION = 1 ]; then
            # 检查目录是否存在，如果不存在则克隆
            if [ ! -d "$APP_DIR" ]; then
                echo "目录 $APP_DIR 不存在，正在克隆代码..."
                cd /
                git clone "https://github.com/ningmengchongshui/visible.git"
                if [ $? -ne 0 ]; then
                    echo "克隆代码失败，请检查网络连接或权限问题。"
                    exit 1
                fi
            fi

            # 检查应用目录是否存在，并进行更新
            if [ ! -e "$CENTOS_START_BASE" ]; then
                echo "# 操作失败，目录不存在或其他问题，请重新执行"
                exit 1
            else
                cd "$APP_DIR"
                echo "正在更新《visible》应用..."
                git fetch --all
                if [ $? -ne 0 ]; then
                    echo "更新失败，请检查网络连接或权限问题。"
                    exit 1
                fi
                git reset --hard main
                git pull
                if [ $? -ne 0 ]; then
                    echo "拉取失败，请检查 Git 仓库配置。"
                    exit 1
                fi
                echo "《visible》已更新。"
                echo "# 执行完成，请输入启动指令唤起..."
            fi
            # 继续进行下一步操作
            read -p "按回车键继续..." Enter
        fi

        # 卸载
        if [ $OPTION = 2 ]; then
            # 确认是否卸载
            whiptail --title "确认卸载" --yesno "确定要卸载《visible》应用吗?" 10 60
            if [ $? -eq 0 ]; then
                echo "正在卸载《visible》应用..."
                sudo rm -rf "$APP_DIR"
                if [ $? -eq 0 ]; then
                    echo "《visible》应用已卸载成功。"
                else
                    echo "卸载失败，请检查权限或目录路径。"
                fi
            else
                echo "取消卸载操作。"
            fi
            # 继续进行下一步操作
            read -p "按回车键继续..." Enter
        fi

    else
        exit 1
    fi
done
