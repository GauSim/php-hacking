#!/bin/bash

# debug:
set -e
# set -x

MYSQL_CONTAINER="shopware-db"
MYSQL_ROOT_PASSWORD="root"
MYSQL_DATABASE_NAME="ud10_334_1"
PHP_MY_ADMIN_CONTAINER="shopware-db-admin"
APP_CONTAINER="shopware";



#################################################################################### 
<< --MULTILINE-COMMENT--
RUN MYSQL CONTAINER 
--MULTILINE-COMMENT--
#################################################################################### 

restart_mysql_container() {
    echo "restart myql";
    
    (docker stop $MYSQL_CONTAINER || :) && docker run --rm -d --name $MYSQL_CONTAINER -v "$PWD/../db-bump":/db-bump -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD mysql:5

    echo "mysql running...";
    echo "mounting =>> $PWD/../db-bump into /db-bump";
    echo "root password is =>> $MYSQL_ROOT_PASSWORD";
}

run_mysql_import() {
  echo "creating DB => $MYSQL_DATABASE_NAME";
  echo "echo 'create database $MYSQL_DATABASE_NAME character set utf8 collate utf8_general_ci' | (mysql --password='$MYSQL_ROOT_PASSWORD')" | docker exec -i $MYSQL_CONTAINER bash;
  echo "";
  echo "running import script, ./db-bump/backup.sql";
  echo "(mysql --password='$MYSQL_ROOT_PASSWORD') < ./db-bump/backup.sql" | docker exec -i $MYSQL_CONTAINER bash
  echo "done";
}

restart_phpmyadmin_container() {
  echo "restart phpmyadmin";

  (docker stop $PHP_MY_ADMIN_CONTAINER || :) && docker run --rm -d --name $PHP_MY_ADMIN_CONTAINER --link $MYSQL_CONTAINER:db -p 8080:80 phpmyadmin/phpmyadmin
  echo "phpmyadmin => http://localhost:8080";
}


build_app_container() {
  echo "building app container";
  (docker rmi $APP_CONTAINER || :) 
  docker build . --file "./docker/Dockerfile" --tag $APP_CONTAINER;
}

restart_app_container() {
  echo "restart app";

  MYSQL_CONTAINER_ID=$(docker inspect --format="{{.Id}}" $MYSQL_CONTAINER || :);
  if [ -z "$MYSQL_CONTAINER_ID" ]; then
    echo "MYSQL Container not Running!!"
    echo "run =>> ./cli/run.sh start mysql" && exit 1;
  fi

  (docker stop $APP_CONTAINER || :) && docker run --rm -i --name $APP_CONTAINER -v "$PWD/container":/var/www/html --link $MYSQL_CONTAINER:db -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD -e MYSQL_DATABASE_NAME=$MYSQL_DATABASE_NAME -e MYSQL_CONTAINER=$MYSQL_CONTAINER -p 80:80 $APP_CONTAINER

  echo "phpmyadmin => http://localhost:80";
}

get_container_name() {
    case $1 in
     mysql)      
          echo $MYSQL_CONTAINER;
          ;;
     phpmyadmin)      
          echo $PHP_MY_ADMIN_CONTAINER;
          ;;
     app)      
          echo $APP_CONTAINER;
          ;;
     *)
          pring_usage_and_exit;
          ;;
    esac
}

restart_container() {
    case $1 in
     mysql)      
          restart_mysql_container;
          ;;
     phpmyadmin)      
          restart_phpmyadmin_container;
          ;;
     app)      
          restart_app_container;
          ;;
     all)      
          (restart_container mysql || :) && (restart_container phpmyadmin || :) && (restart_container app || :)
          ;;
     *)
          pring_usage_and_exit;
          ;;
    esac
}

kill_container() {
    case $1 in
     all)      
          (kill_container mysql || :) && (kill_container phpmyadmin || :) && (kill_container app || :)
          ;;
     *)
          NAME=$(get_container_name $1);
          (docker kill $NAME || :) && (docker rm $NAME || :);
          ;;
    esac
}

bash_into_container() {
    NAME=$(get_container_name $1);
    CONTAINER_ID=$(docker inspect --format="{{.Id}}" $NAME);
    echo "id: $CONTAINER_ID";
    docker exec -it $CONTAINER_ID bash;  
}


#################################################################################### 
<< --MULTILINE-COMMENT--
CLI Tooling
--MULTILINE-COMMENT--
#################################################################################### 

pring_usage_and_exit (){
  echo "[Error] unknonw command";
  echo "try";
  echo "./cli/run.sh start mysql";
  echo "./cli/run.sh kill mysql";
  echo "./cli/run.sh bash mysql";
  echo "";
  echo "./cli/run.sh start phpmyadmin";
  echo "./cli/run.sh kill phpmyadmin";
  echo "./cli/run.sh bash phpmyadmin";
  echo "";
  echo "./cli/run.sh build";
  echo "./cli/run.sh start app";
  echo "./cli/run.sh kill app";
  echo "./cli/run.sh bash app";
  echo ""
  echo "./cli/run.sh start all";
  echo "./cli/run.sh kill all";
  echo "";
  echo "./cli/run.sh cleanup-all";
  echo "./cli/run.sh cleanup-images";
  echo "";
  echo "./cli/run.sh db-import";
  echo "";
  exit 1;
}

case $1 in
     help)
          pring_usage_and_exit;
          ;;
     db-import)
          run_mysql_import;
          ;;
     build)
          build_app_container
          ;;
     start|run)      
          restart_container $2;
          echo "";
          docker ps;
          ;;
     bash)      
          bash_into_container $2;
          ;; 
     kill|stop)      
          kill_container $2;
          echo "";
          docker ps;
          ;;
     cleanup-all)
          echo "removing all old CONTAINERS";      
          docker rm $(docker ps -a -q)
          ;;  
     cleanup-images)
          echo "removing all old IMAGES";      
          docker rmi $(docker images -q)
          ;;   
     *)
          pring_usage_and_exit;
          ;;
esac


