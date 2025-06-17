# Check new download of fish tickets


- [Check 1 - How to load all fish tickets at
  once?](#check-1---how-to-load-all-fish-tickets-at-once)
- [Check 2 - How does new pull of fish ticket data compare to old
  pull?](#check-2---how-does-new-pull-of-fish-ticket-data-compare-to-old-pull)

## Check 1 - How to load all fish tickets at once?

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
    # A tibble: 2 × 4
      col_name coltypes1 coltypes2 same 
      <chr>    <chr>     <chr>     <lgl>
    1 EFP_CODE logical   character FALSE
    2 EFP_NAME logical   character FALSE
    [1] "---"
    [1] "comparing year 2017 to 2018"
    [1] "same # columns? TRUE"
    [1] "same column names? TRUE"
    [1] "same column types? TRUE"
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

It looks like `df_2022` leads to some issues when parsing, unclear to me
why. I ran problems`(df_2022) %>% View()` and the issue was always with
column 105, which is `HSFCA_PERMIT`. It only impacts ~700 records out of
379k records that year, so it’s probably ok to not worry about it. None
of the other years threw warnings.

## Check 2 - How does new pull of fish ticket data compare to old pull?

I want to see if the \# tickets, vessels, landings and revenue are
pretty similar between the old and new data.

This is rough but I’m hoping numbers will look pretty similar between
pulls.

``` r
# calculate # tickets, vessels, landings and revenue per year
new_pull_counts <- ticket_df |>
  # apply a few filters
  filter(
    # remove missing vessel ID
    VESSEL_NUM != "MISSING",
    VESSEL_NUM != "UNKNOWN",
    VESSEL_NUM != "",
    # remove tickets landed in AK and transported to WC
    COUNCIL_CODE != "N",
    # remove tribal fishing
    FLEET_CODE != "TI",
    # remove aquaculture
    PARTICIPATION_GROUP_CODE != "A"
  ) |>
  # select a few columns
  select(
    LANDING_YEAR,
    VESSEL_NUM,
    FTID,
    PACFIN_SPECIES_CODE,
    LANDED_WEIGHT_LBS,
    EXVESSEL_REVENUE
  ) |>
  # de-duplicate
  distinct() |>
  # calculate a few summary statistics per year
  group_by(LANDING_YEAR) |>
  summarise(
    n_vessels = n_distinct(VESSEL_NUM),
    n_tickets = n_distinct(FTID),
    sum_landings = sum(LANDED_WEIGHT_LBS, na.rm = TRUE),
    sum_revenue = sum(EXVESSEL_REVENUE, na.rm = TRUE)
  )

# load old data
old_ticket_df <- read_rds(here(
  'Confidential',
  'raw_data',
  'fish_tickets',
  'all_fishtickets_1994_2023.rds'
))

# calculate # tickets, vessels, landings and revenue per year
old_pull_counts <- old_ticket_df |>
  # apply a few filters
  filter(
    # remove missing vessel ID
    VESSEL_NUM != "MISSING",
    VESSEL_NUM != "UNKNOWN",
    VESSEL_NUM != "",
    # remove tickets landed in AK and transported to WC
    COUNCIL_CODE != "N",
    # remove tribal fishing
    FLEET_CODE != "TI",
    # remove aquaculture
    PARTICIPATION_GROUP_CODE != "A"
  ) |>
  # select a few columns
  select(
    LANDING_YEAR,
    VESSEL_NUM,
    FTID,
    PACFIN_SPECIES_CODE,
    LANDED_WEIGHT_LBS,
    EXVESSEL_REVENUE
  ) |>
  # de-duplicate
  distinct() |>
  # calculate a few summary statistics per year
  group_by(LANDING_YEAR) |>
  summarise(
    n_vessels = n_distinct(VESSEL_NUM),
    n_tickets = n_distinct(FTID),
    sum_landings = sum(LANDED_WEIGHT_LBS, na.rm = TRUE),
    sum_revenue = sum(EXVESSEL_REVENUE, na.rm = TRUE)
  )

# set a column indicating which pull the data is from
old_pull_counts$pull = "old"
new_pull_counts$pull = "new"

# calculate difference between old and new pull in similarly shaped dataframe
diff_counts <- old_pull_counts |>
  left_join(new_pull_counts, by = "LANDING_YEAR", suffix = c("_old", "_new")) |>
  mutate(
    n_vessels = n_vessels_new - n_vessels_old,
    n_tickets = n_tickets_new - n_tickets_old,
    sum_landings = sum_landings_new - sum_landings_old,
    sum_revenue = sum_revenue_new - sum_revenue_old,
    pull = "diff",
    pct_vessels = n_vessels / n_vessels_old * 100,
    pct_tickets = n_tickets / n_tickets_old * 100,
    pct_landings = sum_landings / sum_landings_old * 100,
    pct_revenue = sum_revenue / sum_revenue_old * 100
  ) |>
  select(
    LANDING_YEAR,
    n_vessels,
    n_tickets,
    sum_landings,
    sum_revenue,
    pull,
    pct_vessels,
    pct_tickets,
    pct_landings,
    pct_revenue
  )

# view differences
kable(diff_counts)
```

| LANDING_YEAR | n_vessels | n_tickets | sum_landings | sum_revenue | pull | pct_vessels | pct_tickets | pct_landings | pct_revenue |
|---:|---:|---:|---:|---:|:---|---:|---:|---:|---:|
| 1994 | NA | NA | NA | NA | diff | NA | NA | NA | NA |
| 1995 | NA | NA | NA | NA | diff | NA | NA | NA | NA |
| 1996 | NA | NA | NA | NA | diff | NA | NA | NA | NA |
| 1997 | NA | NA | NA | NA | diff | NA | NA | NA | NA |
| 1998 | NA | NA | NA | NA | diff | NA | NA | NA | NA |
| 1999 | NA | NA | NA | NA | diff | NA | NA | NA | NA |
| 2000 | NA | NA | NA | NA | diff | NA | NA | NA | NA |
| 2001 | NA | NA | NA | NA | diff | NA | NA | NA | NA |
| 2002 | NA | NA | NA | NA | diff | NA | NA | NA | NA |
| 2003 | NA | NA | NA | NA | diff | NA | NA | NA | NA |
| 2004 | NA | NA | NA | NA | diff | NA | NA | NA | NA |
| 2005 | NA | NA | NA | NA | diff | NA | NA | NA | NA |
| 2006 | NA | NA | NA | NA | diff | NA | NA | NA | NA |
| 2007 | NA | NA | NA | NA | diff | NA | NA | NA | NA |
| 2008 | NA | NA | NA | NA | diff | NA | NA | NA | NA |
| 2009 | NA | NA | NA | NA | diff | NA | NA | NA | NA |
| 2010 | NA | NA | NA | NA | diff | NA | NA | NA | NA |
| 2011 | 0 | 7 | 12666.400 | 52127.92 | diff | 0.0000000 | 0.0061901 | 0.0015347 | 0.0111779 |
| 2012 | 1 | 23 | 38298.510 | -11821.76 | diff | 0.0268528 | 0.0206654 | 0.0046104 | -0.0025776 |
| 2013 | 2 | 164 | 195366.652 | 176466.78 | diff | 0.0532907 | 0.1392699 | 0.0215206 | 0.0315664 |
| 2014 | -2 | 26 | -99061.688 | 13521.40 | diff | -0.0528821 | 0.0231905 | -0.0123828 | 0.0026529 |
| 2015 | -2 | 26 | 8740.968 | -152556.80 | diff | -0.0547645 | 0.0273402 | 0.0017460 | -0.0436188 |
| 2016 | -1 | 22 | 25810.663 | 143321.19 | diff | -0.0284900 | 0.0246772 | 0.0049074 | 0.0313227 |
| 2017 | -1 | 34 | -424089.034 | 127922.56 | diff | -0.0297442 | 0.0382289 | -0.0624004 | 0.0278564 |
| 2018 | -2 | -3 | -844467.482 | 76447.88 | diff | -0.0587027 | -0.0034883 | -0.1312424 | 0.0166537 |
| 2019 | -13 | -48 | -764527.185 | 242019.59 | diff | -0.3893381 | -0.0587429 | -0.1300267 | 0.0592160 |
| 2020 | -12 | -300 | -2531295.465 | -839254.22 | diff | -0.3869719 | -0.3983376 | -0.4331041 | -0.2260534 |
| 2021 | -24 | -54 | 158156.642 | 629642.80 | diff | -0.7978723 | -0.0708160 | 0.0256454 | 0.1173567 |
| 2022 | -23 | -318 | -439319.381 | -990426.92 | diff | -0.7610854 | -0.4234918 | -0.0739050 | -0.2161052 |
| 2023 | -11 | 258 | 865757.892 | 2026266.53 | diff | -0.4041146 | 0.3739943 | 0.1645432 | 0.4650286 |

``` r
# write csv
write.csv(
  diff_counts,
  here('Confidential', 'sablefish_vms', 'diff_pull_counts.csv'),
  row.names = FALSE
)
```

``` r
# combine and reshape counts
vis_df <- diff_counts |>
  select(LANDING_YEAR, n_vessels, n_tickets, sum_landings, sum_revenue, pull) |>
  rbind(old_pull_counts, new_pull_counts) |>
  pivot_longer(
    cols = c("n_vessels", "n_tickets", "sum_landings", "sum_revenue"),
    names_to = "variable"
  )
# visualize differences
ggplot(vis_df, aes(x = LANDING_YEAR, y = value, col = pull)) +
  geom_line() +
  facet_grid(
    variable ~ factor(pull, c("old", "new", "diff")),
    scales = "free_y"
  )
```

    Warning: Removed 17 rows containing missing values or values outside the scale range
    (`geom_line()`).

![](16_blh_check-new-fish-tickets_files/figure-commonmark/unnamed-chunk-6-1.png)

``` r
# save output
ggsave(
  here('Confidential', 'sablefish_vms', 'diff_pull_counts.png'),
  width = 8,
  height = 5,
  unit = "in"
)
```

    Warning: Removed 17 rows containing missing values or values outside the scale range
    (`geom_line()`).

I saw a huge gap in 2017, ~10x fewer records than there should have
been. I redownloaded the data and reran to see if the new results look
better, which they do. The differences now are \<1% for the distinct
count of vessels and tickets, and the sum of landings and revenue.
