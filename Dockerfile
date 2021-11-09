####################################
#            HyperC DB             #
# Let Computers Think on Their Own #
####################################


FROM ubuntu:20.04
WORKDIR /build
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y python3.8 python3-pip python-setuptools git software-properties-common wget build-essential lsb-release
RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && apt-get update 
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential libreadline-dev zlib1g-dev flex bison libxml2-dev libxslt-dev libssl-dev libxml2-utils xsltproc

ENV PGVER 14.0
# RUN wget https://ftp.postgresql.org/pub/source/v12.3/postgresql-$PGVER.tar.gz && tar -zxvf postgresql-$PGVER.tar.gz

RUN wget https://ftp.postgresql.org/pub/source/v14.0/postgresql-$PGVER.tar.bz2 && tar xvf postgresql-$PGVER.tar.bz2 
RUN mkdir -p /opt/hyperc/postgres && cd postgresql-$PGVER && ./configure --prefix=/opt/hyperc/postgres --with-python && make -j16 && make install

RUN apt install -y sudo
ENV PGHOME /opt/hyperc/db
RUN mkdir $PGHOME && useradd postgres && chown postgres:postgres $PGHOME && sudo -u postgres /opt/hyperc/postgres/bin/initdb -D $PGHOME/data

####################################
# Build complete. Stage 2.

FROM ubuntu:20.04
ENV PGVER 14.0
ENV PGHOME /opt/hyperc/db
COPY --from=0 /opt /opt
WORKDIR /opt/hyperc
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y sudo python3.8 python3-pip python-setuptools git software-properties-common wget 
RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y $(apt-cache depends postgresql | grep Depends | sed "s/.*ends:\ //" | tr '\n' ' ')
RUN chown -R postgres:postgres $PGHOME
RUN add-apt-repository ppa:pypy/ppa && apt-get update && apt-get install -y pypy3

RUN mkdir -p /var/lib/postgresql && cd /var/lib/postgresql && pip install virtualenv && virtualenv -p python3.8 .local && . .local/bin/activate && pip install downward_ch openpyxl flask formulas schedula sqlalchemy gspread google-api-python-client google_auth_oauthlib flask msal PyYAML==5.4.1 psycopg2-binary logzero 
# RUN mkdir /opt/hyperc/examples
RUN cd /var/lib/postgresql && . .local/bin/activate && pip install git+https://github.com/hyperc-ai/hyperc && pip install git+https://github.com/hyperc-ai/hyper-etable && echo rebuild1
RUN cd /opt/hyperc && git clone --depth=1 https://github.com/hyperc-ai/hyperc-psql-proxy && mkdir /etc/hyperc && cp hyperc-psql-proxy/config.yml.example /etc/hyperc/config.yml && echo rebuild3
COPY config.yml /etc/hyperc/config.yml
RUN mkdir /var/log/postgresql-proxy && chown postgres /var/log/postgresql-proxy
COPY examples/base.sql /opt/hyperc/examples/base.sql
RUN sudo -u postgres /opt/hyperc/postgres/bin/pg_ctl -D $PGHOME/data -l $PGHOME/logfile start && cd /var/lib/postgresql && sudo -u postgres bash -c ". .local/bin/activate && python3 /opt/hyperc/hyperc-psql-proxy/proxy.py /etc/hyperc/config.yml &" && sleep 1 && /opt/hyperc/postgres/bin/psql -d template1 -U postgres -c "CREATE USER pguser WITH PASSWORD '123';" -c "CREATE DATABASE testdb WITH TEMPLATE = template0 ENCODING = 'UTF8';" -c "GRANT ALL PRIVILEGES ON DATABASE testdb to pguser;" && PGPASSWORD=123 /opt/hyperc/postgres/bin/psql -h localhost --port=8493 -d testdb -U pguser -f /opt/hyperc/examples/base.sql && sudo -u postgres /opt/hyperc/postgres/bin/pg_ctl -D $PGHOME/data -l $PGHOME/logfile stop && pkill -f python3

COPY entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]