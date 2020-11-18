#! /bin/bash
set -e
echo "e2e TEST"
# need to find a way to use the Makefile to set these
IMG=$(cat COMPONENT_NAME 2> /dev/null)

echo ${TRAVIS_BUILD}

echo ${TRAVIS_EVENT_TYPE}
echo ${COMPONENT_TAG_EXTENSION}
echo ${TRAVIS_PULL_REQUEST}-${TRAVIS_COMMIT}

if [ "$TRAVIS_BUILD" != 1 ]; then
    echo "Build is on Travis" 

    echo -e "Get kubectl binary \n"
    # Download and install kubectl
    curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x kubectl && sudo mv kubectl /usr/local/bin/

    echo -e "\nDownload and install KinD\n"
    GO111MODULE=on go get sigs.k8s.io/kind

    kind create cluster
    if [ $? != 0 ]; then
            exit $?;
    fi
    sleep 15

fi

kind get kubeconfig > default-kubeconfigs/hub

./build/_output/bin/${IMG} &

sleep 10
curl http://localhost:8765/clusters | head -n 10
curl http://localhost:8765/testcases | head -n 10
curl http://localhost:8765/expectations | head -n 10
curl http://localhost:8765/testcases?id=chn-001 | head -n 10
curl http://localhost:8765/expectations?id=chn-001 | head -n 10


echo "terminate the test server"
ps aux | grep ${IMG} | grep -v 'grep' | awk '{print $2}' | xargs kill -9
