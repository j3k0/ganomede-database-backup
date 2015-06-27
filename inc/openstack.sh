function openstack() {
    docker run --rm \
        -e OS_USERNAME=$OS_USERNAME \
        -e OS_PASSWORD=$OS_PASSWORD \
        -e OS_AUTH_URL=$OS_AUTH_URL \
        -e OS_TENANT_NAME=$OS_TENANT_NAME \
        -e OS_TENANT_ID=$OS_TENANT_ID \
        -e OS_TENANT_NAME=$OS_TENANT_NAME \
        -e OS_REGION_NAME=$OS_REGION_NAME \
        krystism/openstackclient:juno "$@"
}

function nova() {
    openstack nova "$@"
}

function swift() {
    openstack swift "$@"
}
