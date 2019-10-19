#!/bin/bash

set -e

NAME=Default
BACKUP_DIR=
BACKUP_DAYS=2
TEMPORARY_DIR=
WP_DIR=
SSH_HOST=
SSH_PORT=22
APPLY=

function usage_exit {
  cat <<-EOF >&2
$0 [-c][-n NAME][-b BACKUP_DIR][-p BACKUP_DAYS][-t TEMPORARY_DIR(remote)][-d WP_DIR(remote)][-H SSH_HOST][-P SSH_PORT]

ex)
  $0 -n sample -b ~/backup -t /virtual/user/tmp/backup/ -d /virtual/user/public_html -H hoge.example.com
EOF
  exit 1
}

while getopts b:cd:p:n:t:H:P:h OPT
do
  case $OPT in
      c) CHECK=true
          ;;
      n) NAME=$OPTARG
          ;;
      b) BACKUP_DIR=$OPTARG
          ;;
      p) BACKUP_DAYS=$OPTARG
          ;;
      t) TEMPORARY_DIR=$OPTARG
          ;;
      d) WP_DIR=$OPTARG
          ;;
      H) SSH_HOST=$OPTARG
          ;;
      P) SSH_PORT=$OPTARG
          ;;
      h) usage_exit
          ;;
      \?) echo "Invalid Option." >&2
          usage_exit
          ;;
  esac
done

if [[ "$NAME" == "" ]]; then
  echo "Option n is required." >&2
  exit 1
fi
if [[ "$BACKUP_DIR" == "" ]]; then
  echo "Option b is required." >&2
  exit 1
fi
if [[ "$BACKUP_DAYS" == "" ]]; then
  echo "Option c is required." >&2
  exit 1
fi
if [[ "$WP_DIR" == "" ]]; then
  echo "Option d is required." >&2
  exit 1
fi
if [[ "$TEMPORARY_DIR" == "" ]]; then
  echo "Option t is required." >&2
  exit 1
fi
if [[ "$SSH_HOST" == "" ]]; then
  echo "Option H is required." >&2
  exit 1
fi
if [[ "$SSH_PORT" == "" ]]; then
  echo "Option P is required." >&2
  exit 1
fi

echo "**********"
echo "********** ${NAME}"
echo "**********"
BACKUP_FILE=$(date +"%Y%m%d_%H%M%S")_${NAME}
export SSH_CMD="ssh ${SSH_HOST} -p ${SSH_PORT}"
export WP_CMD="wp --allow-root --ssh=${SSH_HOST}:${SSH_PORT}${WP_DIR}"

${WP_CMD} db export "${TEMPORARY_DIR}/${BACKUP_FILE}.db"
${SSH_CMD} tar zc -C / "${WP_DIR} ${TEMPORARY_DIR}/${BACKUP_FILE}.db" > "${BACKUP_DIR}/${BACKUP_FILE}.tgz"
${SSH_CMD} rm ${TEMPORARY_DIR}/${BACKUP_FILE}.db

if [ "$CHECK" == "true" ]; then
  CMD_UPDATE_CORE="${WP_CMD} core check-update"
  CMD_UPDATE_LANGUAGE="${WP_CMD} core language update --dry-run"
  CMD_UPDATE_PLUGINS="${WP_CMD} plugin update --all --dry-run"
  CMD_UPDATE_THEMES="${WP_CMD} theme update --all --dry-run"
else
  CMD_UPDATE_CORE="${WP_CMD} core update"
  CMD_UPDATE_LANGUAGE="${WP_CMD} core language update"
  CMD_UPDATE_PLUGINS="${WP_CMD} plugin update --all"
  CMD_UPDATE_THEMES="${WP_CMD} theme update --all"
fi

echo "*** STEP 3) Core"
${CMD_UPDATE_CORE}
echo
echo "*** STEP 4) Core-Language"
${CMD_UPDATE_LANGUAGE}
echo
echo "*** STEP 5) Plugins"
${CMD_UPDATE_PLUGINS}
echo
echo "*** STEP 6) Theme"
${CMD_UPDATE_THEMES}
echo

