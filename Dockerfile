FROM debian:bullseye-slim

ADD configure.sh /configure.sh
COPY script/supervisord.conf /etc/supervisord.conf
COPY script /tmp
RUN chmod +x /tmp/bin/ttyd
RUN /bin/bash -c 'chmod 755 /tmp/bin && mv /tmp/bin/* /bin/ && rm -rf /tmp/* '	
RUN apt update -y \
	&& apt upgrade -y \
 	&& apt install -y nginx supervisor vim screen wget curl ffmpeg unzip \
	&& mkdir -p /run/screen \
	&& chmod -R 777 /run/screen \
	&& chmod +x /configure.sh \
	&& rm -rf /etc/nginx/nginx.conf \
	&& mkdir -p /var/www/html/ttyd
	
RUN wget https://pkg.cloudflareclient.com/uploads/cloudflare_warp_2022_2_288_1_amd64_a0be7b47b3.deb
RUN apt install ./cloudflare_warp_2022_2_288_1_amd64_a0be7b47b3.deb -y

COPY static-html /var/www/html	
COPY nginx.conf /etc/nginx/nginx.conf
ADD default.conf /etc/nginx/conf.d/default.conf

ENV LANG C.UTF-8
WORKDIR /home
CMD /configure.sh
