FROM tomcat:8-jre8
MAINTAINER Jingcheng Yang <yjcyxky@163.com>, Alexandros Sigaras <als2076@med.cornell.edu>, Fedde Schaeffer <fedde@thehyve.nl>
LABEL Description="Choppy DataPortal for Cancer Genomics"
ENV APP_NAME="cdataportal" \
    PORTAL_HOME="/cbioportal"
#======== Install Prerequisites ===============#
# Set aliyun source for apt-get
COPY ./docker-compose/sources.list /etc/apt/sources.list
RUN apt-get update && apt-get install -y --no-install-recommends \
        git \
        libmysql-java \
        patch \
        python3 \
        python3-jinja2 \
        python3-mysqldb \
        python3-requests \
        maven \
        openjdk-8-jdk \
    && ln -s /usr/share/java/mysql-connector-java.jar "$CATALINA_HOME"/lib/ \
    && rm -rf $CATALINA_HOME/webapps/examples \
    && rm -rf /var/lib/apt/lists/*
#======== Configure cBioPortal ===========================#
COPY . $PORTAL_HOME
# Get cdataporta-frontend.jar from private maven repo [https://repo.rdc.aliyun.com/repository/77439-release-qTdS0A].
WORKDIR $PORTAL_HOME
EXPOSE 8080
#======== Build cBioPortal on Startup ===============#
COPY $PWD/portal/target/cbioportal.war $CATALINA_HOME/webapps/cdataportal.war 
RUN find $PWD/core/src/main/scripts/ -type f -executable \! -name '*.pl'  -print0 | xargs -0 -- ln -st /usr/local/bin

CMD sh $CATALINA_HOME/bin/catalina.sh run
