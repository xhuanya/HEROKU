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
	
RUN curl https://pkg.cloudflareclient.com/pubkey.gpg | sudo gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
RUN echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ bullseye main' | sudo tee /etc/apt/sources.list.d/cloudflare-client.list
RUN apt update -y
RUN apt install cloudflare-warp -y

COPY static-html /var/www/html	
COPY nginx.conf /etc/nginx/nginx.conf
ADD default.conf /etc/nginx/conf.d/default.conf

ENV LANG C.UTF-8
WORKDIR /home
CMD /configure.sh
