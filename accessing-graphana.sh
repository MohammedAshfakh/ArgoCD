#!/bin/bash

kubectl get svc -n monitoring | grep -i monitoring-grafana

kubectl patch svc monitoring-grafana \
-n monitoring \
-p '{"spec":{"type":"LoadBalancer"}}'
