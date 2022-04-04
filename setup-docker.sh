####################
# CONFIGURE DOCKER #
####################

dockerEnvironment="dockerenv1"
acr="acr-k8s-training"
acr_url=""
sql_password="Sql@12345"

echo -e "${WHITE}Set up ${GREEN}Docker Environment${NC}." && echo

#docker network create --driver=bridge --subnet=192.168.0.0/16 br0
sudo docker network create $dockerEnvironment
echo -e "${WHITE}Run ${GREEN}Docker Instance${NC}." && echo
sudo docker run --name sql --network $dockerEnvironment -p 1433:1433 -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=$sql_password" -d mcr.microsoft.com/mssql/server:2017-latestsu
echo -e "${WHITE}Checking running ${GREEN}Docker Instances${NC}." && echo
sudo docker ps

echo -e "${WHITE}Create Database${GREEN}Instance${NC}." && echo
sudo docker exec -it sql /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P $sql_password -Q "CREATE DATABASE [master_db]"
