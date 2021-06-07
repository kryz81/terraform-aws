#!/bin/bash

sudo hostnamectl set-hostname kryz-${nodename} &&
curl -sfL https://get.k3s.io | sh -s - server \
--datastore-endpoint="mysql://${dbuser}:${dbpassword}@tcp(${db_endpoint})/${dbname}" \
--write-kubeconfig-mode 644
