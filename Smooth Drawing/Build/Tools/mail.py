import smtplib

sender = 'yyj@66yun.org'
receivers = ['kavin@66yun.org']

message = """From: Justin <yyj@66yun.org>
To: Kavin <kavin@66yun.org>
Subject: SMTP email sample

- =.
"""

try:
    obj = smtplib.SMTP('smtp.exmail.qq.com')
    obj.sendmail(sender, receivers, message)
    obj.quit()
    print 'OK: send mail succeed'
except Exception:
    print 'Error: unable to send mail'