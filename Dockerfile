FROM gliderlabs/alpine:3.1
RUN apk --update add docker bash
COPY run backup.sh inc /
ENV INTERVAL_IN_SECONDS=86400
ENV OS_AUTH_URL=
ENV OS_TENANT_ID=
ENV OS_TENANT_NAME=
ENV OS_USERNAME=
ENV OS_PASSWORD=
ENV OS_REGION_NAME=
CMD /backup.sh
