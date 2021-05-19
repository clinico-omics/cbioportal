export PORTAL_HOME=/cbioportal/
export CATALINA_OPTS='-Dauthenticate=false -Ddbconnector=jndi -Dpersistence.cache_type=no-cache'
export CATALINA_OPTS="$CATALINA_OPTS -XX:MaxPermSize=2048m -Xms2g -Xmx20g"
