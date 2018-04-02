# Login:
export DOCKER_ID_USER=$1
docker login

# Tag:
#docker tag appdynamics-tomcat $DOCKER_ID_USER/appdynamics-tomcat

# Push:
docker push $DOCKER_ID_USER/appdynamics-tomcat
