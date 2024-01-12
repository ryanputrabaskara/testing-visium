#!/bin/bash
set -x

# step 1: check and install jq
# Check if jq is installed
#!/bin/bash

# Check if jq is installed
if command -v jq &> /dev/null; then
    # macOS version
    if [[ "$(uname -s)" == "Darwin" ]]; then
        jq --version
    else
        # Linux version
        jq -v
    fi
else
    echo "jq is not installed. Please install jq first."
fi



# step 2: get all devide id of Android
# Make the GET request and capture the JSON response
response=$(curl -s -X GET https://farmdemo.visiumlabs.com/api/devices?os=Android \
-H "Content-Type: application/json" \
-H "X-VisiumFarm-Api-Key: 2q3Ue23QgD.Xj0TMbjEpzr2Zf6PfngagnetePGiOjubCr6aUwN0")

# Extract the 'id' attributes from the JSON response and format output with double quotes
ids=$(echo "$response" | jq -r '[.[] | .deviceId] | map("\"" + . + "\"") | join(",")')


# Output the extracted 'id' attributes in the required format
echo "$ids"

export ids=$ids


# step 3: upload APK file and get the id of APK file
# Set the necessary variables
API_KEY="2q3Ue23QgD.Xj0TMbjEpzr2Zf6PfngagnetePGiOjubCr6aUwN0"
FILE_PATH="Simple_Notepad_2.0.1_Apkpure.apk"
API_URL="https://farmdemo.visiumlabs.com/api/v1/apps"

# Make the POST request and capture the response
response=$(curl -s -X POST "$API_URL" \
-H "X-VisiumFarm-Api-Key: $API_KEY" \
-F "file=@$FILE_PATH")

# Extract the 'id' attribute using jq

appId=$(echo "$response" | grep -o '"id" : [0-9]*' | cut -d':' -f2 | tr -d ' ')


# Output the extracted 'appId'
echo "The extracted appId is: $appId"

export appId=$appId

# step 4: Install the APK in all Android devices
curl -X POST https://farmdemo.visiumlabs.com/api/apk/install \
-H "Content-Type: application/json" \
-H "X-VisiumFarm-Api-Key: 2q3Ue23QgD.Xj0TMbjEpzr2Zf6PfngagnetePGiOjubCr6aUwN0" \
-d '{
  "appList": [
    {
      "appId": '"$appId"', 
      "type": "Android"
    }
  ],
  "deviceList": [
    '"$ids"'
  ]
}'
