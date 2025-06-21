#!/bin/bash


# how to run:
# ./output.sh 2>&1 | xclip -selection clipboard

# get output for copilot
set -x

# apply manifest
kubectl apply -f guestbook-helm-app.yaml &&\
argocd app sync guestbook
sleep 5
./deploy.sh
# restart image updater
kubectl delete pod -l app.kubernetes.io/name=argocd-image-updater -n argocd
# quay: get digest
skopeo inspect docker://quay.io/serg_ribeiro/guestbook:latest | grep Digest
# imageupdater: get logs
kubectl logs -l app.kubernetes.io/name=argocd-image-updater -n argocd
# from the pod : get image
kubectl -n default get deploy guestbook-helm-guestbook -o yaml | grep image:

echo "# argocd deployed application - get status"
kubectl -n argocd get application guestbook -o yaml | grep status:

echo "# argocd deployed application - get digest"
kubectl -n argocd get application guestbook -o yaml | grep digest |grep -v apiVersion

echo "# argocd deployed application - show annotations"
kubectl get application -n argocd -o yaml |grep annotations -A15 -m1|grep -v "last-applied"|grep -v "apiVersion"

echo "# argocd deployed application - get values"
kubectl -n argocd get application guestbook -o yaml | grep -A10 "values:" -m1

echo "# get updater version "
kubectl -n argocd get pod -l app.kubernetes.io/name=argocd-image-updater -o jsonpath="{.items[0].spec.containers[0].image}"

echo "# on helm chart values.yaml - get group image"
yq '.image' values.yaml

echo "# templates/deployment.yaml , get image field"
cat templates/deployment.yaml |grep "image:"

echo "# show the application manifest that we are applying"
cat cat guestbook-helm-app.yaml

echo "# application manifest - check for hidden characters"
yamllint guestbook-helm-app.yaml

echo "# application manifest - show the file values-argocd.yaml"
cat values-argocd.yaml 

echo "# check permissions"
kubectl get clusterRoleBinding argocd-image-updater -o yaml

echo "# test manual patching"
kubectl -n argocd patch application guestbook --type merge -p '{"spec":{"source":{"helm":{"values":"image:\n  repository: quay.io/serg_ribeiro/guestbook\n  tag: latest\n  digest: sha256:0bc5930992a28830578e630daac0eefb2927c565ebf11406da41fc2016145dad\n"}}}}'

echo "# check result of manual patching"
kubectl -n default get deploy guestbook-helm-guestbook -o yaml | grep image:

echo "# test helm logic - see it it accepts the digest"
helm template . --set image.repository=quay.io/serg_ribeiro/guestbook --set image.tag=latest --set image.digest=sha256:0bc5930992a28830578e630daac0eefb2927c565ebf11406da41fc2016145dad |grep "image:"

echo ""

