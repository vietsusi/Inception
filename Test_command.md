
#Build
docker compose -f ./srcs/test-mariadb-ngix-wp.yml up -d --build

#Remove
docker compose -f ./srcs/test-mariadb-ngix-wp.yml down

#Clean
docker system prune -a -f --volumes


#Check status
docker ps -a

#check log
docker logs mariadb-test
docker logs wordpress-test
docker logs nginx-test

