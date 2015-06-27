```sh
docker run --rm \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /var/lib/docker:/var/lib/docker \
    -e OS_AUTH_URL=https://auth.runabove.io/v2.0 \
    -e OS_TENANT_ID=01231231231231231231231231231231 \
    -e OS_TENANT_NAME="01231231" \
    -e OS_USERNAME="me@email.com" \
    -e OS_PASSWORD=passw0rd \
    -e OS_REGION_NAME=SBG-1 \
    -e INTERVAL_IN_SECONDS=86400 \
    ganomede/database-backup
```
