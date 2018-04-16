FROM davidcaste/alpine-java-unlimited-jce:jre8

MAINTAINER Gary Chew <gary.chew@appdynamics.com>

ENV TOMCAT_MAJOR=8 \
    TOMCAT_VERSION=8.5.3 \
    TOMCAT_HOME=/home/appuser/apache-tomcat-8.5.3 \
    CATALINA_HOME=/home/appuser/apache-tomcat-8.5.3 \
    CATALINA_OUT=/dev/null \
    AGENT_HOME=/home/appuser/AppServerAgent

ENV CATALINA_OPTS='-javaagent:/home/appuser/AppServerAgent/javaagent.jar -Dappdynamics.controller.ssl.enabled=false -Dappdynamics.agent.reuse.nodeName=true -Dappdynamics.agent.reuse.nodeName.prefix=node'

#ENV APPDYNAMICS_CONTROLLER_HOST_NAME=lab-garydockerlab-gzvlnw1g.srv.ravcloud.com
#ENV APPDYNAMICS_CONTROLLER_PORT=8090
#ENV APPDYNAMICS_AGENT_ACCOUNT_NAME=customer1
#ENV APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY=1269b04b-d6d9-4632-bee0-dc08417b17e4
#ENV APPDYNAMICS_AGENT_APPLICATION_NAME=sample
#ENV APPDYNAMICS_AGENT_TIER_NAME=sample-tier

#RUN apk upgrade --update && \
RUN apk add --update curl

RUN mkdir -p ${AGENT_HOME} && \
    mkdir -p ${TOMCAT_HOME}/webapps/sample

WORKDIR /home/appuser

RUN curl -jksSL -o /tmp/apache-tomcat.tar.gz http://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    gunzip /tmp/apache-tomcat.tar.gz && \
    tar -C /home/appuser -xf /tmp/apache-tomcat.tar && \
    rm -rf /tmp/* /var/cache/apk/*

COPY tomcat8/logging.properties ${TOMCAT_HOME}/conf/logging.properties
COPY tomcat8/server.xml ${TOMCAT_HOME}/conf/server.xml

RUN curl -jksSL -o /tmp/AppServerAgent.zip http://lab-garydockerlab-gzvlnw1g.srv.ravcloud.com/AppServerAgent-4.4.2.22394.zip && \
    curl -jksSL -o /tmp/sample.war http://lab-garydockerlab-gzvlnw1g.srv.ravcloud.com/sample.war

RUN unzip /tmp/sample.war -d ${TOMCAT_HOME}/webapps/sample && \
    unzip /tmp/AppServerAgent.zip -d ${AGENT_HOME}
    
RUN addgroup -g 1000 -S appuser && \
    adduser -u 1000 -S appuser -G appuser && \
    chmod -R 775 /home/appuser && \
    chown -R appuser:appuser /home/appuser

USER appuser

VOLUME ["/logs"]
EXPOSE 8080

CMD ${TOMCAT_HOME}/bin/catalina.sh run
