FROM smallstep/step-cli

USER root

# Install executables
COPY ./docker-entrypoint /docker-entrypoint
COPY ./renewer /usr/local/bin/renewer

# Install crontabs
ADD ./crontab /etc/crontabs/root

# Install permissions
RUN chmod +x /docker-entrypoint /usr/local/bin/renewer
RUN chmod 0644 /etc/crontabs/root

# Install workdir
RUN mkdir -p /var/local/step
RUN chown step:step /var/local/step

HEALTHCHECK CMD step ca health 2>/dev/null | grep "^ok" >/dev/null

USER step

ENV SITECRT=/var/local/step/site.crt
ENV SITEKEY=/var/local/step/site.key

WORKDIR /var/local/step

# Install certificates
ENTRYPOINT ["/docker-entrypoint"]

CMD ["/usr/sbin/crond", "-l", "2", "-f"]