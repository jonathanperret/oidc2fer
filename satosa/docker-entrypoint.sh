#!/usr/bin/env bash
set -Eeuo pipefail

## Override https://github.com/IdentityPython/satosa-docker/blob/main/docker-entrypoint.sh
## to not re-generate config at each start

source /usr/local/bin/docker-entrypoint.sh

function docker_create_config() {
  mkdir -p run
  printenv SAML2_BACKEND_CERT > run/backend.crt
  printenv SAML2_BACKEND_KEY > run/backend.key
  printenv OIDC_FRONTEND_KEY > run/frontend.key
  printenv CLIENT_DB_JSON > run/client_db.json
}

# if the first arg looks like a flag, assume it's for Gunicorn
if [ "${1:0:1}" = '-' ]; then
  set -- gunicorn "$@"
fi

if [ "$1" = 'gunicorn' ]; then
  docker_setup_env
  docker_create_config
  exec "$@"
fi

exec "$@"
