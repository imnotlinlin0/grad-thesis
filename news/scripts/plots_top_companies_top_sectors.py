def main():

    #%%############################################################################
    # Step 0: Basic Setup
    ###############################################################################
    
    #import python libraries
    import re
    import pandas as pd
    import matplotlib.pyplot as plt
    
    
    #%%############################################################################
    # Step 1: Load and prepare the data
    ###############################################################################
    
    data_news_all=pd.read_excel("../outputs/news_all_with_sectors_and_filter.xlsx").drop_duplicates()
    
    #distinguish between matched and unmatched firms
    data_unmatched=data_news_all[data_news_all.dummy_merged==0].copy()
    data_matched=data_news_all[data_news_all.dummy_merged==1].copy()
    
    #convert sector number from float to integer
    data_matched['sector']=[int(str(a).split(".")[0]) for a in data_matched.sector.tolist()]
    
    #distinguish between US and non-US firms within the matched set
    data_matched_US=data_matched[data_matched.dummy_company_US==1]
    
    
    #%%############################################################################
    # Step 2: Plot top companies by sector (5 plots of six sectors each)
    ###############################################################################
    
    #some regular expressions for cleaning / abbreviating company names
    exp_remove_plot_1=re.compile('(\s)(Corporation|Company|Companies|Incorporated)',re.IGNORECASE)
    exp_remove_plot_2=re.compile('(\s)(Inc(\.)?|Corp(\.)?|Co(\.|\s|$)|LLC|LP|LTD|,|of)',re.IGNORECASE)
    exp_remove_plot_3=re.compile('^(The\s)',re.IGNORECASE)
    exp_remove_plot_4=re.compile('(,)',re.IGNORECASE)
    
    #get an ordred list of sector names and select the relevant sectors
    sector_names=data_matched_US[['sector','sector_name']].drop_duplicates().sort_values('sector').sector_name.tolist()
    fig, axes = plt.subplots(nrows=5, ncols=2,figsize=(14,18),sharex=False)
    sectors_selected=[5,11,12,20,22,24,25,27,28,29]
    
    
    for i in range(1,11):
        
        #get the current sector's id
        sector_current=sectors_selected[i-1]
    
        #construct sector name and cleaned version for saving
        sector_name_current=sector_names[sector_current-1]
        sector_name_current_clean=re.sub("\s","_",sector_name_current)
        sector_name_current_clean=re.sub("&","and",sector_name_current_clean)
        sector_name_current_clean=re.sub("\.","",sector_name_current_clean)
        if re.search("^transportation",sector_name_current_clean.lower()): sector_name_current_clean="Transp. & Warehousing" 
        sector_name_current_clean=re.sub("_"," ",sector_name_current_clean)
        sector_name_current=sector_name_current_clean
        
        #get the data of the current sector
        data_matched_sector_current=data_matched_US[data_matched_US.sector==sector_current]
        n_current=data_matched_sector_current['comp_count'].sum()
        company_counts=data_matched_sector_current[['comp_name','comp_count']].groupby('comp_name').sum().sort_values('comp_count',ascending=False)
    
        #clean the company names for plotting
        names_cleaned_current=company_counts.index.tolist()
        names_cleaned_current=[re.sub(exp_remove_plot_1,"",a) for a in names_cleaned_current]
        names_cleaned_current=[re.sub(exp_remove_plot_2,"",a) if not "AT&T " in a else a for a in names_cleaned_current]
        names_cleaned_current=[re.sub(exp_remove_plot_3,"",a) for a in names_cleaned_current]
        names_cleaned_current=[re.sub(exp_remove_plot_4,"",a) for a in names_cleaned_current]
        #use some abbreviations
        names_cleaned_current=[re.sub("Metropolitan","Metrop.",a) for a in names_cleaned_current]
        
        names_cleaned_current=[re.sub("Verizon Communications","Verizon Comms",a) for a in names_cleaned_current]
        names_cleaned_current=[re.sub("Rocketdyne Holdings","Rocketdyne",a) for a in names_cleaned_current]
        names_cleaned_current=[re.sub("Communications","Comms",a) for a in names_cleaned_current]
        names_cleaned_current=[re.sub("Manufacturing","Manuf.",a) for a in names_cleaned_current]
        names_cleaned_current=[re.sub("North America","N.A.",a) for a in names_cleaned_current]
        names_cleaned_current=[re.sub("Exploration","Expl.",a) for a in names_cleaned_current]
        names_cleaned_current=[re.sub("Group","Grp",a) for a in names_cleaned_current]
        
        names_cleaned_current=[re.sub("Entertainment","Ent.",a) for a in names_cleaned_current]
        names_cleaned_current=[re.sub("Enterprises"," ",a) for a in names_cleaned_current]
        names_cleaned_current=[re.sub("FedEx","Federal Express",a) for a in names_cleaned_current]
        names_cleaned_current=[re.sub("Semiconductor","Semicond.",a) for a in names_cleaned_current]
        
        names_cleaned_current=[re.sub("United Continental Holdings","United Cont. Hldgs.",a) for a in names_cleaned_current]
        names_cleaned_current=[re.sub("New York City","NYC",a) for a in names_cleaned_current]
        names_cleaned_current=[re.sub("Advanced Micro Devices","AMD",a) for a in names_cleaned_current]
        names_cleaned_current=[re.sub("Technologies","Tech",a) for a in names_cleaned_current]
        names_cleaned_current=[re.sub("\sInternational"," Int.",a) for a in names_cleaned_current]
        names_cleaned_current=[re.sub("\sIncorporated"," Inc",a) for a in names_cleaned_current]
        names_cleaned_current=[re.sub("\sShipbuilding"," Shipb.",a) for a in names_cleaned_current]
        names_cleaned_current=[re.sub("United States","US.",a) for a in names_cleaned_current]
        names_cleaned_current=[re.sub("Department ","Dept.",a) for a in names_cleaned_current]
        names_cleaned_current=[re.sub(" Santa Fe","",a) for a in names_cleaned_current]
        
        names_cleaned_current=[re.sub("\sCorporation"," Corp.",a) for a in names_cleaned_current]
        names_cleaned_current=[re.sub("\sCompany"," Co.",a) for a in names_cleaned_current]
        names_cleaned_current=[re.sub("\sHoldings"," Hldgs",a) for a in names_cleaned_current]
        names_cleaned_current=[re.sub("Association","Assoc.",a) for a in names_cleaned_current]
        names_cleaned_current=[re.sub("Authority","Auth.",a) for a in names_cleaned_current]
        
        names_cleaned_current=[re.sub("\sCompanies"," Cos.",a) for a in names_cleaned_current]
        names_cleaned_current=[re.sub("\.$","",a) for a in names_cleaned_current]
        names_cleaned_current=[re.sub("\sCompanies"," Cos.",a) for a in names_cleaned_current]
        names_cleaned_current=[re.sub("^The ","",a) for a in names_cleaned_current]
        names_cleaned_current=[re.sub("Transportation","Transp.",a) for a in names_cleaned_current]
        names_cleaned_current=[re.sub("New York and New Jersey","NY & NJ",a) for a in names_cleaned_current]
        names_cleaned_current=[re.sub("New York","NY",a) for a in names_cleaned_current]
        names_cleaned_current=[re.sub("TRW Automotive","TRW Auto",a) for a in names_cleaned_current]
        
        
        names_cleaned_current=["Atlanta Int. Airport" if "Atlanta Int. Airport" in a else a for a in names_cleaned_current]
        names_cleaned_current=["IBM Corp" if "International Business Machines" in a else a for a in names_cleaned_current]
        names_cleaned_current=["Securities & Exch. Comm." if "Securities and Exchange" in a else a for a in names_cleaned_current]
        names_cleaned_current=["Georgia Inst. of Tech." if "Georgia" in a and "Inst" in a else a for a in names_cleaned_current]
        names_cleaned_current=["NCAA" if "National Collegiate" in a else a for a in names_cleaned_current]
        names_cleaned_current=["ACLU" if "Civil Lib" in a else a for a in names_cleaned_current]
        names_cleaned_current=["Thousand Trails" if "Thousand Trails" in a else a for a in names_cleaned_current]    
        names_cleaned_current=["Enron Credit Recov. Corp" if "Enron" in a else a for a in names_cleaned_current]
        names_cleaned_current=["Ebay" if "이베이" in a else a for a in names_cleaned_current]
    
        names_cleaned_current=["Vertex Pharma" if "Vertex Pharma" in a else a for a in names_cleaned_current]
        names_cleaned_current=["Mass. Port Auth." if "Massachusetts Port" in a else a for a in names_cleaned_current]
        names_cleaned_current=["Mass. General Hospital" if "Massachusetts General Hospital" in a else a for a in names_cleaned_current]
        names_cleaned_current=["Int. Monetary Fund" if "International Monetary Fund" in a else a for a in names_cleaned_current]
        names_cleaned_current=["Applied Ind. Tech" if "Applied Industrial Tech" in a else a for a in names_cleaned_current]
        names_cleaned_current=["Harper Collins" if "Collins Publishers" in a else a for a in names_cleaned_current]
        names_cleaned_current=["Associated Press" if "Associated Press" in a else a for a in names_cleaned_current]
        names_cleaned_current=["H.M.H. Publishing" if "Harcourt" in a else a for a in names_cleaned_current]
    
        #correct some abbreviations
        names_cleaned_current=["Dow Jones & Co" if "Dow Jones &" in a else a for a in names_cleaned_current]
        names_cleaned_current=["WW Norton & Co" if "WW Norton &" in a else a for a in names_cleaned_current]
        names_cleaned_current=["Eli Lilly & Co" if "Eli Lilly and" in a else a for a in names_cleaned_current]
        names_cleaned_current=["Merck & Co" if "Merck &" in a else a for a in names_cleaned_current]
        names_cleaned_current=["Best Buy" if "Best BuyInc" in a else a for a in names_cleaned_current]
        names_cleaned_current=["JPMorgan Chase & Co" if "JPMorgan Chase &" in a else a for a in names_cleaned_current]
        names_cleaned_current=["Wells Fargo & Co" if "Wells Fargo &" in a else a for a in names_cleaned_current]
    
        #add the edited names back in
        company_counts.index=names_cleaned_current
    
        
        if i in [1,13,19,25]: 
            temp_fig1=company_counts.iloc[0:19].comp_count.plot(kind='bar',fontsize=8,rot=90,ax=axes[0,0])
            temp_fig1.set_ylabel('number of storries',fontsize=10)
            temp_fig1.set_xlabel('',fontsize=0)
            temp_fig1.set_title('Sector ' +  str(sector_current) + ': ' + sector_name_current.upper() + ' (N=' + str(n_current) + ')',fontsize=12)
            plt.xticks(ha='left')    
            
        if i in [2,14,20,26]: 
            temp_fig2=company_counts.iloc[0:19].comp_count.plot(kind='bar',fontsize=8,rot=90,ax=axes[0,1])
            temp_fig2.set_xlabel('',fontsize=0)
            temp_fig2.set_title('Sector ' +  str(sector_current) + ': ' + sector_name_current.upper() + ' (N=' + str(n_current) + ')',fontsize=12)
            plt.xticks(ha='left')     
            
        if i in [3,15,21,27]: 
            temp_fig3=company_counts.iloc[0:19].comp_count.plot(kind='bar',fontsize=8,rot=90,ax=axes[1,0])
            temp_fig3.set_ylabel('number of storries',fontsize=10)
            temp_fig3.set_xlabel('',fontsize=0)
            temp_fig3.set_title('Sector ' +  str(sector_current) + ': ' + sector_name_current.upper() + ' (N=' + str(n_current) + ')',fontsize=12)
            plt.xticks(ha='left')        
    
        if i in [4,16,22,28]: 
            temp_fig4=company_counts.iloc[0:19].comp_count.plot(kind='bar',fontsize=8,rot=90,ax=axes[1,1])
            temp_fig4.set_xlabel('',fontsize=0)
            temp_fig4.set_title('Sector ' +  str(sector_current) + ': ' + sector_name_current.upper() + ' (N=' + str(n_current) + ')',fontsize=12)
            plt.xticks(ha='left')        
        
        if i in [5,11,17,23,29]: 
            temp_fig5=company_counts.iloc[0:19].comp_count.plot(kind='bar',fontsize=8,rot=90,ax=axes[2,0])
            temp_fig5.set_ylabel('number of storries',fontsize=10)
            temp_fig5.set_xlabel('',fontsize=0)
            temp_fig5.set_title('Sector ' +  str(sector_current) + ': ' + sector_name_current.upper() + ' (N= ' + str(n_current) + ')',fontsize=12)
            plt.xticks(ha='left')    
            
        if i in [6,12,18,24]: 
            temp_fig6=company_counts.iloc[0:19].comp_count.plot(kind='bar',fontsize=8,rot=90,ax=axes[2,1])
            temp_fig6.set_xlabel('',fontsize=0)
            temp_fig6.set_title('Sector ' +  str(sector_current) + ': ' + sector_name_current.upper() + ' (N=' + str(n_current) + ')',fontsize=12)
            plt.xticks(ha='left')    
            
        if i in [7,12,18,24]: 
            temp_fig7=company_counts.iloc[0:19].comp_count.plot(kind='bar',fontsize=8,rot=90,ax=axes[3,0])
            temp_fig7.set_ylabel('number of storries',fontsize=10)
            temp_fig7.set_xlabel('',fontsize=0)
            temp_fig7.set_title('Sector ' +  str(sector_current) + ': ' + sector_name_current.upper() + ' (N=' + str(n_current) + ')',fontsize=12)
            plt.xticks(ha='left')    
            
        if i in [8,12,18,24]: 
            temp_fig8=company_counts.iloc[0:19].comp_count.plot(kind='bar',fontsize=8,rot=90,ax=axes[3,1])
            temp_fig8.set_xlabel('',fontsize=0)
            temp_fig8.set_title('Sector ' +  str(sector_current) + ': ' + sector_name_current.upper() + ' (N=' + str(n_current) + ')',fontsize=12)
            plt.xticks(ha='left')    
            
        if i in [9,12,18,24]: 
            temp_fig9=company_counts.iloc[0:19].comp_count.plot(kind='bar',fontsize=8,rot=90,ax=axes[4,0])
            temp_fig9.set_ylabel('number of storries',fontsize=10)
            temp_fig9.set_xlabel('',fontsize=0)
            temp_fig9.set_title('Sector ' +  str(sector_current) + ': ' + sector_name_current.upper() + ' (N=' + str(n_current) + ')',fontsize=12)
            plt.xticks(ha='left')    
            
        if i in [10,12,18,24]: 
            temp_fig10=company_counts.iloc[0:19].comp_count.plot(kind='bar',fontsize=8,rot=90,ax=axes[4,1])
            temp_fig10.set_xlabel('',fontsize=0)
            temp_fig10.set_title('Sector ' +  str(sector_current) + ': ' + sector_name_current.upper() + ' (N=' + str(n_current) + ')',fontsize=12)
            plt.xticks(ha='left')    
       
    
    #export
    plt.xticks(ha='left')
    plt.subplots_adjust(hspace=1.2)
    plt.xticks(ha='left')
    plt.savefig('../outputs/figure7.pdf',bbox_inches='tight')
    
