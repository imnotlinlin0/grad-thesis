def main():

    #%%############################################################################
    # Step 0: Basic Setup
    ###############################################################################
    
    #import python libraries
    import re
    import pandas as pd
    import numpy as np
    import matplotlib.pyplot as plt
    
    
    #%%############################################################################
    # Step 1: Load the data
    ###############################################################################
    
    data_news_all=pd.read_excel("../outputs/news_all_with_sectors_and_filter.xlsx").drop_duplicates()
    
    
    #%%############################################################################
    # Step 2: Clean and abbreviate the company names for the bar charts
    ###############################################################################
    
    #some regular expressions for cleaning / abbreviating company names
    exp_remove_plot_1=re.compile('(\s)(Corporation|Company|Companies|Incorporated)',re.IGNORECASE)
    exp_remove_plot_2=re.compile('(\s)(Inc(\.)?|Corp(\.)?|Co(\.|\s|$)|LLC|LP|LTD|,|of)',re.IGNORECASE)
    exp_remove_plot_3=re.compile('^(The\s)',re.IGNORECASE)
    exp_remove_plot_4=re.compile('(,)',re.IGNORECASE)
    
    #get a list of all company names ordered as in the full dataframe
    names_all=data_news_all.comp_name.tolist()
    
    #clean the company names for plotting
    names_all=[re.sub(exp_remove_plot_1,"",a) for a in names_all]
    names_all=[re.sub(exp_remove_plot_2,"",a) for a in names_all]
    names_all=[re.sub(exp_remove_plot_3,"",a) for a in names_all]
    names_all=[re.sub(exp_remove_plot_4,"",a) for a in names_all]
    #use some abbreviations
    names_all=[re.sub("Metropolitan","Metrop.",a) for a in names_all]
    
    names_all=[re.sub("Verizon Communications","Verizon Comms",a) for a in names_all]
    names_all=[re.sub("Rocketdyne Holdings","Rocketdyne",a) for a in names_all]
    names_all=[re.sub("Communications","Comms",a) for a in names_all]
    names_all=[re.sub("Manufacturing","Manuf.",a) for a in names_all]
    names_all=[re.sub("North America","N.A.",a) for a in names_all]
    names_all=[re.sub("Exploration","Expl.",a) for a in names_all]
    names_all=[re.sub("Group","Grp",a) for a in names_all]
    
    names_all=[re.sub("Entertainment","Ent.",a) for a in names_all]
    names_all=[re.sub("Enterprises"," ",a) for a in names_all]
    names_all=[re.sub("FedEx","Federal Express",a) for a in names_all]
    names_all=[re.sub("Semiconductor","Semicond.",a) for a in names_all]
    names_all=[re.sub(" \(team\)","",a) for a in names_all]
    
    names_all=[re.sub("United Continental Holdings","United Cont. Hldgs.",a) for a in names_all]
    names_all=[re.sub("New York City","NYC",a) for a in names_all]
    names_all=[re.sub("Advanced Micro Devices","AMD",a) for a in names_all]
    names_all=[re.sub("Technologies","Tech",a) for a in names_all]
    names_all=[re.sub("\sInternational"," Int.",a) for a in names_all]
    names_all=[re.sub("\sIncorporated"," Inc",a) for a in names_all]
    names_all=[re.sub("\sShipbuilding"," Shipb.",a) for a in names_all]
    names_all=[re.sub("United States","US.",a) for a in names_all]
    names_all=[re.sub("Department ","Dept.",a) for a in names_all]
    names_all=[re.sub(" Santa Fe","",a) for a in names_all]
    
    names_all=[re.sub("\sCorporation"," Corp.",a) for a in names_all]
    names_all=[re.sub("\sCompany"," Co.",a) for a in names_all]
    names_all=[re.sub("\sHoldings"," Hldgs",a) for a in names_all]
    names_all=[re.sub("Association","Assoc.",a) for a in names_all]
    names_all=[re.sub("Authority","Auth.",a) for a in names_all]
    
    names_all=[re.sub("\sCompanies"," Cos.",a) for a in names_all]
    names_all=[re.sub("\.$","",a) for a in names_all]
    names_all=[re.sub("\sCompanies"," Cos.",a) for a in names_all]
    names_all=[re.sub("^The ","",a) for a in names_all]
    names_all=[re.sub("Transportation","Transp.",a) for a in names_all]
    names_all=[re.sub("New York and New Jersey","NY & NJ",a) for a in names_all]
    names_all=[re.sub("New York","NY",a) for a in names_all]
    
    names_all=["West Virginia Forestry" if "West Virginia Forestry" in a else a for a in names_all]
    names_all=["Atlanta Int. Airport" if "Atlanta Int. Airport" in a else a for a in names_all]
    names_all=["IBM Corp" if "International Business Machines" in a else a for a in names_all]
    names_all=["Securities & Exch. Comm." if "Securities and Exchange" in a else a for a in names_all]
    names_all=["Georgia Inst. of Tech." if "Georgia" in a else a for a in names_all]
    names_all=["NCAA" if "National Collegiate" in a else a for a in names_all]
    names_all=["ACLU" if "Civil Lib" in a else a for a in names_all]
    names_all=["Thousand Trails" if "Thousand Trails" in a else a for a in names_all]    
    names_all=["Enron Credit Recov. Corp" if "Enron" in a else a for a in names_all]
    names_all=["Ebay" if "이베이" in a else a for a in names_all]
    names_all=["Env. Protection Agency" if "Environmental Protection" in a else a for a in names_all]
    names_all=["Int. Consolidated Airlines" if "Consolidated Airlines" in a else a for a in names_all]
    names_all=["NATO" if "North Atlantic Treaty" in a else a for a in names_all]
    names_all=["Islamic State" if "Islamic State" in a else a for a in names_all]
    names_all=["UN Security Council" if "United Nations Security Council" in a else a for a in names_all]
    names_all=["Shell Transp. & Trad. PLC" if "Shell Transport" in a else a for a in names_all]
    names_all=["Fiat Chrysler Auto NV" if "Fiat Chrysler Automobiles" in a else a for a in names_all]
    names_all=["NBC Universal Media" if "NBCUniversal" in a else a for a in names_all]
    names_all=["JP Morgan Chase" if "Morgan Chase" in a else a for a in names_all]
    names_all=["West Pharma. Svcs." if "West Pharma" in a else a for a in names_all]
    names_all=["Vertex Pharma" if "Vertex Pharma" in a else a for a in names_all]
    names_all=["Mass. Port Auth." if "Massachusetts Port" in a else a for a in names_all]
    names_all=["Mass. General Hospital" if "Massachusetts General Hospital" in a else a for a in names_all]
    names_all=["Int. Monetary Fund" if "International Monetary Fund" in a else a for a in names_all]
    names_all=["Applied Ind. Tech" if "Applied Industrial Tech" in a else a for a in names_all]
    
    
    #add the edited names back to the complete dataframe
    data_news_all['comp_name']=names_all
    
    
    #%%############################################################################
    # Step 3: Distinguish between matched and unmatched companies etc.
    ###############################################################################
    
    #distinguish between matched and unmatched firms
    data_unmatched=data_news_all[data_news_all.dummy_merged==0].copy()
    data_matched=data_news_all[data_news_all.dummy_merged==1].copy()
    
    #convert sector number from float to integer and keep only US companies
    data_matched['sector']=[int(str(a).split(".")[0]) for a in data_matched.sector.tolist()]
    data_matched_US=data_matched[data_matched.dummy_company_US==1]
    
    
    #%%############################################################################
    # Step 4: Plot: Top companies by sector (5 plots)
    ###############################################################################
    
    #some regular expressions for cleaning / abbreviating company names
    exp_remove_plot_1=re.compile('(\s)(Corporation|Company|Companies|Incorporated|Group)',re.IGNORECASE)
    exp_remove_plot_2=re.compile('(\s)(Inc(\.)?|Corp(\.)?|Co(\.|\s|$)|LLC|LP|LTD|,)',re.IGNORECASE)
    exp_remove_plot_3=re.compile('^(The\s)',re.IGNORECASE)
    exp_remove_plot_4=re.compile('(,)',re.IGNORECASE)
    
    #get an ordred list of sector names
    sector_names=data_matched_US[['sector','sector_name']].drop_duplicates().sort_values('sector').sector_name.tolist()
    
    for figure in ["A2","A3","A4","A5","A6"]:
    
        #select sectors for current figure
        if figure=="A2": first=1; last=7
        if figure=="A3": first=7; last=13
        if figure=="A4": first=13; last=19
        if figure=="A5": first=19; last=25
        if figure=="A6": first=25; last=30
        
        
        fig, axes = plt.subplots(nrows=3, ncols=2,figsize=(12,16),sharex=False)
        for i in range(first,last):
            
            #construct sector name and cleaned version
            sector_name_current=sector_names[i-1]
            sector_name_current_clean=re.sub("\s","_",sector_name_current)
            sector_name_current_clean=re.sub("&","and",sector_name_current_clean)
            sector_name_current_clean=re.sub("\.","",sector_name_current_clean)
            
            #get the data of the current sector            
            data_matched_sector_current=data_matched_US[data_matched_US.sector==i]
            n_current=data_matched_sector_current['comp_count'].sum()
            company_counts=data_matched_sector_current[['comp_name','comp_count']].groupby('comp_name').sum().sort_values('comp_count',ascending=False)
        
            #clean the company names for plotting
            names_all=company_counts.index.tolist()
            names_all=[re.sub(exp_remove_plot_1,"",a) for a in names_all]
            names_all=[re.sub(exp_remove_plot_2,"",a) for a in names_all]
            names_all=[re.sub(exp_remove_plot_3,"",a) for a in names_all]
            names_all=[re.sub(exp_remove_plot_4,"",a) for a in names_all]
            #use some abbreviations
            names_all=[re.sub("New York City","NYC",a) for a in names_all]
            names_all=[re.sub("\sInternational"," Int.",a) for a in names_all]
            
            
            company_counts.index=names_all
        
            if i in [1,7,13,19,25]: 
                temp_fig1=company_counts.iloc[0:19].comp_count.plot(kind='bar',fontsize=8,rot=90,ax=axes[0,0])
                temp_fig1.set_ylabel('number of entity tags',fontsize=11)
                temp_fig1.set_xlabel('',fontsize=0)
                temp_fig1.set_title('Sector ' +  str(i) + ': ' + sector_name_current.upper() + ' (TOTAL: ' + str(n_current) + ')',fontsize=11)
                plt.xticks(ha='left')    
                
            if i in [2,8,14,20,26]: 
                temp_fig2=company_counts.iloc[0:19].comp_count.plot(kind='bar',fontsize=8,rot=90,ax=axes[0,1])
                temp_fig2.set_xlabel('',fontsize=0)
                temp_fig2.set_title('Sector ' +  str(i) + ': ' + sector_name_current.upper() + ' (TOTAL: ' + str(n_current) + ')',fontsize=11)
                plt.xticks(ha='left')     
                
            if i in [3,9,15,21,27]: 
                temp_fig3=company_counts.iloc[0:19].comp_count.plot(kind='bar',fontsize=8,rot=90,ax=axes[1,0])
                temp_fig3.set_ylabel('number of entity tags',fontsize=11)
                temp_fig3.set_xlabel('',fontsize=0)
                temp_fig3.set_title('Sector ' +  str(i) + ': ' + sector_name_current.upper() + ' (TOTAL: ' + str(n_current) + ')',fontsize=11)
                plt.xticks(ha='left')    
            
            if i in [4,10,16,22,28]: 
                temp_fig4=company_counts.iloc[0:19].comp_count.plot(kind='bar',fontsize=8,rot=90,ax=axes[1,1])
                temp_fig4.set_xlabel('',fontsize=0)
                temp_fig4.set_title('Sector ' +  str(i) + ': ' + sector_name_current.upper() + ' (TOTAL: ' + str(n_current) + ')',fontsize=11)
                plt.xticks(ha='left')    
            
            
            if i in [5,11,17,23,29]: 
                temp_fig5=company_counts.iloc[0:19].comp_count.plot(kind='bar',fontsize=8,rot=90,ax=axes[2,0])
                temp_fig5.set_ylabel('number of entity tags',fontsize=11)
                temp_fig5.set_xlabel('',fontsize=0)
                temp_fig5.set_title('Sector ' +  str(i) + ': ' + sector_name_current.upper() + ' (TOTAL: ' + str(n_current) + ')',fontsize=11)
                plt.xticks(ha='left')    
            
            
            if i in [6,12,18,24]: 
                temp_fig6=company_counts.iloc[0:19].comp_count.plot(kind='bar',fontsize=8,rot=90,ax=axes[2,1])
                temp_fig6.set_xlabel('',fontsize=0)
                temp_fig6.set_title('Sector ' +  str(i) + ': ' + sector_name_current.upper() + ' (TOTAL: ' + str(n_current) + ')',fontsize=11)
                plt.xticks(ha='left')    
        
            #export
            plt.subplots_adjust(hspace=0.7)
            plt.xticks(ha='left')
            if figure=="A6": axes[2,1].axis('off')
            plt.savefig('../outputs/figure' + str(figure) + '.pdf',bbox_inches='tight')   
    
    
    
