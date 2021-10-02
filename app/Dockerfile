FROM python:3-slim

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFER 1
ENV SOPDS_ROOT_LIB "/books"
ENV SOPDS_INPX_ENABLE False
ENV SOPDS_LANGUAGE "ru-RU"
ENV SOPDS_SU_NAME "admin"
ENV SOPDS_SU_EMAIL "admin@localhost"
ENV SOPDS_SU_PASSWORD "admin"
ENV SOPDS_TELEBOT_API_TOKEN ""
ENV SOPDS_TELEBOT_AUTH ""
ENV SOPDS_DEBUG False
ENV SOPDS_AUTH False
ENV SOPDS_ALLOWED_HOSTS "*"
ENV VERSION 0.47
ENV TZ Asia/Omsk

WORKDIR /sopds
COPY . .

RUN adduser --system --group --no-create-home app \
    && mkdir -p /static /config /books /sopds/tmp \
    && apt-get update \
    && apt-get -y update \
    && apt-get install -y unzip default-mysql-client python3-mysqldb \
#    && apt-get install -y mc \
    && apt-get -y clean \
##    && apt-get install -y bash libxml2 libxslt1.1 libffi7 libjpeg62-turbo zlib1g \
    && pip install --upgrade --no-cache-dir pip \
    && pip install --no-cache-dir -r requirements.txt \
    && chmod +x entrypoint.sh \
    && chown -R app:app . /config  /static /books

#USER app

VOLUME [ "/config", "/books" , "/static"]
#EXPOSE 8000

ENTRYPOINT [ "/sopds/entrypoint.sh" ]
CMD [ "start" ]
