#!/bin/sh

set -euo pipefail
IFS=$'\n\t'

RUN_PREPARE=${DO_NOT_PREPARE:-false}

if [[ "$RUN_PREPARE" = "false" ]]; then
    echo "---> Migrating database..."
    bundle exec rake db:migrate
fi

echo "---> Starting Helpy.io server (unicorn)..."

exec bundle exec unicorn -E production -c config/unicorn.rb
