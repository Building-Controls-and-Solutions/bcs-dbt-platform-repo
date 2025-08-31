# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview
This is BCS' dbt monorepo for all data transformation happening in Snowflake. The repository implements a branch-based development workflow where developers work in DB_DEV and production runs from the main branch to DB_PROD.

### Key Features
- **Branch-based development**: Developers work in feature branches materializing to DB_DEV
- **Environment separation**: Clear separation between development (DB_DEV) and production (DB_PROD)
- **Automated CI/CD**: GitHub Actions for testing PRs and deploying to production
- **Snowflake Git integration**: Repository synced to both DB_DEV and DB_PROD databases

## Environment Setup

### Python & Package Management
- **Python**: 3.13.7 (managed via uv)
- **Package Manager**: uv (installed at ~/.local/bin/uv)
- **Virtual Environment**: .venv (Python 3.13.7)

### Key Tools
- **dbt-core**: 1.10.10 with dbt-snowflake adapter 1.10.0
- **Snowflake CLI**: 3.11.0 (available as `snow` command)
- **Context7 MCP**: Configured for AI-assisted development

## Common Development Commands

### Environment Activation
```bash
# Always activate the virtual environment first
source .venv/Scripts/activate  # Windows Git Bash
# or
.venv\Scripts\activate.bat      # Windows CMD
```

### dbt Commands
```bash
# Initialize a new dbt project
dbt init <project_name>

# Install dependencies for a project
dbt deps

# Run all models
dbt run

# Run specific models
dbt run --select model_name
dbt run --select +model_name  # Run model and all upstream dependencies
dbt run --select model_name+  # Run model and all downstream dependencies

# Test models
dbt test
dbt test --select model_name

# Generate documentation
dbt docs generate
dbt docs serve

# Compile SQL without executing
dbt compile

# Debug connection and configuration
dbt debug

# Run snapshots
dbt snapshot

# Run seeds
dbt seed
```

### Snowflake CLI Commands
```bash
# List available connections
snow connection list

# Test connection
snow connection test -c <connection_name>

# Execute SQL
snow sql -q "SELECT CURRENT_USER(), CURRENT_ROLE()" -c <connection_name>

# Execute SQL file
snow sql -f path/to/file.sql -c <connection_name>

# List databases
snow object list database -c <connection_name>

# List schemas
snow object list schema -c <connection_name> --database <db_name>
```

### Python/uv Commands
```bash
# Install packages
export PATH="$HOME/.local/bin:$PATH"
uv pip install <package_name>

# List installed packages
uv pip list

# Upgrade packages
uv pip install --upgrade <package_name>

# Create requirements file
uv pip freeze > requirements.txt
```

## Architecture & Structure

### Snowflake Infrastructure
The Snowflake infrastructure is managed via Terraform in the `C:\opt\bcs-snowflake-dba` repository:

- **Databases**: DB_DEV (development), DB_PROD (production)
- **Warehouses**: 
  - WH_INGEST (XSMALL) - Data ingestion
  - WH_DBT (SMALL) - Production dbt runs
  - WH_DBT_DEV (XSMALL) - Development dbt work
  - WH_REPORTING (SMALL) - Analytics queries
- **Roles**:
  - DBT_DEVELOPER - Development access (READ/WRITE on DB_DEV)
  - DBT_RUNNER - Production automation (READ on both DBs)
  - ESTUARY_INGESTOR - ELT operations
- **Git Integration**: 
  - Repository connected via GITHUB_API_INTEGRATION
  - Accessible at @DB_DEV.PUBLIC.DBT_PLATFORM_REPO and @DB_PROD.PUBLIC.DBT_PLATFORM_REPO

### dbt Project Structure (once initialized)
```
project_name/
├── dbt_project.yml         # Project configuration
├── profiles.yml            # Connection profiles (usually in ~/.dbt/)
├── models/                 # SQL models
│   ├── staging/           # Staging layer
│   ├── intermediate/      # Intermediate transformations
│   └── marts/            # Business logic/data marts
├── tests/                 # Custom data tests
├── macros/               # Reusable SQL macros
├── seeds/                # Static CSV data
├── snapshots/            # SCD Type 2 history
└── analyses/             # Ad-hoc analytical queries
```

## Snowflake Connection Configuration

### profiles.yml Template
```yaml
default:
  outputs:
    dev:
      type: snowflake
      account: ftb40125.us-east-1
      user: BRANDON.JACKSON  # or service account
      password: "{{ env_var('SNOWFLAKE_PASSWORD') }}"
      role: DBT_DEVELOPER
      database: DB_DEV
      warehouse: WH_DBT_DEV
      schema: PUBLIC
      threads: 4
    prod:
      type: snowflake
      account: ftb40125.us-east-1
      user: DBT_RUNNER
      password: "{{ env_var('SNOWFLAKE_PROD_PASSWORD') }}"
      role: DBT_RUNNER
      database: DB_PROD
      warehouse: WH_DBT
      schema: PUBLIC
      threads: 8
  target: dev
```

## Important Context from Snowflake DBA Repository

### Terraform Management
- All Snowflake infrastructure changes MUST be done via Terraform in `C:\opt\bcs-snowflake-dba`
- Never alter Snowflake resources directly via SQL
- The TERRAFORMER service account manages infrastructure via JWT authentication

### Service Accounts
- **ESTUARY**: For Estuary ELT operations (creates schemas/tables in both DBs)
- **DBT_RUNNER**: For production dbt runs (read-only access)
- **TERRAFORMER**: For Terraform operations (full admin via TERRAFORM_ADMIN role)

### Git Repository Access
After changes are pushed to GitHub, they're available in Snowflake:
```sql
-- List files in repository
LS @DB_DEV.PUBLIC.DBT_PLATFORM_REPO/branches/main/;

-- Execute SQL from repository
EXECUTE IMMEDIATE FROM @DB_DEV.PUBLIC.DBT_PLATFORM_REPO/branches/main/path/to/file.sql;
```

## Development Workflow

### Branch-Based Development Process
1. **Create feature branch** - Work in `feature/your-feature-name`
2. **Develop in DB_DEV** - Models materialize to `DB_DEV.BRANCH_<branch_name>` schema
3. **Test locally** - Run and test models in DB_DEV
4. **Create PR** - Submit for review when ready
5. **CI validates** - GitHub Actions runs models in `DB_DEV.PR_<number>` schema
6. **Merge to main** - After approval, changes go to production
7. **Production deployment** - DBT_RUNNER executes from main branch to DB_PROD.TRANSFORM

### Key Workflow Files
- **DEVELOPMENT_WORKFLOW.md** - Detailed developer guide
- **profiles.yml** - Connection configurations for all environments
- **.github/workflows/** - CI/CD pipeline definitions

### Environment Usage
- **Developers (BRANDON.JACKSON)**: Use DBT_DEVELOPER role, work in DB_DEV
- **CI/PR Testing**: Automated validation in temporary PR schemas
- **Production (DBT_RUNNER)**: Service account deploys main branch to DB_PROD

### Important Commands
```bash
# Set up for development
export SNOWFLAKE_USER="BRANDON.JACKSON"
export SNOWFLAKE_PASSWORD="your_password"
cd bcs_platform
dbt run --profiles-dir ..

# Run in specific environment
dbt run --target dev    # Development
dbt run --target ci     # CI/PR testing
dbt run --target prod   # Production (DBT_RUNNER only)
```

## Testing Strategy

### dbt Tests
- Add schema tests in model YAML files
- Create custom tests in the tests/ directory
- Run tests after model changes: `dbt test --select model_name`

### Snowflake Verification
```bash
# Verify deployment
snow sql -f C:/opt/bcs-snowflake-dba/sqlscripts/verify_deployment.sql -c bcsadmin_key
```

## Security Notes
- Never commit credentials to the repository
- Use environment variables for passwords
- Service account credentials are managed in Terraform
- GitHub token for Git integration must have `repo` and `read:org` permissions

## Additional Resources
- Snowflake Terraform Provider: v2.6.0 (snowflakedb/snowflake) - Documentation available via Context7 MCP
- dbt Documentation: https://docs.getdbt.com/
- Snowflake CLI: https://docs.snowflake.com/en/user-guide/snowflake-cli
- Context7 Libraries: Available via MCP for Snowflake/dbt/Terraform development assistance