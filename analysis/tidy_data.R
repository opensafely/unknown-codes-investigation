library(tidyverse)
# Load coding systems
coding_system_files <- fs::dir_ls(path = "coding_systems", glob = "*.txt$")

clinical_codes <- purrr::map_dfr(coding_system_files,
                                 readr::read_table,
                                 .id = "coding_system",
                                 col_names = "code",
                                 col_types = "c")

clinical_codes <- clinical_codes %>%
 dplyr::mutate(coding_system = stringr::str_replace_all(coding_system,
                                                        c("coding_systems/" = "",
                                                          ".txt" = "")))

# Load output data
output_files <- fs::dir_ls(path = "output", glob = "*.csv$")

outputs <- purrr::map_dfr(output_files,
                          readr::read_csv,
                          .id = "file_name",
                          col_types = list(file_name = readr::col_character(),
                                           month = readr::col_character(),
                                           code = readr::col_character(),
                                           num = readr::col_double()))

# Tidy output data
# Not ideal to hardcode this, maybe include the coding system in all file names
# Additionally the code is quite slow, in particular 'str_replace_all'
outputs <- outputs %>%
  dplyr::mutate(data_source = stringr::str_replace_all(file_name, c("output/" = "", ".csv" = ""))) %>%
  dplyr::mutate(coding_system = dplyr::case_when(stringr::str_detect(file_name, "APCS_Der.Spell_Primary_Diagnosis") ~ "icd10",
                                                 stringr::str_detect(file_name, "CodedEvent.CTV3Code") ~ "ctv3",
                                                 stringr::str_detect(file_name, "CodedEvent_SNOMED.ConceptID") ~ "snomedct")) %>%
  dplyr::relocate(data_source, coding_system, month, code, num) %>%
  dplyr::select(-file_name)

# Check if clinical codes are known
outputs <- outputs %>%
  dplyr::mutate(code_unknown = !code %in% clinical_codes$code)

# remove nums < 10 and Round all numbers to the nearest 10 and 
# Although this is currently also done in the sql queries we want have a separate 
# action for disclosivity ensurance in future
outputs <- outputs %>%
   dplyr::filter(num >= 10) %>%
   dplyr::mutate(num = round(num, -1))

# Write output
readr::write_csv(outputs, "output/output.csv")
