# ==================== CONFIGURAÇÕES ====================
$RM = "556460"
$JAR_NAME = "dimdim-crud-0.0.1-SNAPSHOT.jar"

$REDE = "dimdim-rede-rm$RM"
$VOLUME = "mysql-volume-rm$RM"
$MYSQL_CONTAINER = "mysql-rm$RM"
$APP_CONTAINER = "app-java-rm$RM"

# LIMPEZA
docker stop $MYSQL_CONTAINER $APP_CONTAINER 2>$null
docker rm $MYSQL_CONTAINER $APP_CONTAINER 2>$null

# 1. Rede
docker network create $REDE 2>$null

# 2. Volume
docker volume create $VOLUME

# 3. MySQL
docker run -d `
  --name $MYSQL_CONTAINER `
  --network $REDE `
  -p 3306:3306 `
  -e MYSQL_ROOT_PASSWORD=senha123 `
  -e MYSQL_DATABASE=dimdim `
  -e MYSQL_USER=app `
  -e MYSQL_PASSWORD=senha123 `
  -v ${VOLUME}:/var/lib/mysql `
  mysql:8.0

Write-Host "⏳ Aguardando MySQL subir (40 segundos)..." -ForegroundColor Yellow
Start-Sleep -Seconds 40

# 4. App Java - USANDO VARIÁVEIS PADRÃO DO SPRING BOOT
docker run -d `
  --name $APP_CONTAINER `
  --network $REDE `
  -p 8080:8080 `
  -e SPRING_DATASOURCE_URL=jdbc:mysql://${MYSQL_CONTAINER}:3306/dimdim `
  -e SPRING_DATASOURCE_USERNAME=app `
  -e SPRING_DATASOURCE_PASSWORD=senha123 `
  -e SPRING_JPA_HIBERNATE_DDL_AUTO=update `
  -v "H:\Devops-DP\dimdim-crud\target:/app" `
  eclipse-temurin:17-jdk `
  java -jar /app/$JAR_NAME

Write-Host "✅ Containers iniciados com sucesso!" -ForegroundColor Green
Write-Host "App Java  → http://localhost:8080/clientes" -ForegroundColor Cyan
Write-Host "MySQL     → localhost:3306" -ForegroundColor Cyan