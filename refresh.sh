#!/bin/bash

# define array for later use
charts=()

# download and package charts
while read line; do
    # Create temp working dir
    mkdir tmp
    cd tmp

    # split the row to get the variables from chartsources.txt
    REPOSITORY=$(echo "$line" | cut -d ";" -f 1)
    CHARTDIR=$(echo "$line" | cut -d ";" -f 2)
    FRIENDLYNAME=$(echo "$line" | cut -d ";" -f 3)
    
    # add chart to array
    charts+=("- [$FRIENDLYNAME]($REPOSITORY)")

    # Clone repository
    git clone "$REPOSITORY" .

    # Package chart from specified chart dir
    helm package -d ../packages "./$CHARTDIR"

    # backout and delete tmp dir
    cd ..
    rm -rf tmp
done <chartsources.txt

# Update the index
helm repo index ./packages/
rm -rf index.yaml
mv ./packages/index.yaml index.yaml

# Delete listed charts in readme
sed -i '/^### Charts/,$d' README.md

# Add header and each chart as a new line to README.md
sed -i -e '$a\### Charts\' README.md
for chart in "${charts[@]}"
do
   echo "$chart" >>README.md
done