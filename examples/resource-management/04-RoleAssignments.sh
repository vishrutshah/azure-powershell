#!/bin/bash
set -e
printf "\n=== Managing Role Assignments in Azure ===\n"

printf "\n1. Creating a new resource group: %s and location: %s.\n" "$groupName" "$location"
azure group create --name "$groupName" --location "$location"

printf "\n2. Creating a new Role Assignment.\n"
users=$(azure ad users get)
userId=$(echo $users | cat | jq '.[0].Id' -s --raw-output)
roleDefinitions=$(azure role definition get)
roleDefinitionId=$(echo $roleDefinitions | cat | jq '.[0].Id' -s --raw-output)
subsciptions=$(azure subscription get)
subscriptionId=$(echo $subsciptions | cat | jq '.[0].SubscriptionId' -s --raw-output)
scope="/subscriptions/$subscriptionId/resourceGroups/$groupName"
azure role assignment create --ObjectId "$userId" --RoleDefinitionId "$roleDefinitionId" --Scope "$scope"

printf "\n3. Delete last created Role Assignment.\n"
assignments=$(azure role assignment get)
assignmentId=$(echo $assignments | cat | jq '.[-1].ObjectId' -s --raw-output)
azure role assignment remove --ObjectId "$assignmentId" --Scope "$scope" --RoleDefinitionId "$roleDefinitionId" -f