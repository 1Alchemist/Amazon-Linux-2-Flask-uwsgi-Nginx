FROM amazonlinux

COPY script /script

COPY src/ /var/www/

RUN chmod +x /script/setup.sh

RUN yes | bash /script/setup.sh


EXPOSE 80

CMD ["/usr/local/bin/supervisord","-c","/etc/supervisord.conf","-n"]