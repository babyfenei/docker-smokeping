import zmail
import sys

def send_mail(SUBJECT,CONTENT,MAIL_TO,MAIL_FROM,MAIL_PASSWORD):
        with open(CONTENT,'r') as f:
                content_text = f.read()

        mail = {
                'subject': SUBJECT,
                'content_text': content_text,
                #'content_html': content_html,
                'attachments': CONTENT
                }

        server = zmail.server(MAIL_FROM,MAIL_PASSWORD)
        server.send_mail(MAIL_TO, mail)

send_mail(sys.argv[1], sys.argv[2],sys.argv[3],sys.argv[4],sys.argv[5])
