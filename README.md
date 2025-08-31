# BCS dbt Platform Repository

## Overview
This repository contains all dbt (data build tool) transformations for BCS's Snowflake data platform. It implements a modern data transformation workflow with environment separation, automated testing, and continuous deployment.

## 🏗️ Architecture

### Databases
- **DB_DEV**: Development environment for testing and iteration
- **DB_PROD**: Production environment with validated, business-ready data

### Data Flow
```
Source Systems → Estuary → ING_* Schemas → dbt Transformations → Business Data Models
```

### Key Schemas
- **ING_P21**: Prophet 21 ERP data ingestion
- **ING_BRONZE**: Raw data archive layer
- **TRANSFORM**: Transformed business data models

## 🚀 Quick Start

### Prerequisites
- Python 3.13.7 (managed via uv)
- Snowflake access with DBT_DEVELOPER role
- GitHub repository access

### Setup
```bash
# Clone repository
git clone https://github.com/Building-Controls-and-Solutions/bcs-dbt-platform-repo.git
cd bcs-dbt-platform-repo

# Activate virtual environment
source .venv/Scripts/activate  # Windows Git Bash

# Set credentials
export SNOWFLAKE_USER="YOUR_USERNAME"
export SNOWFLAKE_PASSWORD="YOUR_PASSWORD"

# Test connection
cd bcs_platform
dbt debug --profiles-dir ..

# Run models
dbt run --profiles-dir ..
```

## 📁 Project Structure
```
bcs_platform/
├── models/
│   ├── staging/        # Raw data cleaning and standardization
│   │   └── p21/       # P21 ERP staging models
│   ├── intermediate/   # Business logic and transformations
│   └── marts/         # Business-ready data models
├── tests/             # Data quality tests
├── macros/            # Reusable SQL functions
├── snapshots/         # Historical data tracking
└── dbt_project.yml    # Project configuration
```

## 🔄 Development Workflow

### Branch-Based Development
1. Create feature branch: `git checkout -b feature/your-feature`
2. Develop models (materializes to `DB_DEV.BRANCH_*`)
3. Test locally: `dbt test --profiles-dir ..`
4. Create pull request
5. CI runs validation (creates `DB_DEV.PR_*` schema)
6. Merge to main → Auto-deploy to production

### Environment Matrix
| Environment | Database | Schema Pattern | Used By |
|------------|----------|---------------|---------|
| Development | DB_DEV | TRANSFORM | Developers |
| Feature Branch | DB_DEV | BRANCH_* | Developers |
| Pull Request | DB_DEV | PR_* | CI/CD |
| Production | DB_PROD | TRANSFORM | DBT_RUNNER |

## 📊 Data Sources

### P21 ERP System (`ING_P21`)
- **BCS_COA**: Chart of Accounts
- **OE_HDR**: Order Entry Headers
- **CURRENCY_LINE**: Currency information
- Additional tables documented in `models/staging/_sources.yml`

## 🔧 Configuration

### Connection Profiles
See `profiles.yml` for environment-specific connection settings.

### Project Settings
See `dbt_project.yml` for model configurations and project variables.

## 📚 Documentation

- **[DEVELOPMENT_WORKFLOW.md](DEVELOPMENT_WORKFLOW.md)**: Detailed developer guide
- **[CLAUDE.md](CLAUDE.md)**: AI assistant context and guidance
- **dbt docs**: Generate with `dbt docs generate && dbt docs serve`

## 🤖 CI/CD

### Pull Request Validation
- Triggered on PRs to main branch
- Runs models in isolated schema
- Executes all tests
- Posts results as PR comment

### Production Deployment
- Triggered on merge to main
- DBT_RUNNER service account execution
- Full test suite
- Documentation generation

## 🔐 Security

- Never commit credentials
- Use environment variables for passwords
- Service accounts managed via Terraform
- Role-based access control (RBAC)

## 📞 Support

For issues or questions:
1. Check documentation in this repository
2. Review [dbt documentation](https://docs.getdbt.com/)
3. Contact the data platform team

## 🏷️ Version
- **dbt-core**: 1.10.10
- **dbt-snowflake**: 1.10.0
- **Python**: 3.13.7

---
*Managed by Building Controls and Solutions*