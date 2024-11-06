#!/bin/bash

# Define the path to a file containing the list of project IDs, one per line
PROJECTS_FILE="project_ids.txt"

# Output file name
OUTPUT_FILE="projects_roles_permissions_v2.txt"

# Authenticate if necessary (optional, depending on your setup)
gcloud auth list

# Clear any existing content in the output file
> "$OUTPUT_FILE"

# Check if the projects file exists
if [[ ! -f "$PROJECTS_FILE" ]]; then
  echo "Project IDs file not found: $PROJECTS_FILE"
  exit 1
fi

# Step 1: Loop through each project ID in the file
while IFS= read -r PROJECT_ID; do
  if [[ -z "$PROJECT_ID" ]]; then
    continue  # Skip empty lines
  fi

  echo "Processing Project ID: $PROJECT_ID"
  echo "Project: $PROJECT_ID" >> "$OUTPUT_FILE"
  
  # Step 2: List all custom roles in the project by filtering based on name pattern
  role_ids=$(gcloud iam roles list \
    --project="$PROJECT_ID" \
    --filter="name:projects/$PROJECT_ID/roles/" \
    --format="value(name)")

  # Step 3: Loop through each role ID, remove the prefix, and save the permissions to the text file
  for role_id in $role_ids; do
    # Remove the "projects/<PROJECT_ID>/roles/" prefix from each role ID
    clean_role_id=$(echo "$role_id" | sed "s|projects/$PROJECT_ID/roles/||")
    
    echo "  Processing Role: $clean_role_id"
    
    # Write role ID to the output file
    echo "  Role: $clean_role_id" >> "$OUTPUT_FILE"
    echo "  Permissions:" >> "$OUTPUT_FILE"
    
    # Get permissions for each role and list each on a new line
    gcloud iam roles describe "$clean_role_id" \
      --project="$PROJECT_ID" \
      --format="value(includedPermissions)" | tr ',' '\n' | sed 's/^/    - /' >> "$OUTPUT_FILE"
    
    # Add a blank line after each role for readability
    echo "" >> "$OUTPUT_FILE"
  done

  # Add a blank line after each project for readability
  echo "" >> "$OUTPUT_FILE"
done < "$PROJECTS_FILE"

echo "Permissions saved to $OUTPUT_FILE."
