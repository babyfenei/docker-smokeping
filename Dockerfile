FROM centos

MAINTAINER Fenei <babyfenei@qq.com>

# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG VERSION
LABEL build_version="babyfenei/smokeping version:- ${VERSION} Build-date:- ${BUILD_DATE}"

RUN \
yum install -y epel-release && \
yum install -y wget tzdata gcc make httpd httpd-devel mod_ssl glibc-devel libpng-devel \
pango-devel libxml2-devel perl-ExtUtils-CBuilder perl-ExtUtils-MakeMaker \
perl-LWP-Protocol-https perl-CPAN perl-Module-Build perl-Test-RequiresInternet \
perl-Test-Warn perl-Sys-Syslog openssl openssl-devel tcptraceroute  wqy-zenhei-fonts \
popt-devel file libidn-devel mtr kde-l10n-Chinese glibc-common

VOLUME ["/smokeping/"]

COPY container-files / 

ENV 	TZ=Asia/Shanghai \
	pythonpath=/usr/bin/python
	#LANG=C.UTF-8 \
	#PYTHONIOENCODING=UTF-8 \
	#PYTHONCOERCECLOCALE=UTF-8

RUN \
#echo 'LANG="C.UTF-8"'>/etc/locale && source /etc/profile && \
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

# 编译安装python3
#RUN \
#cd /build && tar -xf  Python-3.6.6.tar.gz && cd Python-3.6.6 && \
#./configure prefix=/usr/local/python3 && \
#make && make install && \
#mv -f $pythonpath ${pythonpath}.bak && \
#ln -s /usr/local/python3/bin/python3 $pythonpath && \
#rm -f /usr/bin/pip && \
#ln -s /usr/local/python3/bin/pip3  /usr/bin/pip && \
#sed -i '1c #!/usr/bin/python2' /usr/bin/yum && \
#sed -i '1c #!/usr/bin/python2' /usr/libexec/urlgrabber-ext-down && \
#rm -rf Python-3.6.6.tar.gz && rm -rf Python-3.6.6 && \
#pip install --upgrade pip && \
#pip install zmail && \


ENV 	RRDTOOL_LOGO=Docker-Smokeping2.7.2/rrdtool1.4.9-BY:Fenei \
	MAIL_TO=alert@mail.com \
	MAIL_FROM=alert_from@qq.com \
	MAIL_FROM_PASSWORD=somepassword \
	MAIL_FROM_SERVER=smtp.qq.com:587

EXPOSE 80

COPY start.sh /start.sh

CMD [ "bash", "/start.sh" ]
