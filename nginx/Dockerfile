FROM nginx:latest

RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d

VOLUME [ "/etc/nginx/conf.d", "/static"]
EXPOSE 80