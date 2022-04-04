####################
# CONFIGURE DOCKER #
####################

dockerEnvironment="dockerenv1"
dockerName="sql-env"
acr="registryqjl3186"
acr_url="$acr.azurecr.io"
sql_password="Sql@12345"

echo -e "${WHITE}Set up ${GREEN}Docker Environment${NC}." && echo

#docker network create --driver=bridge --subnet=192.168.0.0/16 br0
sudo docker network create $dockerEnvironment
echo -e "${WHITE}Run ${GREEN}Docker Instance${NC}." && echo
sudo docker run --name $dockerName --network $dockerEnvironment -p 1437:1437 -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=$sql_password" -d mcr.microsoft.com/mssql/server:2017-latest
echo -e "${WHITE}Checking running ${GREEN}Docker Instances${NC}." && echo
sudo docker ps

echo -e "${WHITE}Create Database ${GREEN}Instance${NC}." && echo
sudo docker exec -it $dockerName /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P $sql_password -Q "CREATE DATABASE [master_db]"
