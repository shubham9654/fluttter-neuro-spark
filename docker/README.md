# Docker Setup for NeuroSpark

## Quick Start

### Build and Run Production Web App

```bash
docker-compose up web
```

The app will be available at: http://localhost:8080

Or build and run manually:

```bash
# Build
docker build -t neuro_spark:latest .

# Run
docker run -p 8080:80 neuro_spark:latest
```

## Docker Compose Service

### `web` - Production Web App
- Builds Flutter web app
- Serves with nginx
- Port: 8080
- Health check enabled

## Environment Variables

You can set environment variables in `docker-compose.yml`:

```yaml
environment:
  - FLUTTER_ENV=production
  - FIREBASE_API_KEY=your_key
```

## Building for Different Platforms

### Web (Current)
The Dockerfile builds for web platform and serves with nginx.

### Android/iOS Builds
For Android and iOS builds, use:
- Local development environment
- CI/CD services (GitHub Actions, Codemagic, etc.)
- See `scripts/build_apk.bat` or `scripts/build_apk.sh` for local Android builds

## Troubleshooting

### Port Already in Use
Change the port in `docker-compose.yml`:
```yaml
ports:
  - "3000:80"  # Use port 3000 instead
```

### Build Fails
1. Check Flutter version compatibility
2. Ensure all dependencies are in `pubspec.yaml`
3. Check Docker has enough resources (memory/CPU)

### Hot Reload Not Working
In development mode, ensure volumes are properly mounted:
```yaml
volumes:
  - .:/app
```

## Production Deployment

### Build and Push to Registry

```bash
# Build
docker build -t your-registry/neuro_spark:latest .

# Tag
docker tag your-registry/neuro_spark:latest your-registry/neuro_spark:v1.0.0

# Push
docker push your-registry/neuro_spark:latest
docker push your-registry/neuro_spark:v1.0.0
```

### Deploy to Cloud

#### AWS ECS/Fargate
```bash
# Build and push to ECR
aws ecr get-login-password | docker login --username AWS --password-stdin your-ecr-url
docker build -t your-ecr-url/neuro_spark:latest .
docker push your-ecr-url/neuro_spark:latest
```

#### Google Cloud Run
```bash
# Build and push to GCR
gcloud builds submit --tag gcr.io/your-project/neuro_spark
gcloud run deploy neuro-spark --image gcr.io/your-project/neuro_spark
```

#### Azure Container Instances
```bash
# Build and push to ACR
az acr build --registry your-registry --image neuro_spark:latest .
```

## Health Check

The production container includes a health check endpoint:
- URL: http://localhost:8080/health
- Returns: `healthy` if the server is running

## Notes

- The production build uses nginx for serving static files
- Development mode supports hot reload
- All Flutter dependencies are cached in a volume
- The web build is optimized for production

