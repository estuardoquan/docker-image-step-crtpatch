FROM smallstep/step-cli

USER root

COPY ./docker-entrypoint.sh /docker-entrypoint.sh
COPY ./renewer.sh /usr/local/bin/renewer.sh

ADD ./crontab /etc/crontabs/root

RUN mkdir -p /var/local/step && \
    chown step:step /var/local/step && \
    chmod +x /docker-entrypoint.sh && \
    chmod +x /usr/local/bin/renewer.sh && \
    chmod 0644 /etc/crontabs/root  
 

HEALTHCHECK CMD step ca health 2> /dev/null | grep "^ok" > /dev/null

USER step

WORKDIR /var/local/step

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["/usr/sbin/crond", "-l", "2", "-f"]
