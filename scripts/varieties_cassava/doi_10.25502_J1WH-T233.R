# R script for "carob"
# license: GPLv3

carob_script <- function(path) {

"Assessment of White root varieties of Cassava for high yield, high dry matter and disease resistance using NCRP Trial (16 clones) in Abuja 2018/2019 Breeding Season advanced from repeat of 2017ncrpfrom 2016(ayt11(derivative of 15ik.uyt19yrt,ayt18htc"
  
	uri <- "doi:10.25502/J1WH-T233"
	group <- "varieties_cassava"
	ff  <- carobiner::get_data(uri, path, group)
		
	meta <- carobiner::get_metadata(uri, path, group, major=NA, minor=NA,
		data_organization = "IITA",
		publication = NA,
		project = NA,
		data_type = "experiment",
		treatment_vars = "variety",
		response_vars = "yield", 
		carob_contributor = "Robert Hijmans",
		carob_date = "2024-09-18",
		notes = NA
	)

	process_cassava <- carobiner::get_function("process_cassava", path, group)
	d <- process_cassava(ff)
	carobiner::write_files(path, meta, d$records, d$timerecs)
}

