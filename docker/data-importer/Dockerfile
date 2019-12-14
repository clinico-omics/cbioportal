# This image includes both the web app and the data import related scripts in
# one image. Because of historic reasons some of these scripts run java
# artifacts under the hood. It therefore currently makes more sense to have a
# single image supporting both instead of moving the scripts out to a separate
# container.
#
# Use from root directory of repo like:
#
# docker build -f docker/data-importer/Dockerfile -t cbioportal-container:tag-name .
#
# WARNING: Be careful about publishing images generated like this publicly
# because your .git folder is exposed in the build step. We are not sure if
# this is a security risk: stackoverflow.com/questions/56278325
FROM cdataportal:v3.0.4-tgmc as build

FROM tomcat:8-jre8
MAINTAINER Jingcheng Yang <yjcyxky@163.com>, Alexandros Sigaras <als2076@med.cornell.edu>, Fedde Schaeffer <fedde@thehyve.nl>
LABEL Description="Choppy DataPortal for Cancer Genomics"
ENV APP_NAME="cdataportal" \
    PORTAL_HOME="/cbioportal"

RUN mkdir -p /cbioportal
COPY --from=build /cbioportal/portal/target/dependency/webapp-runner.jar /webapp-runner.jar
# copy over core jar and scripts
COPY --from=build /cbioportal/core /cbioportal/core
COPY --from=build /cbioportal/scripts /cbioportal/scripts
COPY --from=build /cbioportal/db-scripts /cbioportal/db-scripts
COPY --from=build /cbioportal/requirements.txt /cbioportal/requirements.txt

# install build and runtime dependencies
# ignore update failures
COPY ./docker/data-importer/sources.list /etc/apt/sources.list
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        libmysql-java \
        default-libmysqlclient-dev \
        python3 \
        python3-setuptools \
        python3-dev \
        python3-pip \
	&& rm -rf /var/lib/apt/lists/* \
    && pip3 install wheel \
    && pip3 install -r /cbioportal/requirements.txt

# add importer scripts to PATH for easy running in containers
RUN find /cbioportal/core/src/main/scripts/ -type f -executable \! -name '*.pl'  -print0 | xargs -0 -- ln -st /usr/local/bin

#======== Configure cBioPortal ===========================#
COPY . $PORTAL_HOME
WORKDIR $PORTAL_HOME
EXPOSE 8080

#======== Build cBioPortal on Startup ===============#
COPY $PWD/portal/target/cbioportal.war $CATALINA_HOME/webapps/cdataportal.war 
CMD sh $CATALINA_HOME/bin/catalina.sh run
