#!/bin/bash

# COLORS
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}======================================================${NC}"
echo -e "${YELLOW}🛡️  OBSIDIAN SENTINEL - PRE-FLIGHT SYSTEM CHECK${NC}"
echo -e "${YELLOW}======================================================${NC}"
echo ""

# TRACKING VARIABLES
ERRORS=0

# 1. CHECK TOOLS ====================================================
echo -e "${YELLOW}[1/4] CHECKING ORDNANCE (TOOLS)...${NC}"

# Check Azure CLI
if command -v az &> /dev/null; then
    AZ_VER=$(az --version | head -n 1)
    echo -e "${GREEN}✅ Azure CLI installed:${NC} $AZ_VER"
else
    echo -e "${RED}❌ Azure CLI MISSING.${NC} Install via: brew install azure-cli (or equiv)"
    ((ERRORS++))
fi

# Check Docker
if command -v docker &> /dev/null; then
    # Check if daemon is running
    if docker info &> /dev/null; then
        echo -e "${GREEN}✅ Docker is RUNNING${NC}"
    else
        echo -e "${RED}❌ Docker is installed but NOT RUNNING.${NC} Start Docker Desktop."
        ((ERRORS++))
    fi
else
    echo -e "${RED}❌ Docker MISSING.${NC}"
    ((ERRORS++))
fi

# Check Git
if command -v git &> /dev/null; then
    echo -e "${GREEN}✅ Git installed${NC}"
else
    echo -e "${RED}❌ Git MISSING.${NC}"
    ((ERRORS++))
fi

echo ""

# 2. CHECK AZURE AUTH ===============================================
echo -e "${YELLOW}[2/4] CHECKING SECURITY CLEARANCE (LOGIN)...${NC}"

# Check login status
az account show &> /dev/null
if [ $? -eq 0 ]; then
    SUB_ID=$(az account show --query id -o tsv)
    SUB_NAME=$(az account show --query name -o tsv)
    echo -e "${GREEN}✅ Azure Login ACTIVE${NC}"
    echo -e "   Subscription: $SUB_NAME ($SUB_ID)"
else
    echo -e "${RED}❌ NOT LOGGED IN.${NC} Run: ${YELLOW}az login${NC}"
    ((ERRORS++))
fi

echo ""

# 3. CHECK FILE INTEGRITY ===========================================
echo -e "${YELLOW}[3/4] CHECKING PAYLOAD INTEGRITY (FILES)...${NC}"

REQUIRED_FILES=(
    "deployment/main.bicep"
    "deployment/verify-production.sh"
    ".github/workflows/cd-production.yml"
    "Dockerfile"
    "requirements.txt"
)

for FILE in "${REQUIRED_FILES[@]}"; do
    if [ -f "$FILE" ]; then
        echo -e "${GREEN}✅ Found:${NC} $FILE"
    else
        echo -e "${RED}❌ MISSING:${NC} $FILE"
        ((ERRORS++))
    fi
done

echo ""

# 4. CHECK REPO STATUS ==============================================
echo -e "${YELLOW}[4/4] CHECKING COMMS UPLINK (GIT)...${NC}"

if [ -d ".git" ]; then
    REMOTE=$(git remote get-url origin 2>/dev/null)
    if [[ "$REMOTE" == *"Joedaddy66/agf-sovereign-nexus"* ]]; then
        echo -e "${GREEN}✅ Repository Linked:${NC} $REMOTE"
    else
        echo -e "${YELLOW}⚠️  Repository Remote Warning:${NC} Current remote is $REMOTE (Expected Joedaddy66/agf-sovereign-nexus)"
    fi
else
    echo -e "${RED}❌ Not a Git Repository.${NC} Run: git init"
    ((ERRORS++))
fi

echo ""
echo -e "${YELLOW}======================================================${NC}"

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}🚀 SYSTEM CHECK PASSED. YOU ARE CLEARED FOR DEPLOYMENT.${NC}"
    echo -e "Execute: ${YELLOW}git add . && git commit -m 'deploy' && git push origin main${NC}"
else
    echo -e "${RED}⛔ SYSTEM CHECK FAILED with $ERRORS error(s).${NC}"
    echo -e "Rectify the missing assets above before engaging."
fi
echo -e "${YELLOW}======================================================${NC}"
