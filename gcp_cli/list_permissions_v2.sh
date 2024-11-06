#!/bin/bash

# Replace with your organization ID
ORGANIZATION_ID="384982482799"

# Output file name
OUTPUT_FILE="roles_permissions_v2.txt"

# Authenticate and set the project (optional, depending on your setup)
gcloud auth list

# Clear any existing content in the output file
> "$OUTPUT_FILE"

# Step 1: List all custom roles in the organization
echo "Fetching list of custom roles in organization $ORGANIZATION_ID..."
role_ids=$(gcloud iam roles list \
  --organization="$ORGANIZATION_ID" \
  --filter="stage:GA" \
  --format="value(name)")

# Step 2: Loop through each role ID, remove the prefix, and save the permissions to the text file
for role_id in $role_ids; do
  # Remove the "organizations/<ORG_ID>/roles/" prefix from each role ID
  clean_role_id=$(echo "$role_id" | sed "s|organizations/$ORGANIZATION_ID/roles/||")
  
  echo "Processing Role: $clean_role_id"
  
  # Write role ID to the output file
  echo "Role: $clean_role_id" >> "$OUTPUT_FILE"
  echo "Permissions:" >> "$OUTPUT_FILE"
  
  # Get permissions for each role and list each on a new line
  gcloud iam roles describe "$clean_role_id" \
    --organization="$ORGANIZATION_ID" \
    --format="value(includedPermissions)" | tr ',' '\n' | sed 's/^/  - /' >> "$OUTPUT_FILE"
  
  # Add a blank line after each role for readability
  echo "" >> "$OUTPUT_FILE"
done

echo "Permissions saved to $OUTPUT_FILE."
