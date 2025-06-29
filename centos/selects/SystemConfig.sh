#!/bin/bash

source /visible/globals.sh

# 检查命令执行是否成功
checkCommand() {
    if [ $? -ne 0 ]; then
        echo "命令执行失败: $1"
        read -p "按回车键继续..." Enter
        return 1
    fi
    return 0
}

# 显示防火墙状态
show_firewall_status() {
    echo "正在检查防火墙状态..."
    if command -v firewall-cmd &> /dev/null; then
        echo "=== FirewallD 状态 ==="
        systemctl is-active firewalld
        firewall-cmd --state 2>/dev/null || echo "FirewallD 未运行"
        echo ""
        echo "=== 当前活动区域 ==="
        firewall-cmd --get-active-zones 2>/dev/null || echo "无活动区域"
        echo ""
        echo "=== 开放的端口 ==="
        firewall-cmd --list-ports 2>/dev/null || echo "无开放端口"
    else
        echo "FirewallD 未安装"
    fi
}

# 管理防火墙端口
manage_firewall_ports() {
    while true; do
        PORT_OPTION=$(whiptail \
            --title "《端口管理》" \
            --menu "选择操作" \
            15 60 4 \
            "1" "开放端口" \
            "2" "关闭端口" \
            "3" "查看开放端口" \
            "4" "返回上级菜单" \
            3>&1 1>&2 2>&3)
        
        if [ $? != 0 ]; then
            break
        fi
        
        case $PORT_OPTION in
            1)
                PORT=$(whiptail --inputbox "请输入要开放的端口号 (例如: 8080 或 8080/tcp):" 8 60 3>&1 1>&2 2>&3)
                if [ $? = 0 ] && [ -n "$PORT" ]; then
                    firewall-cmd --permanent --add-port=$PORT
                    checkCommand "开放端口 $PORT" && {
                        firewall-cmd --reload
                        whiptail --msgbox "端口 $PORT 已成功开放" 8 40
                    }
                fi
                ;;
            2)
                PORT=$(whiptail --inputbox "请输入要关闭的端口号 (例如: 8080 或 8080/tcp):" 8 60 3>&1 1>&2 2>&3)
                if [ $? = 0 ] && [ -n "$PORT" ]; then
                    firewall-cmd --permanent --remove-port=$PORT
                    checkCommand "关闭端口 $PORT" && {
                        firewall-cmd --reload
                        whiptail --msgbox "端口 $PORT 已成功关闭" 8 40
                    }
                fi
                ;;
            3)
                PORTS=$(firewall-cmd --list-ports 2>/dev/null || echo "无开放端口")
                whiptail --msgbox "当前开放的端口:\n\n$PORTS" 12 60
                ;;
            4)
                break
                ;;
        esac
    done
}

# 系统服务管理
manage_system_services() {
    while true; do
        SERVICE_OPTION=$(whiptail \
            --title "《系统服务管理》" \
            --menu "选择操作" \
            15 60 6 \
            "1" "查看服务状态" \
            "2" "启动服务" \
            "3" "停止服务" \
            "4" "重启服务" \
            "5" "启用服务开机自启" \
            "6" "禁用服务开机自启" \
            "7" "返回上级菜单" \
            3>&1 1>&2 2>&3)
        
        if [ $? != 0 ]; then
            break
        fi
        
        case $SERVICE_OPTION in
            1)
                SERVICE=$(whiptail --inputbox "请输入服务名称 (例如: nginx, sshd):" 8 50 3>&1 1>&2 2>&3)
                if [ $? = 0 ] && [ -n "$SERVICE" ]; then
                    STATUS=$(systemctl status $SERVICE 2>&1)
                    whiptail --msgbox "服务 $SERVICE 状态:\n\n$STATUS" 20 80 --scrolltext
                fi
                ;;
            2)
                SERVICE=$(whiptail --inputbox "请输入要启动的服务名称:" 8 50 3>&1 1>&2 2>&3)
                if [ $? = 0 ] && [ -n "$SERVICE" ]; then
                    systemctl start $SERVICE
                    checkCommand "启动服务 $SERVICE" && whiptail --msgbox "服务 $SERVICE 已启动" 8 40
                fi
                ;;
            3)
                SERVICE=$(whiptail --inputbox "请输入要停止的服务名称:" 8 50 3>&1 1>&2 2>&3)
                if [ $? = 0 ] && [ -n "$SERVICE" ]; then
                    systemctl stop $SERVICE
                    checkCommand "停止服务 $SERVICE" && whiptail --msgbox "服务 $SERVICE 已停止" 8 40
                fi
                ;;
            4)
                SERVICE=$(whiptail --inputbox "请输入要重启的服务名称:" 8 50 3>&1 1>&2 2>&3)
                if [ $? = 0 ] && [ -n "$SERVICE" ]; then
                    systemctl restart $SERVICE
                    checkCommand "重启服务 $SERVICE" && whiptail --msgbox "服务 $SERVICE 已重启" 8 40
                fi
                ;;
            5)
                SERVICE=$(whiptail --inputbox "请输入要启用开机自启的服务名称:" 8 50 3>&1 1>&2 2>&3)
                if [ $? = 0 ] && [ -n "$SERVICE" ]; then
                    systemctl enable $SERVICE
                    checkCommand "启用服务 $SERVICE 开机自启" && whiptail --msgbox "服务 $SERVICE 开机自启已启用" 8 40
                fi
                ;;
            6)
                SERVICE=$(whiptail --inputbox "请输入要禁用开机自启的服务名称:" 8 50 3>&1 1>&2 2>&3)
                if [ $? = 0 ] && [ -n "$SERVICE" ]; then
                    systemctl disable $SERVICE
                    checkCommand "禁用服务 $SERVICE 开机自启" && whiptail --msgbox "服务 $SERVICE 开机自启已禁用" 8 40
                fi
                ;;
            7)
                break
                ;;
        esac
    done
}

# 时间同步设置
setup_time_sync() {
    echo "正在配置时间同步..."
    
    # 安装 chrony (如果未安装)
    if ! command -v chrony &> /dev/null; then
        echo "安装 chrony..."
        $CENTOS_PKG_MANAGER install chrony -y
        checkCommand "安装 chrony"
    fi
    
    # 启动并启用 chronyd 服务
    systemctl start chronyd
    systemctl enable chronyd
    
    # 强制同步时间
    chrony sources -v
    
    echo "时间同步配置完成"
    echo "当前时间: $(date)"
    read -p "按回车键继续..." Enter
}

# 系统信息显示
show_system_info() {
    INFO=$(cat << EOF
=== 系统信息 ===
主机名: $(hostname)
操作系统: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)
内核版本: $(uname -r)
架构: $(uname -m)
运行时间: $(uptime -p)
当前时间: $(date)

=== CPU 信息 ===
$(lscpu | grep "型号名称\|CPU(s)\|每个座的核数\|每个核的线程数")

=== 内存信息 ===
$(free -h)

=== 磁盘使用情况 ===
$(df -h | grep -v tmpfs | grep -v devtmpfs)

=== 网络接口 ===
$(ip addr show | grep -E "^[0-9]+:|inet " | grep -v "127.0.0.1")
EOF
)
    whiptail --msgbox "$INFO" 25 80 --scrolltext
}

# 主菜单函数
main_menu() {
    while true; do
        OPTION=$(whiptail \
            --title "《系统配置 - System Config》" \
            --menu "$version" \
            20 70 10 \
            "1" "刷新环境变量 Reload Environment" \
            "2" "防火墙管理 Firewall Management" \
            "3" "系统服务管理 Service Management" \
            "4" "时间同步设置 Time Synchronization" \
            "5" "系统信息查看 System Information" \
            "6" "防火墙状态 Firewall Status" \
            "7" "端口管理 Port Management" \
            "8" "关闭防火墙 Disable Firewall" \
            "9" "启用防火墙 Enable Firewall" \
            3>&1 1>&2 2>&3)

        feedback=$?
        if [ $feedback = 0 ]; then
            case $OPTION in
            1)
                echo "正在刷新环境变量..."
                source /etc/profile
                source ~/.bashrc 2>/dev/null || true
                whiptail --msgbox "环境变量已刷新完成!" 8 40
                ;;
            2)
                # 防火墙管理子菜单
                while true; do
                    FW_OPTION=$(whiptail \
                        --title "《防火墙管理》" \
                        --menu "选择防火墙操作" \
                        15 60 6 \
                        "1" "查看防火墙状态" \
                        "2" "启用防火墙" \
                        "3" "关闭防火墙" \
                        "4" "重启防火墙" \
                        "5" "端口管理" \
                        "6" "返回上级菜单" \
                        3>&1 1>&2 2>&3)
                    
                    if [ $? != 0 ]; then
                        break
                    fi
                    
                    case $FW_OPTION in
                        1)
                            show_firewall_status
                            read -p "按回车键继续..." Enter
                            ;;
                        2)
                            systemctl start firewalld
                            systemctl enable firewalld
                            checkCommand "启用防火墙" && whiptail --msgbox "防火墙已启用" 8 40
                            ;;
                        3)
                            systemctl stop firewalld
                            systemctl disable firewalld
                            checkCommand "关闭防火墙" && whiptail --msgbox "防火墙已关闭" 8 40
                            ;;
                        4)
                            systemctl restart firewalld
                            checkCommand "重启防火墙" && whiptail --msgbox "防火墙已重启" 8 40
                            ;;
                        5)
                            manage_firewall_ports
                            ;;
                        6)
                            break
                            ;;
                    esac
                done
                ;;
            3)
                manage_system_services
                ;;
            4)
                setup_time_sync
                ;;
            5)
                show_system_info
                ;;
            6)
                show_firewall_status
                read -p "按回车键继续..." Enter
                ;;
            7)
                manage_firewall_ports
                ;;
            8)
                if whiptail --yesno "确定要关闭防火墙吗？这可能会降低系统安全性。" 8 50; then
                    systemctl stop firewalld
                    systemctl disable firewalld
                    checkCommand "关闭防火墙" && whiptail --msgbox "防火墙已关闭" 8 40
                fi
                ;;
            9)
                systemctl start firewalld
                systemctl enable firewalld
                checkCommand "启用防火墙" && whiptail --msgbox "防火墙已启用" 8 40
                ;;
            *)
                whiptail --msgbox "无效的选项，请重新选择" 8 40
                ;;
            esac
        else
            exit 0
        fi
    done
}

main_menu
