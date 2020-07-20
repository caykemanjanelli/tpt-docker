#!/bin/bash

oc project "$OCP_NAMESPACE"

echo ">> Change project variables..."
ls openshift/[0-9]*.yaml | xargs sed -i "s/KUBE_NAMESPACE/$KUBE_NAMESPACE/g"
ls openshift/[0-9]*.yaml | xargs sed -i "s/CLUSTER/$CLUSTER/g"
ls openshift/[0-9]*.yaml | xargs sed -i "s@DOCKER_ENV_CI_REGISTRY_IMAGE@$DOCKER_ENV_CI_REGISTRY_IMAGE@g" # use @ to separate variable content /
ls openshift/[0-9]*.yaml | xargs sed -i "s/CI_PROJECT_NAME/$CI_PROJECT_NAME/g"
ls openshift/[0-9]*.yaml | xargs sed -i "s/CI_REGISTRY/$CI_REGISTRY/g"
ls openshift/[0-9]*.yaml | xargs sed -i "s/CI_BUILD_TAG/latest/g"
ls openshift/[0-9]*.yaml | xargs sed -i "s/CI_ENVIRONMENT_SLUG/$CI_ENVIRONMENT_SLUG/g"
ls openshift/[0-9]*.yaml | xargs sed -i "s/CI_PROJECT_PATH_SLUG/$CI_PROJECT_PATH_SLUG/g"


IMAGE_TAG="$CI_REGISTRY_IMAGE:$CI_BUILD_REF_NAME"

echo ">> Deleting old application..."
oc get cronjob $CI_PROJECT_NAME && oc delete cronjob $CI_PROJECT_NAME || echo "First Deploy"

echo ">> Deploying image $IMAGE_TAG to env $ENV at $HOSTNAME..."
ls openshift/[0-9]*.yaml | xargs printf -- "-f %s\n" | xargs oc apply

echo ">> Deployed to $CI_ENVIRONMENT_URL"
