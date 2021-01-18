#!/bin/sh
set -e

if [ "$1" = 'supervisord' ]; then
    exec "$@"
else
    su-exec app "$@"
fi

