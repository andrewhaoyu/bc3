
#' Title
#'
#' @param x.self.design
#' @param x.self.design2
#' @param baselineonly
#' @param additive
#' @param pairwise.interaction
#' @param saturated
#' @param z.design
#' @param z.design2
#' @param z.design.baselineonly
#' @param z.design.additive
#' @param z.design.pairwise.interaction
#' @param z.design.saturated
#'
#' @return
#' @export
#'
#' @examples
ZSelfDesigntoZallnew <- function(x.self.design,
                              x.self.design2,
                              baselineonly,
                              additive,
                              pairwise.interaction,
                              saturated,
                              z.design,
                              z.design2,
                              z.design.baselineonly,
                              z.design.additive,
                              z.design.pairwise.interaction,
                              z.design.saturated
){

  M <- nrow(z.design.additive)
  ##the number of covariates in different potential model structures
  self.design.number <- CountCovarNumber(x.self.design)
  self.design.number2 <- CountCovarNumber(x.self.design2)
  baselineonly.number <- CountCovarNumber(baselineonly)
  additive.number <- CountCovarNumber(additive)
  pairwise.interaction.number <- CountCovarNumber(pairwise.interaction)
  saturated.number <- CountCovarNumber(saturated)
  ###second.stage.category for different model structures
  self.design.second.cat <- ncol(z.design)
  self.design.second.cat2 <- ncol(z.design2)
  baselineonly.second.cat <- 1
  additive.second.cat <- ncol(z.design.additive)
  pairwise.interaction.second.cat <- ncol(z.design.pairwise.interaction)
  saturated.second.cat <- ncol(z.design.saturated)
  ###1 for intercept
  total.covar.number <- 1+ self.design.number+self.design.number2+
    baselineonly.number+additive.number+
    pairwise.interaction.number+saturated.number

  z.all <- matrix(0,nrow=(M*total.covar.number),ncol = (M+self.design.second.cat*self.design.number+
                                                          self.design.second.cat2*self.design.number2+                baselineonly.number*baselineonly.second.cat+
                                                          additive.second.cat*additive.number+
                                                          pairwise.interaction.second.cat*pairwise.interaction.number)+saturated.second.cat*saturated.number)

  for(i in c("intercept","self design",
             "self design2",
             "baselineonly",
             "additive","pairwise.interaction",
             "satuared")){
    ##we always keep intercept as saturated model and to simply, we always use diagnonal matrix for intercept
    if(i=="intercept"){
      ###row start and column start point for this category
      row.start <- 0
      column.start <- 0
      for(j in 1:M){
        z.all[row.start+1+(j-1)*total.covar.number,(column.start+j)] = 1
      }
    }else if(i=="self design"){
      column.start <- M
      row.start <- 1
      if(self.design.number!=0){
        for(j in 1:M){
          for(k in 1:self.design.number){
            z.all[row.start+k+(j-1)*total.covar.number,
                  (column.start+(k-1)*self.design.second.cat+1):
                    (column.start+k*self.design.second.cat)] <- as.matrix(z.design[j,])
          }
        }
      }
    }else if(i=="self design2"){
      column.start <- M+self.design.number*self.design.second.cat
      row.start <- 1+self.design.number
      if(self.design.number2!=0){
        for(j in 1:M){
          for(k in 1:self.design.number2){
            z.all[row.start+k+(j-1)*total.covar.number,
                  (column.start+(k-1)*self.design.second.cat2+1):
                    (column.start+k*self.design.second.cat2)] <- as.matrix(z.design2[j,])
          }
        }
      }
    }else if(i=="baselineonly"){
      column.start = M+self.design.number*self.design.second.cat+self.design.number2*self.design.second.cat2
      row.start <- 1+self.design.number+
        self.design.number2
      ###test whether there is any baselineonly variable
      if(baselineonly.number!=0){
        for(j in 1:M){
          for(k in 1:baselineonly.number){
            z.all[row.start+k+(j-1)*total.covar.number,
                  (column.start+(k-1)*baselineonly.second.cat+1):
                    (column.start+k*baselineonly.second.cat)] <- as.matrix(z.design.baselineonly[j,])
          }
        }
      }
    }else if(i=="additive"){
      column.start <- M+self.design.number*self.design.second.cat+self.design.number2*self.design.second.cat2+baselineonly.number
      row.start <- 1+self.design.number+ self.design.number2+baselineonly.number
      if(additive.number!=0){
        for(j in 1:M){
          for(k in 1:additive.number){
            z.all[row.start+k+(j-1)*total.covar.number,
                  (column.start+(k-1)*additive.second.cat+1):
                    (column.start+k*additive.second.cat)] <- as.matrix(z.design.additive[j,])
          }
        }
      }
    }else if(i == "pairwise.interaction"){
      column.start <- M+self.design.number*self.design.second.cat+self.design.number2*self.design.second.cat2+baselineonly.number+additive.number*additive.second.cat
      row.start <- 1+self.design.number+self.design.number2+baselineonly.number+additive.number
      if(pairwise.interaction.number!=0){
        for(j in 1:M){
          for(k in 1:pairwise.interaction.number){
            z.all[row.start+k+(j-1)*total.covar.number,
                  (column.start+(k-1)*pairwise.interaction.second.cat+1):
                    (column.start+k*pairwise.interaction.second.cat)] <- as.matrix(z.design.pairwise.interaction[j,])
          }
        }
      }
    }else {
      column.start <- M+self.design.number*self.design.second.cat+self.design.number2*self.design.second.cat2+baselineonly.number+additive.number*additive.second.cat+
        pairwise.interaction.number*pairwise.interaction.second.cat
      row.start <- 1+self.design.number+self.design.number2+baselineonly.number+additive.number+pairwise.interaction.number
      if(saturated.number!=0){
        for(j in 1:M){
          for(k in 1:saturated.number){
            z.all[row.start+k+(j-1)*total.covar.number,
                  (column.start+(k-1)*saturated.second.cat+1):
                    (column.start+k*saturated.second.cat)] <- as.matrix(z.design.saturated[j,])
          }
        }
      }
    }



  }
  return(z.all)


}
