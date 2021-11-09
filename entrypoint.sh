#!/bin/bash
PGHOME=/opt/hyperc/db 
PGDATA=$PGHOME/data

if [ -z "$(ls -A $PGDATA)" ]; then
    echo "Initializing empty datadir"
    chown -R postgres:postgres $PGHOME && sudo -u postgres /opt/hyperc/postgres/bin/initdb -D $PGDATA
    sudo -u postgres /opt/hyperc/postgres/bin/pg_ctl -D $PGHOME/data -l $PGHOME/logfile start
    PASSWD=`< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c8`
    sudo -u postgres psql -h /tmp -c "ALTER USER postgres WITH PASSWORD '$PASSWD';"
    cd /var/lib/postgresql && sudo -u postgres bash -c ". .local/bin/activate && python3 /opt/hyperc/hyperc-psql-proxy/proxy.py /etc/hyperc/config.yml &" && sleep 1 && /opt/hyperc/postgres/bin/psql -d template1 -U postgres -c "CREATE USER pguser WITH PASSWORD '123';" -c "CREATE DATABASE testdb WITH TEMPLATE = template0 ENCODING = 'UTF8';" -c "GRANT ALL PRIVILEGES ON DATABASE testdb to pguser;" && PGPASSWORD=123 /opt/hyperc/postgres/bin/psql -h localhost --port=8493 -d testdb -U pguser -f /opt/hyperc/examples/base.sql 
    echo "--- User 'postgres' password is '$PASSWD'"
    echo "!!! Don't forget to delete DEMO databse 'testdb' and DEMO user 'pguser'!"
    echo "--- DEMO database 'testdb' initialized with user 'pguser' password '123'"
    sleep infinity 
else
    sudo -u postgres /opt/hyperc/postgres/bin/pg_ctl -D $PGHOME/data -l $PGHOME/logfile start
    while true; do
        sudo -u postgres bash -c "cd /var/lib/postgresql && . .local/bin/activate && python3 /opt/hyperc/hyperc-psql-proxy/proxy.py /etc/hyperc/config.yml"
    done;
fi


