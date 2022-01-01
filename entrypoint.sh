#!/bin/bash
set -e

if [[ -n "${RCLONE_CONFIG}" ]]; then
    mkdir -p /home/latex/.config/rclone
    base64 -d <<<"${RCLONE_CONFIG}" >/home/latex/.config/rclone/rclone.conf
fi

if [[ -n "${GIT_REPO}" ]]; then

    if [[ -n "${GIT_PRIVATE_KEY}" ]]; then
        mkdir -p /home/latex/.ssh
        base64 -d <<< "${GIT_PRIVATE_KEY}" >/home/latex/.ssh/priv_key
        chmod 400 /home/latex/.ssh/priv_key
        git config --global core.sshCommand "ssh -i ~/.ssh/priv_key -o StrictHostKeyChecking=no -F /dev/null"
        URL="git@${GIT_HOST:-github.com}:${GIT_REPO}"
    fi

    if [[ -n "${GIT_TOKEN}" ]]; then
        echo "https://${GIT_USER}:${GIT_TOKEN}@${GIT_HOST:-github.com}" >/home/latex/.git-credentials
        git config --global credential.helper store
        URL="https://${GIT_HOST:-github.com}/${GIT_REPO}"
    fi

    git clone -b "${GIT_BRANCH:-main}" --single-branch "${URL}" /home/latex/cloned
    cd /home/latex/cloned
    exec "${SCRIPT:-./run.sh}"

    if [[ -n "${RCLONE_CONFIG}" ]]; then
        rsync copy "${RCLONE_LOCAL_PATH}" "${RCLONE_REMOTE_PATH}"
    fi

else
    exec "$@"
fi
