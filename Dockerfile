FROM rstudio/plumber
COPY api/ /app/
RUN R -e "install.packages(c('plumber', 'dplyr', 'caret'))"
CMD ["Rscript", "/app/plumber.R"]