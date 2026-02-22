def main():
    
    #%%############################################################################
    # Step 0: Basic Setup
    ###############################################################################
    
    #import python libraries
    import pandas as pd
    import numpy as np
    import matplotlib.pyplot as plt
    
    
    #%%############################################################################
    # Step 1: Load the news data
    ###############################################################################
    
    fractions_average=pd.read_excel('../outputs/news_fractions_baseline.xlsx')
    fractions_average_all=pd.read_excel('../outputs/news_fractions_extended.xlsx')
    fractions_average_filtered=pd.read_excel('../outputs/news_fractions_baseline_filtered.xlsx')
    fractions_average_filtered_all=pd.read_excel('../outputs/news_fractions_extended_filtered.xlsx')
    
    
    #%%############################################################################
    # Step 2: Create the selected figure
    ###############################################################################
    
    #get the sector names
    sector_names_all=fractions_average.columns.values.tolist()
    titles=sector_names_all
    
    for figure in ["9","A7","A8","A9"]:
    
        #select the subset of sectors to show
        if figure=="9": sector_list=[4,10,11,19,21,23,24,26,27,28]
        if figure=="A7": sector_list=[0,1,2,3,4,5,6,7,8,9]
        if figure=="A8": sector_list=[10,11,12,13,14,15,16,17,18,19]
        if figure=="A9": sector_list=[20,21,22,23,24,25,26,27,28]
        
        sector_names_selected=[]
        for a in sector_list: sector_names_selected.append(sector_names_all[a])
        
        #define the xticks and their labels
        xticks=list(np.arange(0,124,8))
        xtick_labels=list(np.arange(1988,2020,2))
        
        #pre-define the 10 sub-plot index locations
        locations=[[0,0],[0,1],[1,0],[1,1],[2,0],[2,1],[3,0],[3,1],[4,0],[4,1]]
        
        fig, axes = plt.subplots(nrows=5, ncols=2,figsize=(11,11),sharex=True)
        for i in range(0,len(sector_list)):
            #print(i)
            sector_name_current=sector_names_selected[i]
            temp_fig1=fractions_average_filtered[sector_name_current].plot(kind='line',fontsize=8,rot=90,ax=axes[locations[i][0],locations[i][1]])
            temp_fig1=fractions_average_filtered_all[sector_name_current].plot(kind='line',linestyle='--',fontsize=8,rot=90,ax=axes[locations[i][0],locations[i][1]])
            temp_fig1=fractions_average[sector_name_current].plot(kind='line',fontsize=8,rot=90,ax=axes[locations[i][0],locations[i][1]])    
            temp_fig1.set_ylabel('fraction of coverage',fontsize=10)
            temp_fig1.set_xlabel('',fontsize=0)
            temp_fig1.set_title('Sector ' +  str(sector_list[i] + 1) + ': ' + sector_name_current.upper(),fontsize=11)
            temp_fig1.set_ylim(bottom=0)
            temp_fig1.set_xlim(0,123)
            temp_fig1.yaxis.grid(color='gray', linestyle='dotted')
            temp_fig1.set_axisbelow(True)
            temp_fig1.set_xticks(xticks)
            temp_fig1.set_xticklabels(xtick_labels)
            temp_fig1.minorticks_off()
            #add recessions
            temp_fig1.axvspan(10, 14, alpha=0.5, color='grey') # q3 1990 - q1 1991
            temp_fig1.axvspan(52, 56, alpha=0.5, color='grey') # q1 2001 - q4 2001
            temp_fig1.axvspan(79, 86, alpha=0.5, color='grey') # q4 2007 - q2 2009
            #add the legend
            if i==8: temp_fig1.legend(loc='lower center',labels=['NYT + WSJ filtered (baseline)','All papers filtered','NYT + WSJ unfiltered'],fontsize=9,ncol=3,bbox_to_anchor=(1.1, -0.65))
        
        
        plt.subplots_adjust(hspace=0.35)
        plt.xticks(ha='center')
        if figure=="A9": plt.axis('off')
        
        ##### EXPORT THE FIGURE
        plt.savefig('../outputs/figure' + str(figure) + '.pdf',bbox_inches='tight')   
