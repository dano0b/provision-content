#!/bin/bash

set -e

family=386
if [[ $(uname -m) == x86_64 ]] ; then
    family=amd64
fi
case $(uname -s) in
    Darwin)
        shasum="command shasum -a 256"
        ;;
    Linux)
        shasum="command sha256sum"
        ;;
    *)
        # Someday, support installing on Windows.  Service creation could be tricky.
        echo "No idea how to check sha256sums"
        exit 1;;
esac

PATH=$PATH:$GOPATH/bin
which drbundler || (curl -L -o $GOPATH/bin/drbundler https://github.com/digitalrebar/provision/releases/download/tip/drbundler && chmod +x $GOPATH/bin/drbundler)
which drpcli || (curl -L -o $GOPATH/bin/drpcli https://github.com/digitalrebar/provision/releases/download/tip/drpcli && chmod +x $GOPATH/bin/drpcli)

. tools/version.sh

tools/pieces.sh | while read i ; do
    dir=$i
    if [[ $i == "drp-community-content" ]] ; then
        dir="content"
    fi
    if [[ $i == "drp-community-contrib" ]] ; then
        dir="contrib"
    fi
    echo -n "$Prepart$MajorV.$MinorV.$PatchV$Extra-$GITHASH" > $dir/._Version.meta
    drbundler $dir $i.yaml
    drpcli contents document $i.yaml > $i.rst
    $shasum $i.yaml > $i.sha256
done

