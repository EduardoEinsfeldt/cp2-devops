#!/bin/bash

# ==================== CONFIGURAÇÕES ====================
RM="556460"
JAR_NAME="dimdim-crud-0.0.1-SNAPSHOT.jar"

REDE="dimdim-rede-rm${RM}"
VOLUME="mysql-volume-rm${RM}"
MYSQL_CONTAINER="mysql-rm${RM}"
APP_CONTAINER="app-java-rm${RM}"

# === LIMPEZA (para poder rodar várias vezes) ===
docker stop ${MYSQL_CONTAINER} ${APP_CONTAINER} 2>/dev/null || true
docker rm ${MYSQL_CONTAINER} ${APP_CONTAINER} 2>/dev/null || true

# 1. Criar rede
docker network create ${REDE} 2>/dev/null || true

# 2. Criar volume nomeado
docker volume create ${VOLUME}

# 3. Rodar MySQL
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

echo "⏳ Aguardando o MySQL subir (40 segundos)..."
sleep 40

# 4. Rodar App Java (IMAGEM CORRIGIDA e confiável)
docker run -d \
  --name ${APP_CONTAINER} \
  --network ${REDE} \
  -p 8080:8080 \
  -e DB_HOST=${MYSQL_CONTAINER} \
  -e DB_PORT=3306 \
  -e DB_NAME=dimdim \
  -e DB_USER=app \
  -e DB_PASSWORD=senha123 \
  -v $(pwd)/target/${JAR_NAME}:/app/app.jar \
  eclipse-temurin:17-jdk \
  java -jar /app/app.jar

echo "✅ Containers iniciados com sucesso!"
echo "App Java  → http://localhost:8080/clientes"
echo "MySQL     → localhost:3306"
echo "RM usado  → ${RM}"