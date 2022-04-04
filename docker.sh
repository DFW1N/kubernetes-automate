#!/bin/bash

# Some aspects of this solution sample may be out of date

# Registry Name
registry_name="registryqjl3186"

dockerEnvironment="test12345"

# Database
sqldbName="sqltestdb1"
sql_username="sa"
sql_password="localtestpw123@"
sql_port="1433"

docker network create $dockerEnvironment

 

sudo docker run -d \
    --network $dockerEnvironment \
    -e "ACCEPT_EULA=Y" \
    -e "SA_PASSWORD=$sql_password" \
    --name $sqldbName \
    -p $sql_port:$sql_port \
    mcr.microsoft.com/mssql/server:2017-latest

 

sleep 20
docker ps
docker logs $sqldbName

 

docker exec $sqldbName /opt/mssql-tools/bin/sqlcmd \
    -S localhost -U SA -P "$sql_password" \
    -Q "CREATE DATABASE mydrivingDB"

 

docker run -d \
    --network $dockerEnvironment \
    --name dataload \
    -e "SQLFQDN=$sqldbName" \
    -e "SQLUSER=$sql_username" \
    -e "SQLPASS=$sql_password" \
    -e "SQLDB=mydrivingDB" \
    registryqjl3186.azurecr.io/dataload:1.0

docker run --network $dockerEnvironment -e SQLFQDN=$sqldbName -e SQLUSER=$sql_username -e SQLPASS=$sql_password -e SQLDB=mydrivingDB $registry_name.azurecr.io/dataload:1.0

# give some time for data to load
sleep 20
docker logs dataload

## Docker Build POI
cd ~/containers_artifacts/src/poi && cp ~/containers_artifacts/dockerfiles/Dockerfile_3 ~/containers_artifacts/src/poi
sudo docker build -f Dockerfile_3 -t "tripinsights/poi:1.0" .

docker run -d \
    --network $dockerEnvironment \
    -p 8080:80 \
    --name poi \
    -e "SQL_PASSWORD=$sql_password" \
    -e "SQL_SERVER=$sqldbName" \
    -e "SQL_USER=$sql_username" \
    -e "ASPNETCORE_ENVIRONMENT=Local" \
    tripinsights/poi:1.0

sudo docker tag tripinsights/poi:1.0 $registry_name.azurecr.io/tripinsights/poi:1.0
sudo docker push $registry_name.azurecr.io/tripinsights/poi:1.0

## Docker Build Trips
cd ~/containers_artifacts/src/poi && cp ~/containers_artifacts/dockerfiles/Dockerfile_4 ~/containers_artifacts/src/trips
sudo docker build -f Dockerfile_4 -t "tripinsights/trips:1.0" .

docker run -d \
    --network $dockerEnvironment \
    -p 8081:80 \
    --name trips \
    -e "SQL_PASSWORD=$sql_password" \
    -e "SQL_SERVER=$sqldbName" \
    -e "SQL_USER=$sql_username" \
    -e "OPENAPI_DOCS_URI=http://temp" \
    tripinsights/trips:1.0

docker run --network $dockerEnvironment \
    -e SQLFQDN=$sqldbName \
    -e SQLUSER=$sql_username \
    -e SQLPASS=$sql_password \
    -e SQLDB=mydrivingDB tripinsights/trips:1.0

sudo docker tag tripinsights/trips:1.0 $registry_name.azurecr.io/tripinsights/trips:1.0
sudo docker push $registry_name.azurecr.io/tripinsights/trips:1.0

## Docker Build Java
cd ~/containers_artifacts/src/user-java && cp ~/containers_artifacts/dockerfiles/Dockerfile_0 ~/containers_artifacts/src/user-java
sudo docker build -f Dockerfile_0 -t "tripinsights/user-java:1.0" .

docker run -d \
    --network $PROJECT_NAME \
    -p 8082:80 \
    --name user-java \
    -e "SQL_PASSWORD=$sql_password" \
    -e "SQL_SERVER=$sqldbName" \
    -e "SQL_USER=$sql_username" \
    tripinsights/user-java:1.0 

sudo docker tag tripinsights/user-java:1.0 $registry_name.azurecr.io/tripinsights/user-java:1.0
sudo docker push $registry_name.azurecr.io/tripinsights/user-java:1.0

## Docker Build User Profile
cd ~/containers_artifacts/src/userprofile && cp ~/containers_artifacts/dockerfiles/Dockerfile_2 ~/containers_artifacts/src/userprofile
sudo docker build -f Dockerfile_2 -t "tripinsights/userprofile:1.0" .

docker run -d \
    --network $PROJECT_NAME \
    -p 8083:80 \
    --name userprofile \
    -e "SQL_PASSWORD=$sql_password" \
    -e "SQL_SERVER=$sqldbName" \
    -e "SQL_USER=$sql_username" \
    tripinsights/userprofile:1.0

docker ps

 

printf "call poi\n"
curl http://localhost:8080/api/poi/healthcheck
curl -X GET 'http://localhost:8080/api/poi'
