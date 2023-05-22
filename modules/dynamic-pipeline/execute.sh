#!/bin/bash

HARNESS_ACCOUNT_ID="UKh5Yts7THSMAbccG3HrLA"
HARNESS_API_KEY="VUtoNVl0czdUSFNNQWJjY0czSHJMQTo6NGpPZVFETElHelpzY3o1Mm1OQWdZeU85TGdZQWQ1NTQyRVFFQVBhdGV4VE9oRjBqbEFXbzVHN3pqR1IxRUhDeU01eG00cTBMc0UxTERnTkc="
HARNESS_APPLICATION_ID="HkVra8JdRUGGdSDBMJOc7g"
PIPELINE_ID="pPVrVm1gTS2Zo8ghfKoc6A"

result=$(curl -Ss "https://app.harness.io/gateway/api/graphql?accountId=${HARNESS_ACCOUNT_ID}" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${HARNESS_API_KEY}" \
  -d '{"query":"mutation ($input: StartExecutionInput\u0021) {\n  startExecution(input: $input) {\n    execution {\n      id\n    }\n    warningMessage\n  }\n}\n","variables":{"input":{"applicationId":"'${HARNESS_APPLICATION_ID}'","executionType":"PIPELINE","entityId":"'${PIPELINE_ID}'"}}}')

executionId=$(echo $result | jq -r '.data.startExecution.execution.id')

if [[ -z "$executionId" ]] || [[ "$executionId" == "null" ]]; then
  >&2 echo "Error: Failed to start pipeline"
  echo $result
  exit 1
fi

echo $executionId
