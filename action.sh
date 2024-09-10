#!/bin/sh
set -e

if [ "$3" != "" ]
then
    SubDirectoryLocation="$3/"
fi

mode="export-release"
if [ "$6" = "true" ]
then
    echo "Exporting in debug mode!"
    mode="export-debug"
fi

# Export for project
echo "Building $1 for $2"
mkdir -p $GITHUB_WORKSPACE/build/${SubDirectoryLocation:-""}
cd "$GITHUB_WORKSPACE/$5"
$7 --headless --${mode} "$2" $GITHUB_WORKSPACE/build/${SubDirectoryLocation:-""}$1
echo "Build Done"

echo ::set-output name=build::build/${SubDirectoryLocation:-""}

if [ "$4" = "true" ]
then
    echo "Packing Build"
    mkdir -p $GITHUB_WORKSPACE/package
    cd $GITHUB_WORKSPACE/build
    zip $GITHUB_WORKSPACE/package/artifact.zip ${SubDirectoryLocation:-"."} -r
    echo ::set-output name=artifact::package/artifact.zip
    echo "Done"
fi