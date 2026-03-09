library(targets)

tar_option_set(
  packages = c("data.table", "readr", "curl", "fs", "pointblank", "lubridate")
)

tar_source("R")

list(

  tar_target(
    download,
    download_data()
  ),

  tar_target(
    patients_raw,
    load_patients()
  ),

  tar_target(
    patients_clean,
    clean_patients(patients_raw)
  ),

  tar_target(
    patients_final,
    convert_factors(patients_clean)
  ),

  tar_target(
    validation,
    validate_patients(patients_final)
  )

)