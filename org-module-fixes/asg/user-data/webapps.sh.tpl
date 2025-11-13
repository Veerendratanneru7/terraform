#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data ) 2>&1

if [ "${upgrade_db}" == "true" ]; then
  LOG_FILE="/var/log/db-script.log"
  PARAMETER_NAME="/${env_id}/apersona/dbupgrade"
  
  UPGRADE_STATUS=$(aws ssm get-parameter --name "$PARAMETER_NAME" --query "Parameter.Value" --output text --region ${aws_region} 2>/dev/null || echo "Not Found")
  
  if [ "$UPGRADE_STATUS" == "True" ]; then
    echo "Database upgrade has already been performed" >> "$LOG_FILE" 2>&1
  else
    echo "Upgrading the database..." >> "$LOG_FILE" 2>&1
    mysql -u root -p"${db_password}" -h "${rds_endpoint}" --force < "/home/ec2-user/aPersona_ASM_v${mfa_version}_Product/asm_v${mfa_version}_upgrade.sql" >> "$LOG_FILE" 2>&1
    aws ssm put-parameter --name "$PARAMETER_NAME" --value "True" --type String --overwrite --region ${aws_region}
    echo "Database upgrade complete" >> "$LOG_FILE" 2>&1
  fi
fi

cat > /var/lib/tomcat/bin/setenv.sh <<'SETENV'
CATALINA_OPTS="-Xms${jvm_xms} -Xmx${jvm_xmx}"
JAVA_OPTS="$JAVA_OPTS -Xlog:gc*:file=/var/lib/tomcat/logs/gc.log:time,uptime,level,tags:filecount=5,filesize=50m"
SETENV
chmod +x /var/lib/tomcat/bin/setenv.sh

cat > /var/lib/tomcat/webapps/asm/WEB-INF/classes/apersona-db.properties <<'DBPROPS'
db.driverClassName=com.mysql.jdbc.Driver
db.url=jdbc:mysql://${rds_endpoint}:3306/apersona
db.username=root
db.password=${db_password}
db.jpa.database=MYSQL
DBPROPS

cat > /var/lib/tomcat/webapps/asm/WEB-INF/classes/apersona-twilio.properties <<'TWILPROPS'
TWILIO_CALLBACK_SERVICE=${callback_url}
TWILIO_CALLBACK_SECRET_KEY=${secret_key_twilio}
TWILPROPS

chmod 755 -R /var/lib/tomcat/webapps/asm
chown -R tomcat:tomcat /var/lib/tomcat/webapps/asm
rm -f /var/lib/tomcat/webapps/ROOT/index.jsp
rm -rf /var/lib/tomcat/webapps/examples
sed -i 's/true/false/g' /var/lib/tomcat/webapps/asm/WEB-INF/classes/phone-coding.properties

systemctl daemon-reload
systemctl enable tomcat.service
systemctl start tomcat.service
