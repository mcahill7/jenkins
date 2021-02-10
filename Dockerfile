FROM jenkins/jenkins:lts

ENV JENKINS_REF /usr/share/jenkins/ref

# install jenkins plugins
#COPY jenkins-home/plugins.txt $JENKINS_REF/
#RUN /usr/local/bin/plugins.sh $JENKINS_REF/plugins.txt

ENV JAVA_OPTS -Dorg.eclipse.jetty.server.Request.maxFormContentSize=100000000 \
 			  -Dorg.apache.commons.jelly.tags.fmt.timeZone=America/New_York \
 			  -Dhudson.diyChunking=false \
 			  -Djenkins.install.runSetupWizard=false

# copy scripts and ressource files
COPY jenkins-home/*.* $JENKINS_REF/
