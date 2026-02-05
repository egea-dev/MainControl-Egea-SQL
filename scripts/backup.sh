#!/bin/bash
# Script de backup para PostgreSQL - Egea Control
# Uso: ./backup.sh

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/var/backups/postgres"
DB_NAME="${POSTGRES_DB:-egea_control}"

mkdir -p $BACKUP_DIR

pg_dump -h localhost -U ${POSTGRES_USER:-egea_admin} $DB_NAME > "$BACKUP_DIR/backup_$DATE.sql"

# Mantener solo los últimos 7 backups
ls -t $BACKUP_DIR/backup_*.sql | tail -n +8 | xargs -r rm

echo "Backup completado: $BACKUP_DIR/backup_$DATE.sql"
