FROM smallstep/step-cli

USER root

ENV STEPPATH=/var/local/step
ENV STEP_ROOT="${STEPPATH}/root_ca.crt"
ENV SITECRT="${STEPPATH}/site.crt"
ENV SITEKEY="${STEPPATH}/site.key"
ENV STEP_RENEW_PERIOD="1m"

COPY ./docker-entrypoint.sh /docker-entrypoint.sh

RUN mkdir -p ${STEPPATH} && \
    chown -R step:step ${STEPPATH} && \
    chmod +x /docker-entrypoint.sh 

HEALTHCHECK CMD step ca health 2> /dev/null | grep "^ok" > /dev/null

WORKDIR ${STEPPATH}

ENTRYPOINT ["/docker-entrypoint.sh"]

USER step

CMD step ca renew --daemon \
    --renew-period "${STEP_RENEW_PERIOD}" \
    "${SITECRT}" \
    "${SITEKEY}"

