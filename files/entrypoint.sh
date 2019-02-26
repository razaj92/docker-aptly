#!/bin/bash -e

GPG_BINARY=${GPG_BINARY:-gpg1}
# Syslog numeric log level, see https://tools.ietf.org/html/rfc5424
# Defaults to warning
LOG_LEVEL=${LOG_LEVEL:-4}
export HOME=/var/lib/aptly

[ $LOG_LEVEL -gt 6 ] && set -x

log_err() {
    if [[ $LOG_LEVEL -eq 0 ]]; then
        echo "[ERROR] $*" 1>&2
    fi
}

log_warn() {
    if [[ $LOG_LEVEL -gt 3 ]]; then
        echo "[WARN] $*" 1>&2
    fi
}

log_info() {
    if [[ $LOG_LEVEL -gt 5 ]]; then
        echo "[INFO] $*" 1>&2
    fi
}

if [ $(stat -c '%u' ${HOME}) != $(id -u aptly) ]; then
    log_warn "Fixing ${HOME} permissions.."
    chown -R aptly:aptly ${HOME}
fi

if [ ! -e ${HOME}/.gnupg ]; then
    log_warn "Generating GPG keypair.."

    $GPG_BINARY --import /.gpg_secret_key

fi

exec aptly serve --listen=0.0.0.0:8080 -config=/etc/aptly.conf &
exec aptly api serve --listen 0.0.0.0:8000 -no-lock=true
