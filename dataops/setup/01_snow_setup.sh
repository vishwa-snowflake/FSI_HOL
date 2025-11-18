#!/bin/bash

# source /workspace/dataops/attendee_config.sh
pwd
cd /root
mkdir .config
cd .config
mkdir snowflake
cd snowflake
pwd

cat <<EOF > /root/.config/snowflake/config.toml
[cli.logs]
save_logs = true
path = "/root/.config/snowflake/logs"
level = "info"

[connections.aisql-connect]
account = "${DATAOPS_SNOWFLAKE_ACCOUNT}"
user = "${EVENT_USER_NAME}"
password = "${EVENT_USER_PASSWORD}"
role = "${EVENT_ATTENDEE_ROLE}"
warehouse = "${EVENT_WAREHOUSE}"
database = "${EVENT_DATABASE}"
schema = "${EVENT_SCHEMA}"
EOF

# ls -al
chmod 0600 /root/.config/snowflake/config.toml
# vim /root/.config/snowflake/config.toml

echo "--- Verifying content of config.toml ---"
cat /root/.config/snowflake/config.toml
echo "--- End of config.toml content ---"

apt-get update && apt-get install -y python3 python3-pip
pip install snowflake-cli

snow connection set-default aisql-connect

pwd
# ls -al
cd ${CI_PROJECT_DIR}
