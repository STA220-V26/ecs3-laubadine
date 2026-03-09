# this is a file where I put my functions
# download data
download_data <- function() {

  if (!fs::file_exists("data.zip")) {
    curl::curl_download(
      "https://github.com/eribul/cs/raw/refs/heads/main/data.zip",
      "data.zip",
      quiet = FALSE
    )
  }

}
# reads patients.csv inside the zip, converts to data.table
load_patients <- function() {

  patients <-
    readr::read_csv(unz("data.zip", "data-fixed/patients.csv")) |>
    data.table::setDT() |>
    data.table::setkey("id")

  patients

}

# clean data, Using janitor to remove:empty rows/columns, constant columns
clean_patients <- function(patients) {

  patients <- janitor::remove_empty(patients, quiet = FALSE)
  patients <- janitor::remove_constant(patients, quiet = FALSE)

  patients

}

# convert abbreviation into readable categories

convert_factors <- function(patients) {

  patients[
    ,
    marital := factor(
      marital,
      levels = c("S","M","D","W"),
      labels = c("Single","Married","Divorced","Widowed")
    )
  ]

  patients

}

# Uses point blank to validation check and create the required file: patient_validation.html
validate_patients <- function(patients) {

  checks <-
    patients |>
    pointblank::create_agent(label = "Patient data validation") |>

    pointblank::col_vals_between(
  where(lubridate::is.Date),
  as.Date("1900-01-01"),
  Sys.Date(),
  na_pass = TRUE,
  label = "Check that all date values are between 1900 and today"
) |>

    pointblank::col_vals_gte(
      deathdate,
      vars(birthdate),
      na_pass = TRUE,
      label = "Check that death date is after birth date"
    ) |>

    pointblank::col_vals_regex(
      ssn,
      "[0-9]{3}-[0-9]{2}-[0-9]{4}$",
      label = "Check that SSN format is XXX-XX-XXXX"
    ) |>

    pointblank::col_is_integer(
      id,
      label = "Check that ID is integer"
    ) |>

    pointblank::interrogate()

  pointblank::export_report(checks, "patient_validation.html")

  checks

}


