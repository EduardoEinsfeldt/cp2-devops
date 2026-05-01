# ==================== CONFIGURAÇÕES ====================
$RM = "556460"
$JAR_NAME = "dimdim-crud-0.0.1-SNAPSHOT.jar"

$REDE = "dimdim-rede-rm$RM"
$VOLUME = "mysql-volume-rm$RM"
$MYSQL_CONTAINER = "mysql-rm$RM"
$APP_CONTAINER = "app-java-rm$RM"

# LIMPEZA (remove containers antigos)
docker stop $MYSQL_CONTAINER $APP_CONTAINER 2>$null
docker rm $MYSQL_CONTAINER $APP_CONTAINER 2>$null

# 1. Criar rede
docker network create $REDE 2>$null

# 2. Criar volume nomeado
docker volume create $VOLUME

# 3. Rodar MySQL
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

# 4. Rodar App Java (caminho nativo do Windows - sem erro de Git Bash)
docker run -d `
  --name $APP_CONTAINER `
  --network $REDE `
  -p 8080:8080 `
  -e DB_HOST=$MYSQL_CONTAINER `
  -e DB_PORT=3306 `
  -e DB_NAME=dimdim `
  -e DB_USER=app `
  -e DB_PASSWORD=senha123 `
  -v "H:\Devops-DP\dimdim-crud\target:/app" `
  eclipse-temurin:17-jdk `
  java -jar /app/$JAR_NAME

Write-Host "✅ Containers iniciados com sucesso!" -ForegroundColor Green
Write-Host "App Java  → http://localhost:8080/clientes" -ForegroundColor Cyan
Write-Host "MySQL     → localhost:3306" -ForegroundColor Cyan