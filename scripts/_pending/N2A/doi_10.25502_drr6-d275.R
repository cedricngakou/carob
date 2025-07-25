# R script for "carob"

## ISSUES
#RH
# many crazy fertilizer amounts and yields
# we can of course remove these but where to draw the line?
# the entire dataset is suspect and am

# ....


carob_script <- function(path) {

"

    N2Africa is to contribute to increasing biological nitrogen fixation and productivity of grain legumes among African smallholder farmers which will contribute to enhancing soil fertility,
    improving household nutrition and increasing income levels of smallholder farmers. As a vision of success, N2Africa will build sustainable,
    long-term partnerships to enable African smallholder farmers to benefit from symbiotic N2-fixation by grain legumes through effective production technologies including inoculants and fertilizers adapted to local settings.
    A strong national expertise in grain legume production and N2-fixation research and development will be the legacy of the project.
    
    The project is implemented in five core countries (Ghana, Nigeria, Tanzania, Uganda and Ethiopia) and six other countries (DR Congo, Malawi, Rwanda, Mozambique, Kenya & Zimbabwe) as tier one countries.

"

	uri <- "doi:10.25502/drr6-d275"
	group <- "fertilizer"
	ff <- carobiner::get_data(uri, path, group)

	meta <- carobiner::get_metadata(uri, path, group, major=1, minor=0,
		project="N2Africa",
		## if there is a paper, include the paper's doi here
		## also add a RIS file in references folder (with matching doi)
		publication= NA,
		data_organization = "IITA",
		data_type = "survey", # or, e.g. "on-farm experiment", "survey", "compilation"
		carob_contributor = "Eduardo Garcia Bendito",
		carob_date="2023-07-12"
	)





	f1 <- ff[basename(ff) == "legumes_area_and_management.csv"]
	f2 <- ff[basename(ff) == "general.csv"]

	r1 <- read.csv(f1)
	r2 <- read.csv(f2)
	
	## no point in using fields with area <= zero
	r1 <- r1[r1$area < 50000,]
	r1 <- r1[r1$area > 0,]
	r <- merge(r1, r2, "farm_id")
	
	##### Location #####
	## make sure that the names are normalized (proper capitalization, spelling, no additional white space).
	## you can use carobiner::fix_name()
	
	d <- data.frame(
	  trial_id = r$farm_id, 
	  on_farm = TRUE,
	  is_survey = TRUE,
	  irrigated = FALSE,
	  country = "Rwanda",
	  site = gsub("I", "", carobiner::fix_name(r$village)),
	  adm1 = carobiner::fix_name(r$district_lga),
	  elevation = r$gps_altitude
	)
	
##### Crop #####
	d$crop[r$type_legume_variety %in%
	         c("Common beans", "Climbing Beans", "Bush Beans", "Sugarbeans")] <- "common bean"	
	d$crop[r$type_legume_variety %in% c("Groundnuts", "groundnuts")] <- "groundnut"
	d$crop[r$type_legume_variety == "Cowpeas"] <- "cowpea"
	d$crop[r$type_legume_variety %in% c("Soybeans", "Soyabeans")] <- "soybean"
	d$crop[r$type_legume_variety %in% c("Bambara nuts")] <- "bambara groundnut"
	
	d$variety_type <- NA
	d$variety_type[r$type_legume_variety == "Bush Beans"] <- "bush bean"
	d$variety_type[r$type_legume_variety == "Climbing Beans"] <- "climbing bean"
	
## EGB: Add intercropping
## more consie a	
	x <- tolower(trimws(r$with_which_crops))
	x <- gsub(",|, |  and | and |,and ", "; ", x)
	x <- gsub("irish potatoes|potatoes|irish crop", "potato", x)
	x <- gsub("sweet potato", "sweetpotato", x)
	x <- gsub("corn", "maize", x)
	x <- gsub("ananas", "pineapple", x)
	x <- gsub("peas", "pea", x)
	x <- gsub("pea; maize", "maize; pea", x)
	x <- gsub("bean with different varieties", "common bean", x) 
	x[x == ""] <- NA
	
	d$intercrops <- x
	
##### Time #####
	## time can be year (four characters), year-month (7 characters) or date (10 characters).
	## use 	as.character(as.Date()) for dates to assure the correct format.
	d$planting_date <- "2012-03"
	d$harvest_date <- "2012-05"
	d$season <- "rainy season"
	
##### Fertilizers #####
	## note that we use P and K, not P2O5 and K2O
	# for readability
	p <- tolower(trimws(r$synthetic_fert_types))
	k <- rep(NA, length(p))
	# Fertilizer type
	k[p == c("dap")] <- "DAP"
	k[p == c("npk")] <- "NPK"
	k[p %in% c("dap,urea", "dap(50kg) and urea(25kg)")] <- "DAP; urea"
	k[p == c("dap and npk")] <- "DAP; NPK"

##RH is this appropriate 
	#k[is.na(k)] <- "none"

	d$fertilizer_type <- k


## is this correct for "DAP; urea" and "DAP; NPK"? That is, the below assumes that 
## r$amount_fert_kg was applied of both these products. Is that correct?
## if that is not correct, what would the proportions be? (and the function would need to be able 
## to address that.

	ftab <- vocal::accepted_values("fertilizer_type")
## NPK is undefined (there are many different mixtures) so you need to add that here.
## E.g. 
	ftab[ftab$name=="NPK", c("N", "P", "K", "S")] <- c(20, 20, 20, 0)	
# if this is not known, we could use typical values for the country / region. 

	get_elements <- carobiner::get_function("get_elements_from_product", path, group)
	elements <- get_elements(ftab, k)
	
	famount <- 10000 * r$amount_fert_kg / r$area  # From kg/m2 to kg/ha
## see tail(sort(famount))	 (too high)

	d <- cbind(d, elements * famount)
	
	# Treatment code	
#	d$treatment <- paste0("N", ifelse(!is.na(d$N_fertilizer), round(d$N_fertilizer), 0),
#	                      "P", ifelse(!is.na(d$P_fertilizer), round(d$P_fertilizer), 0),
#	                      "K", ifelse(!is.na(d$K_fertilizer), round(d$K_fertilizer), 0))
# RH Not clear that missing means zero
    message("review: fertilizers, many NAs")
	
	d$OM_used <- r$organic_fert_applied == "Y"
	d$OM_used[r$organic_fert_applied == ""] <- NA

	# # EGB: Add inoculation
	d$inoculated <- r$inoculant_applied == "Y"
	# # EGB: Inoculant is not specified. Only providers.
	
##### Yield #####
	# # EGB: No biomass
	d$yield <- 10000 * r$production_field_kg / r$area # From kg/m2 to kg/ha

## see tail(sort(d$yield))	 (too high)

	#what plant part does yield refer to?
	d$yield_part <- ifelse(d$crop == "groundnut", "pod", "grain")
	
	# # Formatting coordinates into the dataset
	sss <- data.frame(country = "Rwanda",
         adm1 = c("Bugesera", "Bugesera", "Bugesera", "Bugesera", "Bugesera",
                  "Bugesera", "Bugesera", "Bugesera", "Bugesera", "Bugesera",
                  "Bugesera", "Bugesera", "Burera", "Burera", "Burera", "Burera",
                  "Gakenke", "Gakenke", "Gakenke", "Gakenke", "Gakenke", "Gakenke",
                  "Gakenke", "Gakenke", "Gakenke", "Gakenke", "Gakenke", 
                  "Gakenke", "Gakenke", "Kamonyi", "Kamonyi", "Kamonyi", "Kamonyi", 
                  "Kamonyi", "Kamonyi", "Kamonyi", "Kamonyi", "Kamonyi", "Kamonyi", 
                  "Kamonyi", "Kamonyi", "Kamonyi", "Kamonyi", "Kamonyi", "Kamonyi", 
                  "Kamonyi", "Kamonyi", "Kamonyi", "Kamonyi", "Kamonyi", "Kamonyi", 
                  "Kamonyi", "Kamonyi", "Kamonyi", "Kamonyi", "Kamonyi", "Kayonza", 
                  "Kayonza", "Kayonza", "Kayonza", "Kayonza", "Kayonza", "Kayonza", 
                  "Kayonza", "Kayonza", "Kayonza", "Kayonza", "Kayonza", "Kayonza", 
                  "Kayonza", "Kayonza", "Kayonza", "Kayonza", "Kayonza", "Kayonza", 
                  "Kayonza"),
         site = c("Nyarugati ", "Gitovu", "Nyarugati", "Kagirazina", 
                  "Rusenyi", "Nyamigisha", "Karwana", "Kabere", "Gitwa", "Nyakajuru", 
                  "Gitagata", "Nyakajuri", "Kanoni", "bugeyo", "Bugeyo", "Kagesera", 
                  "Kabuga", "Busana", "Butaraga", "Rwamigumbe", "Rwamigimbu", "Rumba", 
                  "Rwamugimbu", "Butarago", "Nturo", "Bushoka", "Kamwumba", "Mugali", 
                  "Kabuhoma", "Buhunga", "Gihembe", "Gihwogwe", "Gihogwe", "Gacaca", 
                  NA, "Rugwiro", "Tare", "Kigarama", "Mugereke", "Gaserege", "Gitega", 
                  "Gitare/Mugereke", "Nyabitare", "Rwezamenyo", "Rugarama", "Nyarubuye", 
                  "Murehe", "Bumbogo", "Umugarama", "Buye", "Ruvugizo", "Mukuyo", 
                  "Kigwene", "Ruhuha", "Kabungo", "Rwinanka", "Gasogi", "Rugoyi", 
                  "Rugagi", "Rugayi", "Rwangabarezi", "Ruvumu", "gasogi", "Kacyiru", 
                  "Nkondo", "Gasabo", "Kidogo", "Karama", "Karambo ", "Gakenyeli", 
                  "Nyarutunga ", "Nyarutunga", "Butimba", "Karambo", "Mutimba", 
                  "Nyarututunga "),
         latitude = c(-2.1607, -1.43, -2.1607, -2.1623, 
                      -2.149, -2.23456, -2.2562, -2.2362, -2.244, -2.23456, -2.2182, 
                      -2.2024, -1.47394, -1.4266, -1.4266, -1.5678, -1.6367, -1.626, 
                      -1.6981, -1.6981, -1.6981, -1.6981, -1.6981, -1.6981, -1.5892, 
                      -1.5963, -1.5923, -1.5982, -1.5854, -2.065, -2.0202, -2, -2, 
                      -1.505, -2.00521, -2.00521, -2.0773, -2.0058, -1.605, -2.0913, 
                      -2.0792, -1.605, -1.947, -1.8711, -2.048, -2.0547, -1.9312, -2.07, 
                      -2.00521, -2.0588, -2.0684, -2.00521, -2.0756, -2.0789, -2.077, 
                      -2.1057, -1.9434, -1.85101, -1.85101, -1.85101, -1.85101, -1.85101, 
                      -1.9434, -1.937, -1.93835, -1.883, -1.8032, -1.5244, -1.8237, 
                      -1.8141, -1.7879, -1.7879, -1.8225, -1.8237, -1.85101, -1.85101),
         longitude = c(30.067, 30.025, 30.067, 30.0576, 30.071, 30.14825, 
                       30.0525, 30.0299, 29.684, 30.14825, 30.084, 30.0812, 29.83468, 
                       29.7328, 29.7328, 29.8552, 29.7133, 29.878, 29.78543, 29.78543, 
                       29.78543, 29.78543, 29.78543, 29.78543, 29.7347, 29.7448, 29.7434, 
                       29.7253, 29.7456, 29.8181, 29.8497, 29.8475, 29.8475, 29.666, 
                       29.89817, 29.89817, 29.8168, 29.9294, 29.926, 29.8364, 29.8269, 
                       29.926, 29.9744, 29.8954, 29.9221, 29.96767, 29.93831, 29.8942, 
                       29.89817, 29.8694, 29.8767, 29.89817, 29.865, 29.8523, 29.8784, 
                       29.831, 30.48708, 30.65102, 30.65102, 30.65102, 30.65102, 30.65102, 
                       30.48708, 30.078, 30.62019, 29.977, 30.4604, 30.3873, 30.4698, 
                       30.4467, 30.4713, 30.4713, 30.4627, 30.4698, 30.65102, 30.65102))

	d <- merge(d, sss, by = c("country", "adm1", "site"), all.x=TRUE)
	carobiner::write_files(meta, d, path=path)
}

# # # EGB: Extracting spatial coordinates:
# 
# s <- unique(d[,c("country", "adm1", "site")])
# s$latitude <- NA
# s$longitude <- NA
# s$longitude[s$site == "Gitovu"] <- 30.025
# s$latitude[s$site == "Gitovu"] <- -1.430
# s$longitude[s$site == c("Rusenyi")] <- 30.071 # https://www.google.com/maps/place/Rusenyi
# s$latitude[s$site == c("Rusenyi")] <- -2.149 # https://www.google.com/maps/place/Rusenyi
# s$longitude[s$site %in% c("Gitwa")] <- 29.684 # https://www.google.com/maps/place/Esapag-Gitwe
# s$latitude[s$site %in% c("Gitwa")] <- -2.244 # https://www.google.com/maps/place/Esapag-Gitwe
# s$longitude[s$site %in% c("Busana")] <- 29.878 # https://www.google.com/maps/place/Busana
# s$latitude[s$site %in% c("Busana")] <- -1.626 # https://www.google.com/maps/place/Busana
# s$longitude[s$site %in% c("Gihwogwe")] <- 29.84750 
# s$latitude[s$site %in% c("Gihwogwe")] <- -2.00000
# s$longitude[s$site %in% c("Gacaca")] <- 29.666 # https://www.google.com/maps/place/Gacaca,+Rwanda
# s$latitude[s$site %in% c("Gacaca")] <- -1.505 # https://www.google.com/maps/place/Gacaca,+Rwanda
# s$longitude[s$site %in% c("Gitare/Mugereke", "Mugereke")] <- 29.926 # https://www.google.com/maps/place/Gitare+Secondary+School
# s$latitude[s$site %in% c("Gitare/Mugereke", "Mugereke")] <- -1.605 # https://www.google.com/maps/place/Gitare+Secondary+School
# s$longitude[s$site %in% c("Kacyiru")] <- 30.078 # https://www.google.com/maps/place/Kacyiru,+Kigali,+Rwanda
# s$latitude[s$site %in% c("Kacyiru")] <- -1.937 # https://www.google.com/maps/place/Kacyiru,+Kigali,+Rwanda
# s$longitude[s$site %in% c("Gasabo")] <- 29.977 # https://www.google.com/maps/place/Gasabo+Model+Farm
# s$latitude[s$site %in% c("Gasabo")] <- -1.883 # https://www.google.com/maps/place/Gasabo+Model+Farm
# for (i in 1:nrow(s)) {
#   if(is.na(s$latitude[i]) | is.na(s$longitude[i])){
#     ll <- carobiner::geocode(country = s$country[i], adm1 = s$adm1[i], location = s$site[i], service = "geonames", username = "efyrouwa")
#     ii <- unlist(jsonlite::fromJSON(ll))
#     c <- as.integer(ii["totalResultsCount"][[1]])
#     s$latitude[i] <- as.numeric(ifelse(c == 1, ii["geonames.lat"][1], ii["geonames.lat1"][1]))
#     s$longitude[i] <- as.numeric(ifelse(c == 1, ii["geonames.lng"][1], ii["geonames.lng1"][1]))
#   }
# }
# ss <- unique(s[is.na(s$latitude), c("country", "adm1", "site")])
# for (i in 1:nrow(ss)) {
#   ll <- carobiner::geocode(country = ss$country[i], adm1 = ss$adm1[i], location = ss$adm1[i], service = "geonames", username = "efyrouwa")
#   ii <- unlist(jsonlite::fromJSON(ll))
#   c <- as.integer(ii["totalResultsCount"][[1]])
#   ss$latitude[i] <- as.numeric(ifelse(c == 1, ii["geonames.lat"][1], ii["geonames.lat1"][1]))
#   ss$longitude[i] <- as.numeric(ifelse(c == 1, ii["geonames.lng"][1], ii["geonames.lng1"][1]))
# }
# sss <- s
# for (i in 1:nrow(sss)) {
#   if(is.na(sss$latitude[i]) & is.na(sss$longitude[i])){
#     sss$latitude[i] <- ss$latitude[ss$country == sss$country[i] & ss$adm1 == sss$adm1[i] & ss$site == sss$site[i]][1]
#     sss$longitude[i] <- ss$longitude[ss$country == sss$country[i] & ss$adm1 == sss$adm1[i] & ss$site == sss$site[i]][1]
#   }
# }
# sss <- dput(sss)
