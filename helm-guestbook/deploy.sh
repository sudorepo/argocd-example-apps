#!/bin/bash
cd /home/user01/workspace/argocd-example-apps/helm-guestbook
./update.sh
docker build -t guestbook-webserver-local .
docker tag guestbook-webserver-local:latest quay.io/serg_ribeiro/guestbook:latest
docker push quay.io/serg_ribeiro/guestbook:latest
