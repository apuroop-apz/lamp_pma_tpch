## LAMP phpMyAdmin TPC-H Dockerfile
This Dockerfile is packed with [Ubuntu-16.0](www.ubuntu.com), [Apache](www.apache.org), [Mysql-5.7](www.mysql.com), [PHP7.0](www.php.net), [phpMyAdmin](www.phpmyadmin.net) and 100+ mb of [TPC-H](http://www.tpc.org/tpch/) test data imported.

## Usage
# Download the image
`$ docker pull apuroopapz/lamp_pma_tpch`

# Run the image
Run the image detached and an allocated pseudo-TTY. Also binding port 80 of the container to port 80 of the host. ** -p <containerPort>:<hostPort>** <br>
`$ docker run -d -t -p 80:80 --name anyname apuroopapz/lamp_pma_tpch`

Set up the Mysql root password. <br>
`$ docker run -d -t -p 80:80 --name anyname -e MYSQL_ROOT_PASSWORD=anyrootpass apuroopapz/lamp_pma_tpch`

Set up a username & password for Mysql server. <br>
`$ docker run -d -t -p 80:80 --name anyname -e MYSQL_USERNAME=anyusername -e MYSQL_PASSWORD=anypass apuroopapz/lamp_pma_tpch`

Set up a username & password for Mysql and also create a Mysql database. <br>
`$ docker run -d -t -p 80:80 --name anyname -e MYSQL_USERNAME=anyusername -e MYSQL_PASSWORD=anypass -e MYSQL_DBNAME=anydbname apuroopapz/lamp_pma_tpch`

Get into the shell with -i (interactively) <br>
`$ docker run -i -t -p 80:80 --name anyname apuroopapz/lamp_pma_tpch`

## Environment Variables
`MYSQL_USERNAME` <br>
`MYSQL_PASSWORD` <br>
`MYSQL_ROOT_PASSWORD` <br>
`MYSQL_DBNAME` <br>

## Extra info
* The processes in the background will take at least 1:30+ mins once you run the image.
* `$ docker logs container_ID` will give the logs of the container at the time of execution.
