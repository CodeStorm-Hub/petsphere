#!/bin/bash

# Apply PetSphere database migrations using Supabase CLI
# Usage: bash supabase/apply_migrations.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}PetSphere Database Migration Tool${NC}"
echo "=================================="

# Check if supabase CLI is installed
if ! command -v supabase &> /dev/null; then
    echo -e "${RED}Error: Supabase CLI is not installed.${NC}"
    echo "Install it with: npm install -g supabase@latest"
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "supabase/config.toml" ]; then
    echo -e "${RED}Error: supabase/config.toml not found.${NC}"
    echo "Please run this script from the project root directory."
    exit 1
fi

echo -e "${GREEN}✓ Supabase CLI found${NC}"

# List of migrations to apply (in order)
MIGRATIONS=(
    "20260508150000_complete_database_indexing.sql"
)

echo ""
echo "Pending migrations to apply:"
for migration in "${MIGRATIONS[@]}"; do
    echo "  - $migration"
done

echo ""
read -p "Apply these migrations? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Applying migrations...${NC}"

    for migration in "${MIGRATIONS[@]}"; do
        MIGRATION_PATH="supabase/migrations/$migration"

        if [ ! -f "$MIGRATION_PATH" ]; then
            echo -e "${RED}✗ Migration not found: $MIGRATION_PATH${NC}"
            exit 1
        fi

        echo "Applying: $migration"

        # Use supabase db push to apply the migration
        # Note: This assumes you have the project linked via supabase link
        cat "$MIGRATION_PATH" | supabase sql execute - || {
            echo -e "${RED}✗ Failed to apply migration: $migration${NC}"
            exit 1
        }

        echo -e "${GREEN}✓ Applied: $migration${NC}"
    done

    echo ""
    echo -e "${GREEN}✓ All migrations applied successfully!${NC}"
else
    echo -e "${YELLOW}Migration cancelled.${NC}"
    exit 0
fi
