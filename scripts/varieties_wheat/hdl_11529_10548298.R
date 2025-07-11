# R script for "carob"


carob_script <- function(path) {
  
"The WYCYT international nurseries are the result of research conducted to raise the yield potential of spring wheat through the strategic crossing of physiological traits related to source and sink potential in wheat. These trials have been phenotyped in the major wheat-growing mega environments through the International Wheat Improvement Network (IWIN) and the Cereal System Initiative for South Asia (CSISA) network, which included a total of 136 environments (site-year combinations) in major spring wheat-growing countries such as Bangladesh, China, Egypt, India, Iran, Mexico, Nepal, and Pakistan. (2017)"
  
	uri <- "hdl:11529/10548298"
	group <- "varieties_wheat"
	ff <- carobiner::get_data(uri, path, group)
	
	meta <- carobiner::get_metadata(uri, path, group, major=1, minor=2,
		data_organization = "CIMMYT",
		publication= NA,
		project="Wheat Yield Collaboration Yield Trial",
		data_type= "experiment",
		response_vars = "yield",
		treatment_vars = "variety_code",
		carob_contributor= "Fredy Chimire",
		carob_date="2024-04-29"
	)
	
	proc_wheat <- carobiner::get_function("proc_wheat", path, group)
	d <- proc_wheat(ff)	

	# filter yield values within range 
	d <- d[d$yield < 19000, ]
		
	carobiner::write_files(path, meta, d)
}


