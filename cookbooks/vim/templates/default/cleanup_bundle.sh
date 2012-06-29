#!/usr/bin/env bash

declare -A BUNDLES

for constant in <%= @bundles.join(" ") %>; do
	BUNDLES[$constant]=1
done

for i in <%= node[:vim][:rcdir] %>/bundle/*/; do
	bundle=$(basename $i)
	if [[ ! ${BUNDLES[$bundle]} ]]; then
		echo "Removing bundle ${bundle} ..."
		rm -rf $i
	fi
done
