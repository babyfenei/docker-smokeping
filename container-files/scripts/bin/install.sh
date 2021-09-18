#!/bin/bash
# verify if initial install steps are required, if lock file does not exist run the following   

#set -euo pipefail
#echo "127.0.0.1 $(hostname) localhost localhost.localdomain" >> /etc/hosts

# 安装依赖
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo && \
curl -o /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo && \
yum install -y vim wget tzdata gcc python3 python3-pip python36-devel cronie crontabs make httpd httpd-devel mod_ssl glibc-devel libpng-devel \
pango-devel libxml2-devel perl-ExtUtils-CBuilder perl-ExtUtils-MakeMaker \
perl-LWP-Protocol-https perl-CPAN perl-Module-Build perl-Test-RequiresInternet \
perl-Test-Warn perl-Sys-Syslog openssl openssl-devel tcptraceroute  wqy-zenhei-fonts \
libcurl-devel popt-devel file libidn-devel mtr kde-l10n-Chinese glibc-common ntpdate  && \
yum clean all && rm -rf /var/cache/yum/*

# 设置时区
echo 'LANG="C.UTF-8"'>/etc/locale && source /etc/profile && \
cp -rf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
rm -f /etc/httpd/conf.d/welcome.conf && \

# 编译安装 Fping
cd /build && tar xvf fping-4.0.tar.gz && cd fping-4.0 && ./configure && make && make install && rm -rf /build/fping* && \

# 编译安装 Echoping
cd /build && tar xvf echoping-6.0.2.tar.gz && cd echoping-6.0.2 && ./configure && make && make install && rm -rf /build/echoping* && \

# 编译安装 nali
cd /build && tar -xf nali.tar.gz && cd nali && ./configure && make && make install && rm -rf /build/nali* && \
ln -s /usr/local/sbin/fping /usr/sbin/fping && \
ln -s /usr/local/bin/echoping /usr/sbin/echoping


# 编译安装 RRDtool
if [ ! -f /usr/sbin/rrdtool ]; then
    echo "$(date +%F_%R) [New Install]  rrdtool file does not exist - new install."
    echo "$(date +%F_%R) [New Install] Extracting and installing RRDTOOL files"
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
	tar xvf smokeping-2.7.3.tar.gz && cd smokeping-2.7.3
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
	pip3 install --user -r /smokeping/requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
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
