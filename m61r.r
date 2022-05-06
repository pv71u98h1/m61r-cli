#!/usr/bin/Rscript

# requirement
suppressPackageStartupMessages(require(m61r))

#####################
# session directory #
#####################

# create a session to each action and return seesiondir as a result
# tempdir() get deleted after a r session get closed; not relevant for pipes
# => from https://github.com/coolbutuseless/dplyr-cli/blob/master/dplyr :
tmpdir <- c(Sys.getenv(c('TMPDIR', 'TMP', 'TEMP')), "/tmp")
tmpdir <- tmpdir[tmpdir != '']
tmpdir <- tmpdir[1]

m61r_path <- file.path(tmpdir,"m61r-cli")
dir.create(m61r_path,recursive = TRUE,showWarnings = FALSE)

# log
fileCheck <- file.path(m61r_path,"check.log")
if (!file.exists(fileCheck)) {
    tmp <- file.create(fileCheck,showWarnings = FALSE) # 'tmp <- ' to avoid any stdout
}


#################
# init options  #
#################

arg <- commandArgs(trailingOnly = TRUE)
opt <- list(PIPED    = arg[1],
            INPUT    = arg[2],
            EXTRA    = arg[3],
            COMBINE  = arg[4],
            PARAM    = arg[5],
            MANIP    = arg[6],
            ARGUMENT = arg[7],
            OUTPUT   = arg[8])

cat(c(as.character(Sys.time()),"PIPED: ", arg[1],"\n"), file=fileCheck,append=TRUE)
cat(c(as.character(Sys.time()),"INPUT: ", arg[2],"\n"), file=fileCheck,append=TRUE)
cat(c(as.character(Sys.time()),"EXTRA: ", arg[3],"\n"), file=fileCheck,append=TRUE)
cat(c(as.character(Sys.time()),"COMBINE: ", arg[4],"\n"), file=fileCheck,append=TRUE)
cat(c(as.character(Sys.time()),"PARAM: ", arg[5],"\n"), file=fileCheck,append=TRUE)
cat(c(as.character(Sys.time()),"MANIP: ", arg[6],"\n"), file=fileCheck,append=TRUE)
cat(c(as.character(Sys.time()),"ARGUMENT: ", arg[7],"\n"), file=fileCheck,append=TRUE)
cat(c(as.character(Sys.time()),"OUTPUT: ", arg[8],"\n"), file=fileCheck,append=TRUE)

#################
# check options #
#################

combine_list <- c("NULL",
                  "rbind","cbind",
                  "inner_join","left_join","right_join",
                  "full_join", "semi_join","anti_join")

manip_list <- c("NULL",
                "filter","select","group_by",
                "mutate","transmutate","summarise",
                "arrange","desange",
                "gather","spread",
                "values","modify")

PIPED <- tryCatch({
    res <- as.vector(unlist(strsplit(as.character(opt$PIPED), ",")))
    if (length(res) ==1L && res == "NULL")  res <- NULL
    res
  },error = function(err){
    stop(err)
  }
)

INPUT <- tryCatch({
    res <- as.vector(unlist(strsplit(as.character(opt$INPUT), ",")))
    if (length(res) ==1L && res == "NULL")  res <- NULL
    res
  },error = function(err){
    stop(err)
  }
)

EXTRA <- tryCatch({
    res <- as.vector(unlist(strsplit(as.character(opt$EXTRA), ",")))
    if (length(res) ==1L && res == "NULL")  res <- NULL
    res
  },error = function(err){
    stop(err)
  }
)

COMBINE <- tryCatch({
    res <- as.character(opt$COMBINE)
    if(!(res %in% combine_list)) stop("Error in 'COMBINE'")
    if (res == "NULL")  res <- NULL
    res
  },error = function(err){
    stop(err)
  }
)

PARAM <- tryCatch({
  res <- as.character(opt$PARAM)
  if (res == "NULL")  res <- ""
  res
  },error = function(err){
    stop("Error in 'PARAM'")
  }
)

MANIP <- tryCatch({
    res <- as.character(opt$MANIP)
    if(!(res %in% manip_list)) stop("Error in 'MANIP'")
    if (res == "NULL")  res <- NULL
    res
  },error = function(err){
    stop(err)
  }
)

ARGUMENT <- tryCatch({
  res <- as.character(opt$ARGUMENT)
  if (res == "NULL")  res <- ""
  res
  },error = function(err){
    stop("Error in 'ARGUMENT'")
  }
)

OUTPUT <- tryCatch({
    res <- as.character(opt$OUTPUT)
    if (res == "NULL")  res <- NULL
    res
  },error = function(err){
    stop(err)
  }
)

#############################
# -- Piped, Input and Extra #
#############################

# local function
get_m61r_obj_list <- function(filenames){
  res <- lapply(filenames,function(x){
    ext <- tolower(tools::file_ext(x))
    tmp_m61r_obj <- switch(ext,
                 "csv" = m61r::m61r(utils::read.csv(x,header=TRUE, sep=",")),
                 "rds" = readRDS(x),
                  stop("Unknown file extension: ", ext)
                 )
     return(tmp_m61r_obj)
  })
}

if (is.null(PIPED) && is.null(INPUT)){
  stop("PIPED or INPUT non-existant")
}

if (!is.null(PIPED)){

  m61r_obj_list <- list(readRDS(PIPED))

} else if (!is.null(INPUT)){

  m61r_obj_list <- list()

  # path or file
  path_bool <- unlist(lapply(INPUT,function(x){
    file.info(x)$isdir
  }))

  if (length(which(path_bool==FALSE)) > 0){
    m61r_obj_list <- get_m61r_obj_list(INPUT[path_bool==FALSE])
  }
  if (length(which(path_bool==TRUE)) > 0){
    for (i in 1:length(INPUT[path_bool==TRUE])){
      tmp <- list.files(INPUT[path_bool==TRUE][i])
      m61r_obj_list <- c(m61r_obj_list, get_m61r_obj_list(tmp))
    }
  }
}

if (!is.null(EXTRA)){

  m61r_obj_extra_list <- list()

  # path or file
  path_bool <- unlist(lapply(EXTRA,function(x){
    !file.info(x)$isdir
  }))

  if (length(EXTRA[!path_bool]) > 0){
    m61r_obj_extra_list <- get_m61r_obj_list(EXTRA[!path_bool])
  }
  if (length(EXTRA[path_bool]) > 0){
    for (i in 1:length(EXTRA[path_bool])){
      tmp <- list.files(EXTRA[path_bool][i])
      m61r_obj_extra_list <- c(m61r_obj_extra_list, get_m61r_obj_list(tmp))
    }
  }
} else {
  m61r_obj_extra_list <-list()
}

##############
# -- Combine #
##############
if (is.null(COMBINE) && !is.null(PIPED) && is.null(EXTRA)){
  m61r_obj <- m61r_obj_list[[1]]
} else if (is.null(COMBINE) && !is.null(INPUT)){
  m61r_obj <- do.call("rbind",m61r_obj_list)
} else if (is.null(COMBINE) && !is.null(EXTRA)){
  m61r_obj <- do.call("rbind",c(m61r_obj_list,m61r_obj_extra_list))
} else if (COMBINE=="cbind" || COMBINE=="rbind"){
  m61r_obj <- do.call(COMBINE,c(m61r_obj_list,m61r_obj_extra_list))
} else if (COMBINE=="inner_join" || COMBINE=="left_join" || COMBINE=="right_join" || COMBINE=="full_join" || COMBINE=="semi_join" || COMBINE=="anti_join"){
  if (length(c(m61r_obj_list,m61r_obj_extra_list))==2){
    proc <- sprintf("do.call(%s,c(m61r_obj_list,m61r_obj_extra_list,%s))",COMBINE,PARAM)
    m61r_obj <- eval(parse(text = proc,keep.source=FALSE))
  } else stop("Join requires no more than two m61r objects")
}

############
# -- Manip #
############
if (!is.null(MANIP)){
  proc <- sprintf("m61r_obj$%s(%s)",MANIP,ARGUMENT)
  eval(parse(text = proc,keep.source=FALSE))
}

##########
# output #
##########
key_output <- gsub("/","",tempfile(pattern = "", tmpdir = "", fileext = ""))
if (is.null(OUTPUT) || (OUTPUT == "rds")) {
  filename <- file.path(m61r_path,paste0(key_output,".rds"))
  saveRDS(m61r_obj,file=filename)
  cat(filename, "\n")
} else if (OUTPUT == "csv") {
  filename <- file.path(m61r_path,paste0(key_output,".csv"))
  write.csv(m61r_obj[],file=filename,row.names = FALSE)
  cat(filename, "\n")
} else if (OUTPUT == "x"){
  print(m61r_obj[])
}
