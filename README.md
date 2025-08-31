# BCS DBT Platform

This is the DBT project for the BCS Snowflake data platform.

## Project Structure

```
├── analyses/           # Analytical SQL queries (not models)
├── data/              # CSV files for seeding static data
├── macros/            # Reusable SQL snippets and functions
├── models/            # DBT models organized by layer
│   ├── staging/       # Raw data preparation
│   ├── intermediate/  # Business logic transformations
│   └── marts/         # Final presentation layer
├── snapshots/         # SCD Type 2 history tracking
├── tests/            # Custom data tests
├── dbt_project.yml   # Main project configuration
└── packages.yml      # External package dependencies
```

## Getting Started

1. Install dependencies:
   ```bash
   dbt deps
   ```

2. Test connection:
   ```bash
   dbt debug --target dev
   ```

3. Run models:
   ```bash
   dbt run --target dev
   ```

4. Run tests:
   ```bash
   dbt test --target dev
   ```

## Development Workflow

1. Create feature branch
2. Develop models in `models/` directory
3. Test locally using `--target dev`
4. Create pull request
5. Merge to main for production deployment

## Targets

- `dev`: Development environment (DB_DEV)
- `prod`: Production environment (DB_PROD)

## Resources

- [DBT Documentation](https://docs.getdbt.com/)
- [Snowflake DBT Projects](https://docs.snowflake.com/en/user-guide/data-engineering/dbt-projects-on-snowflake)