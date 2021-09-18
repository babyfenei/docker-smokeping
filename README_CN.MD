﻿﻿﻿﻿# Smokeping 2.8.2 Docker Container
---
 [![](https://images.microbadger.com/badges/image/babyfenei/smokeping.svg)](https://microbadger.com/images/babyfenei/smokeping "Get your own image badge on microbadger.com")   [![](https://images.microbadger.com/badges/version/babyfenei/smokeping.svg)](https://microbadger.com/images/babyfenei/smokeping "Get your own version badge on microbadger.com")  [![](https://images.microbadger.com/badges/license/babyfenei/smokeping.svg)](https://microbadger.com/images/babyfenei/smokeping "Get your own license badge on microbadger.com")

##### Github Repo: https://github.com/babyfenei/docker-smokeping
##### Gitee  Repo: https://gitee.com/fenei/docker-smokeping
##### Dockerhub Repo: https://hub.docker.com/r/babyfenei/smokeping/

---
[README](README.md) | [中文文档](README_ZH.md)

### 功能简介
- 1. 使用最新版本2.8.2的smokeping制作。
- 2. 修改rrdtool以支持中文。
- 3. 支持自定义修改rrdtool右侧水印。
- 4. 在smokeping发生丢包等故障时时，可通过电子邮件支持运维人员。
- 5. 增加网页登录验证功能。
- 6. smokeping每分钟想prometheus的pushgateway推送数据，然后通过grafana进行进行绘图
- 7. 自动获取中国3大运营商各省会城市(部分省份为非省会城市)IP地址，并自动更新smokeping配置文件。
  
### 端口列表

80端口为smokeping端口，3000端口为grafana端口

| 端口 |     说明     |  外网是否可以访问 |
|------|:-------------:|:-------------:|
|  80  | Smokeping  Port | YES |
| 3000 | Grafana Port | YES |
| 9090 | Prometheus Port | NO |
| 9091 | Pushgateway Port | NO |


### 单独运行Smokeping
如需单独运行smokeping而不需要grafana绘图，则运行一下命令
```bash
    docker run \
    -d \
    --name smokeping \
    -p 80:80 \
    --env="TZ=Asia/Shanghai" \
    --env="RRDTOOL_LOGO=Smokeping2.8.2/rrdtool1.4.9-BY:Fenei" \
    --env="MAIL_TO=alert@mail.com" \
    --env="MAIL_FROM=alert_from@qq.com" \
    --env="MAIL_FROM_PASSWORD=somepassword" \
    --env="MAIL_FROM_SERVER=smtp.qq.com:587" \
    --env="HTTP_USER=admin" \
    --env="HTTP_PASSWORD=admin@123" \
    -v '/data/smokeping':'/smokeping':'rw' \
    babyfenei/smokeping
```


###变量说明
以下为此容器常用变量，如需更改可以使用env命令进行定义，或者直接修改docker-compose.yml文件。
| 变量名称|默认值|变量说明|
|:------:|:----:|:-----|
|TZ|Asia/Shanghai|Smokeping 时区设置, 默认为中国上海|
|RRDTOOL_LOGO|Docker-Smokeping2.8.2/Rrdtool1.4.9-BY:Fenei|Rrdtool logo, Rrdtool右侧水印设置，可以自行修改#|
|MAIL_TO|alert@mail.com|报警邮箱接收地址|
|MAIL_FROM|alert_from@qq.com|报警邮箱发送地址|
|MAIL_FROM_PASSWORD|somepassword|报警邮箱密码|
|MAIL_FROM_SERVER|smtp.qq.com:587|报警邮箱SMTP服务器地址|
|HTTP_USER|admin|Smokeping登录用户名|
|HTTP_PASSWORD|admin@123|Smokeping登录密码|

### 使用grafana绘图
#### 通过docker-compose运行
```bash
wget https://gitee.com/fenei/docker-smokeping/raw/master/docker-compose.yml | docker-compose up -d
```
- 1. Granfana默认用户名为admin 密码为admin@123 登录后自行修改。
- 2. 登录Grafana后自行添加prometheus数据源 URL栏填入：http://prometheus:9090
- 3. 下载[ grafana 面板模板文件 ](https://gitee.com/fenei/docker-smokeping/raw/master/grafana/ping_monitor.json)然后导入grafana面板。
- 4. 目前Grafana面板存在不出图或数据的bug，暂时可以编辑不出图的图标，切换一下Instant,看下是否可以解决。目前还未找到彻底的解决办法。



### Alarm mail settings
因为sendmail和postfix不能再基于docker下的本地服务器发送邮件，所以在这里使用python3下的zmail库。如果要使用邮件警报功能。请按照以下步骤操作
创建docker时，首先要填写准确的电子邮件信息（包括用户名和密码、SMTP服务器和报警接收地址）。

具体的zmail用法可以参考 zmail:[ https://github.com/ZYunH/zmail]
2.  修改/smokeping/etc/targets文件。向需要发出警报的主机或主机组添加以下命令。
```
alerts = hostdown,hightloss,lossdetect,someloss,rttdetect
```
功能截图
![添加prometheus数据源](https://gitee.com/fenei/Story-writer-picture/raw/master/小书匠/1603269243333.png)
![Grafana展示面板](https://gitee.com/fenei/Story-writer-picture/raw/master/小书匠/1603269449036.png)
![Smokeping面板](https://gitee.com/fenei/Story-writer-picture/raw/master/小书匠/1603269552310.png)

### 联系我
* Blog: [https://blog.fengjinhao.com/](https:/blog.fengjinhao.com/)
* QQ: 407603129
* MAIL：babyfenei@qq.com


### 感谢

此容器使用到一下项目，在此表示感谢。

* [zmail](https://github.com/ZYunH/zmail)
* [idc_ping_monitor](https://github.com/wilsonchai8/idc_ping_monitor)

