# Check new download of fish tickets

Write functions to compare dataframe columns. This might be overkill,
but I didn’t know a good function that already exists in R to do this.

``` r
# print whether column count, name, and type match between two dataframes
compare_df_cols <- function(df1, df2) {
  # check column count
  same_col_n <- ncol(df1) == ncol(df2)
  print(paste("same # columns?", same_col_n))

  # check column name
  if (same_col_n) {
    same_col_names <- sum(colnames(df1) == colnames(df2))
    if (same_col_names == ncol(df1)) {
      print(paste('same column names?', TRUE))
    } else {
      print(paste(
        'same column names?',
        FALSE,
        ncol(df1) - same_col_names,
        "differ"
      ))
    }
  }

  # check column type
  if (same_col_n & same_col_names) {
    coltypes1 = sapply(df1, class)
    coltypes2 = sapply(df2, class)
    same_col_types <- sum(coltypes1 == coltypes2)
    if (same_col_types == ncol(df1)) {
      print(paste('same column types?', TRUE))
    } else {
      types_df = tibble(
        col_name = colnames(df1),
        coltypes1,
        coltypes2,
        same = (coltypes1 == coltypes2)
      )
      print(paste('same column types?', FALSE))
      print(types_df %>% filter(same == FALSE))
    }
  }
}
```

Apply functions to pairs of dataframes from 2011-2024.

``` r
# iterate through years
first_year <- 2011

for (y in 2011:2023) {
  # print progress
  print("---")
  print(paste("comparing year", y, "to", y + 1))

  # load df1
  if (y == first_year) {
    df1 <- read.csv(here(
      'Confidential',
      'raw_data',
      'fish_tickets',
      paste0('fish_tickets_', y, '.csv')
    ))
  } else {
    df1 <- df2
  }

  # load df2
  df2 <- read.csv(here(
    'Confidential',
    'raw_data',
    'fish_tickets',
    paste0('fish_tickets_', y + 1, '.csv')
  ))

  # compare
  compare_df_cols(df1, df2)
}
```

    [1] "---"
    [1] "comparing year 2011 to 2012"
    [1] "same # columns? TRUE"
    [1] "same column names? TRUE"
    [1] "same column types? FALSE"
    # A tibble: 1 × 4
      col_name     coltypes1 coltypes2 same 
      <chr>        <chr>     <chr>     <lgl>
    1 HILLE_PERMIT logical   character FALSE
    [1] "---"
    [1] "comparing year 2012 to 2013"
    [1] "same # columns? TRUE"
    [1] "same column names? TRUE"
    [1] "same column types? TRUE"
    [1] "---"
    [1] "comparing year 2013 to 2014"
    [1] "same # columns? TRUE"
    [1] "same column names? TRUE"
    [1] "same column types? TRUE"
    [1] "---"
    [1] "comparing year 2014 to 2015"
    [1] "same # columns? TRUE"
    [1] "same column names? TRUE"
    [1] "same column types? FALSE"
    # A tibble: 1 × 4
      col_name   coltypes1 coltypes2 same 
      <chr>      <chr>     <chr>     <lgl>
    1 DEALER_NUM integer   character FALSE
    [1] "---"
    [1] "comparing year 2015 to 2016"
    [1] "same # columns? TRUE"
    [1] "same column names? TRUE"
    [1] "same column types? TRUE"
    [1] "---"
    [1] "comparing year 2016 to 2017"
    [1] "same # columns? TRUE"
    [1] "same column names? TRUE"
    [1] "same column types? FALSE"
    # A tibble: 5 × 4
      col_name     coltypes1 coltypes2 same 
      <chr>        <chr>     <chr>     <lgl>
    1 FTID         character integer   FALSE
    2 NUM_OF_FISH  numeric   integer   FALSE
    3 HILLE_PERMIT character logical   FALSE
    4 EFP_CODE     logical   character FALSE
    5 EFP_NAME     logical   character FALSE
    [1] "---"
    [1] "comparing year 2017 to 2018"
    [1] "same # columns? TRUE"
    [1] "same column names? TRUE"
    [1] "same column types? FALSE"
    # A tibble: 3 × 4
      col_name     coltypes1 coltypes2 same 
      <chr>        <chr>     <chr>     <lgl>
    1 FTID         integer   character FALSE
    2 NUM_OF_FISH  integer   numeric   FALSE
    3 HILLE_PERMIT logical   character FALSE
    [1] "---"
    [1] "comparing year 2018 to 2019"
    [1] "same # columns? TRUE"
    [1] "same column names? TRUE"
    [1] "same column types? FALSE"
    # A tibble: 1 × 4
      col_name         coltypes1 coltypes2 same 
      <chr>            <chr>     <chr>     <lgl>
    1 GF_PERMIT_NUMBER logical   character FALSE
    [1] "---"
    [1] "comparing year 2019 to 2020"
    [1] "same # columns? TRUE"
    [1] "same column names? TRUE"
    [1] "same column types? FALSE"
    # A tibble: 1 × 4
      col_name coltypes1 coltypes2 same 
      <chr>    <chr>     <chr>     <lgl>
    1 TRIP_SEQ integer   logical   FALSE
    [1] "---"
    [1] "comparing year 2020 to 2021"
    [1] "same # columns? TRUE"
    [1] "same column names? TRUE"
    [1] "same column types? TRUE"
    [1] "---"
    [1] "comparing year 2021 to 2022"
    [1] "same # columns? TRUE"
    [1] "same column names? TRUE"
    [1] "same column types? TRUE"
    [1] "---"
    [1] "comparing year 2022 to 2023"
    [1] "same # columns? TRUE"
    [1] "same column names? TRUE"
    [1] "same column types? TRUE"
    [1] "---"
    [1] "comparing year 2023 to 2024"
    [1] "same # columns? TRUE"
    [1] "same column names? TRUE"
    [1] "same column types? FALSE"
    # A tibble: 1 × 4
      col_name coltypes1 coltypes2 same 
      <chr>    <chr>     <chr>     <lgl>
    1 TRIP_SEQ logical   integer   FALSE

Interpretation:

There’s the same number columns and column names year over year, but
eight columns are read with different data types by default across
years.

Specify the less restrictive data type (underlined) when reading in the
CSV, and then `bind_rows()` should work on the dataframes read by CSV.

- *HILLE_PERMIT* is logical in 2011, <u>character</u> in 2012-2016,
  logical in 2017, character in 2018-2024

- *DEALER_NUM* is integer in 2011-2014, <u>character</u> in 2015-2024

- *FTID* is <u>character</u> in 2011-2016, integer in 2017, character in
  2018-2024

- *NUM_OF_FISH* is <u>numeric</u> in 2011-2016, integer in 2017, numeric
  in 2018-2024

- *EFP_CODE* is logical in 2011-2016, <u>character</u> in 2017-2024

- *EFP_NAME* is logical in 2011-2016, <u>character</u> in 2017-2024

- *GF_PERMIT_NUMBER* is logical in 2011-2018, <u>character</u> in
  2019-2024

- *TRIP_SEQ* is <u>integer</u> 2011-2019, logical 2020-2023, integer
  2024

When I ran `bind_rows()` below, at first I got an error about
`GEAR_CODE` not matching between integer and double in one set of years,
so I also set that to read in as a double.

``` r
for (y in 2011:2024) {
  # load year of data as df_y
  assign(
    x = paste0("df_", y),
    value = read_csv(
      here(
        'Confidential',
        'raw_data',
        'fish_tickets',
        paste0('fish_tickets_', y, '.csv')
      ),
      col_types = list(
        HILLE_PERMIT = "c",
        DEALER_NUM = "c",
        FTID = "c",
        NUM_OF_FISH = "n",
        EFP_CODE = "c",
        EFP_NAME = "c",
        GF_PERMIT_NUMBER = "c",
        TRIP_SEQ = "i",
        GEAR_CODE = "d"
      )
    )
  )
}
```

    Warning: One or more parsing issues, call `problems()` on your data frame for details,
    e.g.:
      dat <- vroom(...)
      problems(dat)

``` r
# bind rows
ticket_df <- bind_rows(mget(paste0("df_", 2011:2024)))
```

Still need to check whether old vs. new pull have similar \# tickets,
vessels, landings and revenue across years.
