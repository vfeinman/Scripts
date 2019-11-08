#!/usr/bin/env bash
set -- $(aws ecs list-clusters --output text --query "clusterArns")
while [ -n "$1" ]; do 
    aws ecs update-cluster-settings --cluster "$1" --settings name=containerInsights,value=disabled > /dev/null && echo "Disabled ContainerInsights on: $1"
    shift
done