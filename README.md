# Customer Purchase Prediction API

![R](https://img.shields.io/badge/R-276DC3?style=for-the-badge&logo=r&logoColor=white)
![Plumber](https://img.shields.io/badge/API-FF6C37?style=for-the-badge&logo=swagger&logoColor=white)
![Render](https://img.shields.io/badge/Render-46E3B7?style=for-the-badge&logo=render&logoColor=white)

A production-ready REST API for customer purchase predictions, deployed on Render.com's free tier.

## 🚀 Deployment to Render.com

### Prerequisites
- GitHub/GitLab account
- Render.com account (free tier available)
- [API files](#project-structure) committed to Git


### Step-by-Step Deployment

1. **Prepare your repository**:
   ```bash
   # Clone your project
   git clone https://github.com/OumaCavin/purchase-prediction.git
   cd purchase-prediction
   ```

2. **Create `render.yaml`** in your project root:
   ```yaml
   services:
     - type: web
       name: purchase-prediction-api
       runtime: r
       env: r
       buildCommand: |
         R -e "install.packages('plumber')"
         R -e "install.packages('caret')"
       startCommand: R -e "plumber::plumb('api/plumber.R')$run(port=$PORT, host='0.0.0.0')"
   ```

3. **Commit and push**:
   ```bash
   git add render.yaml
   git commit -m "Add Render config"
   git push
   ```

4. **Deploy on Render**:
   - Go to [Render Dashboard](https://dashboard.render.com)
   - Click "New" → "Web Service"
   - Connect your repository
   - Select "Existing configuration" (it will detect `render.yaml`)
   - Click "Create Web Service"

## 🔌 API Endpoints

### Prediction Endpoint
```http
POST https://purchase-prediction-api.onrender.com/predict
Content-Type: application/json

{
  "Age": 35,
  "Gender": 1,
  "EstimatedSalary": 50000
}
```

Response:
```json
{
  "probability": 0.87,
  "prediction": 1
}
```

### Health Check
```http
GET https://purchase-prediction-api.onrender.com/health
```
### Key Features:

1. **Render Configuration**:
   - Auto-installs R dependencies
   - Sets health check endpoint
   - Configures environment variables
   - Enables automatic redeploys on Git pushes

2. **Plumber API**:
   - Production-ready health check
   - Type validation for parameters
   - Versioned API responses
   - OpenAPI schema generation
   - Error handling built-in

## Project Structure
```
purchase-prediction/
├── api/
│   ├── plumber.R          # API endpoint definitions
│   └── purchase_model.rds # Trained model
├── render.yaml            # Render configuration
└── README.md
```

## 💻 Local Development

1. Test your API locally:
   ```bash
   Rscript -e "plumber::plumb('api/plumber.R')$run(port=8000)"
   ```

2. Test endpoints:
   ```bash
   curl -X POST http://localhost:8000/predict \
     -H "Content-Type: application/json" \
     -d '{"Age":35,"Gender":1,"EstimatedSalary":50000}'
   ```

## 🔍 Monitoring
- View logs: Render.com dashboard → Your service → Logs
- Metrics: Automatic on Render.com free tier

## 📈 Scaling
- Upgrade to paid plan for:
  - Zero-downtime deploys
  - Auto-scaling
  - Custom domains with HTTPS

## Contributors
- [Cavin Otieno](mailto:cavin.otieno012@gmail.com)  
[![GitHub](https://img.shields.io/badge/GitHub-100000?style=flat&logo=github)](https://github.com/OumaCavin)

## License
This project is open source under the [MIT License](https://choosealicense.com/licenses/mit/)
