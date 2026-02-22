#%%############################################################################
# Step 0: Basic Setup
###############################################################################

#define the working directory
working_directory='/Users/ryan/Dropbox/CN Sectors and news focus/public_replication_code/'

#import python libraries
import os
import shutil

#change to the working directory
os.chdir(working_directory+"news/scripts/")

#import all python replication scripts
import prep_news_data
import plots_matched_and_unmatched_tags
import plots_news_time_series
import plots_news_vs_macro_data
import plots_ngram_comparison
import plots_top_companies_top_sectors
import plots_top_companies_all_sectors
import regressions


#%%############################################################################
# Step 1: Run the replication scripts
###############################################################################

#create news datasets from the raw inputs
prep_news_data.main()

#replicate the regressions shown in Table 2
regressions.main()

#create Figures 6 and 8
plots_news_vs_macro_data.main()

#create Figure 7
plots_top_companies_top_sectors.main()

#create Figures 9, A7, A8, A9
plots_news_time_series.main()

#create Figure 10
plots_ngram_comparison.main()

#create Figure A1
plots_matched_and_unmatched_tags.main()

#create Figures A2, A3, A4, A5 and A6
plots_top_companies_all_sectors.main()

#erase cache files
shutil.rmtree("__pycache__")