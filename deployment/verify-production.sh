#!/bin/bash
RESOURCE_GROUP="rg-lazarus-omega-production"
CONTAINER_APP="ca-lazarus-omega-brief"

echo "🔍 Verifying deployment..."
echo ""

if az containerapp show --name $CONTAINER_APP --resource-group $RESOURCE_GROUP &> /dev/null; then
    STATUS=$(az containerapp show \
        --name $CONTAINER_APP \
        --resource-group $RESOURCE_GROUP \
        --query properties.runningStatus -o tsv)
    
    echo "Container App: $CONTAINER_APP"
    echo "Status: $STATUS"
    
    if [ "$STATUS" == "Running" ]; then
        echo "✅ Deployment verified - Container App is running"
        
        URL=$(az containerapp show \
            --name $CONTAINER_APP \
            --resource-group $RESOURCE_GROUP \
            --query properties.configuration.ingress.fqdn -o tsv)
        echo "URL: https://$URL"
    else
        echo "⚠️  Container App exists but not running (Status: $STATUS)"
    fi
else
    echo "❌ Container App not found: $CONTAINER_APP"
    exit 1
fi
