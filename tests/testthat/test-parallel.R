# Load furrr package for running in parallel and set up in cluster
library(furrr)
plan(multiprocess)

###############
# Specify the input files
###############
set.seed(54321)

# Example directory with files for traits-based analysis
extdata_dir = np(system.file("extdata/examples/trait_examples/DEC_wTraits", package="BioGeoBEARS"))
extdata_dir
list.files(extdata_dir)


trfn = np(paste(addslash(extdata_dir), "simtr_observed.newick", sep=""))
tr = read.tree(trfn)

geog_1area_fn = np(paste(addslash(extdata_dir), "geog_1area.data", sep=""))
geogfn = np(paste(addslash(extdata_dir), "geog_sim_observed.txt", sep=""))
traitsfn = np(paste(addslash(extdata_dir), "traits_sim_observed.txt", sep=""))

#######################################################
# Inference
#######################################################
max_range_size = 4


## RUN IN SERIAL MODE ##

#######################################################
# Traits-only model -- 1 rate
#######################################################
BioGeoBEARS_run_object = define_BioGeoBEARS_run()

# Set up to run in serial mode
BioGeoBEARS_run_object$cluster_already_open = NULL
BioGeoBEARS_run_object$num_cores_to_use = 1

BioGeoBEARS_run_object$print_optim = TRUE
BioGeoBEARS_run_object$calc_ancprobs=TRUE        # get ancestral states from optim run
BioGeoBEARS_run_object$max_range_size = 1
BioGeoBEARS_run_object$use_optimx="GenSA"
BioGeoBEARS_run_object$speedup=TRUE
BioGeoBEARS_run_object$geogfn = geog_1area_fn
BioGeoBEARS_run_object$trfn = trfn
BioGeoBEARS_run_object = readfiles_BioGeoBEARS_run(BioGeoBEARS_run_object)
BioGeoBEARS_run_object$return_condlikes_table = TRUE
BioGeoBEARS_run_object$calc_TTL_loglike_from_condlikes_table = TRUE
BioGeoBEARS_run_object$calc_ancprobs = TRUE
BioGeoBEARS_run_object$on_NaN_error = -1000000
BioGeoBEARS_run_object$force_sparse = FALSE  # works with kexpmv, but compare to dense,
# time-stratify to break up long branches if you see major differences in lnL

# Set up DEC model, but set all rates to 0 (data are 1 invariant area)
# (nothing to do; defaults)
res = bears_optim_run(BioGeoBEARS_run_object)



## RUN IN PARALLEL MODE ##

#######################################################
# Traits-only model -- 1 rate
#######################################################
BioGeoBEARS_run_object = define_BioGeoBEARS_run()

# Set up to run in parallel with two cores
BioGeoBEARS_run_object$cluster_already_open = "yes"
BioGeoBEARS_run_object$num_cores_to_use = 2

BioGeoBEARS_run_object$print_optim = TRUE
BioGeoBEARS_run_object$calc_ancprobs=TRUE        # get ancestral states from optim run
BioGeoBEARS_run_object$max_range_size = 1
BioGeoBEARS_run_object$use_optimx="GenSA"
BioGeoBEARS_run_object$speedup=TRUE
BioGeoBEARS_run_object$geogfn = geog_1area_fn
BioGeoBEARS_run_object$trfn = trfn
BioGeoBEARS_run_object = readfiles_BioGeoBEARS_run(BioGeoBEARS_run_object)
BioGeoBEARS_run_object$return_condlikes_table = TRUE
BioGeoBEARS_run_object$calc_TTL_loglike_from_condlikes_table = TRUE
BioGeoBEARS_run_object$calc_ancprobs = TRUE
BioGeoBEARS_run_object$on_NaN_error = -1000000
BioGeoBEARS_run_object$force_sparse = FALSE  # works with kexpmv, but compare to dense,
# time-stratify to break up long branches if you see major differences in lnL

# Set up DEC model, but set all rates to 0 (data are 1 invariant area)
# (nothing to do; defaults)

# Run analysis
res = bears_optim_run(BioGeoBEARS_run_object)
