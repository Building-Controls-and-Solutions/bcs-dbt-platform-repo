# Snowflake dbt Projects Usage Guide

## Overview
Snowflake now recognizes this repository as official dbt Projects that can be executed directly within Snowflake.

## Available dbt Projects

| Project Name | Database | Schema | Description |
|-------------|----------|---------|-------------|
| BCS_DBT_PROJECT_DEV | DB_DEV | TRANSFORM | Development environment for testing |
| BCS_DBT_PROJECT_PROD | DB_PROD | TRANSFORM | Production environment |

## Executing dbt Commands

### Development (as DBT_DEVELOPER)
```sql
USE ROLE DBT_DEVELOPER;
USE DATABASE DB_DEV;
USE WAREHOUSE WH_DBT_DEV;

-- List all models
EXECUTE DBT PROJECT DB_DEV.TRANSFORM.BCS_DBT_PROJECT_DEV
  ARGS = 'list';

-- Run all models
EXECUTE DBT PROJECT DB_DEV.TRANSFORM.BCS_DBT_PROJECT_DEV
  ARGS = 'run';

-- Run specific model
EXECUTE DBT PROJECT DB_DEV.TRANSFORM.BCS_DBT_PROJECT_DEV
  ARGS = 'run --select stg_p21__orders';

-- Test models
EXECUTE DBT PROJECT DB_DEV.TRANSFORM.BCS_DBT_PROJECT_DEV
  ARGS = 'test';

-- Generate documentation
EXECUTE DBT PROJECT DB_DEV.TRANSFORM.BCS_DBT_PROJECT_DEV
  ARGS = 'docs generate';
```

### Production (as DBT_RUNNER)
```sql
USE ROLE DBT_RUNNER;
USE DATABASE DB_PROD;
USE WAREHOUSE WH_DBT;

-- Run all production models
EXECUTE DBT PROJECT DB_PROD.TRANSFORM.BCS_DBT_PROJECT_PROD
  ARGS = 'run';

-- Run tests in production
EXECUTE DBT PROJECT DB_PROD.TRANSFORM.BCS_DBT_PROJECT_PROD
  ARGS = 'test';
```

## Refreshing Git Repository

When new changes are pushed to GitHub:

```sql
USE ROLE ACCOUNTADMIN;

-- Refresh development repository
ALTER GIT REPOSITORY DB_DEV.PUBLIC.DBT_PLATFORM_REPO FETCH;

-- Refresh production repository  
ALTER GIT REPOSITORY DB_PROD.PUBLIC.DBT_PLATFORM_REPO FETCH;
```

## Recreating dbt Projects

If configuration changes require recreating the project:

```sql
USE ROLE ACCOUNTADMIN;
USE DATABASE DB_DEV;
USE SCHEMA TRANSFORM;

-- Drop and recreate
DROP DBT PROJECT IF EXISTS BCS_DBT_PROJECT_DEV;

CREATE DBT PROJECT BCS_DBT_PROJECT_DEV
  FROM '@DB_DEV.PUBLIC.DBT_PLATFORM_REPO/branches/main/bcs_platform'
  COMMENT = 'BCS dbt project for development environment';

GRANT USAGE ON DBT PROJECT BCS_DBT_PROJECT_DEV TO ROLE DBT_DEVELOPER;
```

## Viewing Repository Contents

```sql
-- List files in repository
LS @DB_DEV.PUBLIC.DBT_PLATFORM_REPO/branches/main/bcs_platform/;

-- View specific file
SELECT $1 
FROM @DB_DEV.PUBLIC.DBT_PLATFORM_REPO/branches/main/bcs_platform/dbt_project.yml;
```

## Scheduling Production Runs

To schedule automated production runs, create a task:

```sql
USE ROLE DBT_RUNNER;
USE DATABASE DB_PROD;

CREATE OR REPLACE TASK DBT_DAILY_RUN
  WAREHOUSE = WH_DBT
  SCHEDULE = 'USING CRON 0 2 * * * UTC'  -- 2 AM UTC daily
  AS
    EXECUTE DBT PROJECT DB_PROD.TRANSFORM.BCS_DBT_PROJECT_PROD
      ARGS = 'run';

-- Enable the task
ALTER TASK DBT_DAILY_RUN RESUME;
```

## Troubleshooting

### Project Not Recognizing Changes
1. Fetch latest from Git repository
2. Drop and recreate the dbt project

### Permission Issues
- Ensure you're using the correct role (DBT_DEVELOPER or DBT_RUNNER)
- Check warehouse grants

### Model Failures
- View output archive URL in execution results
- Check source data availability in ING_ schemas
- Verify database and schema permissions

## Next Steps

1. Add more staging models for other source systems
2. Create intermediate transformation layers
3. Build data marts for business users
4. Set up incremental models for large tables
5. Implement data quality tests
6. Configure CI/CD pipelines with GitHub Actions