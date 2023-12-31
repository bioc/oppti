# _|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|
#   .onAttach
#
#   Welcome message
#
.onAttach <- function (libname, pkgname){
    welcome.message <- paste0(
        "     _________________________________     \n",
        "    /  __  /  __  /  __  /        /  /    \n",
        "   /  / / /  /_/ /  /_/ /__   ___/  /    \n",
        "  /  /_/ /  ____/  ____/  /  /  /  /    \n",
        " /______/__/   /__/      /__/  /__/    v.",utils::packageVersion(
            "oppti"),"\n",
        "https://github.com/Huang-lab/oppti\n"
    )
    if (runif(1)<0.5) {packageStartupMessage(welcome.message)}
}
# _|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|
#
#   cbindNA
#
#   Binds arbitrary-length columns given in a list into a data frame with
#     NA-filled ends.
#
cbindNA = function(X = list(seq_len(2),seq_len(3),seq_len(4))){
    n = 0
    for (x in X){n = max(n, length(as.matrix(x)))}
    df = data.frame(matrix(NA, nrow = n, ncol = length(X)))
    for (c in seq_along(X)){df[seq_len(as.matrix(X[[c]])), c] = unlist(X[[c]])}
    return(df)
}

# _|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|
#
#   gqplot
#
#   Draws a scatter plot based on the grammar of graphics (ggplot2), then
#     draws a regression line and displays a confidence interval around it.
#
#   Returns each data point's distance to the regression line, and the plot.
#
gqplot = function(y, x, ci = 0.95, xlab = NULL, ylab = NULL, dist.sort = FALSE,
    d.thr = 0, na.action = 'omit', samp.names = NULL, marker.name = NULL,
    highlight = NULL, omit.fit = NULL, maxx = NULL, minx = NULL, maxy = NULL,
    miny = NULL, align.xy = TRUE, cohort.name = NULL) {
    # marker name
    if (is.null(marker.name)) {marker.name = rownames(y)}
    if (is.null(marker.name)) {marker.name = rownames(x)}
    # cohort name
    if (is.null(cohort.name)) {
        tryCatch({cohort.name = strsplit(colnames(y)[1],'\\.')[[1]][1]
        }, error=function(w) w, finally = {})
    }
    if (is.null(cohort.name)) {
        tryCatch({cohort.name = strsplit(colnames(x)[1],'\\.')[[1]][1]
        }, error=function(w) w, finally = {})
    }
    if (is.null(cohort.name)) {cohort.name = ''}
    # align dimensions
    if (nrow(as.matrix(y)) < ncol(as.matrix(y))) {y = t(y)}
    if (nrow(as.matrix(x)) < ncol(as.matrix(x))) {x = t(x)}
    # drop NA values
    if ((any(is.na(y)) | any(is.na(x))) & na.action == 'omit'){
        keep = !is.na(y) & !is.na(x)
        x = x[keep]
        y = y[keep]
        if (!is.null(highlight))
            {highlight[highlight %in% rownames(keep)[keep]]}
    }
    # sample names
    if (is.null(samp.names)) {samp.names = names(y)}
    if (is.null(samp.names)) {samp.names = names(x)}
    # align classes
    if (!methods::is(y)[[2]]=='vector') {y = as.vector(y)}
    if (!methods::is(x)[[2]]=='vector') {x = as.vector(x)}
    # define labels
    if (is.null(xlab)) {xlab = expression('Variable2')}
    if (is.null(ylab)) {ylab = expression('Variable1')}
    # find linear regression fit and compute distances to regression line
    if (is.null(omit.fit)) {
        if (!any(x!=0)) {x[1] = 1e-10}
        if (!any(y!=0)) {y[1] = 1e-10}
        fit = stats::lm(y ~ x)
        preds = predict(stats::lm(y ~ x, na.action = na.exclude),
            interval = 'confidence', level = ci)
    } else if (omit.fit < 1) {
        if (!any(x!=0)) {x[1] = 1e-10}
        if (!any(y!=0)) {y[1] = 1e-10}
        fit = stats::lm(y ~ x)
        preds = predict(stats::lm(y ~ x, na.action = na.exclude),
            interval = 'confidence', level = ci)
    } else {
        y.s = sort(y, decreasing = TRUE, index.return = TRUE, na.last = TRUE)
        non.out = (y <= y[y.s$ix[omit.fit]]) &
            (y >= y[y.s$ix[length(y[!is.na(y)])-omit.fit+1]])
        if (!any(x[non.out]!=0)) {x[non.out][1] = 1e-10}
        if (!any(y[non.out]!=0)) {y[non.out][1] = 1e-10}
        fit = stats::lm(y[non.out] ~ x[non.out], na.action = na.exclude)
        preds = matrix(NA, length(y), 3)
        preds[non.out,] = predict(fit, interval = 'confidence', level = ci)
    }
    d = (y - fit$coefficients[2]*x - fit$coefficients[1]) /
        sqrt(fit$coefficients[2]**2+1)
    if (dist.sort) {
        sd = sort(d, decreasing = TRUE, index.return = TRUE, na.last = TRUE)
        outlier.score = data.frame(sampleID = samp.names[sd$ix[sd$x >=
        quantile(sd$x, d.thr, na.rm = TRUE)]], dist2reg = sd$x[sd$x >=
        quantile(sd$x, d.thr, na.rm = TRUE)])
    } else {
        outlier.score = data.frame(sampleID = samp.names[d >=
        quantile(d, d.thr, na.rm = TRUE)], dist2reg = d[d >=
        quantile(d, d.thr, na.rm = TRUE)])
    }
    # when there is NA, preds is shorten, handle NAs: (NA values dropped)
    df = data.frame(variable1 = y, variable2 = x, clower = preds[,2],
        cupper = preds[,3])
    rownames.df = samp.names
    # newx = seq(min(df$variable2), max(df$variable2),
        # length.out=length(df$variable2))
    if (is.null(minx)) {minx = min(df$variable2, na.rm=TRUE)}
    if (is.null(maxx)) {maxx = max(df$variable2, na.rm=TRUE)}
    if (is.null(miny)) {miny = min(df$variable1, na.rm=TRUE)}
    if (is.null(maxy)) {maxy = max(df$variable1, na.rm=TRUE)}
    if (align.xy) {
        minx = min(minx, miny); miny = minx
        maxx = max(maxx, maxy); maxy = maxx
    }
    if (is.null(highlight)) {
        gg = ggplot2::ggplot(df, ggplot2::aes(x=variable2, y=variable1)) +
            ggplot2::geom_point(ggplot2::aes(variable2, variable1),
                shape = 1, size = 1.5) +
            ggplot2::geom_abline(intercept = fit$coefficients[1],
                slope = fit$coefficients[2], alpha = 0.5) +
            ggplot2::geom_line(ggplot2::aes(variable2, cupper), size = .1) +
            ggplot2::geom_line(ggplot2::aes(variable2, clower), size = .1) +
            ggplot2::theme_bw() +
            ggplot2::xlim(minx,maxx) + ggplot2::ylim(miny,maxy) +
            ggplot2::ggtitle(paste0(marker.name, ' in\n', cohort.name))
            # ggplot2::theme(plot.title = ggtext::element_textbox_simple())
        if (!is.na(xlab)) {gg = gg + ggplot2::xlab(xlab)}
        if (!is.na(ylab)) {gg = gg + ggplot2::ylab(ylab)}
    } else {
        gg = ggplot2::ggplot(df[-which(rownames.df %in% highlight),],
                             ggplot2::aes(x=variable2, y=variable1)) +
            ggplot2::geom_point(ggplot2::aes(variable2, variable1),
                shape = 1, size = 1.5) +
            ggplot2::geom_abline(intercept = fit$coefficients[1],
                slope = fit$coefficients[2], alpha = 0.5) +
            ggplot2::geom_line(ggplot2::aes(variable2, cupper), size = .1) +
            ggplot2::geom_line(ggplot2::aes(variable2, clower), size = .1) +
            ggplot2::theme_bw() +
            ggplot2::xlim(minx,maxx) + ggplot2::ylim(miny,maxy) +
            ggplot2::ggtitle(paste0(marker.name, ' in\n', cohort.name)) +
            ggplot2::geom_point(data = df[which(rownames.df %in% highlight),],
            ggplot2::aes(x=variable2, y=variable1),
            colour = 'orange', shape = 19, size = 1.5)
            # ggplot2::theme(plot.title = ggtext::element_textbox_simple())
        if (!is.na(xlab)) {gg = gg + ggplot2::xlab(xlab)}
        if (!is.na(ylab)) {gg = gg + ggplot2::ylab(ylab)}
    }
    return(list(outlier.score, gg, fit$coefficients[2]))
}
# _|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|
#
#   madNorm
#
#   Normalizes the columns of a data frame to have the unit Median Absolute
#     Deviation (MAD), i.e., median(abs(df$i-median(df$i))) = 1, for every 'i'.
#     Optionally, center the medians to the median of all column medians
#     (centering = TRUE).
#
#   Special attention must be paid to columns with zero-MAD, i.e., no
#     variation, static values. By default, they are omitted (unprocessed).
#     Optionally, they can be centered to the median of all column medians
#     (centering.zero.mad = TRUE), however, they can not be scaled to have a
#     unit-MAD due to static values.
#
madNorm = function(df, centering = FALSE, centering.zero.mad = FALSE){
    mads = apply(df,2,function(x)
        {median(abs(x-median(x,na.rm=TRUE)),na.rm=TRUE)})
    omit = mads==0
    mads[omit] = 1 #omit scaling 0-MAD columns
    df = df / matrix(rep(mads,each=dim(df)[1]),nrow=dim(df)[1],byrow=FALSE)
    if (centering) {
        cent = apply(df,2,'median',na.rm=TRUE)-
            median(apply(df,2,'median',na.rm=TRUE),na.rm=TRUE)
        if (!centering.zero.mad) {cent[omit] = 0} #omit centering 0-MAD columns
        df = df - matrix(rep(cent,each=dim(df)[1]),nrow=dim(df)[1],byrow=FALSE)
    }
    return(df)
}

# _|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|
#
#   uniq
#
#   Return unique elements (and indices) of an array
#   Pick the last one from an array of repeated items
#
uniq = function(x, index.return = FALSE) {
    l = length(x)
    ix = vector()
    for (i in seq_along(x)) {
        if (!x[i] %in% x[(i+1):l]) {
            ix = c(ix,i)
        }
    }
    if (!x[l] %in% x[seq_len(l-1)]) {
        ix = c(ix,l)
    }
    chc = x[!x %in% x[ix]]
    if (length(chc)>0){
        print(paste('Warning! Not sliced: ', unique(chc)))
    }
    if (index.return) {
        return(list(x = x[ix], ix = ix))
    } else {
        return(x[ix])
    }
}

per.test = function(res = oppti.result, res.can.typ = names(res[[1]]), n = 10,
                    draw = FALSE, plot.set = list(BRCA = c('ERBB2'),
                        CCRCC = c('ERBB2', 'TP53')), verbose = FALSE){
    tmp.lis = as.list(rep(NA,length(res[[1]]))) #template for a cohort-size
    # data object
    if (is.null(res.can.typ)){
        names(tmp.lis) = names(res[[1]])
    } else {
        names(tmp.lis) = res.can.typ
    }
    p.values = tmp.lis
    data.overexpressions = tmp.lis
    observed.overexpressions = tmp.lis
    cancer='UCEC'
    for (cancer in res.can.typ) {
        set.seed(1)
        thr = res[[5]][[cancer]]
        dys = res[[1]][[cancer]]
        num.permutation = round(ncol(dys))*n # proportionate to cohort size dof
        observed.overexpression =  100*rowMeans(dys > thr, na.rm = T)
        data.overexpression = setNames(data.frame(matrix(NA, nrow(dys),
            num.permutation), row.names = rownames(dys)), paste0('data',
                seq_len(num.permutation)))
        i=1
        for (i in seq_len(num.permutation)) {
            # message('permutation in ',cancer,': ', i)
            # permute outliers for each sample
            dys = res[[1]][[cancer]]
            s=1
            for (s in seq_len(ncol(dys))) {
                non.na = !is.na(dys[,s])
                dys[non.na, s] = dys[sample(which(non.na), sum(non.na),
                                            replace = F), s]
            }
            # i-th permutation distribution
            data.overexpression[,i] = 100*rowMeans(dys > thr, na.rm = T)
            per.don = which(ceiling(seq(from = num.permutation/100, to =
                num.permutation, by = num.permutation/100)) %in% i) #**
            if (length(per.don) > 0 & verbose) {message(
                'Building permutation distribution in ',cancer,': ',
                    per.don, '% done.')}
        }
        #' # Different markers have different permutation distribution! Combine
        #'  them to generate a universal permutation distribution that is the
        #'  null distribution for an arbitrary marker's overexpression
        data.overexpression = unlist(data.overexpression)
        data.overexpression = sort(as.numeric(data.overexpression))#exclude NA
        data.overexpression = data.overexpression[!is.na(data.overexpression)]
        L = length(data.overexpression)
        p.value = setNames(array(NA, length(observed.overexpression)),
                           names(observed.overexpression))
        for (j in seq_along(observed.overexpression)) {
            if (j %in% round(seq(from=1,to=length(observed.overexpression),
                                 len=100)) & verbose){
                message('Evaluating marker in ',cancer,': ',
                        round(100*j/length(observed.overexpression)),'% done.')
            }
            if (!is.na(observed.overexpression[j])) {
                p.value[j] = length(which(data.overexpression >
                    observed.overexpression[j])) / L # one-tailed test
            }
        }
        p.values[[cancer]] = p.value
        data.overexpressions[[cancer]] = data.overexpression
        observed.overexpressions[[cancer]] = observed.overexpression
    }
    if (draw) {
        cancer=res.can.typ[10]
        for (cancer in res.can.typ) {
            data.overexpression = data.overexpressions[[cancer]]
            observed.overexpression = observed.overexpressions[[cancer]]
            p.value = p.values[[cancer]]
            marker=plot.set[1]
            for (marker in plot.set[[cancer]]) {
                if (!is.na(p.value[marker])){
                    df = data.frame(weight = data.overexpression)
                    p = ggplot(df, aes(x = weight))
                    p = p + geom_histogram(aes(y = ..density..),
                        colour="black", fill="white", binwidth = 1)
                    # p = p + geom_density(alpha=.2, fill="#FF6666")
                    p = p + geom_vline(xintercept =
                        observed.overexpression[marker], color="blue",
                        linetype = 'dashed', size=1)
                    p = p + xlab('Overexpression') + ylab('Density')
                    # p = p + ggtitle(paste0('Permutation distribution
                    # (', marker,', p = ',format.pval(p.value[marker]), ')') )
                    p = p + ggtitle(paste0(marker, ' in ', cancer,', p = ',
                                           format.pval(p.value[marker])))
                    pdf(paste0(cancer,'.',marker,'.pdf'), width = 5,
                        height = 3, useDingbats = FALSE); print(p); dev.off()
                }
            }
        }
    }
    return(p.values)
}
