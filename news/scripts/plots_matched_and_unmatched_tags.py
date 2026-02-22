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
    # Step 1: Load and prepare the data
    ###############################################################################
    
    #load the news data
    data_news_all=pd.read_excel("../outputs/news_all_with_sectors_and_filter.xlsx").drop_duplicates()
    
    #select a subset of variables
    data_news_all=data_news_all[['comp_name','dummy_company_US','comp_count','start_date','sector','match_source','source_code']].drop_duplicates()
    
    #generate a merge dummy
    data_news_all['dummy_matched']=[1 if str(a)!="nan" else 0 for a in data_news_all.match_source]
    
    
    
    #%%############################################################################
    # Step 2: Get dataset properties for the text in section 5
    ###############################################################################
    
    #number of unique matched and unmatched tags
    n_tags_unique=data_news_all['comp_name'].drop_duplicates().count() #4,333
    n_tags_matched_unique=data_news_all[data_news_all.match_source.astype(str)!="nan"]['comp_name'].drop_duplicates().count() #3,043
    n_tags_matched_factiva_compustat_unique=data_news_all[data_news_all.match_source.astype(str).isin(["factiva","compustat"])]['comp_name'].drop_duplicates().count() #2,983
    n_tags_matched_manual_unique=data_news_all[data_news_all.match_source.astype(str).isin(["manual"])]['comp_name'].drop_duplicates().count() #60
    
    #fractions of matched and unmatched tags (for statistics in data section)
    frac_matched_manual=data_news_all[data_news_all.match_source.astype('str')=="manual"].comp_count.sum()/data_news_all.comp_count.sum()
    frac_matched_factiva_compustat=data_news_all[data_news_all.match_source.astype('str').isin(["factiva",'compustat'])].comp_count.sum()/data_news_all.comp_count.sum()
    frac_matched_total=data_news_all[data_news_all.match_source.astype('str')!="nan"].comp_count.sum()/data_news_all.comp_count.sum()
    
    #number of total tags (for statistics in data section)
    n_tags=data_news_all['comp_count'].sum() 
    n_tags_matched=data_news_all[data_news_all.match_source.astype(str)!="nan"]['comp_count'].sum()
    
    
    #%%############################################################################
    # Step 3: Clean and abbreviate the company names for the bar charts
    ###############################################################################
    
    #some regular expressions for cleaning / abbreviating company names
    exp_remove_plot_1=re.compile('(\s)(Corporation|Company|Companies|Incorporated)',re.IGNORECASE)
    exp_remove_plot_2=re.compile('(\s)(Inc(\.)?|Corp(\.)?|Co(\.|\s|$)|LLC|LP|LTD|,|of)',re.IGNORECASE)
    exp_remove_plot_3=re.compile('^(The\s)',re.IGNORECASE)
    exp_remove_plot_4=re.compile('(,)',re.IGNORECASE)
    
    #get a list of all company names ordered as in the full dataframe
    names_all=data_news_all.comp_name.tolist()
    
    #rename to make compatible with subsequent code
    names_cleaned_current=names_all
    
    #clean the company names for plotting
    names_cleaned_current=[re.sub(exp_remove_plot_1,"",a) for a in names_cleaned_current]
    names_cleaned_current=[re.sub(exp_remove_plot_2,"",a) for a in names_cleaned_current]
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
    names_cleaned_current=[re.sub(" \(team\)","",a) for a in names_cleaned_current]
    
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
    
    names_cleaned_current=["Atlanta Int. Airport" if "Atlanta Int. Airport" in a else a for a in names_cleaned_current]
    names_cleaned_current=["IBM Corp" if "International Business Machines" in a else a for a in names_cleaned_current]
    names_cleaned_current=["Securities & Exch. Comm." if "Securities and Exchange" in a else a for a in names_cleaned_current]
    names_cleaned_current=["Georgia Inst. of Tech." if "Georgia" in a and "Tech" in a else a for a in names_cleaned_current]
    names_cleaned_current=["NCAA" if "National Collegiate" in a else a for a in names_cleaned_current]
    names_cleaned_current=["ACLU" if "Civil Lib" in a else a for a in names_cleaned_current]
    names_cleaned_current=["Thousand Trails" if "Thousand Trails" in a else a for a in names_cleaned_current]    
    names_cleaned_current=["Enron Credit Recov. Corp" if "Enron" in a else a for a in names_cleaned_current]
    names_cleaned_current=["Ebay" if "이베이" in a else a for a in names_cleaned_current]
    names_cleaned_current=["Env. Protection Agency" if "Environmental Protection" in a else a for a in names_cleaned_current]
    names_cleaned_current=["Int. Consolidated Airlines" if "Consolidated Airlines" in a else a for a in names_cleaned_current]
    names_cleaned_current=["NATO" if "North Atlantic Treaty" in a else a for a in names_cleaned_current]
    names_cleaned_current=["Islamic State" if "Islamic State" in a else a for a in names_cleaned_current]
    names_cleaned_current=["UN Security Council" if "United Nations Security Council" in a else a for a in names_cleaned_current]
    names_cleaned_current=["Shell Transp. & Trad. PLC" if "Shell Transport" in a else a for a in names_cleaned_current]
    names_cleaned_current=["Fiat Chrysler Auto NV" if "Fiat Chrysler Automobiles" in a else a for a in names_cleaned_current]
    names_cleaned_current=["NBC Universal Media" if "NBCUniversal" in a else a for a in names_cleaned_current]
    names_cleaned_current=["JP Morgan Chase" if "Morgan Chase" in a else a for a in names_cleaned_current]
    names_cleaned_current=["BMW AG" if "Bayerische Motoren Werke AG" in a else a for a in names_cleaned_current]
    names_cleaned_current=["Federal Reserve Board" if "Federal Reserve System" in a else a for a in names_cleaned_current]
    names_cleaned_current=["US Food and Drug Admin." if "Food and Drug Admin" in a else a for a in names_cleaned_current]
    names_cleaned_current=["Federal Bureau of Invest." if "Federal Bureau Invest" in a else a for a in names_cleaned_current]
    
    #add the edited names back to the complete dataframe
    data_news_all['comp_name']=names_cleaned_current
    
    #%%############################################################################
    # Step 4: Get the company counts for the subsamples
    ###############################################################################
    
    #distinguish between matched and unmatched firms
    data_unmatched=data_news_all[data_news_all.dummy_matched==0].copy()
    data_matched=data_news_all[data_news_all.dummy_matched==1].copy()
    
    #convert sector number from float to integer
    data_matched['sector']=[int(str(a).split(".")[0]) for a in data_matched.sector.tolist()]
    
    #matched tags that refer to US companys vs other matched tags
    data_matched_US=data_matched[data_matched.dummy_company_US==1]
    data_matched_non_US=data_matched[data_matched.dummy_company_US==0]
    
    #get the company-specific counts
    comp_counts_matched_US=data_matched_US[['comp_count','comp_name']].groupby('comp_name').sum().sort_values('comp_count',ascending=False)
    comp_counts_matched_non_US=data_matched_non_US[['comp_count','comp_name']].groupby('comp_name').sum().sort_values('comp_count',ascending=False)
    comp_counts_unmatched=data_unmatched[['comp_count','comp_name']].groupby('comp_name').sum().sort_values('comp_count',ascending=False)
    
    
    #%%############################################################################
    # Step 5: Plot
    ###############################################################################
    
    #define the figure
    fig, axes = plt.subplots(nrows=3, ncols=1,figsize=(12,16),sharex=False)
    
    #plot the first category
    temp_fig1=comp_counts_matched_US.iloc[0:25].comp_count.plot(kind='bar',fontsize=8,rot=90,ax=axes[0])
    temp_fig1.set_ylabel('number of entity tags',fontsize=10)
    temp_fig1.set_ylim(0,25000)
    temp_fig1.set_xlabel('',fontsize=0)
    temp_fig1.yaxis.grid(color='gray', linestyle='dashed')
    temp_fig1.set_axisbelow(True)
    total_string=str(comp_counts_matched_US.comp_count.sum())
    temp_fig1.set_title('Most Frequent Matched Entity Tags Classified as US Companies (N = ' + total_string[0:3] + "," + total_string[3:] + ')',fontsize=10)
    plt.xticks(ha='left')    
        
    #plot the second category
    temp_fig2=comp_counts_matched_non_US.iloc[0:25].comp_count.plot(kind='bar',fontsize=8,rot=90,ax=axes[1])
    temp_fig2.set_ylabel('number of entity tags',fontsize=10)
    temp_fig2.set_xlabel('',fontsize=0)
    temp_fig2.set_ylim(0,25000)
    temp_fig2.yaxis.grid(color='gray', linestyle='dashed')
    temp_fig2.set_axisbelow(True)
    total_string=str(comp_counts_matched_non_US.comp_count.sum())
    temp_fig2.set_title('Most Frequent Matched Entity Tags not Classified as US Companies (N = ' + total_string[0:3] + "," + total_string[3:] + ')',fontsize=10)
    plt.xticks(ha='left')     
    
    #plot the third category
    temp_fig3=comp_counts_unmatched.iloc[0:25].comp_count.plot(kind='bar',fontsize=8,rot=90,ax=axes[2])
    temp_fig3.set_ylabel('number of entity tags',fontsize=10)
    temp_fig3.set_xlabel('',fontsize=0)
    temp_fig3.set_ylim(0,25000)
    temp_fig3.yaxis.grid(color='gray', linestyle='dashed')
    temp_fig3.set_axisbelow(True)
    total_string=str(comp_counts_unmatched.comp_count.sum())
    temp_fig3.set_title('Most Frequent Unmatched Entity Tags (N = ' + total_string[0:3] + "," + total_string[3:] + ')',fontsize=10)
    plt.xticks(ha='left')
    
    #export
    plt.subplots_adjust(hspace=0.7)
    plt.xticks(ha='left')
    plt.savefig('../outputs/figureA1.pdf',bbox_inches='tight')
    
