def main():

    #%%############################################################################
    # Step 0: Basic Setup
    ###############################################################################
    
    #import python libraries
    import pandas as pd
    import numpy as np
    import matplotlib.pyplot as plt
    
    
    #%%############################################################################
    # Step 1a: Load and prepare the news data
    ###############################################################################
    
    #import the news fractions and take averages
    data_news=pd.read_excel('../outputs/news_fractions_baseline_filtered.xlsx') 
    average_fractions_news=pd.DataFrame(data_news.mean())
    sector_names=list(data_news.columns.values)
    
    
    #%%############################################################################
    # Step 1b: Load and prepare the macro data
    ###############################################################################
    
    #load the klems data
    klems_new = pd.read_excel("../inputs/multifactor_output.xlsx", sheet_name="Output (gross millions)")
    klems_new=klems_new.rename(columns={"Unnamed: 0": "year"})
    klems_new=klems_new[klems_new.year>=1988]
    klems_new=klems_new[klems_new.year<=2018]
    klems_new = klems_new.set_index('year')
    
    #construct some averages
    fractions=(klems_new.T/klems_new.T.sum()).T
    average_fractions=fractions.mean()
    
    
    #%%############################################################################
    # Step 2: Cross-Plots: Output fraction vs fraction of news coverage
    ###############################################################################
    
    #combine into one dataframe for plotting
    fractions_combined=pd.DataFrame()
    fractions_combined['fractions_news']=average_fractions_news[0].tolist()
    fractions_combined['fractions_real']=average_fractions.tolist()
    fractions_combined['index_new']=list(range(1,30))
    fractions_combined=fractions_combined.set_index('index_new')
    total_fractions=fractions_combined
    
    #define set of sectors to be annotated in the plot
    index_annotate=[1,3,4,10,11,17,19,20,21,23,24,26,27,28]
    
    #plot
    fig, axes = plt.subplots(nrows=1, ncols=1,figsize=(8,8),sharex=True)
    temp_fig1=total_fractions.plot.scatter(x='fractions_real',y='fractions_news',ax=axes,grid=True)
    #loop to annotate
    for k, v in total_fractions.iloc[index_annotate][['fractions_real','fractions_news']].iterrows():
        axes.annotate(sector_names[k-1], v+0.001, fontsize=10)
    #format the plot
    x = np.linspace(-1,1)
    axes.plot(x,x)
    axes.set_xbound(lower=-0.02,upper=0.26)
    axes.set_ybound(lower=-0.02,upper=0.26)
    axes.set_axisbelow(True)
    axes.yaxis.grid(color='gray', linestyle='dotted')
    temp_fig1.set_ylabel("fraction of news coverage",fontsize=12) 
    temp_fig1.set_xlabel("fraction of total gross output",fontsize=12) 
    axes.xaxis.grid(color='gray', linestyle='dotted')
    #export the figure
    plt.savefig('../outputs/figure6.pdf',bbox_inches='tight')
    
    
    #%%############################################################################
    # Step 3: Cross-Plots: Gross output vs fraction of coverage received
    ###############################################################################
    
    #combine into one dataframe for plotting
    fractions_combined=pd.DataFrame()
    fractions_combined['fractions_news']=average_fractions_news[0].tolist()
    fractions_combined['fractions_real']=average_fractions.tolist()
    fractions_combined['index_new']=list(range(1,30))
    fractions_combined=fractions_combined.set_index('index_new')
    total_fractions=fractions_combined
    
    #obtain the cumulative fractions
    fractions_cumulative_news=pd.DataFrame(total_fractions['fractions_news'].sort_values(ascending=False).cumsum())
    fractions_cumulative_real=pd.DataFrame(total_fractions['fractions_real'].sort_values(ascending=False).cumsum())
    fractions_cumulative_both=pd.DataFrame()
    fractions_cumulative_both['fractions_news']=fractions_cumulative_news.fractions_news.tolist()
    fractions_cumulative_both['fractions_real']=fractions_cumulative_real.fractions_real.tolist()
    fractions_cumulative_both['index_new']=list(range(1,30))
    fractions_cumulative_both=fractions_cumulative_both.set_index('index_new')
    
    #plot the cumulative fractions
    fig,axes = plt.subplots(nrows=1, ncols=1,figsize=(7,7),sharex=True)
    temp_fig1=fractions_cumulative_both.plot(ax=axes,grid=True,linewidth=2,fontsize=10,style=['-','--'])
    axes.set_axisbelow(True)
    axes.yaxis.grid(color='gray', linestyle='dotted')
    temp_fig1.set_ylabel("fraction of total",fontsize=10) 
    temp_fig1.set_xlabel("number of sectors",fontsize=10) 
    axes.set_xbound(lower=1,upper=29)
    axes.set_ybound(lower=0,upper=1)
    axes.set_xticks([1,5,10,15,20,25,29])
    axes.xaxis.grid(color='gray', linestyle='dotted')
    temp_fig1.legend(['Cumulative Fractions of News Coverage','Cumulative Fractions of Gross Output'],loc='lower right')
    
    #export the figure
    plt.savefig('../outputs/figure8.pdf',bbox_inches='tight')
    
