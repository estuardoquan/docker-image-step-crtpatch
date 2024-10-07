#!/bin/sh
# Export required variabls for step ca
#
export SITECRT="${STEP_INIT_CRT:-/var/local/step/site.crt}"
export SITEKEY="${STEP_INIT_KEY:-/var/local/step/site.key}"

STEP_INIT_NAME="${STEP_INIT_NAME:-local.site}"

function update_root () {
    rm -f "${STEP_ROOT}" && \
    printf "%s\n" "${STEP_ROOT} removed"
    
    rm -f "${SITECRT}" "${SITEKEY}" && \
    printf "%s\n%s\n" "${SITECRT} removed" "${SITEKEY} removed"
    
    step ca root "${STEP_ROOT}"
}

function get_token () {
    local map="local"
    
    if [ -n ${STEP_INIT_MAP} ]; then
        map="${map} ${STEP_INIT_MAP}"
    fi
    
    set -- \
    "${STEP_INIT_NAME}" \
    --san localhost
    
    if [ -n "${STEP_INIT_DNS}" ]; then
        for domain in $STEP_INIT_DNS; do
            for val in $map; do
                set -- ${@} \
                --san "${domain}.${val}" \
                --san "*.${domain}.${val}"
            done
        done
        unset domain val
    fi    

    if [ -n "${STEP_INIT_SAN}" ]; then
        for san in $STEP_INIT_SAN; do
            set -- ${@} \
            --san "${san}"
        done
        unset san
    fi
    
    step ca token ${@}
}

function get_certificate () {
    TOKEN=$1
    shift 1
    if [ -n "${TOKEN}" ]; then
        set -- \
        --token "${TOKEN}" \
        "${STEP_INIT_NAME}" \
        "${SITECRT}" \
        "${SITEKEY}"
        step ca certificate ${@}
    fi
}

function init () {
    update_root
    get_certificate $(get_token)
}

init
exec "${@}"
