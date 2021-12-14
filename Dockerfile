FROM nginx:alpine

RUN echo "daemon off;" >> /etc/nginx/nginx.conf

ADD . /usr/share/nginx/html

EXPOSE 8080

CMD ["nginx"]
