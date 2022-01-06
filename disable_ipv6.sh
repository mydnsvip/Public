#!/bin/bash
# Date: 2022-01-06
# Author: 豫章小站
# Blog: blog.mydns.vip
# Description: [centos][debian][Ubuntu]关闭ipv6
# 支持centos6,7,8 Ubuntu16,18,20 debian8,9

check_ipv6(){
	ping6 west.cn -c2 >/dev/null 2>&1
		if [ $? -ne 0 ];then
			echo "ipv6关闭成功"
		else
			echo "未成功,需要核实"
		fi
}

centos_8()
{
	sed -i 's/IPV6INIT=yes/IPV6INIT=no/' /etc/sysconfig/network-scripts/ifcfg-eth0 2>/dev/null
	nmcli c reload
	nmcli c up "System eth0"
	#echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf 2>/dev/null
	#echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf 2>/dev/null
	#echo "sysctl -p" >> /etc/rc.local 2>/dev/null
	#sysctl -p >/dev/null 2>&1
	check_ipv6
}

ubuntu_20(){
	echo "1" > /proc/sys/net/ipv6/conf/all/disable_ipv6
	sed -i '/exit 0/i\echo "1" > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local
	check_ipv6
}

Others(){
	echo "1" > /proc/sys/net/ipv6/conf/all/disable_ipv6
	echo 'echo "1" > /proc/sys/net/ipv6/conf/all/disable_ipv6' >>/etc/rc.local
	check_ipv6
}

Check_Go()
{
	if [ -e /etc/redhat-release ]; then
		[ -n "$(grep ' 8\.' /etc/redhat-release 2> /dev/null)" ] && centos_8 || Others
	elif [ -n "$(grep -i 'Debian' /etc/issue 2> /dev/null)" ]; then
		Others
	elif [ -n "$(grep -i 'Ubuntu' /etc/issue 2> /dev/null)" ]; then
		[ -n "$(grep ' 20\.' /etc/issue 2> /dev/null)" ] && ubuntu_20 || Others
	else
		echo "不支持的系统,或其他错误,需要人工核实"
		Exit
	fi

}
Check_Go