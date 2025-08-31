# dbt Development Workflow

## Overview
This document describes the branch-based development workflow for the BCS dbt platform. Developers work in feature branches, materializing models to DB_DEV for testing, then submit pull requests to merge into the main branch for production deployment.

## Environment Architecture

### Databases
- **DB_DEV**: Development database where developers materialize and test their models
- **DB_PROD**: Production database where the main branch models are materialized

### Source Data
- **ING_* Schemas**: Ingestion schemas containing raw data from source systems
  - Available in both DB_DEV and DB_PROD
  - Developers can read from either based on testing needs
  - Production always reads from DB_PROD

### Roles
- **DBT_DEVELOPER**: Can read from both DBs, write to DB_DEV only
- **DBT_RUNNER**: Service account for production, read-only access to both DBs, executes from main branch

## Development Workflow

### 1. Initial Setup

```bash
# Clone the repository
git clone https://github.com/Building-Controls-and-Solutions/bcs-dbt-platform-repo.git
cd bcs-dbt-platform-repo

# Activate virtual environment
source .venv/Scripts/activate  # Windows Git Bash

# Set environment variables
export SNOWFLAKE_USER="BRANDON.JACKSON"  # Your Snowflake username
export SNOWFLAKE_PASSWORD="your_password"
export DBT_TARGET="dev"  # Use dev profile
```

### 2. Create Feature Branch

```bash
# Create and checkout feature branch
git checkout -b feature/add-customer-marts

# Your dbt models will materialize to DB_DEV.BRANCH_FEATURE_ADD_CUSTOMER_MARTS schema
```

### 3. Develop Models

```bash
# Navigate to project
cd bcs_platform

# Test connection
dbt debug --profiles-dir ..

# Run models in your branch schema
dbt run --profiles-dir ..

# Run specific models
dbt run --select stg_p21__orders --profiles-dir ..

# Test models
dbt test --profiles-dir ..

# Generate documentation
dbt docs generate --profiles-dir ..
dbt docs serve --profiles-dir ..
```

### 4. Model Development Best Practices

#### Reading Source Data
Models should use the `source_database` variable to read from the appropriate database:

```sql
-- In staging models
with source as (
    select * from {{ source('p21_ingestion', 'OE_HDR') }}
    -- This automatically uses var('source_database') which is DB_DEV for dev/branch targets
)
```

#### Materializations by Environment
- **Development (DB_DEV)**: Views for faster iteration
- **Production (DB_PROD)**: Tables for better performance

This is handled automatically by the dbt_project.yml configuration:
```yaml
intermediate:
  +materialized: "{{ 'view' if target.name != 'prod' else 'table' }}"
```

### 5. Testing Your Changes

```bash
# Run all models and tests
dbt build --profiles-dir ..

# Run only changed models
dbt run --select state:modified+ --state ./target --profiles-dir ..

# Check source freshness
dbt source freshness --profiles-dir ..
```

### 6. Create Pull Request

```bash
# Commit your changes
git add .
git commit -m "Add customer mart models"

# Push to GitHub
git push origin feature/add-customer-marts
```

Create PR on GitHub with:
- Description of changes
- Test results
- Any schema changes
- Performance considerations

### 7. CI/CD Process

When a PR is created:
1. CI runs dbt models in a temporary schema (PR_123)
2. Tests are executed
3. Documentation is generated
4. Results are posted to PR

When PR is merged to main:
1. DBT_RUNNER service account executes from main branch
2. Models are materialized to DB_PROD.TRANSFORM schema
3. Production documentation is updated

## Production Deployment

### Automated Deployment (Recommended)

The DBT_RUNNER service account automatically:
1. Pulls latest from main branch via Snowflake Git integration
2. Executes `dbt run --target prod`
3. Materializes all models to DB_PROD

### Manual Deployment (If Needed)

```bash
# Only DBT_RUNNER service account should do this
export SNOWFLAKE_PROD_USER="DBT_RUNNER"
export SNOWFLAKE_PROD_PASSWORD="service_account_password"
export DBT_TARGET="prod"

# Run production deployment
dbt run --target prod --profiles-dir ..
```

## Working with Snowflake Git Integration

### Viewing Repository Contents
```sql
-- List files in the repository
LS @DB_DEV.PUBLIC.DBT_PLATFORM_REPO/branches/main/;

-- View specific branch
LS @DB_DEV.PUBLIC.DBT_PLATFORM_REPO/branches/feature/add-customer-marts/;
```

### Executing SQL from Repository
```sql
-- Execute a model directly from the repository
EXECUTE IMMEDIATE FROM @DB_DEV.PUBLIC.DBT_PLATFORM_REPO/branches/main/bcs_platform/models/staging/p21/stg_p21__orders.sql;
```

## Schema Naming Conventions

| Environment | Target | Database | Schema Pattern | Example |
|------------|--------|----------|----------------|---------|
| Development | dev | DB_DEV | TRANSFORM | DB_DEV.TRANSFORM |
| Feature Branch | user_branch | DB_DEV | BRANCH_{branch_name} | DB_DEV.BRANCH_FEATURE_ADD_CUSTOMER_MARTS |
| CI/PR | ci | DB_DEV | PR_{pr_number} | DB_DEV.PR_123 |
| Production | prod | DB_PROD | TRANSFORM | DB_PROD.TRANSFORM |

## Troubleshooting

### Connection Issues
```bash
# Test connection
dbt debug --profiles-dir ..

# Check Snowflake role and warehouse
snow sql -q "SELECT CURRENT_USER(), CURRENT_ROLE(), CURRENT_WAREHOUSE()" -c bcsadmin_key
```

### Permission Issues
- Ensure you have DBT_DEVELOPER role
- Check warehouse access (WH_DBT_DEV for development)
- Verify database grants

### Model Failures
```bash
# Check compiled SQL
dbt compile --profiles-dir ..

# View compiled SQL in target/compiled/bcs_platform/models/

# Run with verbose logging
dbt run --debug --profiles-dir ..
```

## Best Practices

1. **Always work in feature branches** - Never commit directly to main
2. **Test locally first** - Run models in DB_DEV before creating PR
3. **Use source control** - Commit frequently with clear messages
4. **Document your models** - Add descriptions in schema.yml files
5. **Follow naming conventions** - Use consistent prefixes (stg_, int_, mart_)
6. **Write tests** - Add data quality tests for critical models
7. **Review compiled SQL** - Check the target/ directory to understand generated queries
8. **Monitor performance** - Use Snowflake query history to identify slow models

## Support

For issues or questions:
1. Check this documentation
2. Review CLAUDE.md for environment setup
3. Consult dbt documentation: https://docs.getdbt.com/
4. Check Snowflake query history for error details