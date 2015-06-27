FROM gliderlabs/alpine:3.1
RUN apk --update add docker bash
COPY run.sh backup.sh /
ENV INITIAL_DELAY_IN_SECONDS= \
    INTERVAL_IN_SECONDS=86400 \
    BACKUP_CONTAINER=database-backup \
    BACKUP_NAME=daily \
    OS_AUTH_URL= \
    OS_TENANT_ID= \
    OS_TENANT_NAME= \
    OS_USERNAME= \
    OS_PASSWORD= \
    OS_REGION_NAME=
CMD /run.sh
