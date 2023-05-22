#/bin/bash


JIRA_URL="https://micahlmartin.atlassian.net"
JIRA_TICKET_ID="TES-1"
ENVIRONMENT_CUSTOM_FIELD_ID="customfield_10029"
JIRA_USERNAME="micahlmartin@gmail.com"
JIRA_API_KEY="B5OEUr9nePFLHiULDxrN6B52"

error() {
  >&2 echo "Error: $1"
  exit 1
}

shouldNotBeEmptyOrNull() {
  if [[ -z "$1" ]] || [[ "$1" == "null" ]]; then
    error "Error: $2"
    exit 1
  fi
}

shouldBeEmptyOrNull() {
  if [[ ! -z "$1" ]] && [[ "$1" != "null" ]]; then
    error "Error: $1"
    exit 1
  fi
}

ticket_json=$(curl -LSs -u $JIRA_USERNAME:$JIRA_API_KEY ${JIRA_URL}/rest/api/latest/issue/${JIRA_TICKET_ID} | jq -r)
error_message=$(echo $ticket_json | jq -r '.errorMessages[0]')
shouldBeEmptyOrNull "$error_message" "Error: $error_message"

environment=$(echo $ticket_json | jq -r ".fields.${ENVIRONMENT_CUSTOM_FIELD_ID}.value")
shouldNotBeEmptyOrNull $environment "Environment is not set"

attachment_link=$(echo $ticket_json | jq -r '.fields.attachment[] | select(.filename=="bom.json").content')
shouldNotBeEmptyOrNull $attachment_link "BOM attachment is not set"

bom=$(curl -LSs -u $JIRA_USERNAME:$JIRA_API_KEY $attachment_link | jq -r)
shouldNotBeEmptyOrNull $bom "BOM is not set"
