#!/bin/bash

# ======================================================
# 💸 LAZARUS OMEGA: CASH OUT (DEPLOYMENT)
# ======================================================

# 1. SETUP VARIABLES
RG="rg-lazarus-omega-production"
ACR="acrlazarusomega$RANDOM" # Randomize to ensure uniqueness
LOC="eastus2"
SUB_ID=$(az account show --query id -o tsv)

echo "🔥 [1/4] BURNING INFRASTRUCTURE..."
echo "   Target: $RG ($LOC)"
echo "   Sub ID: $SUB_ID"

# 2. CREATE RESOURCES
az group create --name $RG --location $LOC --output none
echo "✅ Resource Group Created"

az acr create --resource-group $RG --name $ACR --sku Standard --admin-enabled true --output none
echo "✅ Container Registry Created: $ACR"

# 3. GENERATE KEYS (THE MONEY)
echo "🔑 [2/4] MINTING CREDENTIALS..."

# Get ACR Keys
ACR_USER=$(az acr credential show --name $ACR --query username -o tsv)
ACR_PASS=$(az acr credential show --name $ACR --query passwords[0].value -o tsv)

# Create Service Principal
SP_NAME="sp-lazarus-omega-github"
SP_JSON=$(az ad sp create-for-rbac --name $SP_NAME --role Contributor --scopes /subscriptions/$SUB_ID/resourceGroups/$RG --sdk-auth --output json)

# 4. UPDATE LOCAL FILES WITH REAL NAMES
# We need to make sure the workflow uses the actual ACR name we just created
sed -i "s/acrlazarusomega/$ACR/g" .github/workflows/cd-production.yml

echo ""
echo "💰 [3/4] DEPOSITING SECRETS..."
echo "=========================================================="
echo "⚠️  ACTION REQUIRED: COPY THESE VALUES TO GITHUB SECRETS ⚠️"
echo "   (Go to: Repo Settings -> Secrets and variables -> Actions)"
echo "=========================================================="
echo ""
echo "SECRET NAME: AZURE_CREDENTIALS"
echo "VALUE:"
echo "$SP_JSON"
echo ""
echo "----------------------------------------------------------"
echo "SECRET NAME: ACR_USERNAME"
echo "VALUE: $ACR_USER"
echo "----------------------------------------------------------"
echo "SECRET NAME: ACR_PASSWORD"
echo "VALUE: $ACR_PASS"
echo "----------------------------------------------------------"
echo "SECRET NAME: AZURE_SUBSCRIPTION_ID"
echo "VALUE: $SUB_ID"
echo "=========================================================="
echo ""
read -p "PRESS ENTER ONCE YOU HAVE SAVED THESE SECRETS IN GITHUB..."

# 5. EXECUTE
echo "🚀 [4/4] EXECUTING LAUNCH..."
git add .
git commit -m "feat: Cash out - deploying production system"
git push origin main

echo ""
echo "✅ TRANSCACTION COMPLETE."
echo "Watch the fireworks here: https://github.com/Joedaddy66/agf-sovereign-nexus/actions"