﻿﻿﻿﻿# Smokeping 2.7.2  Docker Container
---
 [![](https://images.microbadger.com/badges/image/babyfenei/smokeping.svg)](https://microbadger.com/images/babyfenei/smokeping "Get your own image badge on microbadger.com")   [![](https://images.microbadger.com/badges/version/babyfenei/smokeping.svg)](https://microbadger.com/images/babyfenei/smokeping "Get your own version badge on microbadger.com")  [![](https://images.microbadger.com/badges/license/babyfenei/smokeping.svg)](https://microbadger.com/images/babyfenei/smokeping "Get your own license badge on microbadger.com")

##### Github Repo: https://github.com/babyfenei/docker-smokeping
##### Dockerhub Repo: https://hub.docker.com/r/babyfenei/smokeping/

## Features
1. Made with the latest version 2.7.2 of smokeping.

2. Modify the rrdtool to support the Chinese language.

3. Support to modify the rrdtool side watermark.

4. Support the operation and maintenance personnel by email when the smokeping network monitors the fault.

5. Ready to increase web page login verification function.

6. Prepare to increase the smokeping preparation mode.

7. Ready to increase the automatic saving of smokeping data.

---

## Using this image
### Running the container
This docker container supports modifying the rrdtool watermark. If you need to modify, please modify the variable RRDTOOL for what you want, be careful not to use #

### Exposed Ports
The following ports are important and used by Cacti

| Port |     Notes     |  
|------|:-------------:|
|  80  | HTTP GUI Port |


It is recommended to allow at least one of the above ports for access to the monitoring system. 


### Smokeping Deployment
Now when we have our database running we can deploy Smokeping image with appropriate environmental variables set.

Example:  

    docker run \
    -d \
    --name smokeping \
    -p 80:80 \
    --env="TZ=Asia/Shanghai" \
    --env="RRDTOOL_LOGO=Smokeping2.7.2/rrdtool1.4.9-BY:Fenei" \
    --env="EMAIL_TO=alert@mail.com" \
    --env="EMAIL_FROM=alert_from@mail.com" \
    --env="EMAIL_FROM_PASSWORD=somepassword" \
    --env="EMAIL_FROM_SMTP=smtp.mail.com" \
    --env="HTTP_USER=admin" \
    --env="HTTP_PASSWORD=admin@123" \
    -v '/data/smokeping':'/smokeping':'rw' \
    babyfenei/smokeping


### Environmental Variable smokeping
You can modify the contents of the variable as needed. If there is no modification, set it according to the default value.

| Variable|Default|Description|
|:------:|:----:|:-----|
|TZ|Asia/Shanghai|Smokeping server time zone, viewable in /usr/share/zoneinfo|
|RRDTOOL_LOGO|Docker-Smokeping2.7.2/Rrdtool1.4.9-BY:Fenei|Rrdtool logo, you can modify the watermark on the right side of Smokeping graphics, be careful not to enter #|
|EMAIL_TO|alert@mail.com|Fault alarm notification mailbox|
|EMAIL_FROM|alert_from@mail.com|Alarm source email address|
|EMAIL_FROM_PASSWORD|somepassword|Alarm source email password|
|EMAIL_FROM_SMTP|smtp.mail.com|Alarm sending source mailbox SMTP address|
|HTTP_USER|admin|Apache web login username|
|HTTP_PASSWORD|admin@123|Apache web login password|

### Access Smokeping web interface
At present, smoke login has not been added to webpage login verification. This feature will be added later.

### Alarm mail settings
Because sendmail and postfix can no longer send mail based on the local server under docker, so use the zmail library under python3 here. If you want to use the mail alert feature. Please follow the steps below:
1.  First fill in the accurate email information (including username and password, SMTP server and alarm receiving address) when building docker.
Specific zmail usage can refer to
##### zmail: https://github.com/ZYunH/zmail
2.  Modify the /smokeping/etc/targets file. Add the following command to the host or host group that needs to be alerted.
`alerts = hostdown,hightloss,lossdetect,someloss,rttdetect`
