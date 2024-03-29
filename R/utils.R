#' Pipe operator
#'
#' @name %>%
#' @rdname pipe
#' @keywords internal
#' @export
#' @importFrom dplyr %>%
#' @examples
#' x <- 5 %>% sum(10)
#' 
#' @usage lhs \%>\% rhs
#' @return return value of rhs function. 
NULL

harmonize <- function(harmonyObj, iter_harmony, verbose=TRUE) {
    if (iter_harmony < 1) {
        return(0)
    }
    
    for (iter in seq_len(iter_harmony)) {
        if (verbose) {
            message(gettextf('Harmony %d/%d', iter, iter_harmony))        
        }
        
        # STEP 1: do clustering
        err_status <- harmonyObj$cluster_cpp()
        if (err_status == -1) {
            stop('terminated by user')
        } else if (err_status != 0) {
            stop(gettextf('Harmony exited with non-zero exit status: %d', 
                            err_status))
        }
        
        # STEP 2: regress out covariates
        harmonyObj$moe_correct_ridge_cpp()
        
        # STEP 3: check for convergence
        if (harmonyObj$check_convergence(1)) {
            if (verbose) {
                message(gettextf("Harmony converged after %d iterations", 
                        iter))    
            }
            return(0)
        }
    }
}



HarmonyConvergencePlot <- function(
        harmonyObj, round_start=1, round_end=Inf, do_wrap=FALSE
    ) {  
    ## ignore initial value
    ## break down kmeans objective into rounds
    obj_fxn <- data.frame(
        kmeans_idx = Reduce(c, lapply(harmonyObj$kmeans_rounds, 
                        function(rounds) {
            seq_len(rounds)
        })),
        harmony_idx = Reduce(c, lapply(
            seq_len(length(harmonyObj$kmeans_rounds)),
            function(i) {rep(i, harmonyObj$kmeans_rounds[i])})
        ),
        val = utils::tail(harmonyObj$objective_kmeans, -1)
    ) %>%
        dplyr::filter(.data$harmony_idx >= round_start) %>% 
        dplyr::filter(.data$harmony_idx <= round_end) %>% 
        tibble::rowid_to_column("idx") 
    
    
    plt <- obj_fxn %>% ggplot2::ggplot(ggplot2::aes(.data$idx, .data$val,
                                                    col = as.factor(.data$harmony_idx))) + 
        ggplot2::geom_point() + 
        ggplot2::labs(y = "Objective Function", x = "Clustering Step #", color = "Integration #")
    
    if (do_wrap) {
        plt <- plt + ggplot2::facet_grid(.~.data$harmony_idx, scales = 'free',
            space = 'free_x')
    } 
    return(plt)
}





scaleData <- function(A, margin = 1, thresh = 10) {
    if (!"dgCMatrix" %in% class(A))
        A <- methods::as(A, "dgCMatrix")

    if (margin != 1) A <- t(A)

    res <- scaleRows_dgc(A@x, A@p, A@i, ncol(A), nrow(A), thresh)
    if (margin != 1) res <- t(res)
    row.names(res) <- row.names(A)
    colnames(res) <- colnames(A)
    return(res)
}


#' Get beta Utility 
#' 
#' Utility function to get ridge regression coefficients from trained
#' Harmony object 
#' 
#' @param harmonyObj Trained harmony object. Get this by running 
#' RunHarmony function with return_object=TRUE.
#' @return Returns nothing, modifies object in place. 
#' @export
moe_ridge_get_betas <- function(harmonyObj) {
    harmonyObj$moe_ridge_get_betas_cpp()
}


setOMPthreads <- function(ncores) {
    tryCatch({
        ## The following block may fail in some build environments (if
        ## OpenMP is not available). In case OpenMP is not available,
        ## we control the flow and fail gracefully by catching the
        ## exception and warn the user. If ncores parameter, is not
        ## valid for the runtime environment then we prompt the user
        ## user

        ## Flag set in case user provides invalid number of cores
        invalid.number.of.cores <- FALSE

        ## If OpenMP is not supported, this may return NA
        max.cores <- RhpcBLASctl::omp_get_max_threads()
        ## Sanity check for number of cores
        ## NOTE: (ncores > max.cores) throws an exception if ncores is
        ## NA suggesting OpenMP is not supported
        if ((ncores != as.integer(ncores)) || (ncores < 1) || (ncores > max.cores)) {
            invalid.number.of.cores <- TRUE
            stop("")## Throw exception
        }

    },
    error = function(e) {
        if(invalid.number.of.cores) {
            stop(paste0(
                "Invalid number of ncores provided: ", ncores, ". \n",
                "Maximum available cores: ", max.cores))

        } else if(ncores != 1) {
            warning(paste(
                "Harmony was unable to set number of cores for BLAS.",
                "Running in single-thread mode instead"
            ))
        }
        return(FALSE)

    })
    return(TRUE)
}
