import zmail
import sys

def send_mail(SUBJECT,CONTENT,CONTENT_FILE):
        #with open(CONTENT,'r') as f:
        #        content_text = f.read()

        mail = {
                'subject': SUBJECT,
                'content_text': CONTENT,
                #'content_html': content_html,
                'attachments': CONTENT_FILE
                }

        server = zmail.server('MAIL_FROM','MAIL_FROM_PASSWORD')
        server.send_mail('MAIL_TO', mail)

send_mail(sys.argv[1], sys.argv[2], sys.argv[3])
