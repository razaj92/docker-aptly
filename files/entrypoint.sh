#!/bin/bash -e

USER_ID=${LOCAL_USER_ID:-501}
GROUP_ID=${LOCAL_GROUP_ID:-501}
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

log_info "Creating user aptly with UID $USER_ID"
getent group aptly >/dev/null || groupadd --system -g $GROUP_ID aptly
getent passwd aptly >/dev/null || useradd --system --shell /bin/bash -u $USER_ID -g aptly -d ${HOME} -m aptly 1>/dev/null 2>/dev/null

if [ $(stat -c '%u' ${HOME}) != $USER_ID ]; then
    log_warn "Fixing ${HOME} permissions.."
    chown -R aptly:aptly ${HOME}
fi

if [ ! -e ${HOME}/.gnupg ]; then
    log_warn "Generating GPG keypair.."

    gosu aptly bash -c "$GPG_BINARY --import /.gpg_secret_key"

fi

exec gosu aptly "$@"
