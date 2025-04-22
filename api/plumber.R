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

# Load model using environment variable with validation
model_path <- Sys.getenv("MODEL_PATH", "api/purchase_model.rds")
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


#* Log all requests - incoming request data
#* @filter logger
function(req) {
  cat(
    "Time:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n",
    "Request:", req$REQUEST_METHOD, req$PATH_INFO, "\n",
    "User Agent:", req$HTTP_USER_AGENT, "\n",
    "IP:", req$REMOTE_ADDR, "\n\n",
    sep = " "
  )
  plumber::forward()
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
      status = ifelse(file.exists(model_path), "OK", "MISSING"),
      path = Sys.getenv("MODEL_PATH", "default")
    ),
    system = list(
      r_version = R.version.string,
      jit_enabled = as.numeric(Sys.getenv("R_ENABLE_JIT", "0"))
    ),
    system = Sys.info()["sysname"],
    render = TRUE
  )
}



#* Predict purchase probability
#* @param Age:int Customer age (18-100)
#* @param Gender:enum["Male","Female"] Customer gender
#* @param EstimatedSalary:number Monthly salary (KES)
#* @response 200 Returns prediction results
#* @response 400 Bad request if validation fails
#* @post /predict
function(Age, Gender, EstimatedSalary, res) {
  tryCatch({
    # Convert inputs to correct types (critical for JSON parsing)
    Age <- as.numeric(Age)
    EstimatedSalary <- as.numeric(EstimatedSalary)
    Gender <- as.character(Gender)
    
    # Input validation
    if (is.na(Age)) {
      res$status <- 400
      return(list(success = FALSE, error = "Age must be a number"))
    }
    if (is.na(EstimatedSalary)) {
      res$status <- 400
      return(list(success = FALSE, error = "Salary must be a number"))
    }
    if (Age < 18 || Age > 100) {
      res$status <- 400
      return(list(success = FALSE, error = "Age must be between 18 and 100"))
    }
    if (EstimatedSalary < 0) {
      res$status <- 400
      return(list(success = FALSE, error = "Salary must be positive"))
    }
    if (!Gender %in% c("Male", "Female")) {
      res$status <- 400
      return(list(success = FALSE, error = "Gender must be 'Male' or 'Female'"))
    }
    
    # Prepare data (match training format exactly)
    new_data <- data.frame(
      Age = Age,
      Gender = ifelse(Gender == "Male", 1, 0),
      EstimatedSalary = EstimatedSalary
    )
    
    # Make prediction
    prediction <- predict(model, new_data, type = "response")
    
    # Return formatted response
    list(
      success = TRUE,
      probability = round(prediction, 4),
      prediction = ifelse(prediction > 0.5, "Likely to purchase", "Unlikely to purchase"),
      decision_boundary = 0.5,
      model_version = "1.0",
      render_deployment = TRUE
    )
    
  }, error = function(e) {
    # Handle unexpected errors
    res$status <- 500
    return(list(
      success = FALSE,
      error = "Internal server error",
      details = conditionMessage(e),
      timestamp = Sys.time()
    ))
  })
}

#* @plumber
function(pr) {
  # Enable Swagger UI
  pr %>%
    pr_set_docs("swagger") %>%
    pr_set_api_spec(function(spec) {
      spec$components$schemas$PredictionResponse <- list(
        type = "object",
        properties = list(
          probability = list(type = "number"),
          prediction = list(type = "integer"),
          model_version = list(type = "string")
        )
      )
	  spec$info$description  <- paste(
        "Optimized for Render.com |",
        "JIT Level:", Sys.getenv("R_ENABLE_JIT", "0"))
    spec
    })
}
# At bottom of plumber.R
if (Sys.getenv("RENDER") == "true") {
  pr <- plumber::plumb("api/plumber.R")
  pr$run(port=as.numeric(Sys.getenv("PORT")), host="0.0.0.0")
}


  








