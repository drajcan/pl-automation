SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";
BACKUP_RESTORE_SECRETS_FILE=$(realpath $SCRIPT_DIR/../company-private-configs/network-name/private/advanced/backup-restore/secrets.yaml)
BACKUP_RESTORE_CONFIG_FILE=$(realpath $SCRIPT_DIR/../company-private-configs/network-name/private/backup-restore.yaml)
helm upgrade --install --wait --timeout=600s backup-restore pharmaledger-imi/backup-restore -f $BACKUP_RESTORE_SECRETS_FILE -f $BACKUP_RESTORE_CONFIG_FILE
