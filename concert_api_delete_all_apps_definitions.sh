#!/bin/bash
# Script that helps you delete application definitions on IBM Concert using the API

# Define your API key, instance ID, and base URL
CONCERT_API_KEY=""
CONCERT_INSTANCE_ID=""
CONCERT_BASE_URL_API="https://YOURCONCERT/core/api/v1"

# Headers for authentication
# IMPORTANT: C_API_KEY is for installations in VM.
HEADERS=(
  -H "Authorization: C_API_KEY $CONCERT_API_KEY"
  -H "InstanceId: $CONCERT_INSTANCE_ID"
)

# List all application definitions
LIST_URL="${CONCERT_BASE_URL_API}/applications?page_size=100&page_number=1&sort_by=name&sort_direction=asc&filter=&search="
echo "Fetching application definitions from: $LIST_URL"
APPLICATIONS=$(curl -s "${HEADERS[@]}" -X GET "$LIST_URL" -k)
echo "Response: $APPLICATIONS"

# Check if the response is empty or invalid
if [ -z "$APPLICATIONS" ]; then
  echo "No applications found or failed to fetch applications."
  exit 1
fi

# Delete each application definition
for APP_ID in $(echo "$APPLICATIONS" | jq -r '.applications[].id'); do
    # Added this if because I wanted to delete all but one Application
    if [ "$APP_ID" != "YOURAPPLICATIONID" ] ; then
        DELETE_URL="${CONCERT_BASE_URL_API}/applications/$APP_ID?remove_associations=true&delete_all_versions=true&is_cascade_delete=true"
        echo "Deleting application with ID: $APP_ID"
        DELETE_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE "${HEADERS[@]}" "$DELETE_URL" -k)
        echo "Delete response for application $APP_ID: $DELETE_RESPONSE"
    fi
    if [ "$DELETE_RESPONSE" -eq 204 ]; then
        echo "Application $APP_ID deleted successfully."
    else
        echo "Failed to delete application $APP_ID. Status code: $DELETE_RESPONSE"
    fi
done