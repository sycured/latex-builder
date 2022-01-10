#!/bin/bash
set -e

[[ -n "${RCLONE_CONFIG_B64}" ]] && base64 -d <<<"${RCLONE_CONFIG_B64}" >/home/latex/.config/rclone/rclone.conf
[[ -n "${RCLONE_CONFIG}" ]] && cat <<<"${RCLONE_CONFIG}" >/home/latex/.config/rclone/rclone.conf

if [[ -n "${GIT_REPO}" ]]; then

    if [[ -n "${GIT_PRIVATE_KEY}" ]]; then
        mkdir -p /home/latex/.ssh
        base64 -d <<< "${GIT_PRIVATE_KEY}" >/home/latex/.ssh/priv_key
        chmod 400 /home/latex/.ssh/priv_key
        git config --global core.sshCommand "ssh -i ~/.ssh/priv_key -o StrictHostKeyChecking=no -F /dev/null"
        URL="git@${GIT_HOST:-github.com}:${GIT_REPO}"
    fi

    if [[ -n "${GIT_TOKEN}" ]]; then

        if [[ -z "${GIT_USER}" ]]; then
            echo "GIT_USER must be set when using GIT_TOKEN"
            exit 1
        fi

        echo "https://${GIT_USER}:${GIT_TOKEN}@${GIT_HOST:-github.com}" >/home/latex/.git-credentials
        git config --global credential.helper store
        URL="https://${GIT_HOST:-github.com}/${GIT_REPO}"
    fi

    git clone -b "${GIT_BRANCH:-main}" --single-branch "${URL}" /home/latex/cloned
    cd /home/latex/cloned
    "${SCRIPT:-./run.sh}"

    [[ -n "${RCLONE_LOCAL_PATH}" && -n "${RCLONE_REMOTE_PATH}" ]] && rsync "${RCLONE_ACTION:-copy}" "${RCLONE_LOCAL_PATH}" "${RCLONE_REMOTE_PATH}"

else
    exec "$@"
fi
