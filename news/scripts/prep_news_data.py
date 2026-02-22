def main():
    
    #%%############################################################################
    # Step 0: Basic Setup
    ###############################################################################
    
    #import python libraries
    import pandas as pd
    
    
    #%%############################################################################
    # Step 1: Load the news data and the sector linktable
    ###############################################################################
    
    #load the company article counts
    data_news_NYT=pd.read_excel("../inputs/raw_company_counts/raw_company_counts_NYT.xlsx").drop_duplicates()
    data_news_WSJ=pd.read_excel("../inputs/raw_company_counts/raw_company_counts_WSJ.xlsx").drop_duplicates()
    data_news_USAT=pd.read_excel("../inputs/raw_company_counts/raw_company_counts_USAT.xlsx").drop_duplicates()
    data_news_BSTNGB=pd.read_excel("../inputs/raw_company_counts/raw_company_counts_BSTNGB.xlsx").drop_duplicates()
    data_news_ATJC=pd.read_excel("../inputs/raw_company_counts/raw_company_counts_ATJC.xlsx").drop_duplicates()
    data_news_CGAZ=pd.read_excel("../inputs/raw_company_counts/raw_company_counts_CGAZ.xlsx").drop_duplicates()
    
    #load the company name / sector linktable
    linktable_factiva_sectors=pd.read_excel("../inputs/linktable_company_names_sectors.xlsx")
    
    
    #%%############################################################################
    # Step 2: construct the news filter dummmy
    ###############################################################################
    
    #combine news company counts into one dataframe
    data_news_all=data_news_NYT.append(data_news_WSJ).append(data_news_USAT).append(data_news_BSTNGB).append(data_news_ATJC).append(data_news_CGAZ)
    
    #get all company/date combinations and check if NYT / WSJ report on them
    data_temp=data_news_all[['start_date','comp_name']].drop_duplicates()
    data_temp=pd.merge(data_temp,data_news_NYT[['start_date','comp_name','comp_count']],how='left',on=['start_date','comp_name'])
    data_temp=pd.merge(data_temp,data_news_WSJ[['start_date','comp_name','comp_count']],how='left',on=['start_date','comp_name'])
    data_temp.columns=('start_date','comp_name','comp_count_nytf','comp_count_j')
    data_temp=data_temp.fillna(0)
    
    #construct the filter dummy
    data_temp['dummy_nytf']=[1 if a>=1 else 0 for a in data_temp.comp_count_nytf.tolist()] #check if NYT mentions a given company on a given date
    data_temp['dummy_j']=[1 if a>=1 else 0 for a in data_temp.comp_count_j.tolist()] #check if WSJ mentions a given company on a given date
    data_temp['dummy_sum']=data_temp['dummy_nytf'] + data_temp['dummy_j'] 
    data_temp['dummy_filter'] = [1 if a==2 else 0 for a in data_temp.dummy_sum.tolist()]
    
    #construct a datframe that contains only the filter variable
    filter_variable=data_temp[['comp_name','start_date','dummy_filter']].drop_duplicates()
    
    
    #%%############################################################################
    # Step 3: Combine all news counts and add the sector classification
    ###############################################################################
    
    #combine company counts into one dataframe
    data_news_all=data_news_NYT.append(data_news_WSJ).append(data_news_USAT).append(data_news_BSTNGB).append(data_news_ATJC).append(data_news_CGAZ)
    
    #add factiva source code to the dataset
    data_news_all['source_code']=[a.split("=")[2] for a in data_news_all.search_term]
    
    #add a year variable to the dataset and select the sample 
    data_news_all['year']=[int(str(a)[0:4]) for a in data_news_all.start_date]
    data_news_all=data_news_all[data_news_all.year>=1988]
    data_news_all=data_news_all[data_news_all.year<=2018]
    
    #merge the sector codes to the news data and construct a merge dummy
    data_news_all=pd.merge(data_news_all,linktable_factiva_sectors,how='left',left_on="comp_name",right_on="name")
    data_news_all['dummy_merged']=[1 if len(str(a))>3 else 0 for a in data_news_all.match_source]
    
    #add the filter variable to this
    data_news_all=pd.merge(data_news_all,filter_variable,how='left',left_on=['comp_name','start_date'],right_on=['comp_name','start_date'])
    
    #keep only the relevant variables / columns
    selector=['comp_name','comp_count','n_articles','start_date','end_date','search_term','source_code','year','naics','sector','sector_name','dummy_company_US','match_source','dummy_merged','dummy_filter']
    data_news_all=data_news_all[selector]
    
    ###### EXPORT THE NEWS DATA HERE WITH SECTORS AND FILTER DUMMY ################
    data_news_all.to_excel('../outputs//news_all_with_sectors_and_filter.xlsx',index=False)
    
    
    #%%############################################################################
    # Step 4: Calculate news coverage fractions
    ###############################################################################
    
    #get lists of all unique dates sector names, respectively
    sector_names_all=linktable_factiva_sectors[['sector','sector_name']].drop_duplicates().sort_values('sector')['sector_name'].tolist()
    dates_all=data_news_all.reset_index()['start_date'].drop_duplicates()
           
    #define a function used to obtain the outlet-specific sector counts
    def get_outlet_counts(data,dates_all,sector_names_all,source_code):
        data_all=pd.DataFrame(dates_all)
        data=data[data.source_code==source_code]
        for sector_name_current in sector_names_all:
            data_current_sector=data[data.sector_name==sector_name_current]
            counts_current_sector=data_current_sector.groupby(['start_date']).sum()['comp_count']
            counts_current_sector=counts_current_sector.rename(sector_name_current)
            counts_current_sector=pd.DataFrame(counts_current_sector).reset_index()
            data_all=pd.merge(data_all,counts_current_sector,on="start_date",how="left") 
        data_all=data_all.fillna(0)    
        data_all=data_all.drop('start_date',axis=1)
        return data_all
    
    #get the matched and unmatched observations
    data_matched=data_news_all[data_news_all.dummy_merged==1].copy()
    data_matched['sector']=[int(str(a).split(".")[0]) for a in data_matched.sector.tolist()]
    data_unmatched=data_news_all[data_news_all.dummy_merged==0].copy()
    
    #get the filtered and unfiltered data versions
    data_matched_US=data_matched[data_matched.dummy_company_US==1].reset_index().copy()
    data_matched_US_filtered=data_matched_US[data_matched_US.dummy_filter==1].copy()
    
    #get the outlet-specific sector counts (unfiltered)
    counts_j=get_outlet_counts(data_matched_US,dates_all,sector_names_all,'j')
    counts_nytf=get_outlet_counts(data_matched_US,dates_all,sector_names_all,'nytf')
    counts_usat=get_outlet_counts(data_matched_US,dates_all,sector_names_all,'usat')
    counts_bstngb=get_outlet_counts(data_matched_US,dates_all,sector_names_all,'bstngb')
    counts_atjc=get_outlet_counts(data_matched_US,dates_all,sector_names_all,'atjc')
    counts_cgaz=get_outlet_counts(data_matched_US,dates_all,sector_names_all,'cgaz')
    
    #get the outlet-specific sector counts (filtered)
    counts_j_filtered=get_outlet_counts(data_matched_US_filtered,dates_all,sector_names_all,'j')
    counts_nytf_filtered=get_outlet_counts(data_matched_US_filtered,dates_all,sector_names_all,'nytf')
    counts_usat_filtered=get_outlet_counts(data_matched_US_filtered,dates_all,sector_names_all,'usat')
    counts_bstngb_filtered=get_outlet_counts(data_matched_US_filtered,dates_all,sector_names_all,'bstngb')
    counts_atjc_filtered=get_outlet_counts(data_matched_US_filtered,dates_all,sector_names_all,'atjc')
    counts_cgaz_filtered=get_outlet_counts(data_matched_US_filtered,dates_all,sector_names_all,'cgaz')
    
    #convert to fractions (unfiltered)
    fractions_j=(counts_j.T/(counts_j.T.sum())).T
    fractions_nytf=(counts_nytf.T/(counts_nytf.T.sum())).T
    fractions_usat=(counts_usat.T/(counts_usat.T.sum())).T
    fractions_bstngb=(counts_bstngb.T/(counts_bstngb.T.sum())).T
    fractions_atjc=(counts_atjc.T/(counts_atjc.T.sum())).T
    fractions_cgaz=(counts_cgaz.T/(counts_cgaz.T.sum())).T
    
    #convert to fractions (filtered)
    fractions_j_filtered=(counts_j_filtered.T/(counts_j_filtered.T.sum())).T
    fractions_nytf_filtered=(counts_nytf_filtered.T/(counts_nytf_filtered.T.sum())).T
    fractions_usat_filtered=(counts_usat_filtered.T/(counts_usat_filtered.T.sum())).T
    fractions_bstngb_filtered=(counts_bstngb_filtered.T/(counts_bstngb_filtered.T.sum())).T
    fractions_atjc_filtered=(counts_atjc_filtered.T/(counts_atjc_filtered.T.sum())).T
    fractions_cgaz_filtered=(counts_cgaz_filtered.T/(counts_cgaz_filtered.T.sum())).T
    
    #NYT and WSJ only, with and without filter
    fractions_average=0.5*fractions_nytf + 0.5*fractions_j
    fractions_average_filtered=0.5*fractions_nytf_filtered + 0.5*fractions_j_filtered
    
    #All papers, without filter
    fractions_average_all=(1/4)*fractions_nytf + (1/4)*fractions_j + (1/4)*fractions_usat + (1/12)*fractions_bstngb + (1/12)*fractions_atjc + (1/12)*fractions_cgaz
    fractions_average_all=fractions_average.iloc[0:36].append(fractions_average_all.iloc[36:])
    
    #All papers, with filter
    fractions_average_filtered_all=(1/4)*fractions_nytf_filtered + (1/4)*fractions_j_filtered + (1/4)*fractions_usat_filtered + (1/12)*fractions_bstngb_filtered + (1/12)*fractions_atjc_filtered + (1/12)*fractions_cgaz_filtered
    fractions_average_filtered_all=fractions_average_filtered.iloc[0:36].append(fractions_average_filtered_all.iloc[36:])
    
    
    #%%############################################################################
    # Step 5: Export the time series for the regressions and plots
    ###############################################################################
    
    fractions_average.to_excel('../outputs/news_fractions_baseline.xlsx',index=False)
    fractions_average_all.to_excel('../outputs/news_fractions_extended.xlsx',index=False)
    fractions_average_filtered.to_excel('../outputs/news_fractions_baseline_filtered.xlsx',index=False)
    fractions_average_filtered_all.to_excel('../outputs/news_fractions_extended_filtered.xlsx',index=False)
    
    
    #%%############################################################################
    # Step 6: Calculate and export annual averages of the news coverage fractions
    ###############################################################################
    
    years=[i for i in range(1988,2019,1) for temp in range(4)]
    temp=fractions_average_filtered.copy()
    temp['year']=years
    annual_means=temp.groupby('year').mean()
    annual_means.to_excel('../outputs/news_fractions_baseline_filtered_ANNUAL_MEANS.xlsx')
    
    
    
    
    
    
    
    
    
    
    
    
    
