#!/bin/bash
# verify if initial install steps are required, if lock file does not exist run the following   

#set -euo pipefail
#echo "127.0.0.1 $(hostname) localhost localhost.localdomain" >> /etc/hosts

# 编译安装 RRDtool
if [ $RRDTOOL_LOGO != "Docker-Smokeping2.8.2/rrdtool1.4.9-BY:Fenei" ];then
    	echo "$(date +%F_%R) [New Install]  rrdtool file does not exist - new install."
    	echo "$(date +%F_%R) [New Install] Extracting and installing RRDTOOL files"
        #curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
    	#curl -o /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
	cd /build && tar xvf rrdtool-1.4.9.tar.gz && cd rrdtool-1.4.9
	#Modify watermark
	sed -i "s#RRDTOOL / TOBI OETIKER#$RRDTOOL_LOGO#g" src/rrd_graph.c
	#Modify watermark transparency
	sed -i "s/water_color.alpha = 0.3;/water_color.alpha = 1.0;/g" src/rrd_graph.c
	./configure --prefix=/usr/local/rrdtool && make && make install && rm -rf /build/rrdtool*
	cp /usr/local/rrdtool/lib/perl/$(perl -v | grep -o 5.[0-9][0-9].[0-9])/x86_64-linux-thread-multi/RRDs.pm /usr/lib64/perl5/
	cp /usr/local/rrdtool/lib/perl/$(perl -v | grep -o 5.[0-9][0-9].[0-9])/x86_64-linux-thread-multi/auto/RRDs/RRDs.so /usr/lib64/perl5/
	ln -s /usr/local/rrdtool/bin/* /usr/sbin/
	yum install -y rrdtool-devel
else
    echo "$(date +%F_%R) [Note] rrdtool has installed in this server."
fi


# SMOKEPING INSTALL
if [ ! -f /smokeping/install.lock ]; then
    echo "$(date +%F_%R) [New Install] Lock file does not exist - new install."
    echo "$(date +%F_%R) [New Install] Extracting and installing SMOKEPING files"
   
	# if [ -f /smokeping/etc/targets ]; then
		# \cp -rf /smokeping/etc/targets  /tmp/targets
		# rm -rf /smokeping/
	# fi
	# 编译安装 Smokeping
	cd /build
	tar xvf smokeping-2.8.2.tar.gz && cd smokeping-2.8.2
	export PERL5LIB=/smokeping/thirdparty/lib/perl5/
	./configure --prefix=/smokeping 
	gmake && gmake install
        echo "$(date +%F_%R) [New Install] Copying templated configurations to smokeping."
	cd /smokeping/
	mkdir cache data var log
	mv /smokeping/htdocs/smokeping.fcgi.dist /smokeping/htdocs/smokeping.fcgi
	ln -s /smokeping/htdocs/smokeping.fcgi /smokeping/htdocs/smokeping.cgi
	cp -rf /scripts/etc/* /smokeping/etc/
	cp -rf /scripts/bin/* /smokeping/bin/
	cp -rf /scripts/requirements.txt /smokeping/
	#pip3 install --user -r /smokeping/requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
	sed -i "160i \'--font\'\, \"TITLE:20:WenQuanYi Zen Hei Mono\"\," /smokeping/lib/Smokeping/Graphs.pm
	mv /smokeping/etc/basepage.html.dist /smokeping/etc/basepage.html
	sed -i "/SmokePing Latency Page for/s/SmokePing Latency Page for/Smokeping 网络质量监测工具 - /" /smokeping/etc/basepage.html
	sed -i "/Running on/s/Running on/Running on Docker \<a href\=\"https:\/\/hub.docker.com\/r\/babyfenei\/smokeping\/\"\>babyfenei\/smokeping/" /smokeping/etc/basepage.html
	sed -i "s/MAIL_TO/$MAIL_TO/g" /smokeping/bin/mailz.py
	sed -i "s/MAIL_FROM_PASSWORD/$MAIL_FROM_PASSWORD/g" /smokeping/bin/mailz.py
	sed -i "s/MAIL_FROM/$MAIL_FROM/g" /smokeping/bin/mailz.py
	sed -i "s/MAIL_TO/$MAIL_TO/g" /smokeping/bin/maily.sh
	sed -i "s/MAIL_FROM_PASSWORD/$MAIL_FROM_PASSWORD/g" /smokeping/bin/maily.sh
	sed -i "s/MAIL_FROM_SERVER/$MAIL_FROM_SERVER/g" /smokeping/bin/maily.sh
	sed -i "s/MAIL_FROM/$MAIL_FROM/g" /smokeping/bin/maily.sh
	sed -i "s#RRDTOOL_LOGO#$RRDTOOL_LOGO#g" /smokeping/bin/send_mail.sh
	ln -s /smokeping/bin/* /usr/sbin/
	# CLEANUP
    echo "$(date +%F_%R) [New Install] Removing temp smokeping installation files."
    # create lock file so this is not re-ran on restart
	touch /smokeping/install.lock
	if [ -f /smokeping/install.lock ]; then
		echo "$(date +%F_%R) [Note] smokeping has installed in this server."
	else
		touch /smokeping/install.lock
		echo "$(date +%F_%R) [New Install] Creating lock file, smokeping setup complete."
	fi
fi

if [ ! -f /usr/bin/tcpping ]; then
	cp -rf /scripts/tcpping /usr/bin/ && chmod 777 /usr/bin/tcpping
fi

# create htpasswd  file
if [ ! -f /smokeping/etc/.htpasswd ]; then
	if  [ -n "$HTTP_USER" ] && [ -n "$HTTP_PASSWORD" ] ;then
		echo "$(date +%F_%R) [Note] Copy http config."
		echo "$(date +%F_%R) [Note] Create htpasswd file."
		cp -rf /scripts/smokeping_auth.conf /etc/httpd/conf.d/smokeping.conf
		echo "htpasswd -bc /smokeping/etc/.htpasswd HTTP_USER HTTP_PASSWORD" > /smokeping/bin/create_user.sh
		sed -i "s/HTTP_USER/$HTTP_USER/g" /smokeping/bin/create_user.sh
		sed -i "s/HTTP_PASSWORD/$HTTP_PASSWORD/g" /smokeping/bin/create_user.sh
		bash /smokeping/bin/create_user.sh
	else
		echo "$(date +%F_%R) [Note] Copy http config."
		cp -rf /scripts/smokeping.conf /etc/httpd/conf.d/smokeping.conf
	fi
fi




# correcting file permissions
echo "$(date +%F_%R) [Note] Setting smokeping file permissions."
mkdir -p /smokeping/log/
chmod 600 /smokeping/etc/smokeping_secrets
chmod 600 /smokeping/etc/slavesecrets
chmod +x /smokeping/bin/*
cp -rf /scripts/sendEmail /usr/bin/
chmod +x /usr/bin/sendEmail
chown -R apache:apache /smokeping/

pkill httpd
rm -rf /var/run/httpd/*

# start cron service
echo "$(date +%F_%R) [Note] Starting crond service."
if [ ! -f /etc/cron.d/smokeping_cron ]; then
	cp -rf /scripts/smokeping_cron /etc/cron.d/ && chmod 644 /etc/cron.d/smokeping_cron
fi
/usr/sbin/crond -i -s &

# start syslog service
echo "$(date +%F_%R) [Note] Starting smokeping service."
/smokeping/bin/smokeping &

# start web service
echo "$(date +%F_%R) [Note] Starting httpd service."
httpd -DFOREGROUND
