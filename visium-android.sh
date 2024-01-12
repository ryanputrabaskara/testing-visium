#!/bin/bash
set -x

# Step 1: Check and install jq
# Check if jq is installed
if ! command jq --version &> /dev/null; then
    echo "jq is not installed. Installing..."

    # Install jq using Homebrew
    if command brew --version &> /dev/null; then
        brew install jq
        if command jq --version &> /dev/null; then
            echo "jq has been successfully installed."
        else
            echo "Failed to install jq. Please install it manually."
            exit 1
        fi
    else
        echo "Homebrew is not installed. Please install Homebrew first."
        exit 1
    fi
else
    echo "jq is already installed."
fi

# Step 2: Get all device IDs of Android
# Make the GET request and capture the JSON response
response=$(curl -s -X GET https://farmdemo.visiumlabs.com/api/devices?os=Android \
-H "Content-Type: application/json" \
-H "X-VisiumFarm-Api-Key: 2q3Ue23QgD.Xj0TMbjEpzr2Zf6PfngagnetePGiOjubCr6aUwN0")

# Extract the 'id' attributes from the JSON response and format output with double quotes
ids=$(echo "$response" | jq -r '[.[] | .deviceId] | map("\"" + . + "\"") | join(",")')

# Output the extracted 'id' attributes in the required format
echo "$ids"

export ids=$ids

# Step 3: Upload APK file and get the ID of the APK file
# Set the necessary variables
API_KEY="2q3Ue23QgD.Xj0TMbjEpzr2Zf6PfngagnetePGiOjubCr6aUwN0"
FILE_PATH="Register_2.0_Apkpure.apk"
API_URL="https://farmdemo.visiumlabs.com/api/v1/apps"

# Make the POST request and capture the response
response=$(curl -s -X POST "$API_URL" \
-H "X-VisiumFarm-Api-Key: $API_KEY" \
-F "file=@$FILE_PATH")

# Extract the 'id' attribute using jq
appId=$(echo "$response" | jq -r '.id')

# Output the extracted 'appId'
echo "The extracted appId is: $appId"

export appId=$appId

# Step 4: Install the APK in all Android devices
curl -X POST https://farmdemo.visiumlabs.com/api/apk/install \
-H "Content-Type: application/json" \
-H "X-VisiumFarm-Api-Key: 2q3Ue23QgD.Xj0TMbjEpzr2Zf6PfngagnetePGiOjubCr6aUwN0" \
-d '{
  "appList": [
    {
      "appId": "'"$appId"'",
      "type": "Android"
    }
  ],
  "deviceList": [
    '"$ids"'
  ]
}'
