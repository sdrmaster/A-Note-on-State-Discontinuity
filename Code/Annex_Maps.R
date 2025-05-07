# List of required packages
required_packages <- c("dplyr", "ggplot2", "ggpubr", "readxl", "sf")
# Install missing packages
for (pkg in required_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg)
  }
}
# Load necessary libraries
library(ggplot2)
library(readxl)
library(dplyr)
library(sf)
library(ggpubr)
# Clear all
rm(list = ls())

# Working Directory
setwd("C:/Users/sdavi/OneDrive/Desktop/Reproducibility_Package")


# Define the countries and their respective codes
country_codes <- c("geo1_am2001", "geo1_bj2013", "geo1_br2010", "geo1_cr2011", "geo1_hn2001", "geo1_ht2003", "geo1_la2005", "geo1_ml2009", "geo1_mz2007")

# DENSITY
# Loop through each country code
for (code in country_codes) {
  
  # Import dataset
  density_data <- read_excel("Data/Cleaned/new/density_maps.xlsx")
  
  # Filter dataset
  density_data <- density_data %>% filter(isoc == code)
  
  # Rename column for merging
  names(density_data)[names(density_data) == "region"] <- "ADMIN_NAME"
  
  
  
  # Define the shapefile path
  shapefile_path <- paste0("Data/Raw/Shapefiles/", code, "/", code, ".shp")
  
  
  # Read shapefile with conditional encoding
  if (code == "geo1_ml2009") {
    country_sf <- st_read(shapefile_path, options = "ENCODING=LATIN1")
  } else if (code == "geo1_mz2007") {
    country_sf <- st_read(shapefile_path, options = "ENCODING=LATIN1")
  } else {
    country_sf <- st_read(shapefile_path)
  }
  
  # Merge data frames
  merged_density_sf <- merge(country_sf, density_data, by = "ADMIN_NAME")
  
  # Calculate the centroids of the polygons and create a new data frame for labeling
  centroid_data <- st_centroid(merged_density_sf)
  label_data <- data.frame(ADMIN_NAME = merged_density_sf$ADMIN_NAME, x = st_coordinates(centroid_data)[, "X"], y = st_coordinates(centroid_data)[, "Y"])
  
  
  decile_colors <- c("Decile 1" = "#fef8e4",  # Very Light Orange
                     "Decile 2" = "#ffeda0",
                     "Decile 3" = "#f7d68a",
                     "Decile 4" = "#f1c27e",
                     "Decile 5" = "#fbb46c",
                     "Decile 6" = "#fb9b3e",
                     "Decile 7" = "#fa821e",
                     "Decile 8" = "#e56b1f",
                     "Decile 9" = "#d45a1e",
                     "Decile 10" = "#c14e1d")  # Dark Orange
  
  # Create the plot
  countries_decile <- ggplot() +
    geom_sf(data = merged_density_sf, size = 0.1, aes(fill = decile), color = "black") +
    # Use color scale
    scale_fill_manual(values=decile_colors) +  
    labs(title = "", 
         fill = "Density", 
         x = NULL, 
         y = NULL) + 
    theme_minimal() +
    #Add state labels
    geom_text(data = label_data, aes(x = x, y = y, label = ADMIN_NAME), color = ifelse(merged_density_sf$decile %in% c("Decile 7", "Decile 8", "Decile 9", "Decile 10"), "white", "black"),
              size = 2, nudge_y = 0.1, check_overlap = TRUE) +
    theme(legend.position = "none",
          legend.title = element_text(size = 12),
          legend.text = element_text(size = 10),
          plot.title = element_text(size = 20, hjust = 0.5),
          axis.text = element_blank(),
          axis.title = element_blank(),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          plot.background = element_rect(fill = "white", colour = "white")) +
    if (code == "geo1_am2001") {
      labs(title = "Armenia") 
    } else if (code == "geo1_bj2013") {
      labs(title = "Benin") 
    } else if (code == "geo1_br2010") {
      labs(title = "Brazil") 
    } else if (code == "geo1_cr2011") {
      labs(title = "Costa Rica") 
    } else if (code == "geo1_hn2001") {
      labs(title = "Honduras") 
    } else if (code == "geo1_ht2003") {
      labs(title = "Haiti") 
    } else if (code == "geo1_la2005") {
      labs(title = "Laos") 
    } else if (code == "geo1_ml2009") {
      labs(title = "Mali") 
    } else {
      labs(title = "Mozambique") 
    } 
    
  if (code == "geo1_am2001") {
    density_geo1_am2001 <- countries_decile
  } else if (code == "geo1_bj2013") {
    density_geo1_bj2013 <- countries_decile
  } else if (code == "geo1_br2010") {
    density_geo1_br2010 <- countries_decile
  } else if (code == "geo1_cr2011") {
    density_geo1_cr2011 <- countries_decile
  } else if (code == "geo1_hn2001") {
    density_geo1_hn2001 <- countries_decile
  } else if (code == "geo1_ht2003") {
    density_geo1_ht2003 <- countries_decile 
  } else if (code == "geo1_la2005") {
    density_geo1_la2005 <- countries_decile
  } else if (code == "geo1_ml2009") {
    density_geo1_ml2009 <- countries_decile
  } else {
    density_geo1_mz2007 <- countries_decile
  }
  }

#EFFECTIVENESS

#Health - Children surviving
# Loop through each country code
for (code in country_codes) {
  
  # Import dataset
  effectiveness_data <- read_excel("Data/Cleaned/new/effectiveness_maps.xlsx")
  
  # Filter dataset
  effectiveness_data <- effectiveness_data %>% filter(isoc == code)
  effectiveness_data <- effectiveness_data %>% filter(indicator_vector == "child_surv")
  
  # Rename column for merging
  names(effectiveness_data)[names(effectiveness_data) == "region"] <- "ADMIN_NAME"
  
  # Define the shapefile path
  shapefile_path <- paste0("Data/Raw/Shapefiles/", code, "/", code, ".shp")
  
  # Read shapefile with conditional encoding
  if (code == "geo1_ml2009") {
    country_sf <- st_read(shapefile_path, options = "ENCODING=LATIN1")
  } else if (code == "geo1_mz2007") {
    country_sf <- st_read(shapefile_path, options = "ENCODING=LATIN1")
  } else {
    country_sf <- st_read(shapefile_path)
  }
  # Merge data frames
  merged_effectiveness_sf <- merge(country_sf, effectiveness_data, by = "ADMIN_NAME")
  
  # Calculate the centroids of the polygons and create a new data frame for labeling
  centroid_data <- st_centroid(merged_effectiveness_sf)
  label_data <- data.frame(ADMIN_NAME = merged_effectiveness_sf$ADMIN_NAME, x = st_coordinates(centroid_data)[, "X"], y = st_coordinates(centroid_data)[, "Y"])
  
  # Green Palette with more contrast
  decile_colors <- c(
    "Decile 1" = "#E5F5E0",  # Very light green
    "Decile 2" = "#D3EDCC",  # Light pastel green
    "Decile 3" = "#C1E5B8",  # Light fresh green
    "Decile 4" = "#B0DEA4",  # Soft medium green
    "Decile 5" = "#9ED690",  # Medium green
    "Decile 6" = "#8CCF7D",  # Stronger green
    "Decile 7" = "#7BC769",  # Darker green
    "Decile 8" = "#69C055",  # Deep green
    "Decile 9" = "#57B841",  # Darker, saturated green
    "Decile 10" = "#46B12E"  # Very dark green
  )
  
  
  # Create the plot
  countries_effectiveness <- ggplot() +
    geom_sf(data = merged_effectiveness_sf, size = 0.1, aes(fill = decile), color = "black") +
    # Use color scale
    scale_fill_manual(values=decile_colors) +
    labs(title = "d. Health", 
         fill = "", 
         x = NULL, 
         y = NULL) +
    theme_minimal() +
    #Add state labels
    geom_text(data = label_data, aes(x = x, y = y, label = ADMIN_NAME), color = ifelse(merged_effectiveness_sf$decile %in% c("Decile 7", "Decile 8", "Decile 9", "Decile 10"), "white", "black"),
              size = 2, nudge_y = 0.1, check_overlap = TRUE) +
    theme(legend.position = "none",
          legend.title = element_text(size = 12),
          legend.text = element_text(size = 10),
          plot.title = element_text(size = 20, hjust = 0.5),
          axis.text = element_blank(),
          axis.title = element_blank(),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          plot.background = element_rect(fill = "white", colour = "white"))
  # conditional encoding
  if (code == "geo1_am2001") {
    health_effect_geo1_am2001 <- countries_effectiveness
  } else if (code == "geo1_bj2013") {
    health_effect_geo1_bj2013 <- countries_effectiveness
  } else if (code == "geo1_br2010") {
    health_effect_geo1_br2010 <- countries_effectiveness
  } else if (code == "geo1_cr2011") {
    health_effect_geo1_cr2011 <- countries_effectiveness
  } else if (code == "geo1_hn2001") {
    health_effect_geo1_hn2001 <- countries_effectiveness
  } else if (code == "geo1_ht2003") {
    health_effect_geo1_ht2003 <- countries_effectiveness
  } else if (code == "geo1_la2005") {
    health_effect_geo1_la2005 <- countries_effectiveness
  } else if (code == "geo1_ml2009") {
    health_effect_geo1_ml2009 <- countries_effectiveness
  } else {
    health_effect_geo1_mz2007 <- countries_effectiveness
  }
}
# Basic services - Electricity

# Loop through each country code
for (code in country_codes) {
  
  # Import dataset
  effectiveness_data <- read_excel("Data/Cleaned/new/effectiveness_maps.xlsx")
  
  # Filter dataset
  effectiveness_data <- effectiveness_data %>% filter(isoc == code)
  effectiveness_data <- effectiveness_data %>% filter(indicator_vector == "yes_electric")
  
  # Rename column for merging
  names(effectiveness_data)[names(effectiveness_data) == "region"] <- "ADMIN_NAME"
  
  # Define the shapefile path
  shapefile_path <- paste0("Data/Raw/Shapefiles/", code, "/", code, ".shp")
  
  # Read shapefile with conditional encoding
  if (code == "geo1_ml2009") {
    country_sf <- st_read(shapefile_path, options = "ENCODING=LATIN1")
  } else if (code == "geo1_mz2007") {
    country_sf <- st_read(shapefile_path, options = "ENCODING=LATIN1")
  } else {
    country_sf <- st_read(shapefile_path)
  }
  # Merge data frames
  merged_effectiveness_sf <- merge(country_sf, effectiveness_data, by = "ADMIN_NAME")
  
  # Calculate the centroids of the polygons and create a new data frame for labeling
  centroid_data <- st_centroid(merged_effectiveness_sf)
  label_data <- data.frame(ADMIN_NAME = merged_effectiveness_sf$ADMIN_NAME, x = st_coordinates(centroid_data)[, "X"], y = st_coordinates(centroid_data)[, "Y"])
  
  # Define the list of colors
  decile_colors <- c(
    "Decile 1" = "#F4F1E1",
    "Decile 2" = "#E5DECD",
    "Decile 3" = "#D6CCBA",
    "Decile 4" = "#C7B9A7",
    "Decile 5" = "#B8A794",
    "Decile 6" = "#A99480",
    "Decile 7" = "#9A826D",
    "Decile 8" = "#8B6F5A",
    "Decile 9" = "#7C5D47",
    "Decile 10" = "#6E4B34"
  )
  
  # Create the plot
  countries_effectiveness <- ggplot() +
    geom_sf(data = merged_effectiveness_sf, size = 0.1, aes(fill = decile), color = "black") +
    # Use color scale
    scale_fill_manual(values=decile_colors) +
    labs(title = "b. Electricity", 
         fill = "", 
         x = NULL, 
         y = NULL) +
    theme_minimal() +
    #Add state labels
    geom_text(data = label_data, aes(x = x, y = y, label = ADMIN_NAME), color = ifelse(merged_effectiveness_sf$decile %in% c("Decile 7", "Decile 8", "Decile 9", "Decile 10"), "white", "black"),
              size = 2, nudge_y = 0.1, check_overlap = TRUE) +
    theme(legend.position = "none",
          legend.title = element_text(size = 12),
          legend.text = element_text(size = 10),
          plot.title = element_text(size = 20, hjust = 0.5),
          axis.text = element_blank(),
          axis.title = element_blank(),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          plot.background = element_rect(fill = "white", colour = "white"))
  # conditional encoding
  if (code == "geo1_am2001") {
    elec_effect_geo1_am2001 <- countries_effectiveness
  } else if (code == "geo1_bj2013") {
    elec_effect_geo1_bj2013 <- countries_effectiveness
  } else if (code == "geo1_br2010") {
    elec_effect_geo1_br2010 <- countries_effectiveness
  } else if (code == "geo1_cr2011") {
    elec_effect_geo1_cr2011 <- countries_effectiveness
  } else if (code == "geo1_hn2001") {
    elec_effect_geo1_hn2001 <- countries_effectiveness
  } else if (code == "geo1_ht2003") {
    elec_effect_geo1_ht2003 <- countries_effectiveness
  } else if (code == "geo1_la2005") {
    elec_effect_geo1_la2005 <- countries_effectiveness
  } else if (code == "geo1_ml2009") {
    elec_effect_geo1_ml2009 <- countries_effectiveness
  } else {
    elec_effect_geo1_mz2007 <- countries_effectiveness
  }
}



#Basic Services - Water supply
# Loop through each country code
for (code in country_codes) {
  
  # Import dataset
  effectiveness_data <- read_excel("Data/Cleaned/new/effectiveness_maps.xlsx")
  
  # Filter dataset
  effectiveness_data <- effectiveness_data %>% filter(isoc == code)
  effectiveness_data <- effectiveness_data %>% filter(indicator_vector == "yes_watsup")
  
  # Rename column for merging
  names(effectiveness_data)[names(effectiveness_data) == "region"] <- "ADMIN_NAME"
  
  # Define the shapefile path
  shapefile_path <- paste0("Data/Raw/Shapefiles/", code, "/", code, ".shp")
  
  # Read shapefile with conditional encoding
  if (code == "geo1_ml2009") {
    country_sf <- st_read(shapefile_path, options = "ENCODING=LATIN1")
  } else if (code == "geo1_mz2007") {
    country_sf <- st_read(shapefile_path, options = "ENCODING=LATIN1")
  } else {
    country_sf <- st_read(shapefile_path)
  }
  # Merge data frames
  merged_effectiveness_sf <- merge(country_sf, effectiveness_data, by = "ADMIN_NAME")
  
  # Calculate the centroids of the polygons and create a new data frame for labeling
  centroid_data <- st_centroid(merged_effectiveness_sf)
  label_data <- data.frame(ADMIN_NAME = merged_effectiveness_sf$ADMIN_NAME, x = st_coordinates(centroid_data)[, "X"], y = st_coordinates(centroid_data)[, "Y"])
  
  decile_colors <- c(
    "Decile 1" = "#E6F0FF",
    "Decile 2" = "#D6E5FF",
    "Decile 3" = "#C7DAFF",
    "Decile 4" = "#B8CFFF",
    "Decile 5" = "#A8C4FF",
    "Decile 6" = "#99B9FF",
    "Decile 7" = "#8AAEFF",
    "Decile 8" = "#7AA3FF",
    "Decile 9" = "#6B98FF",
    "Decile 10" = "#5C8EFF"
  )
  
  # Create the plot
  countries_effectiveness <- ggplot() +
    geom_sf(data = merged_effectiveness_sf, size = 0.1, aes(fill = decile), color = "black") +
    # Use color scale
    scale_fill_manual(values=decile_colors) +
    labs(title = "a. Water", 
         fill = "", 
         x = NULL, 
         y = NULL) +
    theme_minimal() +
    #Add state labels
    geom_text(data = label_data, aes(x = x, y = y, label = ADMIN_NAME), color = ifelse(merged_effectiveness_sf$decile %in% c("Decile 7", "Decile 8", "Decile 9", "Decile 10"), "white", "black"),
              size = 2, nudge_y = 0.1, check_overlap = TRUE) +
    theme(legend.position = "none",
          legend.title = element_text(size = 12),
          legend.text = element_text(size = 10),
          plot.title = element_text(size = 20, hjust = 0.5),
          axis.text = element_blank(),
          axis.title = element_blank(),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          plot.background = element_rect(fill = "white", colour = "white"))
  # conditional encoding
  if (code == "geo1_am2001") {
    water_effect_geo1_am2001 <- countries_effectiveness
  } else if (code == "geo1_bj2013") {
    water_effect_geo1_bj2013 <- countries_effectiveness
  } else if (code == "geo1_br2010") {
    water_effect_geo1_br2010 <- countries_effectiveness
  } else if (code == "geo1_cr2011") {
    water_effect_geo1_cr2011 <- countries_effectiveness
  } else if (code == "geo1_hn2001") {
    water_effect_geo1_hn2001 <- countries_effectiveness
  } else if (code == "geo1_ht2003") {
    water_effect_geo1_ht2003 <- countries_effectiveness
  } else if (code == "geo1_la2005") {
    water_effect_geo1_la2005 <- countries_effectiveness
  } else if (code == "geo1_ml2009") {
    water_effect_geo1_ml2009 <- countries_effectiveness
  } else {
    water_effect_geo1_mz2007 <- countries_effectiveness
  }
}


#Education
# Loop through each country code
for (code in country_codes) {
  
  # Import dataset
  effectiveness_data <- read_excel("Data/Cleaned/new/effectiveness_maps.xlsx")
  
  # Filter dataset
  effectiveness_data <- effectiveness_data %>% filter(isoc == code)
  effectiveness_data <- effectiveness_data %>% filter(indicator_vector == "literate_perc")
  
  # Rename column for merging
  names(effectiveness_data)[names(effectiveness_data) == "region"] <- "ADMIN_NAME"
  
  # Define the shapefile path
  shapefile_path <- paste0("Data/Raw/Shapefiles/", code, "/", code, ".shp")
  
  # Read shapefile with conditional encoding
  if (code == "geo1_ml2009") {
    country_sf <- st_read(shapefile_path, options = "ENCODING=LATIN1")
  } else if (code == "geo1_mz2007") {
    country_sf <- st_read(shapefile_path, options = "ENCODING=LATIN1")
  } else {
    country_sf <- st_read(shapefile_path)
  }
  # Merge data frames
  merged_effectiveness_sf <- merge(country_sf, effectiveness_data, by = "ADMIN_NAME")
  
  # Calculate the centroids of the polygons and create a new data frame for labeling
  centroid_data <- st_centroid(merged_effectiveness_sf)
  label_data <- data.frame(ADMIN_NAME = merged_effectiveness_sf$ADMIN_NAME, x = st_coordinates(centroid_data)[, "X"], y = st_coordinates(centroid_data)[, "Y"])
  
  # Define the purple color scale for 10 deciles
  decile_colors <- c(
    "Decile 1" = "#F0E6FF",
    "Decile 2" = "#E3DAFF",
    "Decile 3" = "#D6CFFF",
    "Decile 4" = "#CAC4FF",
    "Decile 5" = "#BDB8FF",
    "Decile 6" = "#B1ADFF",
    "Decile 7" = "#A4A2FF",
    "Decile 8" = "#9896FF",
    "Decile 9" = "#8B8BFF",
    "Decile 10" = "#7F80FF"
  )
  
  
  # Create the plot
  countries_effectiveness <- ggplot() +
    geom_sf(data = merged_effectiveness_sf, size = 0.1, aes(fill = decile), color = "black") +
    # Use color scale
    scale_fill_manual(values=decile_colors) +
    labs(title = "c. Education", 
         fill = "", 
         x = NULL, 
         y = NULL) +
    theme_minimal() +
    #Add state labels
    geom_text(data = label_data, aes(x = x, y = y, label = ADMIN_NAME), color = ifelse(merged_effectiveness_sf$decile %in% c("Decile 7", "Decile 8", "Decile 9", "Decile 10"), "white", "black"),
              size = 2, nudge_y = 0.1, check_overlap = TRUE) +
    theme(legend.position = "none",
          legend.title = element_text(size = 12),
          legend.text = element_text(size = 10),
          plot.title = element_text(size = 20, hjust = 0.5),
          axis.text = element_blank(),
          axis.title = element_blank(),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          plot.background = element_rect(fill = "white", colour = "white"))
  # conditional encoding
  if (code == "geo1_am2001") {
    educ_effect_geo1_am2001 <- countries_effectiveness
  } else if (code == "geo1_bj2013") {
    educ_effect_geo1_bj2013 <- countries_effectiveness
  } else if (code == "geo1_br2010") {
    educ_effect_geo1_br2010 <- countries_effectiveness
  } else if (code == "geo1_cr2011") {
    educ_effect_geo1_cr2011 <- countries_effectiveness
  } else if (code == "geo1_hn2001") {
    educ_effect_geo1_hn2001 <- countries_effectiveness
  } else if (code == "geo1_ht2003") {
    educ_effect_geo1_ht2003 <- countries_effectiveness
  } else if (code == "geo1_la2005") {
    educ_effect_geo1_la2005 <- countries_effectiveness
  } else if (code == "geo1_ml2009") {
    educ_effect_geo1_ml2009 <- countries_effectiveness
  } else {
    educ_effect_geo1_mz2007 <- countries_effectiveness
  }
}


#Violence
# Loop through each country code
for (code in country_codes) {
  
  # Import dataset
  effectiveness_data <- read_excel("Data/Cleaned/new/effectiveness_maps.xlsx")
  
  # Filter dataset
  effectiveness_data <- effectiveness_data %>% filter(isoc == code)
  effectiveness_data <- effectiveness_data %>% filter(indicator_vector == "no_violence")
  
  # Rename column for merging
  names(effectiveness_data)[names(effectiveness_data) == "region"] <- "ADMIN_NAME"
  
  # Define the shapefile path
  shapefile_path <- paste0("Data/Raw/Shapefiles/", code, "/", code, ".shp")
  
  # Read shapefile with conditional encoding
  if (code == "geo1_ml2009") {
    country_sf <- st_read(shapefile_path, options = "ENCODING=LATIN1")
  } else if (code == "geo1_mz2007") {
    country_sf <- st_read(shapefile_path, options = "ENCODING=LATIN1")
  } else {
    country_sf <- st_read(shapefile_path)
  }
  # Merge data frames
  merged_effectiveness_sf <- merge(country_sf, effectiveness_data, by = "ADMIN_NAME")
  
  # Calculate the centroids of the polygons and create a new data frame for labeling
  centroid_data <- st_centroid(merged_effectiveness_sf)
  label_data <- data.frame(ADMIN_NAME = merged_effectiveness_sf$ADMIN_NAME, x = st_coordinates(centroid_data)[, "X"], y = st_coordinates(centroid_data)[, "Y"])
  
  # Define a manually created palette with distinct shades of red
  decile_colors <- c(
    "Decile 1" = "#FFE5E5",  # Very light pink
    "Decile 2" = "#F8BDBD",  # Light blush pink
    "Decile 3" = "#F59B9B",  # Soft light red
    "Decile 4" = "#F17A7A",  # Fresh medium red
    "Decile 5" = "#ED5858",  # Stronger red
    "Decile 6" = "#E73636",  # Darker red
    "Decile 7" = "#E31E1E",  # Bold red
    "Decile 8" = "#D41010",  # Deep red
    "Decile 9" = "#C70000",  # Very dark red
    "Decile 10" = "#A70000"  # Almost maroon red
  )
  
  
  # Create the plot
  countries_effectiveness <- ggplot() +
    geom_sf(data = merged_effectiveness_sf, size = 0.1, aes(fill = decile), color = "black") +
    # Use color scale
    scale_fill_manual(values=decile_colors) +
    labs(title = "e. Security", 
         fill = "", 
         x = NULL, 
         y = NULL) +
    theme_minimal() +
    #Add state labels
    geom_text(data = label_data, aes(x = x, y = y, label = ADMIN_NAME), color = ifelse(merged_effectiveness_sf$decile %in% c("Decile 7", "Decile 8", "Decile 9", "Decile 10"), "white", "black"),
              size = 2, nudge_y = 0.1, check_overlap = TRUE) +
    theme(legend.position = "none",
          legend.title = element_text(size = 12),
          legend.text = element_text(size = 10),
          plot.title = element_text(size = 20, hjust = 0.5),
          axis.text = element_blank(),
          axis.title = element_blank(),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          plot.background = element_rect(fill = "white", colour = "white"))
  # conditional encoding
  if (code == "geo1_am2001") {
    sec_effect_geo1_am2001 <- countries_effectiveness
  } else if (code == "geo1_bj2013") {
    sec_effect_geo1_bj2013 <- countries_effectiveness
  } else if (code == "geo1_br2010") {
    sec_effect_geo1_br2010 <- countries_effectiveness
  } else if (code == "geo1_cr2011") {
    sec_effect_geo1_cr2011 <- countries_effectiveness
  } else if (code == "geo1_hn2001") {
    sec_effect_geo1_hn2001 <- countries_effectiveness
  } else if (code == "geo1_ht2003") {
    sec_effect_geo1_ht2003 <- countries_effectiveness
  } else if (code == "geo1_la2005") {
    sec_effect_geo1_la2005 <- countries_effectiveness
  } else if (code == "geo1_ml2009") {
    sec_effect_geo1_ml2009 <- countries_effectiveness
  } else {
    sec_effect_geo1_mz2007 <- countries_effectiveness
  }
}

#Figure A1 - New version
ggarrange(water_effect_geo1_cr2011, elec_effect_geo1_cr2011, educ_effect_geo1_cr2011, health_effect_geo1_cr2011, sec_effect_geo1_cr2011,
          ncol = 5, nrow = 1, align="hv", common.legend = FALSE, widths = c(1, 1, 1, 1, 1))
ggsave("Outputs/Annex/Maps/A1_cr.png", width = 14, height = 5, dpi=500, bg = "white")

#Figure A2 - New version
ggarrange(water_effect_geo1_ml2009, elec_effect_geo1_ml2009, educ_effect_geo1_ml2009, health_effect_geo1_ml2009, sec_effect_geo1_ml2009,
          ncol = 5, nrow = 1, align="hv", common.legend = FALSE, widths = c(1, 1, 1, 1, 1))
ggsave("Outputs/Annex/Maps/A2_ml.png", width = 14, height = 5, dpi=500, bg = "white")

#Figure A3 - New version
ggarrange(water_effect_geo1_mz2007, elec_effect_geo1_mz2007, educ_effect_geo1_mz2007, health_effect_geo1_mz2007, sec_effect_geo1_mz2007,
          ncol = 5, nrow = 1, align="hv", common.legend = FALSE, widths = c(1, 1, 1, 1, 1))
ggsave("Outputs/Annex/Maps/A3_mz.png", width = 14, height = 5, dpi=500, bg = "white")

#Figure A4 - New version
ggarrange(water_effect_geo1_am2001, elec_effect_geo1_am2001, educ_effect_geo1_am2001, health_effect_geo1_am2001, sec_effect_geo1_am2001,
          ncol = 5, nrow = 1, align="hv", common.legend = FALSE, widths = c(1, 1, 1, 1, 1))
ggsave("Outputs/Annex/Maps/A4_am.png", width = 14, height = 5, dpi=500, bg = "white")

#Figure A5 - New version
ggarrange(water_effect_geo1_br2010, elec_effect_geo1_br2010, educ_effect_geo1_br2010, health_effect_geo1_br2010, sec_effect_geo1_br2010,
          ncol = 5, nrow = 1, align="hv", common.legend = FALSE)
ggsave("Outputs/Annex/Maps/A5_br.png", width = 14, height = 5, dpi=500, bg = "white")

#Figure A6 - New version
ggarrange(density_geo1_am2001, density_geo1_bj2013, density_geo1_br2010, density_geo1_cr2011, density_geo1_hn2001, density_geo1_ht2003,density_geo1_la2005, density_geo1_ml2009, density_geo1_mz2007,
          ncol = 5, nrow = 2, align="hv", common.legend = FALSE)
ggsave("Outputs/Annex/Maps/A6_density.png", width = 11, height = 10, dpi=500, bg = "white")

