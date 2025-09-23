# Deployment Configuration

This document describes the configuration needed for deploying HousekeepingBook.

## Environment Variables

### Development Environment

For local development, create a `.env` file in the project root (see `.env.example`):

```bash
# Database
DEV_DB_USER=postgres
DEV_DB_PASSWORD=your_password
DEV_DB_HOST=localhost

# Secret Key (generate with: mix phx.gen.secret)
DEV_SECRET_KEY_BASE=your_dev_secret
```

### Test Environment

```bash
# Database
TEST_DB_USER=postgres
TEST_DB_PASSWORD=your_password
TEST_DB_HOST=localhost

# Secret Key (generate with: mix phx.gen.secret)
TEST_SECRET_KEY_BASE=your_test_secret
```

### Production Environment

Set these environment variables on your production server:

#### Required Variables

- `DATABASE_URL` - PostgreSQL connection string (e.g., `ecto://user:pass@host/database`)
- `SECRET_KEY_BASE` - Production secret key (generate with `mix phx.gen.secret`)
- `PHX_HOST` - Your domain name (e.g., `example.com`)
- `DOMAINS` - Comma-separated list of domains for SSL (e.g., `example.com,www.example.com`)
- `EMAILS` - Comma-separated list of admin emails for SSL certificates

#### Optional Variables

- `PORT` - HTTP port (default: 4000)
- `DEPLOY_HTTP_PORT` - Deployment HTTP port (default: 4000)
- `DEPLOY_HTTPS_PORT` - Deployment HTTPS port (default: 4040)
- `CERT_PATH` - SSL certificate storage path (default: `/opt/site_encrypt_db`)
- `APP_DIR` - Application directory for deployment scripts (default: `/opt/housekeeping_book`)
- `POSTMARK_API_KEY` - Postmark API key for sending emails
- `MAILER_SENDER` - Email sender address (e.g., `noreply@example.com`)
- `PHX_SERVER` - Set to `true` when running with `mix release`

## Deployment Scripts

The deployment scripts (`deploy.sh` and `rollback.sh`) use the `APP_DIR` environment variable to locate the application. Set this to match your server configuration.

## Security Notes

1. **Never commit `.env` files to version control**
2. **Always use strong, unique secrets in production**
3. **Rotate secrets regularly**
4. **Use environment variables or secure secret management systems**

## Generating Secrets

To generate secure secrets for your application:

```bash
mix phx.gen.secret
```

Or using OpenSSL:

```bash
openssl rand -base64 48
```