#Analysis script for Dymecki lab CP pipeline
#libraries
library(ggplot2)
library(here)
library(dplyr)
library(RColorBrewer)
library(readr)

#paths NOTE YOU NEED TO CHANGE THESE TO RUN ON YOUR LOCAL MACHINE
path_to_csv_folder = "/Users/rsenft/Documents/GitHub/RebeccaSenft_Projects/002_Dymecki_neuro/Batch_3_analysis/"
save_path <- path_to_csv_folder
filename="Tph2_Per_Image_metadata_corrected.csv"
metadata_filename="Litter-groups-A-through-ii.csv" #note I gave this headings

#process data
df <- read.csv(paste0(path_to_csv_folder,filename), check.names=FALSE)
metadata <- read.csv(paste0(path_to_csv_folder,metadata_filename), check.names = FALSE)
df_combined <- merge(df, metadata, by.x="Image_Metadata_Litter", by.y="Litter")

#ignore for now:
cols2summarize <- names(df)[grepl("*Area*|*Intensity*|*Neighbor*", names(df))] #get columns with Area or Intensity in column name

df_summary_mean <- df_combined %>% 
  group_by(ExpGroup, Image_Metadata_Mouse, Image_Metadata_Region) %>%
  summarize(across(all_of(cols2summarize), mean))

#Cell counts grouped by ExpGroup, Mouse, Region
df_summary_ind_imagecount <- df_combined %>% 
  group_by(ExpGroup, Image_Metadata_Mouse, Image_Metadata_Region) %>% 
  tally() %>% dplyr::rename(n_image = n)

df_summary_ind_cellcount <- df_combined %>% 
  group_by(ExpGroup, Image_Metadata_Mouse, Image_Metadata_Region) %>% 
  summarize(across(c(Image_Count_Cells, Image_Count_Cells_with_nuclei), list(mean = mean, sd = sd, sum=sum)))

df_summary_ind <- merge(df_summary_ind_cellcount, df_summary_ind_imagecount, by=c("ExpGroup", "Image_Metadata_Mouse", "Image_Metadata_Region"))

df_summary_ind <- df_summary_ind %>% dplyr::mutate(avg_cells_per_image = Image_Count_Cells_sum / n_image) #change to Image_Count_Cell_sum from mean
df_summary_ind <- df_summary_ind %>% dplyr::mutate(avg_cells_with_nuclei_per_image = Image_Count_Cells_with_nuclei_sum / n_image) #change to Image_Count_Cells_with_Nuclei_sum from mean
write.csv(df_summary_ind, file=paste0(save_path, "Cell_counts_ind.csv"))

#Cell counts grouped by ExpGroup, Region

df_summary_group_mouseCount <- df_summary_ind %>% group_by(ExpGroup,Image_Metadata_Region) %>% 
  tally() %>% dplyr::rename(n_mice = n)

df_summary_group_cellCount <- df_summary_ind %>% 
  select(-ends_with("sd")) %>% 
  group_by(ExpGroup, Image_Metadata_Region) %>% 
  summarize(across(starts_with("Image_Count"), list(mean = mean, sd = sd)))

df_summary_group <- merge(df_summary_group_cellCount, df_summary_group_mouseCount, by=c("ExpGroup", "Image_Metadata_Region"))
write.csv(df_summary_group, file=paste0(save_path, "Cell_counts_group.csv"))


# Plot
pal=c("#FFE66D",  "#C2CAE8", "#FF4365", "#00D9C0", "#F26419", "#86BBD8")
pal_dark=c("#A38800",  "#273568","#FF6B6B", "#FF4365", "#00D9C0", "#F26419", "#86BBD8")

# avg cells per image
ggplot(df_summary_ind, aes(x=Image_Metadata_Region, y=avg_cells_per_image, fill=ExpGroup))+
  scale_fill_manual(values=pal)+
  geom_boxplot(position = position_dodge(0.9))+
  geom_jitter(position = position_dodge(0.9), alpha=0.8, aes(color=ExpGroup))+
  scale_color_manual(values=pal_dark)+
  stat_summary(fun=mean, geom="point", shape=18,
               position = position_dodge(0.9),
               size=3, color="firebrick")+
  #geom_jitter(position = position_dodge(0.9), alpha=0.4)+
  labs(title="Avg. Number of Tph2 Neurons / Image", 
       subtitle="Each dot represents 1 animal",
       caption="Source: Batch 3",
       x="Region",
       y="Tph2 Count")

# avg cells with nuclei per image
ggplot(df_summary_ind, aes(x=Image_Metadata_Region, y=avg_cells_with_nuclei_per_image, fill=ExpGroup))+
  scale_fill_manual(values=pal)+
  geom_boxplot(position = position_dodge(0.9))+
  geom_jitter(position = position_dodge(0.9), alpha=0.8, aes(color=ExpGroup))+
  scale_color_manual(values=pal_dark)+
  stat_summary(fun=mean, geom="point", shape=18,
               position = position_dodge(0.9),
               size=3, color="firebrick")+
  #geom_jitter(position = position_dodge(0.9), alpha=0.4)+
  labs(title="Avg. Number of Tph2 Neurons with nuclei / Image", 
       subtitle="Each dot represents 1 animal",
       caption="Source: Batch 3",
       x="Region",
       y="Tph2 Count")

# number of neighbors
ggplot(df_summary_ind, aes(x=Image_Metadata_Region, y=avg_cells_with_nuclei_per_image, fill=ExpGroup))+
  scale_fill_manual(values=pal)+
  geom_boxplot(position = position_dodge(0.9))+
  geom_jitter(position = position_dodge(0.9), alpha=0.8, aes(color=ExpGroup))+
  scale_color_manual(values=pal_dark)+
  stat_summary(fun=mean, geom="point", shape=18,
               position = position_dodge(0.9),
               size=3, color="firebrick")+
  #geom_jitter(position = position_dodge(0.9), alpha=0.4)+
  labs(title="Avg. Number of Tph2 Neurons with nuclei / Image", 
       subtitle="Each dot represents 1 animal",
       caption="Source: Batch 3",
       x="Region",
       y="Tph2 Count")

#t test for MR on avg # per image
grp1 <- df_summary_ind %>% filter(Image_Metadata_Region=="MR", ExpGroup=="11% IH") %>% select(avg_cells_per_image)
grp2 <- df_summary_ind %>% filter(Image_Metadata_Region=="MR", ExpGroup=="RA") %>% select(avg_cells_per_image)
t.test(grp1, grp2)


## Add metadata onto all cell measurements.
metadata_df <- read_csv(here("Batch_3_analysis", "Metadata.csv"))
Tph2_per_Cell <- read_csv(here("Batch_3_analysis", "Tph2_Per_Cells_with_nuclei.csv"))

litter_key <- read_csv(here("Batch_3_analysis", "Litter-groups-A-through-ii.csv"))

merged_df <- merge(metadata_df, Tph2_per_Cell, by="ImageNumber")
merged_df <- merge(litter_key, merged_df, by.x="Litter", by.y="Image_Metadata_Litter")
write.csv(merged_df,file=here("Batch_3_analysis", "Tph2_Per_Cells_with_nuclei_plus_key.csv"))

# all tph2 neurons: 
Tph2_per_Cell_all <- read_csv(here("Batch_3_analysis", "Tph2_Per_Cells.csv"))
merged_df_allCells <- merge(metadata_df, Tph2_per_Cell_all, by="ImageNumber")
merged_df_allCells <- merge(litter_key, merged_df_allCells, by.x="Litter", by.y="Image_Metadata_Litter")
write.csv(merged_df,file=here("Batch_3_analysis", "Tph2_Per_Cells_plus_key.csv"))

## graph the features that show up as significant in morpheus
feature_list <- c("Cells_with_nuclei_AreaShape_Orientation", 
             "Cells_with_nuclei_Intensity_LowerQuartileIntensity_Tph2",
             "Cells_with_nuclei_AreaShape_FormFactor",
             "Cells_with_nuclei_Intensity_MinIntensityEdge_Tph2",
             "Cells_with_nuclei_Intensity_MinIntensity_Tph2",
             "Cells_with_nuclei_AreaShape_Extent",
             "Cells_with_nuclei_Intensity_MedianIntensity_Tph2",
             "Cells_with_nuclei_AreaShape_MaxFeretDiameter",
             "Cells_with_nuclei_Intensity_MaxIntensity_DNA",
             "Cells_with_nuclei_Intensity_StdIntensity_DNA"
)

tph2_feature_list <- c("Cells_with_nuclei_Intensity_LowerQuartileIntensity_Tph2",
                  "Cells_with_nuclei_Intensity_MedianIntensity_Tph2",
                  "Cells_with_nuclei_Intensity_LowerQuartileIntensity_Tph2",
                  "Cells_with_nuclei_Intensity_MeanIntensity_Tph2"
)
plot_list <- lapply(feature_list, plot_my, merged_df)
cowplot::plot_grid(plotlist = plot_list, ncol=2)

plot_list_all <- lapply(feature_list, plot_my_all, merged_df)
cowplot::plot_grid(plotlist = plot_list_all, ncol=2)

tph2_plot_list_all <- lapply(tph2_feature_list, plot_my_all, merged_df)
cowplot::plot_grid(plotlist = tph2_plot_list_all, ncol=2)

plot_my_all("Cells_Neighbors_PercentTouching_20", merged_df_allCells)

plot_my <- function(feature, merged_df){
  ggplot(merged_df, aes(x=ExpGroup, y=get(feature), fill=ExpGroup))+
    scale_fill_manual(values=pal)+
    geom_violin(position = position_dodge(0.9))+
    geom_jitter(position = position_dodge(0.9), alpha=0.01, aes(color=ExpGroup))+
    geom_boxplot(position = position_dodge(0.9), outlier.shape = NA, width=0.2)+

    scale_color_manual(values=pal_dark)+
    stat_summary(fun=mean, geom="point", shape=18,
                 position = position_dodge(0.9),
                 size=3, color="firebrick")+
    labs(title=feature, 
         subtitle="Each dot represents 1 cell",
         caption="Source: Batch 3",
         x="Region",
         y="Tph2 Count")
}
plot_my_all <- function(feature, merged_df){
  ggplot(merged_df, aes(x=Image_Metadata_Region, y=get(feature), fill=ExpGroup))+
    scale_fill_manual(values=pal)+
    geom_violin(position = position_dodge(0.9))+
    geom_boxplot(position = position_dodge(0.9), width=0.2, outlier.shape = NA)+
    #geom_jitter(position = position_dodge(0.9), alpha=0.01, aes(color=ExpGroup))+
    scale_color_manual(values=pal_dark)+
    stat_summary(fun=mean, geom="point", shape=18,
                 position = position_dodge(0.9),
                 size=3, color="firebrick")+
    labs(title=feature, 
         subtitle="Each dot represents 1 cell",
         caption="Source: Batch 3",
         x="Region",
         y="Tph2 Count")
}

## t tests
IH <- subset(merged_df, ExpGroup=="11% IH")
RA <- subset(merged_df, ExpGroup=="RA")

t.test(IH$Cells_with_nuclei_Intensity_StdIntensity_DNA, RA$Cells_with_nuclei_Intensity_StdIntensity_DNA)

prettify_name_numeric <- function(df){
  numeric_names <- colnames(select_if(df, is.numeric))
  categories <- sub("_.*", "", numeric_names)
  measurements <- sub(".*?_", "", numeric_names)
  output_list <- split(measurements, categories)
  return(output_list)
}
