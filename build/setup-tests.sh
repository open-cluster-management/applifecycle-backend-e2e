#!/bin/bash -e
###############################################################################
# (c) Copyright IBM Corporation 2019, 2020. All Rights Reserved.
# Note to U.S. Government Users Restricted Rights:
# U.S. Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule
# Contract with IBM Corp.
# Copyright (c) Red Hat, Inc.
# Copyright Contributors to the Open Cluster Management project
###############################################################################

os=$(go env GOOS)
arch=$(go env GOARCH)

# download kubebuilder and extract it to tmp
curl -L https://go.kubebuilder.io/dl/2.3.1/${os}/${arch} | tar -xz -C /tmp/

mkdir -p test_tmp/bin
_test_bin_dir=$(realpath test_tmp/bin)
mv /tmp/kubebuilder_2.3.1_${os}_${arch} $_test_bin_dir/kubebuilder

echo -e "\nDownload and install KinD\n"
go get sigs.k8s.io/kind@v0.9.0