#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data ) 2>&1

cat > /var/lib/tomcat/bin/setenv.sh <<'SETENV'
CATALINA_OPTS="-Xms${jvm_xms} -Xmx${jvm_xmx}"
JAVA_OPTS="$JAVA_OPTS -Xlog:gc*:file=/var/lib/tomcat/logs/gc.log:time,uptime,level,tags:filecount=5,filesize=50m"
SETENV
chmod +x /var/lib/tomcat/bin/setenv.sh

cat > /var/lib/tomcat/webapps/asm_callback/WEB-INF/classes/asm-callback.properties <<'CBPROPS'
TWILIO_CALLBACK_SECRET_KEY=${secret_key_twilio}
CBPROPS

chmod 755 -R /var/lib/tomcat/webapps/asm_callback
chown -R tomcat:tomcat /var/lib/tomcat/webapps/asm_callback
rm -f /var/lib/tomcat/webapps/ROOT/index.jsp
rm -rf /var/lib/tomcat/webapps/examples

systemctl daemon-reload
systemctl enable tomcat.service
systemctl start tomcat.service
