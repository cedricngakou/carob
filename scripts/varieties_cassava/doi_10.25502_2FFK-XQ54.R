# R script for "carob"
# license: GPLv3

carob_script <- function(path) {

"Assessment of high TC and dry matter materials selected from 2017/18 17.GS.C4.CET1124.IK harvested in Ikenne. Selection criteria: DM > 39%, RTWT > 13kg; CMD3S <2"
  
	uri <- "doi:10.25502/2FFK-XQ54"
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

