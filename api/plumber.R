# Customer Purchase Prediction API using Plumber - Render.com Optimized

#* @apiTitle Purchase Prediction API
#* @apiDescription Predicts customer purchase probability from demographic data
#* @apiVersion 1.0.0
#* @apiContact list(name = "API Support", email = "cavin.otieno012@gmail.com")
#* @apiLicense list(name = "MIT")

# Load required libraries
library(plumber)
library(caret)
library(dplyr)

# Load model with robust path handling
model_path <- Sys.getenv("MODEL_PATH", "/app/api/purchase_model.rds")
model_path <- normalizePath(model_path, mustWork = FALSE)
if (!file.exists(model_path)) {
  stop(paste("Model file not found at:", model_path))
}
model <- readRDS(model_path)

# Verify JIT status
jit_status <- as.numeric(Sys.getenv("R_ENABLE_JIT", "0"))
if (jit_status >= 2) {
  message("JIT compilation enabled at level ", jit_status)
} else {
  warning("JIT disabled - performance may be affected")
}

#* Log all requests
#* @filter logger
function(req) {
  cat(
    sprintf("[%s] %s %s - %s\n",
      format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
      req$REQUEST_METHOD,
      req$PATH_INFO,
      req$REMOTE_ADDR
    )
  )
  forward()
}

#* Health check endpoint
#* @get /health
function() {
  list(
    status = "OK",
    time = Sys.time(),
    model = list(
      version = "1.0",
      loaded = exists("model"),
      path = model_path,
      size = file.size(model_path)
    ),
    system = list(
      r_version = R.version.string,
      jit_enabled = jit_status,
      platform = R.version$platform
    )
  )
}

#* Predict purchase probability
#* @param Age:int Customer age (18-100)
#* @param Gender:character Customer gender (Male/Female)
#* @param EstimatedSalary:number Monthly salary (KES)
#* @response 200 Returns prediction results
#* @response 400 Bad request if validation fails
#* @post /predict
function(Age, Gender, EstimatedSalary, res) {
  tryCatch({
    # Convert and validate inputs
    Age <- as.numeric(Age)
    EstimatedSalary <- as.numeric(EstimatedSalary)
    Gender <- as.character(Gender)
    
    if (is.na(Age) || Age < 18 || Age > 100) {
      res$status <- 400
      return(list(error = "Age must be a number between 18-100"))
    }
    if (is.na(EstimatedSalary) || EstimatedSalary < 0) {
      res$status <- 400
      return(list(error = "Salary must be a positive number"))
    }
    if (!Gender %in% c("Male", "Female")) {
      res$status <- 400
      return(list(error = "Gender must be 'Male' or 'Female'"))
    }
    
    # Make prediction
    prediction <- predict(
      model,
      data.frame(
        Age = Age,
        Gender = ifelse(Gender == "Male", 1, 0),
        EstimatedSalary = EstimatedSalary
      ),
      type = "response"
    )
    
    # Return response
    list(
      success = TRUE,
      probability = round(prediction, 4),
      prediction = ifelse(prediction > 0.5, 1, 0),
      model_version = "1.0"
    )
    
  }, error = function(e) {
    res$status <- 500
    return(list(
      error = "Internal server error",
      details = conditionMessage(e)
    ))
  })
}

#* @plumber
function(pr) {
  pr %>%
    pr_set_docs("swagger") %>%
    pr_set_api_spec(function(spec) {
      spec$info$description <- paste(
        "Production API |",
        "Model:", basename(model_path),
        "| JIT Level:", jit_status
      )
      spec
    })
}

# Start server if not in test environment
if (!identical(Sys.getenv("TEST_ENV"), "true")) {
  pr <- plumber::plumb(environment())
  pr$run(
    host = '0.0.0.0',
    port = as.numeric(Sys.getenv("PORT", 8000)),
    swagger = TRUE
  )
}