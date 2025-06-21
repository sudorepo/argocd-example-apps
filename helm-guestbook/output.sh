#!/bin/bash


# how to run:
# ./output.sh 2>&1 | xclip -selection clipboard

# get output for copilot

# apply manifest
kubectl delete application guestbook
kubectl apply -f guestbook-helm-app.yaml &&\
argocd app sync guestbook
sleep 5
./deploy.sh

echo "# imageupdater - immediately restart image updater. no need to wait 2 minutes"
kubectl delete pod -l app.kubernetes.io/name=argocd-image-updater -n argocd

echo "# wait 2 secs so that the pod starts"
sleep 2

echo "# imageupdater - get logs from the new pod"
kubectl logs -l app.kubernetes.io/name=argocd-image-updater -n argocd

echo "# quay: get digest"
skopeo inspect docker://quay.io/serg_ribeiro/guestbook:latest | grep Digest

echo "# from the pod - get image"
kubectl -n default get deploy guestbook-helm-guestbook -o yaml | grep image:

echo "on the pod - check patch events"
echo "$ kubectl logs -l app.kubernetes.io/name=argocd-image-updater -n argocd | grep PATCH"
kubectl logs -l app.kubernetes.io/name=argocd-image-updater -n argocd | grep PATCH
echo ""

echo "# argocd deployed application - get status"
echo "$ kubectl -n argocd get application guestbook -o yaml | grep status:"
kubectl -n argocd get application guestbook -o yaml | grep status:
echo ""

echo "# argocd deployed application - get digest"
echo "$ kubectl -n argocd get application guestbook -o yaml | grep digest |grep -v apiVersion"
kubectl -n argocd get application guestbook -o yaml | grep digest |grep -v apiVersion
echo ""

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

#echo "# application manifest - show the file values-argocd.yaml"
#cat values-argocd.yaml 

echo "# check permissions"
kubectl get clusterRoleBinding argocd-image-updater -o yaml

echo "# imageupdater - immediately restart image updater. no need to wait 2 minutes"
kubectl delete pod -l app.kubernetes.io/name=argocd-image-updater -n argocd

echo "# wait 2 secs so that the pod starts"
sleep 2

echo "# imageupdater - get logs from the new pod"
kubectl logs -l app.kubernetes.io/name=argocd-image-updater -n argocd
echo ""


echo "# imageupdater - check for logs or warn"
kubectl logs -l app.kubernetes.io/name=argocd-image-updater -n argocd | grep -i error
kubectl logs -l app.kubernetes.io/name=argocd-image-updater -n argocd | grep -i warn
echo ""


echo "# imageupdater - Check for Application Conditions"
echo "$ kubectl -n argocd get application guestbook -o yaml | grep -A20 conditions:"
kubectl -n argocd get application guestbook -o yaml | grep -A20 conditions:
echo ""


echo "# is there a configmap overriding behavior?""
echo "$ kubectl get cm argocd-image-updater-config -o yaml"
kubectl get cm argocd-image-updater-config -o yaml
echo ""


echo "What has already been tried and didn't fix:"
echo "- test manual patching"
echo "- kubectl -n argocd patch application guestbook --type merge -p '{"spec":{"source":{"helm":{"values":"image:\n  repository: quay.io/serg_ribeiro/guestbook\n  tag: latest\n  digest: sha256:0bc5930992a28830578e630daac0eefb2927c565ebf11406da41fc2016145dad\n"}}}}'"
echo "- check result of manual patching"
echo "- kubectl -n default get deploy guestbook-helm-guestbook -o yaml | grep image:"
echo "- test helm logic - see it it accepts the digest"
echo "- helm template . --set image.repository=quay.io/serg_ribeiro/guestbook --set image.tag=latest --set image.digest=sha256:0bc5930992a28830578e630daac0eefb2927c565ebf11406da41fc2016145dad |grep "image:""
echo "- tried deleting and recreating the application. didn't fix it."
echo "- doublechecked yaml formatting. checked. i am already using yamllint. check in this output above."

echo ""

