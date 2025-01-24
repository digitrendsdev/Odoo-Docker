#!/bin/bash
set -e

# Wait for PostgreSQL to be available
/usr/local/bin/wait-for-psql.py --db_host=$DB_HOST --db_port=$DB_PORT --db_user=$DB_USER --db_password=$DB_PASSWORD --timeout=30

# Start Odoo
exec "$@"
