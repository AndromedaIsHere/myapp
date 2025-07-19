# OpenAI API Configuration

This application uses OpenAI's API for generating thumbnails. Here's how to configure it:

## Environment Variables

Create a `.env` file in your project root with the following variables:

```bash
# Required
OPENAI_API_KEY=your_openai_api_key_here

# Optional
OPENAI_API_BASE_URL=https://api.openai.com
OPENAI_MODEL=gpt-image-1
OPENAI_TIMEOUT=30
OPENAI_MAX_RETRIES=3
```

## Rails Credentials (Production)

For production environments, you can store the API key in Rails credentials:

```bash
EDITOR="nano" bin/rails credentials:edit
```

Add this to the credentials file:
```yaml
openai:
  api_key: your_openai_api_key_here
```

## Configuration Priority

The application will look for the API key in this order:
1. Rails credentials (production)
2. Environment variable `OPENAI_API_KEY`

## Getting an OpenAI API Key

1. Go to https://platform.openai.com/
2. Sign up or log in
3. Navigate to API Keys section
4. Create a new API key
5. Copy the key and add it to your configuration

## Security Notes

- Never commit your actual API key to version control
- The `.env` file is already in `.gitignore`
- Use Rails credentials for production deployments
- Consider using environment-specific credentials for different environments 