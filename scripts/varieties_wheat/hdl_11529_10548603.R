# R script for "carob"

carob_script <- function(path) {

"The Karnal Bunt Screening Nursery is a single replicate nursery that contains diverse spring bread wheat (Triticum aestivum) germplasm adapted to ME1 (Optimally irrigated, low rainfall environment) with total 50-100 entries and white/red grain color. (2020)"

	uri <- "hdl:11529/10548603"
	group <- "varieties_wheat"

	ff <- carobiner::get_data(uri, path, group)

	meta <- carobiner::get_metadata(uri, path, group=group, major=2, minor=0,
		data_organization = "CIMMYT",
		publication=NA,
		project="Karnal Bunt Screening Nursery",
		data_type= "experiment",
		response_vars = "yield",
		treatment_vars = "variety_code",
		carob_contributor= "Hope Mazungunye",
		carob_date="2024-07-30"
	)

	proc_wheat <- carobiner::get_function("proc_wheat", path, group)
	d <- proc_wheat(ff)
	
	carobiner::write_files(path, meta, d)
}
