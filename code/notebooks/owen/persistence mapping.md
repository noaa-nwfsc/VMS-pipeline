# Dungeness Crab Fishing Effort Persistence Mapping
Owen R. Liu
2025-06-05

- [Setup and Purpose](#setup-and-purpose)
- [Import Data](#import-data)
  - [Gridded Fishing Effort](#gridded-fishing-effort)
- [Grids](#grids)
  - [Functions](#functions)
- [Counts, Mean, and Variance](#counts-mean-and-variance)
  - [Total Pings, Positive Area](#total-pings-positive-area)
  - [Months Fished](#months-fished)
  - [Average monthly landings](#average-monthly-landings)
  - [VMS Records](#vms-records)
  - [Number of Vessels](#number-of-vessels)
  - [CPUE](#cpue)
- [Cumulative Effort](#cumulative-effort)
- [Quantiles](#quantiles)

# Setup and Purpose

The goal of this analysis is to characterize the spatial consistency, or
persistence, of spatial fishing patterns in the US West Coast Dungeness
crab fishery. We want to produce useful maps of the overall patterns of
effort that summarize across the time series. There are potentially many
ways to conceptualize this, and we will try a few different ones.

# Import Data

## Gridded Fishing Effort

This is summarized Dungeness crab fishing effort from a combination of
VMS and fish tickets, projected/summarized on a 5km, coastwide grid,
monthly.

``` r
dat <- read_csv(here('dcrb_5km_monthly_nonconfidential_df.csv'))
```

    Rows: 3007 Columns: 13
    ── Column specification ────────────────────────────────────────────────────────
    Delimiter: ","
    chr  (3): crab_year_character, year_month_character, month_factor
    dbl  (8): GRID5KM_ID, year_numeric, month_numeric, dcrb_lbs, dcrb_rev, n_vms...
    lgl  (1): remove_for_confidentiality
    date (1): year_month_date

    ℹ Use `spec()` to retrieve the full column specification for this data.
    ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

# Grids

Next, the spatial layers we need for mapping

``` r
# 5km grid, entire coast
grid5k <- read_sf(here('spatial_data','grids','fivekm_grid_polys_shore_lamb.shp'))
# background map, from rnaturalearth
coast <- ne_states(country='United States of America',returnclass = 'sf') %>%
  filter(name %in% c('California','Oregon','Washington','Nevada')) %>%
  st_transform(crs = st_crs(grid5k))
```

We can filter this large grid to only encompass the cells with some crab
fishing effort. Do this with a filter-buffer-crop workflow (could also
use, e.g., a distance from shore or depth cutoff):

``` r
cells_we_need <- unique(dat$GRID5KM_ID)
grid5k_filt <- grid5k %>% filter(GRID5KM_ID %in% cells_we_need)
# buffer by 50km
grid5k_filt_buff <- grid5k_filt %>% summarise() %>% st_buffer(1e4)
#crop
grid5k_final <- grid5k %>% st_filter(grid5k_filt_buff)
bbox <- st_bbox(grid5k_final)

# map
ggplot()+
  geom_sf(data=grid5k_final,aes(fill=NGDC_med_m),col=NA)+
  geom_sf(data=coast,fill='gray30',col=NA)+
  xlim(bbox[1],bbox[3])+ylim(bbox[2],bbox[4])+
  scale_fill_viridis(option="turbo",direction=-1)
```

![](persistence-mapping_files/figure-commonmark/unnamed-chunk-3-1.png)

``` r
# map with facets
# designate the spatial zones
grid5k_final <- grid5k_final %>% mutate(map_zone=na_if(STATE,"CA")) %>% 
  mutate(map_zone=coalesce(RAMP_area,map_zone)) %>% 
  filter(map_zone!="Southern") %>% 
  mutate(map_zone=ifelse(map_zone=="San Francisco","Central",map_zone)) %>% 
  mutate(map_zone=factor(map_zone,levels=c("WA","OR","Northern","Central")))
ggplot()+
  geom_sf(data=grid5k_final,aes(fill=NGDC_med_m),col=NA)+
  geom_sf(data=coast,fill='gray30',col=NA)+
  facet_wrap(~map_zone)+
  scale_fill_viridis(option="turbo",direction=-1)
```

![](persistence-mapping_files/figure-commonmark/unnamed-chunk-3-2.png)

``` r
# this doesn't quite work because we need different zooms/bounding boxes for each zone. Let's do it with cowplot instead
bboxes <- map(levels(grid5k_final$map_zone),function(z){
  grid5k_final %>% filter(map_zone==z) %>% st_bbox()
})
names(bboxes)=levels(grid5k_final$map_zone)
# now we have a separate bounding box for each coast sections, and can map
pl <- map2(levels(grid5k_final$map_zone),bboxes,function(z,b){
  datsub <- grid5k_final %>% filter(map_zone==z)
  ggplot()+
  geom_sf(data=datsub,aes(fill=NGDC_med_m),col=NA)+
  geom_sf(data=coast,fill='gray30',col=NA)+
  xlim(b[1],b[3])+ylim(b[2],b[4])+
  scale_fill_viridis(option="turbo",direction=-1)
})

plot_grid(plotlist=pl)
```

![](persistence-mapping_files/figure-commonmark/unnamed-chunk-3-3.png)

``` r
# this will work for now
```

We make a couple of spatially rotated grids, for better visualization
when mapping the whole coastline

``` r
# grid extent, rotated (for better plotting)
rot30 <- read_sf(here('spatial_data','map_rotation','fivekm_grid_extent_rect_30.shp')) %>% st_crs()
rot21 <- read_sf(here('spatial_data','map_rotation','fivekm_grid_extent_rect_21.shp')) %>% st_crs()
rot15 <- read_file(here('spatial_data','map_rotation','Rectified_Skew_Orthomorphic_center_15deg_rotation.wkt')) %>% st_crs()

grid5k_rot30 <- grid5k_final %>% st_transform(rot30)
bbox_rot30 <- st_bbox(grid5k_rot30)
grid5k_rot21 <- grid5k_final %>% st_transform(rot21)
bbox_rot21 <- st_bbox(grid5k_rot21)
grid5k_rot15 <- grid5k_final %>% st_transform(rot15)
bbox_rot15 <- st_bbox(grid5k_rot15) +c(0,0,-20000,0)

# map

ggplot()+
  geom_sf(data=grid5k_rot15,aes(fill=NGDC_med_m),col=NA)+
  geom_sf(data=coast,fill='gray30',col=NA)+
  xlim(bbox_rot15[1],bbox_rot15[3])+ylim(bbox_rot15[2],bbox_rot15[4])+
  scale_fill_viridis(option="turbo",direction=-1)
```

![](persistence-mapping_files/figure-commonmark/unnamed-chunk-4-1.png)

``` r
ggplot()+
  geom_sf(data=grid5k_rot21,aes(fill=NGDC_med_m),col=NA)+
  geom_sf(data=coast,fill='gray30',col=NA)+
  xlim(bbox_rot21[1],bbox_rot21[3])+ylim(bbox_rot21[2],bbox_rot21[4])+
  scale_fill_viridis(option="turbo",direction=-1)
```

![](persistence-mapping_files/figure-commonmark/unnamed-chunk-4-2.png)

``` r
ggplot()+
  geom_sf(data=grid5k_rot30,aes(fill=NGDC_med_m),col=NA)+
  geom_sf(data=coast,fill='gray30',col=NA)+
  xlim(bbox_rot30[1],bbox_rot30[3])+ylim(bbox_rot30[2],bbox_rot30[4])+
  scale_fill_viridis(option="turbo",direction=-1)
```

![](persistence-mapping_files/figure-commonmark/unnamed-chunk-4-3.png)

``` r
# rotated 15 degrees seems like the skinniest, most zoomed in map for coastwide viz
```

## Functions

Keep track of some generic functions we’ll use for mapping/visualizing
outputs.

``` r
# coastwide map of a continuous variable
make_map_coastwide <- function(df, column) {
  dat2 <- df %>% st_transform(rot15)
  ggplot() + 
    geom_sf(data=dat2,aes(fill= {{column}}),col=NA)+
    geom_sf(data=coast,fill='gray30',col=NA)+
    xlim(bbox_rot15[1],bbox_rot15[3])+
    ylim(bbox_rot15[2],bbox_rot15[4])+
    scale_fill_viridis(option='turbo',na.value='white')
}
make_map_coastwide(grid5k_final, centro_lat)
```

![](persistence-mapping_files/figure-commonmark/unnamed-chunk-5-1.png)

``` r
make_map_coastwide(grid5k_final, WM_NGDC_m)
```

![](persistence-mapping_files/figure-commonmark/unnamed-chunk-5-2.png)

``` r
# "facetted" by coastal zone
# make_map_zones <- function(df, column) {
#   
#   # scale limits, common across subplots
#   lims <- df %>% pull( {{column}} ) %>% range()
#   # now we have a separate bounding box for each coast sections, and can map
#   pl <- map2(levels(df$map_zone),bboxes,function(z,b){
#     datsub <- df %>% filter(map_zone==z)
#     ggplot()+
#       geom_sf(data=datsub,aes(fill= {{column}} ),col=NA)+
#       geom_sf(data=coast,fill='gray30',col=NA)+
#       xlim(b[1],b[3])+ylim(b[2],b[4])+
#       scale_fill_viridis(option="turbo",na.value='white',limits=lims)
#   })
# 
#   plot_grid(plotlist=pl)
# }

make_map_zones <- function(df, column) {
  
  # scale limits, common across subplots
  lims <- df %>% pull( {{column}} ) %>% range()
  # now we have a separate bounding box for each coast sections, and can map
  pl <- map(bboxes,function(b){
    ggplot()+
      geom_sf(data=df,aes(fill= {{column}} ),col=NA)+
      geom_sf(data=coast,fill='gray30',col=NA)+
      xlim(b[1],b[3])+ylim(b[2],b[4])+
      scale_fill_viridis(option="turbo",na.value='white',limits=lims)
  })

  plot_grid(plotlist=pl)
}

make_map_zones(grid5k_final,centro_lat)
```

![](persistence-mapping_files/figure-commonmark/unnamed-chunk-5-3.png)

``` r
make_map_zones(grid5k_final,WM_NGDC_m)
```

![](persistence-mapping_files/figure-commonmark/unnamed-chunk-5-4.png)

``` r
# finally, if we want a map with a log10 transform (could come back to this later and make other transformations)
make_map_zones_sqrt <- function(df, column) {
  
  # scale limits, common across subplots
  lims <- df %>% pull( {{column}} ) %>% range()
  # now we have a separate bounding box for each coast sections, and can map
  pl <- map2(levels(df$map_zone),bboxes,function(z,b){
    datsub <- df %>% filter(map_zone==z)
    ggplot()+
      geom_sf(data=datsub,aes(fill= {{column}} ),col=NA)+
      geom_sf(data=coast,fill='gray30',col=NA)+
      xlim(b[1],b[3])+ylim(b[2],b[4])+
      scale_fill_viridis(option="turbo",na.value='white',limits=lims,transform='sqrt')
  })

  plot_grid(plotlist=pl)
}

make_map_zones_sqrt(grid5k_final,-WM_NGDC_m)
```

    Warning in transform$transform(limits): NaNs produced
    Warning in transform$transform(limits): NaNs produced
    Warning in transform$transform(limits): NaNs produced
    Warning in transform$transform(limits): NaNs produced

![](persistence-mapping_files/figure-commonmark/unnamed-chunk-5-5.png)

Now that we have some data and tools together, let’s figure out some
persistence maps.

# Counts, Mean, and Variance

We have just one year of data here, but it is enough to start with.
Calculate summary statistics of various kinds:

*Disclaimer* : We did not expand the dataset to include zeroes for
month/grid cell combinations before summarizing. This means that, for
example, mean revenue per month in a given grid cell will be a mean
across only those months with positive catch.

``` r
dat_summs <- dat %>% 
  group_by(GRID5KM_ID) %>% 
  summarise(nmonths=n_distinct(year_month_date) %>% as.numeric,
            mean_lbs=mean(dcrb_lbs),
            max_lbs=max(dcrb_lbs),
            sd_lbs=sd(dcrb_lbs),
            mean_rev=mean(dcrb_rev),
            max_rev=max(dcrb_rev),
            sd_rev=sd(dcrb_rev),
            mean_vms_records=mean(n_vms_records),
            max_vms_records=max(n_vms_records),
            sd_vms_records=sd(n_vms_records),
            cv_vms_records=sd_vms_records/mean_vms_records,
            mean_unique_vessels=mean(n_unique_vessels),
            sd_unique_vessels=sd(n_unique_vessels)) %>% 
  ungroup()

dat_summs_grid <- grid5k_final %>% 
  left_join(dat_summs,by="GRID5KM_ID") %>% 
  # fill in zeroes
  mutate(across(c("nmonths","mean_lbs","max_lbs","sd_lbs","mean_rev","max_rev","sd_rev","mean_vms_records","max_vms_records","sd_vms_records","cv_vms_records","mean_unique_vessels","sd_unique_vessels"),~coalesce(.,0L)))
```

Now we can make a bunch of maps, using the generic map functions we
wrote above.

## Total Pings, Positive Area

Time series of total pings across all grid cells, and positive area
fished (i.e., total area of cells with nonzero fishing effort)

``` r
total_pings_ts <- dat %>% 
  group_by(year_month_date) %>% 
  summarise(totpings=sum(n_vms_records))
total_pings_ts %>%
  ggplot(aes(year_month_date,totpings))+geom_line()+labs(x="Date",y="Total Pings")
```

![](persistence-mapping_files/figure-commonmark/unnamed-chunk-7-1.png)

``` r
positive_area_ts <- dat %>% 
  left_join(grid5k_final,by="GRID5KM_ID") %>% 
  group_by(year_month_date) %>% 
  summarise(totarea=sum(AREA))
positive_area_ts %>%
  ggplot(aes(year_month_date,totarea/1e6))+geom_line()+labs(x="Date",y="Total Area Fished (sq.km)")
```

![](persistence-mapping_files/figure-commonmark/unnamed-chunk-7-2.png)

## Months Fished

Total number of months each grid cell was fished, out of the 13 possible
months in this dataset. Clear already here are the “core” areas near
shore and near ports that are fished most continuously. (Editorial
comment- even though this is one of the simplest ways to summarise
effort, it also seems like one of the most clear, and least
assumption-driven)

``` r
make_map_coastwide(dat_summs_grid,nmonths)+ggtitle("Number of Months Fished")
```

![](persistence-mapping_files/figure-commonmark/unnamed-chunk-8-1.png)

``` r
make_map_zones(dat_summs_grid,nmonths)
```

![](persistence-mapping_files/figure-commonmark/unnamed-chunk-8-2.png)

## Average monthly landings

In pounds and in revenue.

``` r
make_map_coastwide(dat_summs_grid,mean_lbs)+scale_fill_viridis(transform="sqrt",na.value='white',option='turbo')+ggtitle("Mean Monthly Landings")
```

    Scale for fill is already present.
    Adding another scale for fill, which will replace the existing scale.

![](persistence-mapping_files/figure-commonmark/unnamed-chunk-9-1.png)

``` r
make_map_zones_sqrt(dat_summs_grid,mean_lbs)
```

![](persistence-mapping_files/figure-commonmark/unnamed-chunk-9-2.png)

``` r
make_map_coastwide(dat_summs_grid,mean_rev)+scale_fill_viridis(transform="sqrt",na.value='white',option='turbo')+ggtitle("Mean Monthly Revenue")
```

    Scale for fill is already present.
    Adding another scale for fill, which will replace the existing scale.

![](persistence-mapping_files/figure-commonmark/unnamed-chunk-9-3.png)

``` r
make_map_zones_sqrt(dat_summs_grid,mean_rev)
```

![](persistence-mapping_files/figure-commonmark/unnamed-chunk-9-4.png)

## VMS Records

Mean, max, and CV in pings/month.

``` r
make_map_coastwide(dat_summs_grid,mean_vms_records)+ggtitle("Mean Monthly VMS pings")
```

![](persistence-mapping_files/figure-commonmark/unnamed-chunk-10-1.png)

``` r
make_map_zones(dat_summs_grid,mean_vms_records)
```

![](persistence-mapping_files/figure-commonmark/unnamed-chunk-10-2.png)

``` r
make_map_coastwide(dat_summs_grid,max_vms_records)+ggtitle("Max Monthly VMS pings")
```

![](persistence-mapping_files/figure-commonmark/unnamed-chunk-10-3.png)

``` r
make_map_zones(dat_summs_grid,max_vms_records)
```

![](persistence-mapping_files/figure-commonmark/unnamed-chunk-10-4.png)

``` r
make_map_coastwide(dat_summs_grid,cv_vms_records)+ggtitle("CV Monthly VMS pings")
```

![](persistence-mapping_files/figure-commonmark/unnamed-chunk-10-5.png)

``` r
make_map_zones(dat_summs_grid,cv_vms_records)
```

![](persistence-mapping_files/figure-commonmark/unnamed-chunk-10-6.png)

## Number of Vessels

These data are screened for confidentiality, and so will be limited to
cells with \>=3 unique vessels in any given month. With that said, we
can still look at the distribution of vessel activity, and map the mean
number of unique vessels per grid cell per month.

``` r
# distribution of n_unique_vessels in the pre-summarized data
dat %>% 
  ggplot(aes(n_unique_vessels))+
  geom_density()+
  labs(title="Number of Unique Vessels per Month\n(unsummarized data)",x="Number of Unique Vessels")
```

![](persistence-mapping_files/figure-commonmark/unnamed-chunk-11-1.png)

``` r
# now the same in the cross-months, summarized version
dat_summs %>% 
  ggplot(aes(mean_unique_vessels))+
  geom_density()+
  labs(title="Mean Number of Unique Vessels per Month\n(summarized data)",x="Mean Number of Unique Vessels")
```

![](persistence-mapping_files/figure-commonmark/unnamed-chunk-11-2.png)

We can map this as well

``` r
make_map_coastwide(dat_summs_grid,mean_unique_vessels)+ggtitle("Mean Monthly Unique Vessels")
```

![](persistence-mapping_files/figure-commonmark/unnamed-chunk-12-1.png)

``` r
make_map_zones(dat_summs_grid,mean_unique_vessels)
```

![](persistence-mapping_files/figure-commonmark/unnamed-chunk-12-2.png)

``` r
make_map_coastwide(dat_summs_grid,sd_unique_vessels)+ggtitle("SD Monthly Unique Vessels")
```

![](persistence-mapping_files/figure-commonmark/unnamed-chunk-12-3.png)

``` r
make_map_zones(dat_summs_grid,sd_unique_vessels)
```

![](persistence-mapping_files/figure-commonmark/unnamed-chunk-12-4.png)

``` r
#mean/variance relationship- are the places with the most effort also have the most variable effort?
dat_summs %>% 
  ggplot(aes(mean_unique_vessels,sd_unique_vessels^2))+
  geom_point()+
  geom_smooth()+
  labs(x="Mean Unique Vessels per Month",y="Variance in Vessels")
```

    `geom_smooth()` using method = 'loess' and formula = 'y ~ x'

    Warning: Removed 249 rows containing non-finite outside the scale range
    (`stat_smooth()`).

    Warning: Removed 249 rows containing missing values or values outside the scale range
    (`geom_point()`).

![](persistence-mapping_files/figure-commonmark/unnamed-chunk-12-5.png)

There is a strong relationship here (not unexpected). This means that
the grid cells with the highest vessel traffic also have the most
variable traffic.

## CPUE

We can define catch per unit effort as total landings (lbs) divided by
total pings (our best measure of effort). We calculate this at the grid
cell/month level, then roll it up to a mean across time.

``` r
dat_cpue <- dat %>% 
  mutate(cpue=dcrb_lbs/n_vms_records)
dat_cpue %>% 
  ggplot(aes(as.factor(year_month_date),cpue))+
  geom_boxplot()+
  labs(x="Date",y="Landings/Pings (CPUE)",title="CPUE across grid cells")+
  theme(axis.text.x=element_text(angle=45,vjust=0.5))
```

![](persistence-mapping_files/figure-commonmark/unnamed-chunk-13-1.png)

Now, summarize across months

``` r
dat_cpue_summ <- dat_cpue %>% 
  group_by(GRID5KM_ID) %>% 
  summarise(mean_cpue=mean(cpue))
dat_cpue_grid <- grid5k_final %>% 
  left_join(dat_cpue_summ,by="GRID5KM_ID") %>% 
  # fill in zeroes
  mutate(mean_cpue=coalesce(mean_cpue,0L))
```

``` r
make_map_coastwide(dat_cpue_grid,mean_cpue)+ggtitle("Mean CPUE")
```

![](persistence-mapping_files/figure-commonmark/unnamed-chunk-15-1.png)

``` r
make_map_zones(dat_cpue_grid,mean_cpue)
```

![](persistence-mapping_files/figure-commonmark/unnamed-chunk-15-2.png)

Something to notice here that is a little different than these other,
correlated maps: You can see a signal of high cpue in some of the more
offshore edges of the fished area, particularly in N. California around
Cape Mendocino. I think this likely reflects the reality of the early
season derby: at the beginning of the season, when crab densities are
high, there may be high catch rates everywhere, but only some vessels
(maybe because of size, weather, safety, power, etc.) are able to access
the lucrative (i.e., high CPUE), more offshore grid cells. Later in the
season, as the stock gets fished down, there is a retraction of effort
towards shore. As seen in the “Months Fished” maps above, these “core”
areas closer to shore get more consistent effort across the fishing
season, meaning that, on average, CPUE might be lower in those places.

The reason to consider these differences between effort maps and CPUE
maps is because while some grid cells may be important core areas for
the entirety of the crab season, certain other, offshore areas may be
the most desirable (if ephemeral) opportunities for high catch rates,
particularly in the early season.

# Cumulative Effort

Summarize total effort by summing up total pings, lbs, and revenue
across time for each grid cell. Presumably, this should look quite
similar to some of the other maps above.

``` r
dat_cume <- dat %>% 
  group_by(GRID5KM_ID) %>% 
  summarise(tot_pings=sum(n_vms_records),
            tot_lbs=sum(dcrb_lbs),
            tot_rev=sum(dcrb_rev)) %>% 
  ungroup()

dat_cume_grid <- grid5k_final %>% 
  left_join(dat_cume,by="GRID5KM_ID") %>% 
  # fill in zeroes
  mutate(across(contains("tot"),~coalesce(.,0L)))
```

``` r
make_map_coastwide(dat_cume_grid,tot_pings)+scale_fill_viridis(transform="sqrt",na.value='white',option='turbo')+ggtitle("Total Pings")
```

    Scale for fill is already present.
    Adding another scale for fill, which will replace the existing scale.

![](persistence-mapping_files/figure-commonmark/unnamed-chunk-17-1.png)

``` r
make_map_zones_sqrt(dat_cume_grid,tot_pings)
```

![](persistence-mapping_files/figure-commonmark/unnamed-chunk-17-2.png)

``` r
make_map_coastwide(dat_cume_grid,tot_lbs)+scale_fill_viridis(transform="sqrt",na.value='white',option='turbo')+ggtitle("Total Landed Pounds")
```

    Scale for fill is already present.
    Adding another scale for fill, which will replace the existing scale.

![](persistence-mapping_files/figure-commonmark/unnamed-chunk-17-3.png)

``` r
make_map_zones_sqrt(dat_cume_grid,tot_lbs)
```

![](persistence-mapping_files/figure-commonmark/unnamed-chunk-17-4.png)

``` r
make_map_coastwide(dat_cume_grid,tot_rev)+scale_fill_viridis(transform="sqrt",na.value='white',option='turbo')+ggtitle("Total Revenue")
```

    Scale for fill is already present.
    Adding another scale for fill, which will replace the existing scale.

![](persistence-mapping_files/figure-commonmark/unnamed-chunk-17-5.png)

``` r
make_map_zones_sqrt(dat_cume_grid,tot_rev)
```

![](persistence-mapping_files/figure-commonmark/unnamed-chunk-17-6.png)

# Quantiles

Another, relatively simple summary of these data is to look at
quantiles; that is, to rank-order the average amount of fishing effort
in each grid cell. This will allow us to, e.g., describe where the top
XX% of effort is located (time-averaged).

For now, we do calculate quantiles with total pings (mean and max), but
we could do this with other attributes as well (e.g., landings,
revenue).

``` r
# add a quantile attribute to the summary
dat_summ_quants <- dat_summs %>% 
  mutate(quant_mean_vms_records=cume_dist(mean_vms_records),
         quant_max_vms_records=cume_dist(max_vms_records))

# are these two measures extremely tightly correlated?
dat_summ_quants %>% 
  ggplot(aes(quant_mean_vms_records,quant_max_vms_records))+
  geom_point()+
  geom_smooth(method='lm',se=F)+
  geom_abline(slope=1,intercept=0,linetype=2,color='red')+
  labs(x="Quantile Using Mean Pings",y="Quantile Using Max Pings")
```

    `geom_smooth()` using formula = 'y ~ x'

![](persistence-mapping_files/figure-commonmark/unnamed-chunk-18-1.png)

``` r
dat_quants_grid <- grid5k_final %>% 
  left_join(dat_summ_quants,by="GRID5KM_ID") %>% 
  # fill in zeroes
  mutate(across(contains("quant"),~coalesce(.,0L)))

make_map_coastwide(dat_quants_grid,quant_mean_vms_records)+labs(title="Quantile (Mean Monthly Pings)",fill="")
```

![](persistence-mapping_files/figure-commonmark/unnamed-chunk-19-1.png)

``` r
make_map_zones(dat_quants_grid,quant_mean_vms_records)
```

![](persistence-mapping_files/figure-commonmark/unnamed-chunk-19-2.png)

``` r
make_map_coastwide(dat_quants_grid,quant_max_vms_records)+labs(title="Quantile (Max Monthly Pings)",fill="")
```

![](persistence-mapping_files/figure-commonmark/unnamed-chunk-19-3.png)

``` r
make_map_zones(dat_quants_grid,quant_max_vms_records)
```

![](persistence-mapping_files/figure-commonmark/unnamed-chunk-19-4.png)

We could even make this binary, e.g., we could ask, “where are the top
20% of fished grid cells, based on mean pings”?

``` r
dat_quants_grid_top20 <- dat_quants_grid %>% 
  mutate(top20_bin=ifelse(quant_mean_vms_records>=0.8,"Top 20%","Bottom 80%"))

make_map_coastwide(dat_quants_grid_top20,top20_bin)+labs(title="Top 20% Most Fished",fill="")+scale_fill_manual(values=c("lightblue","darkgreen"))
```

    Scale for fill is already present.
    Adding another scale for fill, which will replace the existing scale.

![](persistence-mapping_files/figure-commonmark/unnamed-chunk-20-1.png)
