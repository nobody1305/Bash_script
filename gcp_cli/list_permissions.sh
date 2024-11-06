#!/bin/bash

# Replace with your organization ID
ORGANIZATION_ID="384982482799"

# Authenticate and set the project (optional, depending on your setup)
gcloud auth list

# Output file name
OUTPUT_FILE="roles_permissions.csv"

# Write headers to the output file
echo "Role ID,Permissions" > "$OUTPUT_FILE"

# Step 1: List all custom roles in the organization
echo "Fetching list of custom roles in organization $ORGANIZATION_ID..."
role_ids=$(gcloud iam roles list \
  --organization="$ORGANIZATION_ID" \
  --filter="stage:GA" \
  --format="value(name)")

# Step 2: Loop through each role ID, remove the prefix, and save the permissions to a CSV file
for role_id in $role_ids; do
  # Remove the "organizations/<ORG_ID>/roles/" prefix from each role ID
  clean_role_id=$(echo "$role_id" | sed "s|organizations/$ORGANIZATION_ID/roles/||")
  
  echo "Processing Role: $clean_role_id"
  
  # Get permissions for each role and format as a comma-separated list
  permissions=$(gcloud iam roles describe "$clean_role_id" \
    --organization="$ORGANIZATION_ID" \
    --format="value(includedPermissions)" | tr '\n' ',')

  # Remove trailing comma from permissions list
  permissions=${permissions%,}

  # Append role ID and permissions to the output file
  echo "$clean_role_id,$permissions" >> "$OUTPUT_FILE"
done

echo "Permissions saved to $OUTPUT_FILE."

