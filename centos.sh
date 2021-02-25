#!/bin/bash
###
 # @Author: your name
 # @Date: 2021-02-16 11:43:42
 # @LastEditTime: 2021-02-26 00:14:51
 # @LastEditors: Please set LastEditors
 # @Description: In User Settings Edit
 # @FilePath: \k8s\shell\centos.sh
### 

##########判断是否是root用户
if [ `whoami` != "root" ];then
echo "请登录到root用户下执行此脚本"
exit 1
fi
##########执行前提示
echo -e "\033[31m这是centos7系统初始化脚本，将更新系统内核至最新版本，请慎重运行!\033[0m"
read -s -n1 -p "按任意键继续或按ctrl+C取消"

##########修改修改静态ip地址
system_network(){
    cp /etc/sysconfig/network-scripts/ifcfg-ens33 /etc/sysconfig/network-scripts/ifcfg-ens33.back
    echo > /etc/sysconfig/network-scripts/ifcfg-ens33
    echo "请输入静态IP地址:"
    read IP
    #echo -e "\033[31m输入的IP地址是：$IP\033[0m" 
    echo "请输入网关地址："
    read Gateway
    #echo -e "\033[31m输入的网关地址是：$Gateway\033[0m"
cat > /etc/sysconfig/network-scripts/ifcfg-ens33 << EOF
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=static
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
IPV6_ADDR_GEN_MODE=stable-privacy
NAME=ens33
DEVICE=ens33
ONBOOT=yes
IPADDR=$IP
NETMASK=255.255.255.0
GATEWAY=$Gateway
DNS1=8.8.8.8
DNS2=114.114.114.114
EOF
systemctl restart network
}

##########测试系统是否能上网
system_ping(){
    ping -c1 www.baidu.com &>/dev/null
    if [ $? -eq 0 ]
        then
        return 0
    else
        return 1
    fi
}

##########关系防火墙和selinux
system_firewalld(){
    systemctl stop firewalld && systemctl disable firewalld &> /dev/null
    sed -i "s/SELINUX=enforcing/SELINUX=disabled/" /etc/selinux/config
    setenforce 0
}

##########安装阿里云centos7源
system_repo_config(){
    mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
    wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
    yum clean all && yum makecache
}

##########安装依赖包
system_tools(){
    echo y|yum install –y vim wget curl curl-devel bash-completion lsof iotop iostat unzip bzip2 bzip2-devel zip lrzsz  bash-*
    echo y|yum install –y gcc gcc-c++ make cmake autoconf openssl-devel openssl-perl net-tools
    source /usr/share/bash-completion/bash_completion
}

##########修改时区
system_update_time(){
    echo y|yum install cronie -y &> /dev/null
　　ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
　　hwclock &> /dev/null
　　echo '*/10 * * * * /usr/sbin/ntpdate -u ntp.aliyun.com &> /dev/null' >> /var/spool/cron/root
　　systemctl restart crond
}

##########最大文件打开数
system_limit_tune(){
echo '
* soft nofile 128000
* hard nofile 256000

root soft nofile 128000
root hard nofile 256000
' >> /etc/security/limits.conf
}

##########升级内核
system_update_kernel (){
    rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
    rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
    echo y|yum --enablerepo=elrepo-kernel install -y kernel-ml
    #查看内核有哪些版本
    #yum --disablerepo="*" --enablerepo="elrepo-kernel" list available
    #安装最稳定的内核版本
    #echo y|yum -y --enablerepo=elrepo-kernel install kernel-ml.x86_64 kernel-ml-devel.x86_64
    # 下载指定版本用rpm -Uvh安装或者用yum安装：
    # yum -y install kernel-ml-devel-4.12.4-1.el7.elrepo.x86_64.rpm
    # yum -y install kernel-ml-4.12.4-1.el7.elrepo.x86_64.rpm
    grub2-set-default 0
    grub2-mkconfig -o /boot/grub2/grub.cfg
}

##########关系swap分区
system_swap_off(){
    echo "0" > /proc/sys/vm/swappiness
}

##########修改内核参数
system_kernel(){

}
#执行脚本
main(){
    
    #修改为静态IP地址
    system_network;
    #测试系统是否能上网
    system_ping;
    #关闭防火墙和selinux
    system_firewalld;
    #修改yum源地址
    system_repo_config;
    #安装工具
    system_tools;
    #修改系统时区
    system_update_time;
    #修改系统打开文件数
    system_limit_tune;
    #升级系统内核
    system_update_kernel;
    #关闭swap分区
    system_swap_off;
    #修改内核参数
    system_kernel;
    
}

main



