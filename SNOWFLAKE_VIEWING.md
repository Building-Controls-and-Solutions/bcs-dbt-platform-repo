# Viewing Repository in Snowflake Snowsight

Once this repository is pushed to GitHub and synced with Snowflake, you can explore it using the following SQL commands in Snowsight:

## List Repository Contents

```sql
-- List all files in the main branch
LS @DB_DEV.PUBLIC.DBT_PLATFORM_REPO/branches/main/;

-- List all available branches
LS @DB_DEV.PUBLIC.DBT_PLATFORM_REPO/branches/;

-- List models directory
LS @DB_DEV.PUBLIC.DBT_PLATFORM_REPO/branches/main/bcs_platform/models/;
```

## View File Contents

```sql
-- View the dbt project configuration
SELECT $1 
FROM @DB_DEV.PUBLIC.DBT_PLATFORM_REPO/branches/main/bcs_platform/dbt_project.yml;

-- View the staging model for P21 orders
SELECT $1 
FROM @DB_DEV.PUBLIC.DBT_PLATFORM_REPO/branches/main/bcs_platform/models/staging/p21/stg_p21__orders.sql;

-- View the source configuration
SELECT $1 
FROM @DB_DEV.PUBLIC.DBT_PLATFORM_REPO/branches/main/bcs_platform/models/staging/_sources.yml;

-- View profiles configuration
SELECT $1 
FROM @DB_DEV.PUBLIC.DBT_PLATFORM_REPO/branches/main/profiles.yml;
```

## Execute SQL from Repository

```sql
-- Execute a model directly from the repository (be careful with this!)
EXECUTE IMMEDIATE FROM @DB_DEV.PUBLIC.DBT_PLATFORM_REPO/branches/main/bcs_platform/models/staging/p21/stg_p21__orders.sql;
```

## Check Feature Branches

```sql
-- List files in a feature branch (when available)
LS @DB_DEV.PUBLIC.DBT_PLATFORM_REPO/branches/feature/add-customer-marts/;
```

## Repository in Production

The same repository is also available in DB_PROD:

```sql
-- List files in production
LS @DB_PROD.PUBLIC.DBT_PLATFORM_REPO/branches/main/;
```

## Refresh Repository

If changes aren't showing up:

```sql
-- Refresh the repository to get latest changes
ALTER GIT REPOSITORY DB_DEV.PUBLIC.DBT_PLATFORM_REPO FETCH;
ALTER GIT REPOSITORY DB_PROD.PUBLIC.DBT_PLATFORM_REPO FETCH;
```

## Notes

- The repository syncs automatically, but there may be a small delay
- Both DB_DEV and DB_PROD have access to the same repository
- Only the main branch should be used for production executions
- Feature branches are available for review and testing