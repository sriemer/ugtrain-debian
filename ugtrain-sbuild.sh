#!/bin/bash

PACKAGE="ugtrain"
DEBRELS=`cat debian/changelog | head -n1 | grep -o "(.*)" | tr -d "()"`
VERS=`echo "${DEBRELS}" | cut -d '-' -f1`
RELS=`echo "${DEBRELS}" | cut -d '-' -f2`

git branch -D source
git checkout -b source
mkdir ${PACKAGE}
git mv debian/ ${PACKAGE}/
git commit -a -m "Move dir 'debian' into new dir '${PACKAGE}'"
cd ${PACKAGE}
uscan --force-download || exit 1
git add ../*
git commit -a -m "Run 'uscan --force-download'

The quilt format always requires an orig.tar.gz file. So provide it."
tar xzf ../${PACKAGE}-${VERS}.tar.gz
mv ${PACKAGE}-${VERS}/* .
mv ${PACKAGE}-${VERS}/.* .
rmdir ${PACKAGE}-${VERS}
git add *
git add .*
git commit -a -m "Import the code from v${VERS} upstream"
debuild -S || exit 1
git add ../*
git commit -a -m "Run 'debuild -S'"
git branch -D unstable-amd64
git checkout -b unstable-amd64
cd ..
sbuild -A --arch=amd64 -c unstable-amd64-sbuild -d unstable --run-lintian -k 84927565 ${PACKAGE}_${VERS}-${RELS}.dsc || exit 1
git add *
git commit -a -m "Build with local sbuild for unstable-amd64

Run the following command to build this with sbuild for Debian
unstable amd64:

$ sbuild -A --arch=amd64 -c unstable-amd64-sbuild -d unstable \
--run-lintian -k 84927565 ${PACKAGE}_${VERS}-${RELS}.dsc"
