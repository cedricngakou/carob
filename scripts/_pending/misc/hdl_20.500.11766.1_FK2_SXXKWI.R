# R script for "carob"


carob_script <- function(path) {

"

    Final dataset from agronomic experiment in Gumara Maksegnit (2016), as elaborated by GARC researchers in charge for this trial (Alemu Tarekegn and Yengusie Demsew). Please contact author and contact person at ICARDA to obtain more detailed metadata or to propose collaboration.

"

	uri <- "hdl:20.500.11766.1/FK2/SXXKWI"
	group <- "conservation_agriculture"
	ff <- carobiner::get_data(uri, path, group)

	meta <- carobiner::get_metadata(uri, path, group, major=2, minor=1,
		project=NA,
		## if there is a paper, include the paper's doi here
		## also add a RIS file in references folder (with matching doi)
		publication= "",
		data_organization = "ICARDA",
   		data_type="field experiment", 
		carob_contributor="Shumirai Manzvera",
		# date of first submission to carob
		carob_date="2023-10-27" 
	)

  path<-C/carob


	f <- ff[basename(ff) == "_____________"]

	r <- read.csv(f)
	r <- readxl::read_excel(f) |> as.data.frame()

	
## process file(s)

## use a subset


	d<-Sorghum_Data_csv
#### about the data #####
## (TRUE/FALSE)

	
	d$on_farm <- FALSE
	d$is_survey <- FALSE
	d$is_experiment <- TRUE
	d$irrigated <- FALSE
## the treatment code	
	d$treatment <- d$Treatment

##### Location #####
## make sure that the names are normalized (proper capitalization, spelling, no additional white space).
## you can use carobiner::fix_name()
	d$country <- "Ethiopia"
	d$site <- "Gondar"
	d$elevation <- 2133 
## each site must have corresponding longitude and latitude
## see carobiner::geocode
	d$longitude <- 37.466667
	d$latitude <- 12.6

##### Crop #####
## normalize variety names
## see carobiner::fix_name
	d$crop <- "sorghum"
	

##### Time #####
## time can be year (four characters), year-month (7 characters) or date (10 characters).
## use 	as.character(as.Date()) for dates to assure the correct format.
	d$planting_date <- "2015/03"
	d$harvest_date  <- "2016/01"

  
##### in general, add comments to your script if computations are
##### based on information gleaned from metadata, a publication, 
##### or when they are not immediately obvious for other reasons

##### Yield #####
	
	d$yield <- d$Grain_yield
	#what plant part does yield refer to?
##replication
	d$rep<-d$Replication
	##intercroping
	d$intercrops< "vetch"
	#plant height
	d$plant_height<-d$Plant_height
	carobiner::write_files(meta, d, path=path)
}


