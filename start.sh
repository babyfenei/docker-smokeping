#!/bin/bash
# verify if initial install steps are required, if lock file does not exist run the following   

#set -euo pipefail
#echo "127.0.0.1 $(hostname) localhost localhost.localdomain" >> /etc/hosts

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
	# SMOKEPING INSTALL
else
    echo "$(date +%F_%R) [Note] rrdtool has installed in this server."
fi


if [ ! -f /smokeping/install.lock ]; then
    echo "$(date +%F_%R) [New Install] Lock file does not exist - new install."
    echo "$(date +%F_%R) [New Install] Extracting and installing SMOKEPING files"
        # 编译安装 Smokeping
        cd /build
        tar xvf smokeping-2.7.2.tar.gz && cd smokeping-2.7.2
        export PERL5LIB=/smokeping/thirdparty/lib/perl5/
        ./configure --prefix=/smokeping 
        gmake && gmake install
    echo "$(date +%F_%R) [New Install] Copying templated configurations to smokeping."
        cd /smokeping/
        mkdir cache data var
        mv /smokeping/htdocs/smokeping.fcgi.dist /smokeping/htdocs/smokeping.fcgi
        ln -s /smokeping/htdocs/smokeping.fcgi /smokeping/htdocs/smokeping.cgi
        mv -f /scripts/config /smokeping/etc/
        mv -f /scripts/targets /smokeping/etc/
        mv -f /scripts/send_mail.sh /smokeping/bin/ 
        mv -f /scripts/mailz.py /smokeping/bin/
	mv -f /scripts/smokeping_secrets /smokeping/etc/smokeping_secrets
	mv -f /scripts/slavesecrets /smokeping/etc/slavesecrets
	sed -i "160i \'--font\'\, \"TITLE:20:WenQuanYi Zen Hei Mono\"\," /smokeping/lib/Smokeping/Graphs.pm
	mv /smokeping/etc/basepage.html.dist /smokeping/etc/basepage.html
	sed -i "/SmokePing Latency Page for/s/SmokePing Latency Page for/Smokeping 网络质量监测工具 - /" /smokeping/etc/basepage.html
	sed -i "/Running on/s/Running on/Running on Docker \<a href\=\"https:\/\/hub.docker.com\/r\/babyfenei\/smokeping\/\"\>babyfenei\/smokeping/" /smokeping/etc/basepage.html
	sed -i "s/EMAIL_TO/$EMAIL_TO/g" /smokeping/bin/send_mail.sh
	sed -i "s/EMAIL_FROM_PASSWORD/$EMAIL_FROM_PASSWORD/g" /smokeping/bin/send_mail.sh
	sed -i "s/EMAIL_FROM_SMTP/$EMAIL_FROM_PASSWORD/g" /smokeping/bin/send_mail.sh
	sed -i "s/EMAIL_FROM/$EMAIL_FROM/g" /smokeping/bin/send_mail.sh
	sed -i "s#RRDTOOL_LOGO#$RRDTOOL_LOGO#g" /smokeping/bin/send_mail.sh
	ln -s /smokeping/bin/* /usr/sbin/
 # CLEANUP
    echo "$(date +%F_%R) [New Install] Removing temp smokeping installation files."
        rm -rf /build/
        yum remove -y gcc make wget cpp
        yum clean all
        rm -rf /var/cache/yum
         # create lock file so this is not re-ran on restart
    touch /smokeping/install.lock
    echo "$(date +%F_%R) [New Install] Creating lock file, smokeping setup complete."
else
    echo "$(date +%F_%R) [Note] smokeping has installed in this server."
fi


if [ ! -f /etc/httpd/conf.d/smokeping.conf ]; then
	cp -rf  /scripts/smokeping.conf /etc/httpd/conf.d/
fi

if [ ! -f /usr/bin/tcpping ]; then
	cp -rf /scripts/tcpping /usr/bin/ && chmod 777 /usr/bin/tcpping
fi

# correcting file permissions
echo "$(date +%F_%R) [Note] Setting smokeping file permissions."
chown -R apache:apache /smokeping/
chown apache:apache /smokeping/etc/smokeping_secrets
chmod 600 /smokeping/etc/smokeping_secrets
chown apache:apache /smokeping/etc/slavesecrets
chmod 600 /smokeping/etc/slavesecrets
chmod +x /smokeping/bin/send_mail.sh
chmod +x /smokeping/bin/mailz.py

# start syslog service
echo "$(date +%F_%R) [Note] Starting smokeping service."
/smokeping/bin/smokeping &


# start web service
echo "$(date +%F_%R) [Note] Starting httpd service."
httpd -DFOREGROUND
