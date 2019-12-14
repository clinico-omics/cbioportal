# This is the web only image of cBioPortal. Useful when you would like to run a
# small image without all data import/validate related scripts and
# dependencies. It includes the ShenandoahGC
# (https://wiki.openjdk.java.net/display/shenandoah/Main), an experimental
# garbage collector which in our experience works better in a cloud environment
# where you have multiple containers running on a single node. It gives unused
# memory back to the system allowing other containers to utilize it. Enable
# this GC with JAVA_OPTS=-XX:+UnlockExperimentalVMOptions -XX:+UseShenandoahGC.
#
# Use from root directory of repo like:
#
# docker build -t cbioportal-container:web-shenandoah-tag-name .
#
# WARNING: the shendoah image is a nightly, untested, experimental build. If
# you want to use an official openjdk image instead use the web-and-data image.
#
# WARNING: Be careful about publishing images generated like this publicly
# because your .git folder is exposed in the build step. We are not sure if
# this is a security risk: stackoverflow.com/questions/56278325
FROM tomcat:8-jre8
MAINTAINER Jingcheng Yang <yjcyxky@163.com>, Alexandros Sigaras <als2076@med.cornell.edu>, Fedde Schaeffer <fedde@thehyve.nl>
LABEL Description="Choppy DataPortal for Cancer Genomics"
ENV APP_NAME="cdataportal" \
    PORTAL_HOME="/cbioportal"

#======== Configure cBioPortal ===========================#
COPY . $PORTAL_HOME
WORKDIR $PORTAL_HOME
EXPOSE 8080

#======== Build cBioPortal on Startup ===============#
COPY $PWD/portal/target/cbioportal.war $CATALINA_HOME/webapps/cdataportal.war 
CMD sh $CATALINA_HOME/bin/catalina.sh run
