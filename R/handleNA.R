#' Deal with NAs in the dataset!
#'
#' This function removes NAs from the counts data
#'
#' @param  data count data in a sample by feature matrix.
#' @param  thresh_prop threshold proportion of NAs for removal of feature
#'                     or replacing the NA values.
#'
#' @description This function handles the NA values in the count data.
#'              If for a feature, the proportion of NAs is greater than
#'              threshold proportion, then we remove the feature, otherwise
#'              we use MAR substitution scheme using the distribution of
#'              the non NA values for the feature. If threshold proportion
#'              is 0, it implies removal of all features with NA values.
#'              Default value of threshold proportion is 0.
#'
#' @return Returns a list with
#'      \item{data}{The modified data with NA substitution and removal}
#'      \item{na_removed_cols}{The columns in the data with NAs that were removed}
#'      \item{na_sub_cols}{The columns in the data with NAs that were substituted}
#'
#' @keywords counts data, clustering
#'
#' @importFrom stats rpois
#'
#' @export
#' @examples
#' mat <- rbind(c(2,4,NA),c(4,7,8),c(3,NA,NA));
#' handleNA(mat,thresh_prop=0.5)
#' handleNA(mat)
#'

handleNA <- function(data, thresh_prop = 0)
{
    na_count_cols <- apply(data, 2, function(x) length(which(is.na(x)==TRUE)));
    if(max(na_count_cols)==0){
        message('there are no NA in the data : using full data',
                domain = NULL, appendLF = TRUE)
        ll <- list("data" = data,
                   "na_removed_cols" = as.numeric(),
                   "na_sub_cols" = as.numeric())
        return(ll)
    } else{
        na_indices <- which(na_count_cols > 0);
        na_to_remove <- which(na_count_cols/ncol(data) > thresh_prop)

        na_to_substitute <- na_indices[which(!na_indices %in% na_to_remove)];

        if(length(na_to_substitute) > 0){
            na_to_sub_data <- as.matrix(data[,na_to_substitute]);

            na_sub_data <- apply(na_to_sub_data, 2, function(x){
                indices <- which(is.na(x));
                x[indices] <- rpois( length(indices),
                                     mean(x,na.rm=TRUE))
                return(x)
            })
            data[,na_to_substitute] <- na_sub_data;
        }
        data <- as.matrix(data[,-na_to_remove]);
        ll <- list("data" = data,
                   "na_removed_cols" = na_to_remove,
                   "na_sub_cols" = na_to_substitute)
        message("NAs removed/substituted, data modified",
                domain = NULL,
                appendLF = TRUE)
        return(ll)
    }
}
