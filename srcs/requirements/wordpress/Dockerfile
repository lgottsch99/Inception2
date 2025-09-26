FROM debian:12

RUN apt update -y && apt upgrade -y

#install php + all dependemcies
RUN apt install -y \
	  php8.2-fpm php8.2-mysql php8.2-mbstring php8.2-xml php8.2-gd php8.2-curl php8.2-zip \
	  mariadb-client curl unzip git

	