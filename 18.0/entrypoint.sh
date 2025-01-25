#!/bin/bash
set -e

# Log a message indicating the script has started
echo "Starting Odoo entrypoint script..."

# Check if required environment variables are set
if [ -z "$DB_HOST" ] || [ -z "$DB_PORT" ] || [ -z "$DB_USER" ] || [ -z "$DB_PASSWORD" ]; then
  echo "Error: Required environment variables (DB_HOST, DB_PORT, DB_USER, DB_PASSWORD) are not set."
  exit 1
fi

# Wait for PostgreSQL to be available
echo "Waiting for PostgreSQL to be ready..."
/usr/local/bin/wait-for-psql.py \
  --db_host="$DB_HOST" \
  --db_port="$DB_PORT" \
  --db_user="$DB_USER" \
  --db_password="$DB_PASSWORD" \
  --timeout=30

if [ $? -ne 0 ]; then
  echo "Error: PostgreSQL is not ready within the timeout period."
  exit 1
fi

echo "PostgreSQL is ready."

# Check if the database exists
if ! PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -U "$DB_USER" -p "$DB_PORT" -lqt | cut -d \| -f 1 | grep -qw "$DB_NAME"; then
  echo "Database $DB_NAME does not exist. Creating it..."
  PGPASSWORD="$DB_PASSWORD" createdb -h "$DB_HOST" -U "$DB_USER" -p "$DB_PORT" "$DB_NAME"
  echo "Database $DB_NAME created."
fi

# Start Odoo
echo "Starting Odoo..."
exec "$@"
