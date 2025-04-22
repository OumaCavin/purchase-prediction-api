# Customer Purchase Prediction API

![R](https://img.shields.io/badge/R-276DC3?style=for-the-badge&logo=r&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Render](https://img.shields.io/badge/Render-46E3B7?style=for-the-badge&logo=render&logoColor=white)

A containerized REST API for customer purchase predictions deployed on Render.com.

## 🚀 Docker Deployment on Render.com

### Prerequisites
- GitHub/GitLab repository with:
  - Dockerfile
  - API files
  - Trained model
- Render.com account

### Deployment Steps

1. **Set up your repository**:
```bash
git clone https://github.com/OumaCavin/purchase-prediction-api.git
cd purchase-prediction
```

2. **Create `render.yaml`**:
```yaml
services:
  - type: web
    name: purchase-prediction-api
    dockerfile: Dockerfile
    envVars:
      - key: R_ENABLE_JIT
        value: "3"
      - key: MODEL_PATH
        value: "/app/api/purchase_model.rds"
    healthCheckPath: /health
```

3. **Deploy to Render**:
- Connect your repository
- Select "Docker" as runtime
- Render will auto-detect your Dockerfile

## 🔌 API Endpoints

### Prediction Endpoint
```http
POST /predict
Content-Type: application/json

{
  "Age": 35,
  "Gender": "Male",  # "Male" or "Female"
  "EstimatedSalary": 50000
}
```

Response:
```json
{
  "success": true,
  "probability": 0.8723,
  "prediction": "Likely to purchase",
  "model_version": "1.0"
}
```

### Health Check
```http
GET /health
```

## Project Structure
```
purchase-prediction/
├── Dockerfile             # Container configuration
├── render.yaml            # Render deployment config
├── api/
│   ├── plumber.R          # API endpoints
│   └── purchase_model.rds # Trained model
└── README.md
```

## 💻 Local Development

1. **Build and run**:
```bash
docker build -t purchase-api .
docker run -p 8000:8000 purchase-api
```

2. **Test endpoints**:
```bash
curl -X POST http://localhost:8000/predict \
  -H "Content-Type: application/json" \
  -d '{"Age":35,"Gender":"Male","EstimatedSalary":50000}'
```

## Key Features

### Deployment
- Dockerized for consistent environments
- Automatic scaling on Render
- Health checks and monitoring

### API
- Input validation (Age 18-100, Gender Male/Female)
- JIT compilation for performance
- Detailed error responses
- Swagger documentation at `/__docs__`

## Monitoring
- View logs in Render dashboard
- Health endpoint reports:
  - Model status
  - System info
  - JIT compilation level

## Scaling Options
1. **Render Paid Plans**:
   - Custom domains
   - Auto-scaling
   - Persistent storage

2. **Alternative Hosting**:
   - AWS ECS
   - Google Cloud Run
   - Azure Container Instances

## Contributors
- [Cavin Otieno](mailto:cavin.otieno012@gmail.com)  
[![GitHub](https://img.shields.io/badge/GitHub-100000?style=flat&logo=github)](https://github.com/OumaCavin)

## License
This project is open source under the [MIT License](https://choosealicense.com/licenses/mit/)
