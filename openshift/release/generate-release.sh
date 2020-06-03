#!/usr/bin/env bash
set -e

source $(dirname $0)/../resolve-yamls.sh

release=$1
output_file="openshift/release/tektoncd-triggers-${release}.yaml"

if [ $release = "ci" ]; then
    image_prefix="image-registry.openshift-image-registry.svc:5000/tektoncd-triggers/tektoncd-triggers-"
else
    image_prefix="quay.io/openshift-pipeline/tektoncd-triggers"
    tag=$release
fi

resolve_resources config/ $output_file noignore $image_prefix $tag

sed -i -e 's/\(triggers.tekton.dev\/release\): "devel"/\1: "v0.5.0"/g' -e 's/\(version\): "devel"/\1: "v0.5.0"/g' $output_file

