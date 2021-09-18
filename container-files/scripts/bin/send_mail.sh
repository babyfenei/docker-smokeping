#!/bin/bash
#########################################################
# Script to email a ping report on alert from Smokeping #
#########################################################
# 解析变量
alertname=$1
target=$2
losspattern=$3
rtt=$4
hostname=$5
timestamp=`date`
SRC_IP=$(curl -s canhazip.com)
DET_IP=$5
# 自定义变量

smokename="RRDTOOL_LOGO"
smokeping_mail_content="/smokeping/log/smokeping_mail_content.$(date +%s%N)"
invoke_file=/smokeping/log/invoke.log
mail_send_log=/smokeping/log/send.log

# 把所有传过来的变量输出到脚本调用日志里，方便统计和问题排查
#echo "$(date +%F-%T)" >> invoke.log
#echo $@ >> invoke.log

# 网络恢复逻辑判断
if [ "$losspattern" = "loss: 0%" ];
then
    subject="Clear-Smokeping-${SRC_IP}-Alert:${target}:${hostname}"
else
    subject="Alert-Smokeping-${SRC_IP}-Alert:${target}:${hostname}"
fi

# generate mail content
# 清空并重新生成邮件内容
touch ${smokeping_mail_content}
>${smokeping_mail_content}

echo -e "\n" | tee -a ${smokeping_mail_content}
echo "Packet loss report from ${hostname} for $target at $timestamp" | tee -a ${smokeping_mail_content}
echo -e "\n" | tee -a ${smokeping_mail_content}
echo "Name of Alert: " $alertname | tee -a ${smokeping_mail_content}
echo "Target: " $target | tee -a ${smokeping_mail_content}
echo "Loss Pattern: " $losspattern | tee -a ${smokeping_mail_content}
echo "RTT Pattern: " $rtt | tee -a ${smokeping_mail_content}
echo "Hostname: " $hostname | tee -a ${smokeping_mail_content}
echo -e "\n" | tee -a ${smokeping_mail_content}
echo "----------------MTR--------------------" | tee -a ${smokeping_mail_content}
echo "SOURCE IP :$SRC_IP  DESTENT IP :$DET_IP"|nali | tee -a ${smokeping_mail_content}
#echo "SOURCE IP :$SRC_IP  DESTENT IP :$DET_IP"| tee -a ${smokeping_mail_content}
mtr --no-dns  -r -c3 -w -b $DET_IP |nali| column -s "]" -s " " -s "[" | column -t |grep -v "对方和您在
同一内部网" | tee -a ${smokeping_mail_content}
echo -e "\n" | tee -a ${smokeping_mail_content}
echo "----------------PING-------------------" | tee -a ${smokeping_mail_content}
ping -c 10 -i 0.5 $hostname |tail -n 3 | tee -a ${smokeping_mail_content}
echo -e "\n" | tee -a ${smokeping_mail_content}
echo "This message was send by $SRC_IP Smokeping Server. By Fenei From AMSINPUL. " | tee -a ${smokeping_mail_content}
# 创建invoke文件
if [ ! -f $invoke_file ]; then
        touch $invoke_file
fi
content_send=`cat $smokeping_mail_content`

# 判断最近10次报警是否包含本次报警主机
invoke_info=`awk 'BEGIN {"date --date=\"-60 minutes\" +%s"|getline start_time;"date +%s"|getline end_time} start_time <= $3 && $3 <= end_time' $invoke_file|grep -w $hostname`
#invoke_info=`cat $invoke_file | tail -5 | grep -w $hostname`
#如果包含退出脚本，不包含则发送邮件
if [[ -z $invoke_info ]] ;then
echo "$(date +'%F %T') $(date +%s) $hostname : mail has been send **************************************!" >> $invoke_file
#cat $smokeping_mail_content |mail -s "$subject" $email_to
#python /smokeping/bin/mailz.py "$subject" "$content_send" "$smokeping_mail_content" >> $mail_send_log 2>&1
/bin/bash /smokeping/bin/maily.sh "$subject" "$content_send" "$smokeping_mail_content" >> $mail_send_log 2>&1

exit
else
echo "$(date +'%F %T') $(date +%s) $hostname :mail not send #####################################" >> $invoke_file
#python /smokeping/bin/mailz.py "$subject" "$content_send" "$smokeping_mail_content" >> $mail_send_log 2>&1
#/bin/bash /smokeping/bin/maily.sh "$subject" "$content_send" "$smokeping_mail_content" >> $mail_send_log 2>&1
exit
fi
rm -rf $smokeping_mail_content
