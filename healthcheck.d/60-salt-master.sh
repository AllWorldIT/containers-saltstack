#!/bin/bash


if ! SALT_TEST_RESULT_IPV4=$( salt-call --local status.ping_master 127.0.0.1 2>&1 ); then
    echo -e "ERROR: Healthcheck failed for Salt IPv4:\n$SALT_TEST_RESULT_IPV4"
    false
fi
if [ -n "$CI" ]; then
    echo -e "INFO: Healthcheck for Salt IPv4:\n$SALT_TEST_RESULT_IPV4"
fi


# Return if we don't have IPv6 support
if [ -z "$(ip -6 route show default)" ]; then
    return 0
fi


if ! SALT_TEST_RESULT_IPV6=$( salt-call --local status.ping_master ::1 2>&1 ); then
    echo -e "ERROR: Healthcheck failed for Salt IPv6:\n$SALT_TEST_RESULT_IPV4"
    false
fi
if [ -n "$CI" ]; then
    echo -e "INFO: Healthcheck for Salt IPv6:\n$SALT_TEST_RESULT_IPV4"
fi
