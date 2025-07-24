# Deployment Setup Guide

## Database Configuration

After consolidating the database configuration, you need to set up the `DATABASE_URL` environment variable for deployment.

### Setting up DATABASE_URL Secret

1. **For Kamal Deployment:**

   Add the `DATABASE_URL` to your Kamal secrets:

   ```bash
   bin/kamal secrets set DATABASE_URL "postgresql://username:password@host:port/database_name"
   ```

   Example:
   ```bash
   bin/kamal secrets set DATABASE_URL "postgresql://myapp:myapp_password@localhost:5432/myapp_production"
   ```

2. **For Heroku Deployment:**

   Set the environment variable in Heroku:

   ```bash
   heroku config:set DATABASE_URL="postgresql://username:password@host:port/database_name"
   ```

   Or use Heroku's automatic database provisioning:
   ```bash
   heroku addons:create heroku-postgresql:mini
   ```

3. **For Other Platforms:**

   Set the `DATABASE_URL` environment variable according to your platform's documentation.

### DATABASE_URL Format

The `DATABASE_URL` should follow this format:
```
postgresql://username:password@host:port/database_name
```

Components:
- `username`: Database user
- `password`: Database password
- `host`: Database server hostname or IP
- `port`: Database port (usually 5432 for PostgreSQL)
- `database_name`: Name of your database

### Example Configurations

**Local Development:**
```
postgresql://myapp:password@localhost:5432/myapp_development
```

**Production (Kamal):**
```
postgresql://myapp:secure_password@192.168.0.2:5432/myapp_production
```

**Heroku:**
```
postgresql://username:password@host.amazonaws.com:5432/database_name
```

### Verification

After setting the `DATABASE_URL`, verify the connection:

1. **Test database connection:**
   ```bash
   bin/rails db:version
   ```

2. **Run migrations:**
   ```bash
   bin/rails db:migrate
   ```

3. **Check environment variables:**
   ```bash
   bin/kamal secrets list
   ```

### Security Notes

- Never commit `DATABASE_URL` to version control
- Use strong passwords for production databases
- Consider using connection pooling for high-traffic applications
- Regularly rotate database credentials

### Troubleshooting

**Common Issues:**

1. **Connection refused:** Check if the database server is running and accessible
2. **Authentication failed:** Verify username and password
3. **Database does not exist:** Create the database first
4. **Permission denied:** Ensure the user has proper permissions

**Debug Commands:**
```bash
# Test database connection
bin/rails dbconsole

# Check environment variables
bin/rails runner "puts ENV['DATABASE_URL']"

# View Kamal secrets (without values)
bin/kamal secrets list
``` 