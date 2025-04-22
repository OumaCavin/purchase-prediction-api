# Dockerfile
FROM rstudio/plumber

# Set environment variables
ENV R_ENABLE_JIT=3 \
    MODEL_PATH=/app/api/purchase_model.rds \
    PORT=8000

# Set environment variable
#ENV MODEL_PATH=/app/api/purchase_model.rds

# Install dependencies first (better layer caching)
RUN R -e "install.packages(c('plumber', 'dplyr', 'caret'), repos='https://cloud.r-project.org')"

# Create directory structure
RUN mkdir -p /app/api

# Copy application files
#COPY api/ /app/api/

# Copy required files
COPY api/plumber.R /app/api/
COPY api/purchase_model.rds /app/api/

# Expose port and run
EXPOSE 8000

# Run the API
CMD ["Rscript", "/app/api/plumber.R"]





