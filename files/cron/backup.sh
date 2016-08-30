#!/bin/bash

display_usage() {
    echo "This script triggers GraphDB backup"
    echo -e "\nUsage:\n$0 <graphdb_master_endpoint> <graphdb_master_repository_id> [<backup_id>] \n"
}

if [  $# -lt 2 ]; then
    display_usage
    exit 1
fi

GRAPHDB_MASTER_ENDPOINT=$1
GRAPHDB_MASTER_REPOSITORY_ID=$2

BACKUP_ID=$(date +%Y%d%m%H%M%S)
if [[ -n $3 ]]; then
    BACKUP_ID=$3
fi

BODY="{\"type\":\"EXEC\",\"mbean\":\"ReplicationCluster:name=ClusterInfo/${GRAPHDB_MASTER_REPOSITORY_ID}\",\"operation\":\"backup\",\"arguments\":[\"${BACKUP_ID}\"]}"
COMMAND="curl -f -s -X POST -u ':<%= @jolokia_secret %>' -d "${BODY}" ${GRAPHDB_MASTER_ENDPOINT}/jolokia"

echo -e "Backup creation triggered: [${BACKUP_ID}]"
$COMMAND

if [ $? -ne 0 ];then
    echo "Backup error!"
    exit 1
fi

echo -e "\nBackup created successfully: [${BACKUP_ID}]"
