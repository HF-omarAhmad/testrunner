#!/bin/bash

MODE_STAGING="staging"
MODE_PRODUCTION="production"
BUMP_MAJOR="major"
BUMP_MINOR="minor"
BUMP_PATCH="patch"

DEFAULT_TO_BUMP=$BUMP_PATCH

# Parse Arguments
while [[ "$#" -gt 0 ]]; do case $1 in
  -m|--mode) MODE="$2"; shift;;
  -b|--bump) TO_BUMP="$2"; shift;;
  *) echo "Unknown parameter passed: $1"; exit 1;;
esac; shift; done

if [ -z $MODE ]
then
    echo Provide mode using -m, --mode
    exit 1
fi

if [ -z $TO_BUMP ]
then
    TO_BUMP=$DEFAULT_TO_BUMP
fi

if [ "$MODE" = "$MODE_STAGING" ]
then
    LAST_TAG=(`git tag --sort=-committerdate`)
else
    LAST_TAG=(`git tag --sort=-committerdate | grep -E "v[0-9]+.[0-9]+.[0-9]+$"`)
fi

if [[ -z "$LAST_TAG" && "$MODE" = "$MODE_PRODUCTION" ]]
then
    echo "v0.0.0"
    exit 0
elif [[ -z "$LAST_TAG" ]]
then
    LAST_TAG="v0.0.0"
fi
VERSION_AND_RC=(`echo $LAST_TAG | tr '-' ' '`)
VERSION=${VERSION_AND_RC[0]}
RC=${VERSION_AND_RC[1]}

if [ "$MODE" = "$MODE_STAGING" ]
then
    if [ -n "$RC" ]
    then
        RC_IDENTIFIER=${RC#"rc"}
        RC_IDENTIFIER=$((RC_IDENTIFIER + 1))
        NEW_TAG="$VERSION-rc$RC_IDENTIFIER"
    else
        BASE_LIST=(`echo $VERSION | tr '.' ' '`)
        V_MAJOR=${BASE_LIST[0]}
        V_MINOR=${BASE_LIST[1]}
        V_PATCH=${BASE_LIST[2]}
        if [ "$TO_BUMP" = "$BUMP_MAJOR" ]
        then
            V_MAJOR=$((V_MAJOR + 1))
            V_MINOR=0
            V_PATCH=0
        elif [ "$TO_BUMP" = "$BUMP_MINOR" ]
        then
            V_MINOR=$((V_MINOR + 1))
            V_PATCH=0
        elif [ "$TO_BUMP" = "$BUMP_PATCH" ]
        then
            V_PATCH=$((V_PATCH + 1))
        else
            echo Unknown bump parameter use either \`$BUMP_MAJOR\`, \`$BUMP_MINOR\` or \`$BUMP_PATCH\`
            exit 2
        fi

        NEW_TAG="$V_MAJOR.$V_MINOR.$V_PATCH-rc1"
    fi
elif [ "$MODE" = "$MODE_PRODUCTION" ]
then
    BASE_LIST=(`echo $VERSION | tr '.' ' '`)
    V_MAJOR=${BASE_LIST[0]}
    V_MINOR=${BASE_LIST[1]}
    V_PATCH=${BASE_LIST[2]}
    if [ "$TO_BUMP" = "$BUMP_MAJOR" ]
    then
        V_MAJOR=$((V_MAJOR + 1))
        V_MINOR=0
        V_PATCH=0
    elif [ "$TO_BUMP" = "$BUMP_MINOR" ]
    then
        V_MINOR=$((V_MINOR + 1))
        V_PATCH=0
    elif [ "$TO_BUMP" = "$BUMP_PATCH" ]
    then
        V_PATCH=$((V_PATCH + 1))
    else
        echo Unknown bump parameter use either \`$BUMP_MAJOR\`, \`$BUMP_MINOR\` or \`$BUMP_PATCH\`
        exit 2
    fi
    NEW_TAG="$V_MAJOR.$V_MINOR.$V_PATCH"
else
    echo Unknown mode use either \`$MODE_STAGING\` or \`$MODE_PRODUCTION\`
    exit 4
fi

echo $NEW_TAG