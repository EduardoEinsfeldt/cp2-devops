#!/bin/bash

# ==================== CONFIGURAÇÕES ====================

RM="556460"
JAR_NAME="dimdim-crud-0.0.1-SNAPSHOT.jar"

REDE="dimdim-rede-rm${RM}"
VOLUME="mysql-volume-rm${RM}"
MYSQL_CONTAINER="mysql-rm${RM}"
APP_CONTAINER="app-java-rm${RM}"

# Limpeza
docker stop ${MYSQL_CONTAINER} ${APP_CONTAINER} 2>/dev/null || true
docker rm ${MYSQL_CONTAINER} ${APP_CONTAINER} 2>/dev/null || true

docker network create ${REDE} 2>/dev/null || true
docker volume create ${VOLUME}

# MySQL
docker run -d \
  --name ${MYSQL_CONTAINER} \
  --network ${REDE} \
  -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD=senha123 \
  -e MYSQL_DATABASE=dimdim \
  -e MYSQL_USER=app \
  -e MYSQL_PASSWORD=senha123 \
  -v ${VOLUME}:/var/lib/mysql \
  mysql:8.0

echo "⏳ Aguardando MySQL (40s)..."
sleep 40

# App Java - montando a pasta inteira (funciona melhor no Windows)
docker run -d \
  --name ${APP_CONTAINER} \
  --network ${REDE} \
  -p 8080:8080 \
  -e DB_HOST=${MYSQL_CONTAINER} \
  -e DB_PORT=3306 \
  -e DB_NAME=dimdim \
  -e DB_USER=app \
  -e DB_PASSWORD=senha123 \
  -v "/h/Devops-DP/dimdim-crud/target:/app" \
  eclipse-temurin:17-jdk \
  java -jar /app/${JAR_NAME}

echo "✅ Containers iniciados com sucesso!"
echo "App Java  → http://localhost:8080/clientes"
echo "MySQL     → localhost:3306"
echo "RM usado  → ${RM}"