def main():

    #%%############################################################################
    # Step 0: Basic Setup
    ###############################################################################

    #import python libraries
    import os
    import pandas as pd
    import numpy as np
    import matplotlib.pyplot as plt
    
    
    #%%############################################################################
    # Step 1a: Load and prepare the ngram-based news data
    ###############################################################################
    
    #get the relevant filenames
    path='../inputs/raw_ngram_counts/'
    filenames_all=os.listdir(path)
    files_j=[a for a in filenames_all if "j-" in a and "xlsx" in a]
    files_nytf=[a for a in filenames_all if "nytf-" in a and "xlsx" in a]
    
    #get a list of all n-gram based sector names
    sector_names_ng=[a.split("-")[1].split('.xlsx')[0] for a in files_j]
    
    #load the files and combine into one dataframe
    data_ng_all=pd.DataFrame()
    for outlet_current in ['j','nytf']:
        for sector_name_current in sector_names_ng:
            file_current=path +  outlet_current + "-" + sector_name_current + ".xlsx"
            data_ng_current=pd.read_excel(file_current)
            data_ng_current['source_code']=outlet_current
            data_ng_current['sector']=sector_name_current 
            data_ng_all=data_ng_all.append(data_ng_current)
     
    #keep only obersvations between 1988 and 2018 (consistent sample)
    data_ng_all['year']=[int(str(a)[0:4]) for a in data_ng_all.start_date.tolist()]  
    data_ng_all=data_ng_all[data_ng_all.year>=1988]
    data_ng_all=data_ng_all[data_ng_all.year<=2018]
    
    #get all dates and all sectors from the n-gram sector data
    sector_names_ng_all=data_ng_all[['sector']].drop_duplicates().sort_values('sector')['sector'].tolist()
    dates_ng_all=data_ng_all.reset_index()['start_date'].drop_duplicates()
    
    
    #%%############################################################################
    # Step 1b: Load and prepare the company-based news data 
    ###############################################################################
    
    #load the company name-based news data
    data_names_all=pd.read_excel("../outputs/news_all_with_sectors_and_filter.xlsx").drop_duplicates()
    data_names_all=data_names_all[data_names_all.source_code.isin(['j','nytf'])]
    data_names_all=data_names_all[data_names_all.year>=1988]
    data_names_all=data_names_all[data_names_all.year<=2018]
    data_names_filtered=data_names_all[data_names_all.dummy_filter==1] #get the filtered version
    
    #get all dates and all sectors
    sector_names_all=data_names_all[['sector','sector_name']].drop_duplicates().sort_values('sector')['sector_name'].tolist()
    sector_names_all=[a for a in sector_names_all if str(a)!="nan"]
    dates_all=data_names_all.reset_index()['start_date'].drop_duplicates()
    
    
    #%%############################################################################
    # Step 2: Define some functions
    ###############################################################################
    
    #set up a function used to get the outlet specific sector counts (NAME-based)
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
    
    #set up a function used to get the outlet specific sector counts (NGRAM-based)
    def get_outlet_counts_ng(data,dates_all,sector_names_all,source_code):
        data_all=pd.DataFrame(dates_all)
        data=data[data.source_code==source_code]
        for sector_name_current in sector_names_all:
            data_current_sector=data[data.sector==sector_name_current]
            counts_current_sector=data_current_sector[['n_articles','start_date']].drop_duplicates().groupby(['start_date']).sum()['n_articles']
            counts_current_sector=counts_current_sector.rename(sector_name_current)
            counts_current_sector=pd.DataFrame(counts_current_sector).reset_index()
            data_all=pd.merge(data_all,counts_current_sector,on="start_date",how="left") 
        data_all=data_all.fillna(0)    
        data_all=data_all.drop('start_date',axis=1)
        return data_all
    
    
    #%%############################################################################
    # Step 3: Get the news focus for the name-based sector definitions
    ###############################################################################
    
    #get the outlet-specific sector counts (raw-counts)
    counts_names_j=get_outlet_counts(data_names_all,dates_all,sector_names_all,'j')
    counts_names_nytf=get_outlet_counts(data_names_all,dates_all,sector_names_all,'nytf')
    
    #get the fractions of these counts
    fractions_names_j=(counts_names_j.T/(counts_names_j.T.sum())).T
    fractions_names_nytf=(counts_names_nytf.T/(counts_names_nytf.T.sum())).T
    
    #take the average across both newspapers
    fractions_names_avg=(1/2)*fractions_names_j + (1/2)*fractions_names_nytf 
    
    
    #%%############################################################################
    # Step 4: Get the news focus for the n-gram based sector definitions
    ###############################################################################
    
    #get the counts using the function
    counts_ng_j=get_outlet_counts_ng(data_ng_all,dates_all,sector_names_ng_all,'j')
    counts_ng_nytf=get_outlet_counts_ng(data_ng_all,dates_all,sector_names_ng_all,'nytf')
    
    #get the fractions of these counts
    fractions_ng_j=(counts_ng_j.T/(counts_ng_j.T.sum())).T
    fractions_ng_nytf=(counts_ng_nytf.T/(counts_ng_nytf.T.sum())).T
    
    #take the average across both newspapers
    fractions_ng_avg=(1/2)*fractions_ng_j + (1/2)*fractions_ng_nytf 
    
    
    
    #%%############################################################################
    # Step 5: Construct the plot (Figure 10)
    ###############################################################################
    
    #order the data for easy plotting in 3x1 format
    temp_fire=fractions_names_avg['F.I.R.E.'].to_frame()
    temp_fire['N-GRAM-BASED']=fractions_ng_avg['housing+financial']
    temp_fire.columns=['Name-based','NGRAM-based']
    
    #order the data for easy plotting in 3x1 format
    temp_auto=fractions_names_avg['motor vehicles'].to_frame()
    temp_auto['N-GRAM-BASED']=fractions_ng_avg['auto']
    temp_auto.columns=['Name-based','NGRAM-based']
    
    #order the data for easy plotting in 3x1 format
    temp_food_kindred=fractions_names_avg['food & kindred products'].to_frame()
    temp_food_kindred['N-GRAM-BASED']=fractions_ng_avg['food+tobacco']
    temp_food_kindred.columns=['Name-based','NGRAM-based']
    
    #make a plot for comparison
    fig, axes = plt.subplots(nrows=1, ncols=3,figsize=(10,2),sharex=True)
    temp_fig1=temp_fire.plot(kind='line',fontsize=8,rot=90,ax=axes[0],legend=False)
    temp_fig2=temp_auto.plot(kind='line',fontsize=8,rot=90,ax=axes[1],legend=False)
    temp_fig3=temp_food_kindred.plot(kind='line',fontsize=8,rot=90,ax=axes[2],legend=False)
    
    #format the axes
    temp_fig1.set_ylim(0,0.45)
    temp_fig2.set_ylim(0,0.45)
    temp_fig3.set_ylim(0,0.45)
    temp_fig1.set_xlim(0,123)
    temp_fig2.set_xlim(0,123)
    temp_fig3.set_xlim(0,123)
    
    #add the grid
    temp_fig1.yaxis.grid(color='gray', linestyle='dotted')
    temp_fig1.set_axisbelow(True)
    temp_fig2.yaxis.grid(color='gray', linestyle='dotted')
    temp_fig2.set_axisbelow(True)
    temp_fig3.yaxis.grid(color='gray', linestyle='dotted')
    temp_fig3.set_axisbelow(True)
    
    #add recessions
    temp_fig1.axvspan(10, 14, alpha=0.5, color='grey') # q3 1990 - q1 1991
    temp_fig1.axvspan(52, 56, alpha=0.5, color='grey') # q1 2001 - q4 2001
    temp_fig1.axvspan(79, 86, alpha=0.5, color='grey') # q4 2007 - q2 2009
    #add recessions
    temp_fig2.axvspan(10, 14, alpha=0.5, color='grey') # q3 1990 - q1 1991
    temp_fig2.axvspan(52, 56, alpha=0.5, color='grey') # q1 2001 - q4 2001
    temp_fig2.axvspan(79, 86, alpha=0.5, color='grey') # q4 2007 - q2 2009
    #add recessions
    temp_fig3.axvspan(10, 14, alpha=0.5, color='grey') # q3 1990 - q1 1991
    temp_fig3.axvspan(52, 56, alpha=0.5, color='grey') # q1 2001 - q4 2001
    temp_fig3.axvspan(79, 86, alpha=0.5, color='grey') # q4 2007 - q2 2009
    
    #add / format xticks
    xticks=list(np.arange(0,124,8))
    xtick_labels=list(np.arange(1988,2020,2))
    temp_fig1.set_xticks(xticks)
    temp_fig1.set_xticklabels(xtick_labels)
    temp_fig1.minorticks_off()
    temp_fig2.minorticks_off()
    temp_fig3.minorticks_off()
    
    #titles and labels
    temp_fig1.set_ylabel('fraction of news coverage',fontsize=10)
    temp_fig1.set_title('F.I.R.E.',fontsize=11)
    temp_fig2.set_title('Motor Vehicles',fontsize=11)
    temp_fig3.set_title('Food & Kindred Products',fontsize=11)
    
    #titles, labels, legend
    temp_fig1.set_xlabel('',fontsize=0)
    temp_fig2.set_xlabel('',fontsize=0)
    temp_fig3.set_xlabel('',fontsize=0)
    temp_fig2.legend(loc='lower center',labels=['Company-Based Definition','N-Gram-Based Definition'],fontsize=9,ncol=2,bbox_to_anchor=(0.5, -0.6))
    
    #general formatting
    plt.subplots_adjust(hspace=0.30)
    plt.savefig('../outputs/figure10.pdf',bbox_inches='tight')
    
