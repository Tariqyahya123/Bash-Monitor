#!/bin/bash

ipaddr=$(hostname -I | xargs)


# Define the JSON body
json_body="{
  \"track_total_hits\": false,
  \"sort\": [
    {
      \"@timestamp\": {
        \"order\": \"desc\",
        \"unmapped_type\": \"boolean\"
      }
    }
  ],
  \"fields\": [
    {
      \"field\": \"*\",
      \"include_unmapped\": \"true\"
    },
    {
      \"field\": \"@timestamp\",
      \"format\": \"strict_date_optional_time\"
    },
    {
      \"field\": \"jsonfields.billInfo.lastInvoiceDate\",
      \"format\": \"strict_date_optional_time\"
    },
    {
      \"field\": \"jsonfields.dateOfBirth\",
      \"format\": \"strict_date_optional_time\"
    },
    {
      \"field\": \"jsonfields.paymentResponse.lastInvoiceDate\",
      \"format\": \"strict_date_optional_time\"
    },
    {
      \"field\": \"jsonfields.responseTimestamp\",
      \"format\": \"strict_date_optional_time\"
    }
  ],
  \"size\": 500,
  \"version\": true,
  \"script_fields\": {},
  \"stored_fields\": [
    \"*\"
  ],
  \"runtime_mappings\": {},
  \"_source\": false,
  \"query\": {
    \"bool\": {
      \"must\": [],
      \"filter\": [
        {
          \"range\": {
            \"@timestamp\": {
              \"format\": \"strict_date_optional_time\",
              \"gte\": \"now-15m\",
              \"lte\": \"now\"
            }
          }
        },
        {
          \"match_phrase\": {
            \"message\": \"the_phrase_to_match\"
          }
        },
        {
          \"match_phrase\": {
            \"host.ip\": \"$ipaddr\"
          }
        }
      ],
      \"should\": [],
      \"must_not\": []
    }
  },
  \"highlight\": {
    \"pre_tags\": [
      \"@kibana-highlighted-field@\"
    ],
    \"post_tags\": [
      \"@/kibana-highlighted-field@\"
    ],
    \"fields\": {
      \"*\": {}
    },
    \"fragment_size\": 2147483647
  }
}"



echo $json_body


# Send the POST request with the JSON body
response=$(curl -X POST -H 'Content-Type: application/json' -d "$json_body" http://your_elk_server_ip/your_index/_search -u user:password)

# Print the response
echo $response

hits=$(jq '.hits["hits"]' <<< "$response")

my_hits_array=($hits)

amount_of_hits=${#my_hits_array[@]}


echo $amount_of_hits

if (($amount_of_hits > 1)); then
  echo $amount_of
  else
  echo "RESTART"
  echo "APP is restarting" | mail -s "APP is restarting" youremail@yourdomain.com
  systemctl restart your_service
fi

# Store the response in a variable
response_variable=$response
