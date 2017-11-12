# Elastalert Docker image running on Alpine Linux.
# Build image with: docker build -t ivankrizsan/elastalert:latest .

FROM alpine

LABEL maintainer="vijayakumar, https://github.com/nsvijay04b1"

# Set this environment variable to True to set timezone on container start.
ENV SET_CONTAINER_TIMEZONE False
# Default container timezone as found under the directory /usr/share/zoneinfo/.
ENV CONTAINER_TIMEZONE Europe/Stockholm
# URL from which to download Elastalert.
ENV ELASTALERT_URL https://github.com/Yelp/elastalert/archive/master.zip
# Directory holding configuration for Elastalert .
ENV EA_CONFIG_DIR /etc/elastalert
# Directory holding configuration for Supervisor.
ENV SV_CONFIG_DIR /etc/supervisord
# Elastalert configuration file path in configuration directory.
ENV ELASTALERT_CONFIG ${EA_CONFIG_DIR}/elastalert.yaml
# Directory to which Elastalert and Supervisor logs are written.
ENV LOG_DIR /var/logs/elastalert
# Elastalert home directory full path.
ENV ELASTALERT_HOME /opt/elastalert-server
# Elastalert rules directory.
ENV RULES_DIRECTORY ${ELASTALERT_HOME}/rules
# Supervisor configuration file for Elastalert.
ENV ELASTALERT_SUPERVISOR_CONF ${SV_CONFIG_DIR}/elastalert_supervisord.conf
# Alias, DNS or IP of Elasticsearch host to be queried by Elastalert. Set in default Elasticsearch configuration file.
ENV ELASTICSEARCH_HOST elasticsearch-020-elasticsearch-client
#ENV ELASTICSEARCH_HOST elasticsearch.dto373.k8s.cloudnative.corp.amdocs.com
# Port on above Elasticsearch host. Set in default Elasticsearch configuration file.
ENV ELASTICSEARCH_PORT 9200
# Use TLS to connect to Elasticsearch (True or False)
ENV ELASTICSEARCH_TLS False
# Verify TLS
ENV ELASTICSEARCH_TLS_VERIFY True
# ElastAlert writeback index
ENV ELASTALERT_INDEX elastalert_status
ENV FTP_PROXY "http://genproxy.corp.amdocs.com:8080/"

ENV ftp_proxy "http://genproxy.corp.amdocs.com:8080/"

ENV HTTPS_PROXY "http://genproxy.corp.amdocs.com:8080/"

ENV https_proxy "http://genproxy.corp.amdocs.com:8080/"

ENV no_proxy "localhost,127.0.0.1,.corp.amdocs.com,.amdocs.com,corp.amdocs.com,amdocs.com,localaddress,.localdomain.com,/var/run/docker.sock,.sock"

ENV HTTP_PROXY "http://genproxy.corp.amdocs.com:8080/"

WORKDIR /opt

# Install software required for Elastalert and NTP for time synchronization.
RUN apk update && \
    apk upgrade && \
    apk add ca-certificates openssl-dev openssl libffi-dev python2 python2-dev py2-pip py2-yaml gcc musl-dev tzdata openntpd wget && \
# Download and unpack Elastalert.
    wget -O elastalert.zip "${ELASTALERT_URL}" && \
    unzip elastalert.zip && \
    rm elastalert.zip && \
    mv e* "${ELASTALERT_HOME}" && \
    sed -i.back "s#elasticsearch#urllib3==1.21.1\nelasticsearch#g" ${ELASTALERT_HOME}/requirements.txt && \
    sed -i.back "s#'elasticsearch',#'urllib3==1.21.1',\n\t'elasticsearch',#g" ${ELASTALERT_HOME}/setup.py && \
    cat ${ELASTALERT_HOME}/requirements.txt  ${ELASTALERT_HOME}/setup.py

WORKDIR "${ELASTALERT_HOME}"


# Install Elastalert.
RUN python setup.py install && \
    pip install -e . && \
    pip uninstall twilio --yes && \
    pip install twilio==6.0.0 && \

# Install Supervisor.
    easy_install supervisor && \

# Create directories. The /var/empty directory is used by openntpd.
    mkdir -p "${EA_CONFIG_DIR}" && \
    mkdir -p "${SV_CONFIG_DIR}" && \
    mkdir -p "${ELASTALERT_HOME}" && \
    mkdir -p "${RULES_DIRECTORY}" && \
    mkdir -p "${LOG_DIR}" && \
    mkdir -p /var/empty && \

# Clean up.
    apk del python2-dev && \
    apk del musl-dev && \
    apk del gcc && \
    apk del openssl-dev && \
    apk del libffi-dev && \
    rm -rf /var/cache/apk/*

# Copy the script used to launch the Elastalert when a container is started.
COPY ./start-elastalert.sh ${SV_CONFIG_DIR}

COPY ./severity_frequency.yaml ${RULES_DIRECTORY}/
# Make the start-script executable.
RUN chmod +x ${SV_CONFIG_DIR}/start-elastalert.sh

# Define mount points.
VOLUME [ "${EA_CONFIG_DIR}", "${SV_CONFIG_DIR}","${RULES_DIRECTORY}", "${LOG_DIR}"]

# Launch Elastalert when a container is started.
CMD ["/etc/supervisord/start-elastalert.sh"]




