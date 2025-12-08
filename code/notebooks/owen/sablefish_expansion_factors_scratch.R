library(tidyverse)
library(here)

dat <- read_csv(here("FG.OBS.RATE.POT.csv"))
datNA<- read_csv(here("FG.OBS.RATE.POT.NA.csv"))

x <- dat %>% 
  filter(is.na(OBS_HAULS))

# total observed vs. unobserved
datsumm <- dat %>% 
  group_by(SubSector,YEAR) %>%
  # FT
  summarise(totobsFT=sum(OBS_FT,na.rm=T),
            tot_unob_FT=sum(FT[is.na(OBS_FT)]),
            totFT=sum(FT),
            # VESSELS
            totobsVESSELS=sum(OBS_VESSELS,na.rm=T),
            tot_unob_VESSELS=sum(VESSELS[is.na(OBS_VESSELS)]),
            totVESSELS=sum(VESSELS),
            #TRIPS
            totobsTRIPS=sum(OBS_TRIPS,na.rm=T),
            tot_unob_TRIPS=sum(TRIPS[is.na(OBS_TRIPS)]),
            totTRIPS=sum(TRIPS)) %>% 
  ungroup()

datsumm %>% ggplot(aes(x=YEAR))+
  geom_col(aes(y=totFT),fill='#33cccc')+
  geom_col(aes(y=tot_unob_FT),fill='gray50')+
  facet_wrap(~SubSector,scales="free_y")+
  labs(y="Number of Tickets\n(gray:tix from unobserved ports; blue:total tix)")

datsumm %>% ggplot(aes(x=YEAR))+
  geom_col(aes(y=totVESSELS),fill='#33cccc')+
  geom_col(aes(y=tot_unob_VESSELS),fill='gray50')+
  facet_wrap(~SubSector,scales="free_y")+
  labs(y="Number of Vessels\n(gray:vessels from unobserved ports; blue:total vessels)")

datsumm %>% ggplot(aes(x=YEAR))+
  geom_col(aes(y=totTRIPS),fill='#33cccc')+
  geom_col(aes(y=tot_unob_TRIPS),fill='gray50')+
  facet_wrap(~SubSector,scales="free_y")+
  labs(y="Number of Trips\n(gray:trips from unobserved ports; blue:total trips)")

#742x462