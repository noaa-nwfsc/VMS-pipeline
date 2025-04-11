12_blh_example-ranked-persistence-map
================
Brooke Hawkins
2025-04-10

Create a ranked persistence map, which will visualize the top X% of
fishing activity based on the number of interpolated pings for a given
year in a given grid cell. X will be our cutoff or threshold (I’m using
those terms interchangeably).

For simplicity, I use `year` (e.g. 2013) in these examples, but in the
actual mapping code, I use use `crab_year` (e.g. 2013_2014 for
Nov. 2013 - Oct. 2014).

## Simple - Coast - All time

There are a few versions of this map, let’s start with the simple
version for the whole coast and the whole time frame.

Consider a simple example, for three grid cells in three years.

``` r
ex_1_df <- tibble(year = c(rep(2013, 3), rep(2014, 3), rep(2015, 3)),
                  grid_cell = c(letters[1:3], sample(letters[1:3]), sample(letters[1:3])),
                  n_pings = c(75, 10, 15, 160, 30, 10, 60, 20, 20))
kable(ex_1_df)
```

| year | grid_cell | n_pings |
|-----:|:----------|--------:|
| 2013 | a         |      75 |
| 2013 | b         |      10 |
| 2013 | c         |      15 |
| 2014 | b         |     160 |
| 2014 | a         |      30 |
| 2014 | c         |      10 |
| 2015 | b         |      60 |
| 2015 | a         |      20 |
| 2015 | c         |      20 |

For each grid cell, calculate how many years the grid cell had any
fishing activity.

``` r
ex_1_map_df <- ex_1_df %>%
  group_by(grid_cell) %>%
  summarise(years_with_activity = n_distinct(year),
            .groups = 'drop')
kable(ex_1_map_df)
```

| grid_cell | years_with_activity |
|:----------|--------------------:|
| a         |                   3 |
| b         |                   3 |
| c         |                   3 |

This dataframe would then be joined to the 5km grid by `grid_cell`, and
plotted on a map. Each grid cell had activity in every year, so every
cell would be included on the map with 3 years of activity.

## Ranked - Coast - All time

Let’s make it a little trickier. Now we only want to consider grid cells
that contribute to the top X% of fishing activity. We’ll still consider
the whole coast and the whole time frame.

Let’s consider a 75% threshold.

``` r
threshold <- 0.75
```

To decide which grid cells contribute towards the 75% fishing activity,
we need to do a couple of things:

1.  Sort each year of data from most pings to fewest pings
2.  Calculate total number of pings per year
3.  Calculate the threshold number of pings per year (if it’s a
    fraction, round up to the nearest whole number)
4.  Calculate a cumulative sum of number of pings for each year
5.  Compare the cumulative number of pings to the threshold number of
    pings to decide which cells get included in the persistence map

``` r
ex_1_threshold_df <- ex_1_df %>%
  arrange(year, n_pings * -1) %>%
  group_by(year) %>% 
  mutate(year_pings = sum(n_pings),
         threshold_pings = ceiling(threshold * year_pings)) %>%
  ungroup() %>%
  group_by(year) %>% 
  mutate(cumulative_pings = cumsum(n_pings),
         include = (cumulative_pings <= threshold_pings) | 
           (cumulative_pings > threshold_pings & lag(cumulative_pings) < threshold_pings) | 
           (cumulative_pings > threshold_pings & is.na(lag(cumulative_pings) < threshold_pings)))
kable(ex_1_threshold_df)
```

| year | grid_cell | n_pings | year_pings | threshold_pings | cumulative_pings | include |
|-----:|:----------|--------:|-----------:|----------------:|-----------------:|:--------|
| 2013 | a         |      75 |        100 |              75 |               75 | TRUE    |
| 2013 | c         |      15 |        100 |              75 |               90 | FALSE   |
| 2013 | b         |      10 |        100 |              75 |              100 | FALSE   |
| 2014 | b         |     160 |        200 |             150 |              160 | TRUE    |
| 2014 | a         |      30 |        200 |             150 |              190 | FALSE   |
| 2014 | c         |      10 |        200 |             150 |              200 | FALSE   |
| 2015 | b         |      60 |        100 |              75 |               60 | TRUE    |
| 2015 | a         |      20 |        100 |              75 |               80 | TRUE    |
| 2015 | c         |      20 |        100 |              75 |              100 | FALSE   |

This logic for `include` probably seems arbitrarily complicated, but
here are a few use cases considered here:

- What if the cumulative pings is exactly equal to the threshold pings?
  (2013)
- What if cumulative pings is not exactly equal to the threshold pings?
  (2014, 2015)
- What if the first record reaches the threshold? (2014)

Not *exactly* 75% of the fishing effort is included; it’s more accurate
to say at least 75% fishing effort is included. For example, in 2014 and
in 2015, 80% of the effort is included.

Edge case - I’m still not satisfied with ties at the threshold. For
example, in 2015, grid cells b and c both have 20 pings, and grid cell b
is included while grid cell c isn’t. I haven’t figured out a way to
handle that exception without iterating over records one by one in a for
loop, which seems slow. I did see this happen in the actual VMS data for
the 2016-2017 crab year. I doubt it has huge impacts on the maps, just
calling out this one remaining caveat.

Anyway, moving on.

When mapping persistence for grid cells that contribute to the top 75%
of fishing activity, we now need to find how many years each of the grid
cells are included. The steps are:

1.  Filter for grid cells that should be included in the summary
2.  Count the number of distinct years for each grid cell

``` r
ex_1_threshold_map_df <- ex_1_threshold_df %>%
  filter(include) %>%
  group_by(grid_cell) %>%
  summarize(years_with_activity = n_distinct(year),
            .groups = 'drop')
kable(ex_1_threshold_map_df)
```

| grid_cell | years_with_activity |
|:----------|--------------------:|
| a         |                   2 |
| b         |                   2 |

Only grid cells a and b contributed towards the top 75% fishing effort,
and in 2 years each.

Note: the ranked version for a 100% threshold is identical to the simple
version. The 100% threshold will just do some sorting and calculating
that isn’t required, because every value for `include` will be true
until 100% of the pings are represented.

## Ranked - State - All time

Now let’s do the same exact thing, but instead of considering the whole
coast, we’ll look at each state separately. We can use a similar
dataframe as before, but we need to have state included in the
aggregation.

Consider a new example with two years and two states of data.

``` r
ex_2_df <- tibble(year = c(rep(2013, 5), rep(2014, 5)),
                  state = c(rep('C', 3), rep('O', 2), rep('C', 2), rep('O', 3)),
                  grid_cell = c(letters[1:5], sample(letters[1:2]), sample(letters[4:6])),
                  n_pings = c(10, 30, 60, 50, 50, 80, 20, 45, 35, 10))
kable(ex_2_df)
```

| year | state | grid_cell | n_pings |
|-----:|:------|:----------|--------:|
| 2013 | C     | a         |      10 |
| 2013 | C     | b         |      30 |
| 2013 | C     | c         |      60 |
| 2013 | O     | d         |      50 |
| 2013 | O     | e         |      50 |
| 2014 | C     | a         |      80 |
| 2014 | C     | b         |      20 |
| 2014 | O     | d         |      45 |
| 2014 | O     | e         |      35 |
| 2014 | O     | f         |      10 |

There are two versions here:

A. Ranking top X% in each state based on the whole coast’s fishing
activity. *Universe for analysis = whole coast.* (This just splits the
map into separate panels, so the coastal trends are easier to see.) B.
Rank top X% in each state based on that state’s fishing activity.
*Universe for analysis = each state.* (This is a different analytical
task, because the yearly totals need to be grouped by state in addition
to by year.)

### Version A

For version A, we do the same process as above, just add the `state`
identifier whenever the `grid_cell` identifier is grouped by for
aggregations. Since each grid cell has only one state, the results are
the same, just with the addition of the the `state` column.

Repeat the checks for whether a grid cell contributes to the top 75% of
fishing activity:

``` r
ex_2_a_threshold_df <- ex_2_df %>%
  arrange(year, state, n_pings * -1) %>% # state is now included here
  group_by(year) %>%
  mutate(year_pings = sum(n_pings),
         threshold_pings = ceiling(threshold * year_pings)) %>%
  ungroup() %>%
  group_by(year) %>%
  mutate(cumulative_pings = cumsum(n_pings),
         include = (cumulative_pings <= threshold_pings) |
           (cumulative_pings > threshold_pings & lag(cumulative_pings) < threshold_pings) |
           (cumulative_pings > threshold_pings & is.na(lag(cumulative_pings) < threshold_pings)))
kable(ex_2_a_threshold_df)
```

| year | state | grid_cell | n_pings | year_pings | threshold_pings | cumulative_pings | include |
|---:|:---|:---|---:|---:|---:|---:|:---|
| 2013 | C | c | 60 | 200 | 150 | 60 | TRUE |
| 2013 | C | b | 30 | 200 | 150 | 90 | TRUE |
| 2013 | C | a | 10 | 200 | 150 | 100 | TRUE |
| 2013 | O | d | 50 | 200 | 150 | 150 | TRUE |
| 2013 | O | e | 50 | 200 | 150 | 200 | FALSE |
| 2014 | C | a | 80 | 190 | 143 | 80 | TRUE |
| 2014 | C | b | 20 | 190 | 143 | 100 | TRUE |
| 2014 | O | d | 45 | 190 | 143 | 145 | TRUE |
| 2014 | O | e | 35 | 190 | 143 | 180 | FALSE |
| 2014 | O | f | 10 | 190 | 143 | 190 | FALSE |

Repeat the aggreagation for how many years a grid cell contributes to
the top 75% of fishing activity:

``` r
ex_2_a_threshold_map_df <- ex_2_a_threshold_df %>%
  filter(include) %>%
  group_by(grid_cell, state) %>% # state is now included here
  summarize(years_with_activity = n_distinct(year),
            .groups = 'drop')
kable(ex_2_a_threshold_map_df)
```

| grid_cell | state | years_with_activity |
|:----------|:------|--------------------:|
| a         | C     |                   2 |
| b         | C     |                   2 |
| c         | C     |                   1 |
| d         | O     |                   2 |

### Version B

For version B, we do the same process as above, but when we calculate
the total number of pings and compare a grid cell against a threshold,
we compare to the state total, not the whole coast total.

``` r
ex_2_b_threshold_df <- ex_2_df %>%
  arrange(year, state, n_pings * -1) %>% # state is still included here
  group_by(year, state) %>% # state is now included here too
  mutate(year_pings = sum(n_pings),
         threshold_pings = ceiling(threshold * year_pings)) %>%
  ungroup() %>%
  group_by(year, state) %>% # state is now included here too
  mutate(cumulative_pings = cumsum(n_pings),
         include = (cumulative_pings <= threshold_pings) |
           (cumulative_pings > threshold_pings & lag(cumulative_pings) < threshold_pings) |
           (cumulative_pings > threshold_pings & is.na(lag(cumulative_pings) < threshold_pings)))
kable(ex_2_b_threshold_df)
```

| year | state | grid_cell | n_pings | year_pings | threshold_pings | cumulative_pings | include |
|---:|:---|:---|---:|---:|---:|---:|:---|
| 2013 | C | c | 60 | 100 | 75 | 60 | TRUE |
| 2013 | C | b | 30 | 100 | 75 | 90 | TRUE |
| 2013 | C | a | 10 | 100 | 75 | 100 | FALSE |
| 2013 | O | d | 50 | 100 | 75 | 50 | TRUE |
| 2013 | O | e | 50 | 100 | 75 | 100 | TRUE |
| 2014 | C | a | 80 | 100 | 75 | 80 | TRUE |
| 2014 | C | b | 20 | 100 | 75 | 100 | FALSE |
| 2014 | O | d | 45 | 90 | 68 | 45 | TRUE |
| 2014 | O | e | 35 | 90 | 68 | 80 | TRUE |
| 2014 | O | f | 10 | 90 | 68 | 90 | FALSE |

``` r
ex_2_b_threshold_map_df <- ex_2_b_threshold_df %>%
  filter(include) %>%
  group_by(grid_cell, state) %>% # state is still included here
  summarize(years_with_activity = n_distinct(year),
            .groups = 'drop')
kable(ex_2_b_threshold_map_df)
```

| grid_cell | state | years_with_activity |
|:----------|:------|--------------------:|
| a         | C     |                   1 |
| b         | C     |                   1 |
| c         | C     |                   1 |
| d         | O     |                   2 |
| e         | O     |                   2 |
