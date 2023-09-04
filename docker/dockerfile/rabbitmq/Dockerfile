FROM rabbitmq:3.11-management-alpine

COPY ./docker/dockerfile/rabbitmq/rabbitmq_delayed_message_exchange-3.11.1.ez /opt/rabbitmq/plugins/
RUN rabbitmq-plugins enable --offline rabbitmq_delayed_message_exchange




COPY  --chown=root:root ./docker/dockerfile/rabbitmq/check_enabled_rabbitmq.sh /usr/local/bin
RUN chmod +x /usr/local/bin/check_enabled_rabbitmq.sh
ENTRYPOINT ["check_enabled_rabbitmq.sh", "docker-entrypoint.sh" ]