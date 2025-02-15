#!/bin/sh

#set -eo pipefail

SITECRT="${SITECRT:?ERROR: required SITECRT}"
SITEKEY="${SITEKEY:?ERROR: required SITEKEY}"
STEP_ROOT="${STEP_ROOT:?ERROR: required ROOTCRT}"

STEP_INIT_NAME="${STEP_INIT_NAME:-}"

function update_root () {

    local c="${1:?ERROR: required crt}"
    local k="${2:?ERROR: required key}"    
    local r="${3:?ERROR: required root}"
    
    rm -f "${r}" && \
    printf  "[%s] removed: %s\n" "${FUNCNAME}" "${r}"
    
    rm -f "${c}" && \
    printf  "[%s] removed: %s\n" "${FUNCNAME}" "${c}"

    rm -f "${k}" && \
    printf  "[%s] removed: %s\n" "${FUNCNAME}" "${k}"

    local e=-1

    while [[ $e != 1 ]]; do 
        step ca root "${r}" && break || sleep 5
        
        e=$((e+1))
    
        if [[ $e == 1 ]]; then
            printf "[%s] ERROR: %s\n" "${FUNCNAME}" "Exceeded attempts to download root certificate" >&2
            return 1
        fi
    done
}

function get_token () {
    local name="${1:?Error: required name}"
    local dns="${2:-localhost}"
    local san="${3:-}"
    
    set -- "${name}"
    
    if [ -n "${dns}" ]; then
        for d in $dns; do
                set -- ${@} \
                --san "${d}" \
                --san "*.${d}"
        done
        unset d
    fi    

    if [ -n "${san}" ]; then
        for s in $san; do
            set -- ${@} \
            --san "${s}"
        done
        unset s
    fi

    step ca token ${@} 2> /dev/null || echo -1 > /dev/null 
}

function init () {
    update_root "${SITECRT}" "${SITEKEY}" "${STEP_ROOT}" && \
        printf "[%s]: %s\n" "${FUNCNAME}" "Certificates updated successfully" || \
        return 1


    local token=$(get_token "${STEP_INIT_NAME}" "${STEP_INIT_DNS}" "${STEP_INIT_SAN}")
    
    if [[ $token == -1 ]]; then
        printf "[%s] ERROR: %s\n" "${FUNCNAME}" "Token could not be retrieved" >&2
        return 1
    else    
        printf "[%s]: %s\n" "${FUNCNAME}" "Token retrieved successfully"
    fi
    
    set -- \
        --token "${token}" \
        "${STEP_INIT_NAME}" \
        "${SITECRT}" \
        "${SITEKEY}"

    step ca certificate ${@}
}

init && \
    printf "%s\n" "Step CA initialized" || \
    printf "%s\n" "Error initializing Step CA"

exec "${@}"
