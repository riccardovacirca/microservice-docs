#!/bin/bash
# ------------------------------------------------------------------------------
if [ -z "$BASH_VERSION" ]; then exec /bin/bash "$0" "$@"; fi
# ------------------------------------------------------------------------------
if [ -f /.dockerenv ]; then
  echo "Error: You cannot run this installation inside a docker container."
  echo ""
  exit 1
fi
# ------------------------------------------------------------------------------
if [ -z "$1" ]; then
  option="default"
else
  option="${1#--}"
fi
# ------------------------------------------------------------------------------
# ENV VARIABLES
# ------------------------------------------------------------------------------
SERVICE_NAME=$(basename "$PWD")
SERVICE_AUTHOR=""
SERVICE_DESCRIPTION=""
SERVICE_URI=""
SERVICE_CMD="/usr/bin/service"
SERVICE_BIN="bin/service"
SERVICE_HOST="0.0.0.0"
SERVICE_PORT=2310
SERVICE_TLS_PORT=2443
SERVICE_LOG="/var/log/service.log"
SERVICE_PID_FILE="/run/service.pid"
SERVICE_JWT_KEY="jwt-key-secret"
SERVICE_NETWORK="service-network"
SERVICE_DOCKER_IMAGE="ubuntu:latest"
SERVICE_WORKING_DIR="/service"
SERVICE_INSTALL_DIR="/opt/services"
SERVICE_DEV_DEPENDENCIES="apt-utils nano clang make curl git python3 \
autoconf libtool-bin libexpat1-dev cmake libssl-dev libmariadb-dev libpq-dev \
libsqlite3-dev unixodbc-dev libapr1-dev libaprutil1-dev libaprutil1-dbd-mysql \
libaprutil1-dbd-pgsql libaprutil1-dbd-sqlite3 libjson-c-dev libjwt-dev siege \
valgrind doxygen graphviz nlohmann-json3-dev libgtest-dev docker.io \
ca-certificates mysql-client"
DB_IMAGE=""
DB_CONTAINER=""
DB_SERVER="mariadb"
DB_DRIVER="mysql"
DB_HOST="mariadb"
DB_PORT="3306"
DB_ROOT_PASSWORD=""
DB_PASSWORD=""
DB_SCHEMA="database/mariadb-schema.sql"
DB_DATA="database/mariadb-data.sql"
GITHUB_USER=""
GITHUB_MAIL=""
GITHUB_TOKEN=""
BENCH_CONCURRENCE=1
BENCH_TIME=10s
SERVICE_DEPENDENCIES="curl libssl3 libmariadb3 libpq5 libsqlite3-0 unixodbc \
libjson-c5 libapr1 libaprutil1 libaprutil1-dbd-mysql libaprutil1-dbd-pgsql \
libaprutil1-dbd-sqlite3 libjwt2 wget gnupg"
MONGOOSE_GITHUB_REPO="https://github.com/riccardovacirca/mongoose.git"
MONGOOSE_DIR="mongoose"
UNITY_GITHUB_REPO="https://github.com/riccardovacirca/Unity.git"
UNITY_DIR="unity"
CPPJWT_GITHUB_REPO="https://github.com/riccardovacirca/cpp-jwt.git"
CPPJWT_DIR="cppjwt"
# ------------------------------------------------------------------------------
# HELP
# ------------------------------------------------------------------------------
if [ "$option" = "help" ]; then
  VERS="v0.0.1"
  if [ -f VERSION ]; then VERS=$(cat VERSION); fi
  echo "${SERVICE_NAME}-${VERS}"
  echo "(C)2023-2025 Riccardo Vacirca - All right reserved."
  echo ""
  echo "Usage: ./install.sh [OPTION]"
  echo ""
  echo "Options:"
  echo "    --env        Build the .env configuration file"
  echo "    --env-test   Build the .env configuration file for test"
  echo "    --release    Install the release version"
  echo "    --help       Show this help"
  echo ""
  exit 0
fi
# ------------------------------------------------------------------------------
# ENV FILE
# ------------------------------------------------------------------------------
if [ "$option" = "env" ]; then
  if [ -f .env ]; then
    echo "Error: .env file exists!"
    exit 1
  fi
  cat > ".env" << EOF
SERVICE_NAME="${SERVICE_NAME}"
SERVICE_AUTHOR="${SERVICE_AUTHOR}"
SERVICE_DESCRIPTION="${SERVICE_DESCRIPTION}"
SERVICE_URI="${SERVICE_URI}"
SERVICE_CMD="${SERVICE_CMD}"
SERVICE_BIN="${SERVICE_BIN}"
SERVICE_HOST="${SERVICE_HOST}"
SERVICE_PORT="${SERVICE_PORT}"
SERVICE_TLS_PORT="${SERVICE_TLS_PORT}"
SERVICE_LOG="${SERVICE_LOG}"
SERVICE_PID_FILE="${SERVICE_PID_FILE}"
SERVICE_JWT_KEY="${SERVICE_JWT_KEY}"
SERVICE_DOCKER_IMAGE="${SERVICE_DOCKER_IMAGE}"
SERVICE_WORKING_DIR="${SERVICE_WORKING_DIR}"
SERVICE_INSTALL_DIR="${SERVICE_INSTALL_DIR}"
SERVICE_DEV_DEPENDENCIES="${SERVICE_DEV_DEPENDENCIES}"
SERVICE_NETWORK="${SERVICE_NETWORK}"
GITHUB_USER="${GITHUB_USER}"
GITHUB_MAIL="${GITHUB_MAIL}"
GITHUB_TOKEN="${GITHUB_TOKEN}"
BENCH_CONCURRENCE=$BENCH_CONCURRENCE
BENCH_TIME=$BENCH_TIME
SERVICE_DEPENDENCIES="${SERVICE_DEPENDENCIES}"
DB_IMAGE="${DB_IMAGE}"
DB_CONTAINER="${DB_CONTAINER}"
DB_SERVER="${DB_SERVER}"
DB_DRIVER="${DB_DRIVER}"
DB_HOST="${DB_HOST}"
DB_PORT="${DB_PORT}"
DB_ROOT_PASSWORD="${DB_ROOT_PASSWORD}"
DB_PASSWORD="${DB_PASSWORD}"
DB_SCHEMA="${DB_SCHEMA}"
DB_DATA="${DB_DATA}"
MONGOOSE_GITHUB_REPO="${MONGOOSE_GITHUB_REPO}"
MONGOOSE_DIR="${MONGOOSE_DIR}"
UNITY_GITHUB_REPO="${UNITY_GITHUB_REPO}"
UNITY_DIR="${UNITY_DIR}"
CPPJWT_GITHUB_REPO="${CPPJWT_GITHUB_REPO}"
CPPJWT_DIR="${CPPJWT_DIR}"
EOF
  exit 0
fi
# ------------------------------------------------------------------------------
# ENV FILE TEST
# ------------------------------------------------------------------------------
if [ "$option" = "env-test" ]; then
  if [ -f .env ]; then
    echo "Error: .env file exists!"
    exit 1
  fi
  cat > ".env" << EOF
SERVICE_NAME="service"
SERVICE_CMD="${SERVICE_CMD}"
SERVICE_BIN="${SERVICE_BIN}"
SERVICE_HOST="127.0.0.1"
SERVICE_PORT="2222"
SERVICE_TLS_PORT="3333"
SERVICE_LOG="${SERVICE_LOG}"
SERVICE_PID_FILE="${SERVICE_PID_FILE}"
SERVICE_JWT_KEY="secret-jwt-key"
SERVICE_DOCKER_IMAGE="${SERVICE_DOCKER_IMAGE}"
SERVICE_WORKING_DIR="${SERVICE_WORKING_DIR}"
SERVICE_INSTALL_DIR="${SERVICE_INSTALL_DIR}"
SERVICE_DEV_DEPENDENCIES="${SERVICE_DEV_DEPENDENCIES}"
SERVICE_NETWORK="${SERVICE_NETWORK}"
DB_IMAGE="mariadb:latest"
DB_CONTAINER="mariadb"
DB_SERVER="${DB_SERVER}"
DB_DRIVER="${DB_DRIVER}"
DB_HOST="${DB_HOST}"
DB_PORT="${DB_PORT}"
DB_ROOT_PASSWORD="secret"
DB_PASSWORD="secret"
DB_SCHEMA="${DB_SCHEMA}"
DB_DATA="${DB_DATA}"
BENCH_CONCURRENCE=$BENCH_CONCURRENCE
BENCH_TIME=$BENCH_TIME
MONGOOSE_GITHUB_REPO="${MONGOOSE_GITHUB_REPO}"
MONGOOSE_DIR="${MONGOOSE_DIR}"
UNITY_GITHUB_REPO="${UNITY_GITHUB_REPO}"
UNITY_DIR="${UNITY_DIR}"
CPPJWT_GITHUB_REPO="${CPPJWT_GITHUB_REPO}"
CPPJWT_DIR="${CPPJWT_DIR}"
EOF
  exit 0
fi
# ------------------------------------------------------------------------------
if [ ! -f .env ]; then
  echo "Error: .env file does not exists!"
  exit 1
fi
# ------------------------------------------------------------------------------
source .env
# ------------------------------------------------------------------------------
# PURGE
# ------------------------------------------------------------------------------
if [ "$option" = "purge" ]; then
  rm -rf cppjwt mongoose unity
  rm -rf bin tmp .env
  if [ -n "$(docker ps -a -q -f name=${SERVICE_NAME})" ]; then
    docker stop $SERVICE_NAME && docker rm $SERVICE_NAME
  fi
  if [ -n "$(docker ps -a -q -f name=${DB_CONTAINER})" ]; then
    docker stop $DB_CONTAINER && docker rm $DB_CONTAINER
  fi
  docker system prune -a --volumes
  exit 0
fi
# ------------------------------------------------------------------------------
# DOCS
# ------------------------------------------------------------------------------
if [ "$option" = "docs" ]; then
  if [ -n "$GITHUB_USER" ] && [ -n "$GITHUB_MAIL" ]; then
    if [ -n "$GITHUB_TOKEN" ] && [ -z "${GIT_DOCS_SUBTREE_INSTALLED}" ]; then
      mkdir -p docs
      mkdir -p docs/bin
      mkdir -p docs/.github/workflows
      cat > Doxyfile << EOF
PROJECT_NAME=${SERVICE_NAME}
INPUT=microservice.c microservice.h main.c service.c service.h
OUTPUT_DIRECTORY=docs
GENERATE_HTML=YES
GENERATE_LATEX=NO
EOF
      cat > docs/index.html << EOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${SERVICE_NAME}</title>
</head>
<body>
  <h1>${SERVICE_NAME}</h1>
  <h3>${SERVICE_DESCRIPTION}</h3>
</body>
</html>
EOF
      cat > docs/.github/workflows/workflow.yml << EOF
name: Main CI/CD Workflow
on:
  push:
    branches:
      - main
    paths:
      - 'bin/service'
jobs:
  branch-main-job:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3
        with:
          fetch-depth: 0
      - name: Run binary unit-test
        run: ./install.sh --env-test && ./install.sh --test-bin
EOF
      if [ -n "${SERVICE_URI}" ]; then
        echo "${SERVICE_URI}" > docs/CNAME
      fi
      docker exec -i $SERVICE_NAME bash -c "\
        cd ${SERVICE_WORKING_DIR} && doxygen Doxyfile"
      docker exec -i $SERVICE_NAME bash -c "\
        curl -X POST https://api.github.com/user/repos \
        -H \"Authorization: token ${GITHUB_TOKEN}\" \
        -H \"Accept: application/vnd.github.v3+json\" \
        -d '{\"name\": \"${SERVICE_NAME}-docs\", \"private\": false}'"
      docker exec -i $SERVICE_NAME bash -c "\
        cd ${SERVICE_WORKING_DIR}/docs \
        && git init \
        && git config --global --add safe.directory $SERVICE_WORKING_DIR/docs \
        && git config user.name \"$GITHUB_USER\" \
        && git config user.email \"$GITHUB_MAIL\" \
        && git remote add origin https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${SERVICE_NAME}-docs.git \
        && git checkout -b main \
        && git add . \
        && git commit -m \"Initial commit\" \
        && git push -u origin main"
      # Non funziona con un classic token
      # if [ -n "${SERVICE_URI}" ]; then
      #   docker exec -i $SERVICE_NAME bash -c "\
      #     curl -X PUT https://api.github.com/repos/${GITHUB_USER}/${SERVICE_NAME}-docs/pages \
      #     -H \"Authorization: token ${GITHUB_TOKEN}\" \
      #     -H \"Accept: application/vnd.github.v3+json\" \
      #     -d '{
      #       \"source\": {
      #         \"branch\": \"main\", 
      #         \"path\": \"/\"
      #       },
      #       \"cname\": \"${SERVICE_URI}\"
      #     }'"
      # fi
      echo ""
      echo "Specificare il path nella sezione Pages di Github per settare un custom CNAME"
    fi
  fi
  exit 0
fi
# ------------------------------------------------------------------------------
# NETWORK
# ------------------------------------------------------------------------------
if [ -n "${SERVICE_NETWORK}" ]; then
  echo "Check for network..."
  if ! docker network ls --format '{{.Name}}' | grep -q "^${SERVICE_NETWORK}$"; then
    STEP="y"
    if [ "$option" = "debug" ]; then
      read -p "docker network create ${SERVICE_NETWORK}? (y/N) " STEP;
    fi
    if [ "$STEP" = "y" ]; then
      docker network create "${SERVICE_NETWORK}"
    fi
  fi
fi
# ------------------------------------------------------------------------------
# DATABASE SERVER
# ------------------------------------------------------------------------------
if [ -n "${DB_CONTAINER}" ]; then
  echo "Check for database container..."
  if [ -z "$(docker ps -a -q -f name=${DB_CONTAINER})" ]; then
    echo "Container ${DB_CONTAINER} does not exists."
    STEP="y"
    if [ -n "${DB_IMAGE}" ]; then
      if [ "$option" = "debug" ]; then
        read -p "docker pull ${DB_IMAGE}? (y/N) " STEP;
      fi
      if [ "$STEP" = "y" ]; then
        docker pull $DB_IMAGE
      fi
    fi
    if [ "${DB_SERVER}" = "mariadb" ]; then
      if [ -n "$DB_ROOT_PASSWORD" ]; then
        STEP="y"
        if [ "$option" = "debug" ]; then
          read -p "docker run -d --name ${DB_CONTAINER}...? (y/N) " STEP;
        fi
        if [ "$STEP" = "y" ]; then
          docker run -d --name $DB_CONTAINER --network $SERVICE_NETWORK \
            -e MARIADB_ROOT_PASSWORD=$DB_ROOT_PASSWORD -p 3306:3306 $DB_IMAGE
          docker start $DB_CONTAINER
        fi
        until [ "$(docker inspect -f '{{.State.Running}}' $DB_CONTAINER 2>/dev/null)" = "true" ]; do
          echo "Waiting for container $DB_CONTAINER to start..."
          sleep 2
        done
        STEP="y"
        if [ "$option" = "debug" ]; then
          read -p "Install mysql into $DB_CONTAINER? (y/N) " STEP;
        fi
        if [ "$STEP" = "y" ]; then
          docker exec -i $DB_CONTAINER bash -c "\
            apt-get update && apt-get install -y --no-install-recommends \
            mysql-client && apt-get clean && rm -rf /var/lib/apt/lists/* && \
            until mysql -h 127.0.0.1 -uroot -p$DB_ROOT_PASSWORD \
              -e \"SELECT 1;\" > /dev/null 2>&1; do \
              echo \"Waiting for $DB_CONTAINER to be ready...\"; \
              sleep 2; \
            done && \
            mysql -h 127.0.0.1 -uroot -p$DB_ROOT_PASSWORD -e \" \
              GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' \
              IDENTIFIED BY '$DB_ROOT_PASSWORD' WITH GRANT OPTION; \
              FLUSH PRIVILEGES;\""
        fi
      else
        echo "Invalid root password"
      fi
    fi
    if [ "${DB_CONTAINER}" = "postgresql" ]; then
      echo "${DB_CONTAINER} not supported."
    fi
    if [ "${DB_CONTAINER}" = "sqlite3" ]; then
      echo "${DB_CONTAINER} not supported."
    fi
  fi
fi
# ------------------------------------------------------------------------------
# TEST-BIN
# Se ./install.sh --test-bin viene eseguito sul server di sviluppo
# occorre rinominare il container di test per evitare confitti con quello
# di sviluppo
# ------------------------------------------------------------------------------
if [ "$option" = "test-bin" ] && [ "${SERVICE_NAME}" != "service" ]; then
  SERVICE_NAME="service"
fi
# ------------------------------------------------------------------------------
# DATABASE SCHEMA/DATA
# ------------------------------------------------------------------------------
if [ -z "$DB_INSTALLED" ]; then
  if [ "$DB_SERVER" = "mariadb" ]; then
    if [ -n "$DB_PASSWORD" ]; then
      if [ -f "$DB_SCHEMA" ]; then
        ROOT_PASSWORD_OPT=""
        if [ -n "$DB_ROOT_PASSWORD" ]; then
          ROOT_PASSWORD_OPT="-p${DB_ROOT_PASSWORD}"
        fi
        STEP="y"
        if [ "$option" = "debug" ]; then
          read -p "Create database and user? (y/N/s=stop) " STEP;
        fi
        if [ "$STEP" = "s" ]; then exit 0; fi
        if [ "$STEP" = "y" ]; then
          docker exec -i $DB_CONTAINER bash -c "\
            mysql -h 127.0.0.1 -uroot ${ROOT_PASSWORD_OPT} -e \"
            CREATE DATABASE IF NOT EXISTS $SERVICE_NAME;
            CREATE USER IF NOT EXISTS '$SERVICE_NAME'@'%' \
            IDENTIFIED BY '$DB_PASSWORD';
            GRANT ALL PRIVILEGES ON $SERVICE_NAME.* \
            TO '$SERVICE_NAME'@'%' WITH GRANT OPTION;
            FLUSH PRIVILEGES;\""
        fi
        if [ -n $DB_SCHEMA ]; then
          STEP="y"
          if [ "$option" = "debug" ]; then
            read -p "Create schema and data? (y/N/s=stop) " STEP;
          fi
          if [ "$STEP" = "s" ]; then exit 0; fi
          if [ "$STEP" = "y" ]; then
            cat $DB_SCHEMA | \
              docker exec -i $DB_CONTAINER mysql -h 127.0.0.1 -u$SERVICE_NAME \
              -p$DB_PASSWORD $SERVICE_NAME
            if [ -f "$DB_DATA" ]; then
              cat $DB_DATA | \
                docker exec -i $DB_CONTAINER mysql -h 127.0.0.1 -u$SERVICE_NAME \
                -p$DB_PASSWORD $SERVICE_NAME
            fi
          fi
        fi
        DB_CONN_S=""
        if [ -n "${DB_HOST}" ] && \
          [ -n "${DB_PORT}" ] && \
          [ -n "${DB_PASSWORD}" ] && \
          [ -n "${SERVICE_NAME}" ]; then
          DB_CONN_S="host=${DB_HOST},port=${DB_PORT},"
          DB_CONN_S+="user=${SERVICE_NAME},pass=${DB_PASSWORD},"
          DB_CONN_S+="dbname=${SERVICE_NAME}"
          echo "DB_CONN_S=\"${DB_CONN_S}\"" >> .env
          echo "DB_INSTALLED=\"y\"" >> .env
        fi
      fi
    fi
  fi
fi
# ------------------------------------------------------------------------------
# RELEASE
# Installa immagine e conatiner della versione di rilascio dal file di
# distribuzione tar.gz generato con make
# ------------------------------------------------------------------------------
if [ "$option" = "release" ]; then
  VERS=""
  if [ -f VERSION ]; then
		VERS=$(cat VERSION)
	fi
  if [ -n "${VERS}" ]; then
    docker load -i "${SERVICE_NAME}_${VERS}.tar"
    docker run -v $(pwd)/log:/var/log -d --name $SERVICE_NAME \
    -p $SERVICE_PORT:2310 -P $SERVICE_TLS_PORT:2443 \
    --network $SERVICE_NETWORK $SERVICE_NAME:$VERS
  fi
  exit 0
fi
# ------------------------------------------------------------------------------
# DEV IMAGE/CONTAINER
# ------------------------------------------------------------------------------
if [ -z "$(docker ps -a -q -f name=${SERVICE_NAME})" ]; then
  STEP="y"
  if [ "$option" = "debug" ]; then
    read -p "docker pull $SERVICE_DOCKER_IMAGE? (y/N/s=stop) " STEP;
  fi
  if [ "$STEP" = "s" ]; then exit 0; fi
  if [ "$STEP" = "y" ]; then
    docker pull $SERVICE_DOCKER_IMAGE
  fi
  STEP="y"
  if [ "$option" = "debug" ]; then
    read -p "docker run -dit --name $SERVICE_NAME? (y/N/s=stop) " STEP;
  fi
  if [ "$STEP" = "s" ]; then exit 0; fi
  if [ "$STEP" = "y" ]; then
    if [ "$option" = "test-bin" ]; then
      docker run -di --name $SERVICE_NAME --network $SERVICE_NETWORK \
        -v "$(pwd):$SERVICE_WORKING_DIR" $SERVICE_DOCKER_IMAGE
    else
      docker run -dit --name $SERVICE_NAME --network $SERVICE_NETWORK \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v "$(pwd):$SERVICE_WORKING_DIR" $SERVICE_DOCKER_IMAGE
    fi
  fi
fi
STEP="y"
if [ "$option" = "debug" ]; then
  read -p "docker start $SERVICE_NAME? (y/N/s=stop) " STEP;
fi
if [ "$STEP" = "s" ]; then exit 0; fi
if [ "$STEP" = "y" ]; then
  docker start $SERVICE_NAME
  until [ "$(docker inspect -f '{{.State.Running}}' $SERVICE_NAME 2>/dev/null)" = "true" ]; do
    echo "Waiting for container $SERVICE_NAME to start..."
    sleep 2
  done
fi
# ------------------------------------------------------------------------------
# TIMEZONE
# ------------------------------------------------------------------------------
STEP="y"
if [ "$option" = "debug" ]; then
  read -p "Install timezone? (y/N/s=stop) " STEP;
fi
if [ "$STEP" = "s" ]; then exit 0; fi
if [ "$STEP" = "y" ]; then
  docker exec -i $SERVICE_NAME bash -c "\
    export DEBIAN_FRONTEND=noninteractive && \
    ln -fs /usr/share/zoneinfo/Europe/Rome /etc/localtime && \
    echo \\\"Europe/Rome\\\" > /etc/timezone && \
    apt-get update && apt-get install -y tzdata && \
    dpkg-reconfigure -f noninteractive tzdata"
fi
# ------------------------------------------------------------------------------
# APT PACKAGES
# ------------------------------------------------------------------------------
DEPS="${SERVICE_DEV_DEPENDENCIES}"
if [ "$option" = "test-bin" ]; then
  DEPS="${SERVICE_DEPENDENCIES}"
fi
STEP="y"
if [ "$option" = "debug" ]; then
  read -p "Install dependencies packages? (y/N/s=stop) " STEP;
fi
if [ "$STEP" = "s" ]; then exit 0; fi
if [ "$STEP" = "y" ]; then
  docker exec -i $SERVICE_NAME bash -c "\
    apt-get update && apt-get install -y --no-install-recommends \
    $DEPS && apt-get clean && rm -rf /var/lib/apt/lists/*"
fi
# ------------------------------------------------------------------------------
# TEST-BIN
# Run della versione di test compilata nel container di release
# ------------------------------------------------------------------------------
if [ "$option" = "test-bin" ]; then
  RUN="$SERVICE_BIN -h \"${SERVICE_HOST}\" -p \"${SERVICE_PORT}\" -P \"${SERVICE_TLS_PORT}\" -l \"${SERVICE_LOG}\""
	if [ -n "${DB_CONN_S}" ]; then
    RUN+=" -d \"${DB_DRIVER}\" -D \"${DB_CONN_S}\"";
  fi
  echo "RUN: ${RUN}" > /service/bin/output.txt
  EXIT_CODE=$(docker exec -i $SERVICE_NAME bash -c "cd /service && ${RUN} >> /service/bin/output.txt && echo $?");
  if [ "$EXIT_CODE" -ne 0 ]; then
    exit 1;
  fi
  echo $EXIT_CODE
  exit 0
fi
# ------------------------------------------------------------------------------
# MONGOOSE, UNITY, CPPJWT
# ------------------------------------------------------------------------------
if [ ! -d "mongoose" ]; then
  STEP="y"
  if [ "$option" = "debug" ]; then
    read -p "Install mongoose? (y/N/s=stop) " STEP;
  fi
  if [ "$STEP" = "s" ]; then exit 0; fi
  if [ "$STEP" = "y" ]; then
    docker exec -i $SERVICE_NAME bash -c "\
      cd $SERVICE_WORKING_DIR \
      && git clone ${MONGOOSE_GITHUB_REPO} ${MONGOOSE_DIR}"
  fi
fi
if [ ! -d "unity" ]; then
  STEP="y"
  if [ "$option" = "debug" ]; then
    read -p "Install unity? (y/N/s=stop) " STEP;
  fi
  if [ "$STEP" = "s" ]; then exit 0; fi
  if [ "$STEP" = "y" ]; then
    docker exec -i $SERVICE_NAME bash -c "\
      cd $SERVICE_WORKING_DIR \
      && git clone ${UNITY_GITHUB_REPO} ${UNITY_DIR}"
  fi
fi
if [ ! -d "cppjwt" ]; then
  STEP="y"
  if [ "$option" = "debug" ]; then
    read -p "Install cppjwt? (y/N/s=stop) " STEP;
  fi
  if [ "$STEP" = "s" ]; then exit 0; fi
  if [ "$STEP" = "y" ]; then
    docker exec -i $SERVICE_NAME bash -c "\
      cd $SERVICE_WORKING_DIR \
      && git clone ${CPPJWT_GITHUB_REPO} ${CPPJWT_DIR} \
      && cd cppjwt && mkdir -p build && cd build && cmake .. \
      && cmake --build . -j"
  fi
fi
STEP="y"
if [ "$option" = "debug" ]; then
  read -p "Create 'clear' alias? (y/N/s=stop) " STEP;
fi
if [ "$STEP" = "s" ]; then exit 0; fi
if [ "$STEP" = "y" ]; then
  docker exec -i $SERVICE_NAME bash -c "\
    echo \"alias cls='clear'\" >> /etc/bash.bashrc && source /etc/bash.bashrc"
fi
# ------------------------------------------------------------------------------
# GITHUB ENV/REPO / GIT LOCAL CONFIG
# ------------------------------------------------------------------------------
if [ -n "$GITHUB_USER" ] && [ -n "$GITHUB_MAIL" ]; then
  if [ -d ".git" ] && [ -n "$GITHUB_TOKEN" ]; then
    echo ""
    echo "Directory .git exist." 
    echo ""
  fi
  if [ ! -d ".git" ] && [ -n "$GITHUB_TOKEN" ]; then
    STEP="y"
    if [ "$option" = "debug" ]; then
      read -p "Create Github repository? (y/N/s=stop) " STEP;
    fi
    if [ "$STEP" = "s" ]; then exit 0; fi
    if [ "$STEP" = "y" ]; then
      REMOTE_URL="https://$GITHUB_TOKEN@github.com/$GITHUB_USER/$SERVICE_NAME.git"
      docker exec -i $SERVICE_NAME bash -c "\
        cd $SERVICE_WORKING_DIR; \
        if [ -d ".git" ]; then \
          rm -rf .git; \
        fi; \
        curl -u \"$GITHUB_USER:$GITHUB_TOKEN\" https://api.github.com/user/repos \
          -d \"{\\\"name\\\":\\\"$SERVICE_NAME\\\", \\\"private\\\":true}\"; \
        if [ $? -eq 0 ]; then \
          cd $SERVICE_WORKING_DIR \
          && git init \
          && git config --global --add safe.directory $SERVICE_WORKING_DIR \
          && git config user.name \"$GITHUB_USER\" \
          && git config user.email \"$GITHUB_MAIL\" \
          && git remote add origin \"$REMOTE_URL\" \
          && git checkout -b main \
          && git add README.md LICENSE \
          && git commit -m \"initial commit\" \
          && git push -u origin main \
          && git checkout -b develop \
          && git push -u origin develop; \
        else \
          echo \"Error: Remote repository not installed!\"; \
        fi;"
    fi
  else
    STEP="y"
    if [ "$option" = "debug" ]; then
      read -p "Configure Git? (y/N/s=stop) " STEP;
    fi
    if [ "$STEP" = "s" ]; then exit 0; fi
    if [ "$STEP" = "y" ]; then
      docker exec -i $SERVICE_NAME bash -c "\
        cd $SERVICE_WORKING_DIR; \
        if [ ! -d .git ]; then \
          git init; \
        fi; \
        git config --global --add safe.directory $SERVICE_WORKING_DIR \
        && git config user.name \"$GITHUB_USER\" \
        && git config user.email \"$GITHUB_MAIL\" \
        && git config user.name && git config user.email"
    fi
  fi
fi
# ------------------------------------------------------------------------------
# TEST
# ------------------------------------------------------------------------------
if [ "$option" = "test" ]; then
  EXIT_CODE=$(docker exec -i service bash -c "\
    cd ${SERVICE_WORKING_DIR} && mkdir -p bin && make test >/dev/null; \
    make run >/dev/null; echo $?")
  if [ "$EXIT_CODE" -ne 0 ]; then exit 1; fi
  echo $EXIT_CODE
  exit $EXIT_CODE
fi
# ------------------------------------------------------------------------------
# GITHUB CI/CD WORKFLOWS
# ------------------------------------------------------------------------------
if [ ! -d .github ]; then
  STEP="y"
  if [ "$option" = "test" ]; then STEP="n"; fi
  if [ "$option" = "debug" ]; then
    read -p "Install Github develop-workflow.yml? (y/N/s=stop) " STEP;
  fi
  if [ "$STEP" = "s" ]; then exit 0; fi
  if [ "$STEP" = "y" ]; then
    mkdir -p .github/workflows
    cat > .github/workflows/develop-workflow.yml << EOF
name: CI/CD Workflow
on:
  push:
    branches:
      - develop
jobs:
  branch-develop-job:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3
        with:
          fetch-depth: 0
      - name: Build unit-test
        run: ./install.sh --env-test && ./install.sh --test
EOF
  fi
  STEP="y"
  if [ "$option" = "test" ]; then STEP="n"; fi
  if [ "$option" = "debug" ]; then
    read -p "Install Github main-workflow.yml? (y/N/s=stop) " STEP;
  fi
  if [ "$STEP" = "s" ]; then exit 0; fi
  if [ "$STEP" = "y" ]; then
    mkdir -p .github/workflows
    cat > .github/workflows/main-workflow.yml << EOF
name: CI/CD Workflow
on:
  push:
    branches:
      - main
jobs:
  branch-main-job:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3
        with:
          fetch-depth: 0
      - name: Build unit-test
        run: ./install.sh --env-test && ./install.sh --test
EOF
  fi
fi
