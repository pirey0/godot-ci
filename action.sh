#!/bin/sh
set -e

# Move godot templates to location engine will look up
mkdir -v -p ~/.local/share/godot/export_templates
cp -a $GITHUB_WORKSPACE/$8/. ~/.local/share/godot/export_templates/

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
chmod +x $GITHUB_WORKSPACE/$7
$GITHUB_WORKSPACE/$7 --headless --${mode} "$2" $GITHUB_WORKSPACE/build/${SubDirectoryLocation:-""}$1
echo "Build Done"

echo build=build/${SubDirectoryLocation:-""} >> $GITHUB_OUTPUT
if [ "$4" = "true" ]
then
    echo "Packing Build"
    mkdir -p $GITHUB_WORKSPACE/package
    cd $GITHUB_WORKSPACE/build
    zip $GITHUB_WORKSPACE/package/artifact.zip ${SubDirectoryLocation:-"."} -r
    echo artifact=package/artifact.zip >> $GITHUB_OUTPUT
    echo "Done"
fi