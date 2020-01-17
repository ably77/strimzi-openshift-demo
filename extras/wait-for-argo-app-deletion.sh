#!/bin/bash

# Wait for app deletion

seconds=0
OUTPUT=$(argocd app list | tail -n +2 | wc -l)

while [ "$OUTPUT" -ne "0" ]; do
  OUTPUT=$(argocd app list | tail -n +2 | wc -l)
  seconds=$((seconds+5))
  printf "Waiting %s seconds for apps to delete.\n" "${seconds}"
  sleep 5
done

echo done
