#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data ) 2>&1

cat > /var/lib/tomcat/bin/setenv.sh <<'SETENV'
CATALINA_OPTS="-Xms${jvm_xms} -Xmx${jvm_xmx}"
JAVA_OPTS="$JAVA_OPTS -Xlog:gc*:file=/var/lib/tomcat/logs/gc.log:time,uptime,level,tags:filecount=5,filesize=50m"
SETENV
chmod +x /var/lib/tomcat/bin/setenv.sh

cat > /var/lib/tomcat/webapps/asm_portal/WEB-INF/classes/apersona-db.properties <<'DBPROPS'
db.driverClassName=com.mysql.jdbc.Driver
db.url=jdbc:mysql://${rds_endpoint}:3306/apersona
db.username=root
db.password=${db_password}
db.jpa.database=MYSQL
DBPROPS

cat > /var/lib/tomcat/webapps/asm_portal/WEB-INF/classes/apersona-twilio.properties <<'TWILPROPS'
TWILIO_CALLBACK_SERVICE=${callback_url}
TWILIO_CALLBACK_SECRET_KEY=${secret_key_twilio}
TWILPROPS

chmod 755 -R /var/lib/tomcat/webapps/asm_portal
chown -R tomcat:tomcat /var/lib/tomcat/webapps/asm_portal
rm -f /var/lib/tomcat/webapps/ROOT/index.jsp
rm -rf /var/lib/tomcat/webapps/examples

cat > /opt/aws/asmportalmonitoringwithcloudwatch.sh <<'MONITORING'
#!/bin/bash
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
ASGName=$(aws autoscaling describe-auto-scaling-instances --instance-ids $INSTANCE_ID --region ${aws_region} | grep "AutoScalingGroupName" | awk '{print $2}' | sed 's/[",]//g')
version='Version:${mfa_version}'
cmd=$(curl -s 'http://localhost:8080/asm_portal/about.ap' | grep -o "$version")
if [ "$cmd" == "$version" ]; then
  count=1
else
  count=0
fi
aws cloudwatch put-metric-data --namespace "System/Linux" --metric-name "ASMPortalStatus" --value $count --unit "Count" --dimensions AutoScalingGroupName=$ASGName --region ${aws_region}
MONITORING
chmod 700 /opt/aws/asmportalmonitoringwithcloudwatch.sh
echo '* * * * * /bin/bash -c "/opt/aws/asmportalmonitoringwithcloudwatch.sh" >> /var/log/crontab-monitoring.log 2>&1' | crontab -

systemctl daemon-reload
systemctl enable tomcat.service
systemctl start tomcat.service
