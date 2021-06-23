#!/bin/bash
# Author: mydns.vip
# Blog: https://blog.mydns.vip

eth0f="/etc/sysconfig/network-scripts/ifcfg-eth0"
resf="/etc/resolv.conf"
ipv6=""
ipgw=""
restartflag=0

Help() {
	echo "Usage: ./$(basename $0) -s[-b] ipv6 [ipv6]"
	echo
	echo "OPTIONS:"
	echo "-s | --single: Binding IPV6"
	echo "-b | --batch: Batch Binding IPV6"
	echo "-h | --help: Show Help"
	echo
	echo "Example: ./$(basename $0) -s 240e:d9:c200:101:7bb2::120"
	echo "Example: ./$(basename $0) -b 240e:d9:c200:101:7bb2::120 240e:d9:c200:101:7bb2::130"
	echo
}

#获取系统及版本
CheckOS() {
	if [ -e /etc/redhat-release ]; then
		OS=CentOS
		[ -n "$(grep ' 7\.' /etc/redhat-release 2> /dev/null)" ] && CentOSVer=7
		[ -n "$(grep ' 6\.' /etc/redhat-release 2> /dev/null)" ] && CentOSVer=6
	elif [ -n "$(grep -i 'Debian' /etc/issue 2> /dev/null)" ]; then
		OS=Debian
	elif [ -n "$(grep -i 'Ubuntu' /etc/issue 2> /dev/null)" ]; then
		OS=Ubuntu
	else
		OS=UnknownOS
	fi
}

CheckIpv6() {
	echo "ipv6"
}

ShowIpv6() {
	[ $1 -eq 7 ] && ifconfig|grep inet6|grep -i global|awk '{print $2}'
	[ $1 -eq 6 ] && ifconfig|grep inet6|grep -i global|awk '{print $3}'
}


Batch() {
	start="`echo $1|awk -F ':' '{print $NF}'`"
	end="`echo $2|awk -F ':' '{print $NF}'`"
	pre=`echo ${1%:*}`
	dstart=`printf %d 0X${start}`
	dend=`printf %d 0X${end}`
	total=$(($dend-$dstart+1))
	ipv6string=""
	for ((i=1;i<=$total;i++))
	do	
		[ $i -eq $total ] && ipv6string=${ipv6string}${pre}:`printf %x $dstart`"/64" || ipv6string=${ipv6string}${pre}:`printf %x $dstart`"/64 \\ "
		let dstart=dstart+1	
	done
	echo "Batch Binding IPV6"
	echo "IPV6ADDR_SECONDARIES=\"$ipv6string\"" >> $eth0f
	SetIpv6 $1 "-b"
}

SetIpv6() {
	ipv6=$1
	ipgw=`echo $ipv6|awk -F ':' '{print $1":"$2":"$3":"$4"::1"}'`
	[ -f $eth0f ] && cp $eth0f{,.bak}
	if [ -z "`grep ^'IPV6INIT=yes' $eth0f`" ]; then
		echo "IPV6INIT=yes" >> $eth0f
		echo "IPV6_DEFROUTE=yes" >> $eth0f
		[ -z $2 ] && echo "IPV6ADDR=${ipv6}/64" >> $eth0f
		echo "IPV6_DEFAULTGW=$ipgw" >> $eth0f
		restartflag=1
	else
		echo "skip set ipv6"
	fi
	[ -f $resf ] && cp $resf{,.bak}	
	if [ -z "`grep ^'nameserver 240e:56:4000:8000::69' $resf`" ]; then
		echo "nameserver 240e:56:4000:8000::69" >> $resf
		echo "nameserver 240C::6666" >> $resf
		restartflag=1
	else
		echo "skip set ipv6 dns"
	fi
	[ $restartflag -eq 1 ] && service network restart && ShowIpv6 $CentOSVer && echo "set ipv6 success"
}

CheckOS

[ -z $1 ] && ShowIpv6 $CentOSVer
while [ $1 ]; do
	case $1 in
		'-b' | '--batch' )
			[ -z "$2" -o -z "$3" ] && echo "Incomplete parameters" && exit
			Batch $2 $3
			break
			;;
		'-s' | '--single' )
			[ -z "$2" ] && echo "Incomplete parameters" && exit
			SetIpv6 $2
			break
			;;
		'-h' | '--help' )
			Help
			break
			;;
		* )
			Help
			exit
			;;
	esac
	shift		
done
