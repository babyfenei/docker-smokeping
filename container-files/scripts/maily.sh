#!/bin/bash

/usr/bin/sendEmail -f MAIL_FROM -t MAIL_TO -s MAIL_FROM_SERVER -u "$1" -o message-content-type=auto -o tls=yes -o message-charset=utf8 -xu MAIL_FROM -xp MAIL_FROM_PASSWORD -m "$2" -a $3
