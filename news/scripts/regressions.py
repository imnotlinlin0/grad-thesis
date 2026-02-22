def main(): 

    #%%############################################################################
    # Step 0: Basic Setup
    ###############################################################################
    
    #import python libraries
    import regex as re
    import pandas as pd
    import numpy as np
    import statsmodels.api as sm
    import matplotlib.pyplot as plt
    from statsmodels.iolib.summary2 import summary_col
    
    #%%############################################################################
    # Step 1: Load and prepare the news data 
    ###############################################################################
    
    #import the news time series
    data_news=pd.read_excel('../outputs/news_fractions_baseline_filtered.xlsx')
    
    #add a year variable to the news dataframe
    years=[]
    for i in range(1988,2019): 
        years.append(i) 
        years.append(i)
        years.append(i)
        years.append(i)
    data_news['year']=years
    
    #annual averages
    data_news_annual=data_news.groupby('year').mean()
    
    #reformat the news series to long panel format
    sector_names=list(data_news_annual.columns) 
    data_news_annual_long=pd.DataFrame()
    for i in range(0,len(sector_names)):
        sector_name_current=sector_names[i]
        data_news_annual_current=pd.DataFrame(data_news_annual[sector_name_current])
        data_news_annual_current.columns = ["news_fraction"]
        data_news_annual_current['sector_name']=sector_name_current
        data_news_annual_current['sector']=i+1
        data_news_annual_long=data_news_annual_long.append(data_news_annual_current)
    
    
    #%%############################################################################
    # Step 2: Load and prepare the macro data
    ###############################################################################
    
    #import the macro data
    data_gdp = pd.read_excel("../inputs/multifactor_output.xlsx", sheet_name="Output (index)").rename(columns={"Unnamed: 0": "year"}).set_index('year')
    data_labor = pd.read_excel("../inputs/multifactor_output.xlsx", sheet_name="Labor (index)").rename(columns={"Unnamed: 0": "year"}).set_index('year')
    data_tfp = pd.read_excel("../inputs/multifactor_output.xlsx", sheet_name="TFP (index)").rename(columns={"Unnamed: 0": "year"}).set_index('year')
    
    #reformat the macro series to long panel format
    sector_names=list(data_news_annual.columns) 
    data_gdp_long=pd.DataFrame()
    data_tfp_long=pd.DataFrame()
    data_labor_long=pd.DataFrame()
    
    for i in range(0,len(sector_names)):
        sector_name_current=sector_names[i]
        sector_current=i+1
        data_gdp_current=pd.DataFrame(data_gdp.iloc[:,sector_current-1])
        data_tfp_current=pd.DataFrame(data_tfp.iloc[:,sector_current-1])
        data_labor_current=pd.DataFrame(data_labor.iloc[:,sector_current-1])
        data_gdp_current.columns = ["gdp"]
        data_tfp_current.columns = ["tfp"]
        data_labor_current.columns = ["labor"]
        data_gdp_current['sector_name']=sector_name_current
        data_tfp_current['sector_name']=sector_name_current
        data_labor_current['sector_name']=sector_name_current
        data_gdp_current['sector']=i+1
        data_tfp_current['sector']=i+1
        data_labor_current['sector']=i+1
        data_gdp_long=data_gdp_long.append(data_gdp_current)
        data_tfp_long=data_tfp_long.append(data_tfp_current)
        data_labor_long=data_labor_long.append(data_labor_current)
        
    #combine all macro data into one dataframe
    data_macro_long=data_gdp_long
    data_macro_long['tfp']=data_tfp_long['tfp']
    data_macro_long['labor']=data_labor_long['labor']

    #log differences
    data_macro_long['delta_gdp']=np.log(data_macro_long.groupby('sector')['gdp'].shift(0)) - np.log(data_macro_long.groupby('sector')['gdp'].shift(1))
    data_macro_long['delta_tfp']=np.log(data_macro_long.groupby('sector')['tfp'].shift(0)) - np.log(data_macro_long.groupby('sector')['tfp'].shift(1))
    data_macro_long['delta_labor']=np.log(data_macro_long.groupby('sector')['labor'].shift(0)) - np.log(data_macro_long.groupby('sector')['labor'].shift(1))
    #absolute values of log differences
    data_macro_long['abs_delta_gdp']=np.abs(data_macro_long.delta_gdp)
    data_macro_long['abs_delta_tfp']=np.abs(data_macro_long.delta_tfp)
    data_macro_long['abs_delta_labor']=np.abs(data_macro_long.delta_labor)
    
    
    #%%############################################################################
    # Step 3: Merge the macro and news data into one dataframe 
    ###############################################################################
    
    #merge the two datasets and select sample
    data_merged=pd.merge(data_news_annual_long,data_macro_long,left_on=['year','sector'],right_on=['year','sector'],how="left")
    data_merged=data_merged[['sector_name_x','sector','news_fraction','gdp','tfp','labor','delta_gdp','delta_tfp','delta_labor','abs_delta_gdp','abs_delta_tfp','abs_delta_labor']].rename(columns={"sector_name_x": "sector_name"})
    data_merged=data_merged[data_merged.index>=1988]
    data_merged=data_merged[data_merged.index<=2018]
    
    
    #%%############################################################################
    # Step 4: Run the regressions
    ###############################################################################
    
    #make a table
    sectors_used=[5,11,12,20,22,24,25,27,28,29]
    names_sectors_used=data_merged[data_merged.sector.isin(sectors_used)].sort_values('sector')['sector_name'].drop_duplicates().tolist()
    names_sectors_used=[a.upper() for a in names_sectors_used]
    reg_results=pd.DataFrame(columns=['const','delta_labor','delta_gdp','delta_tfp','abs_delta_labor','abs_delta_gdp','abs_delta_tfp'])
    count=1
    for sector_current in sectors_used:    
        #run the first regression
        data_merged_current=data_merged[data_merged.sector==sector_current]
        x=data_merged_current[['delta_labor','delta_gdp','delta_tfp','abs_delta_labor','abs_delta_gdp','abs_delta_tfp']]
        x=sm.add_constant(x)
        results=sm.OLS(data_merged_current['news_fraction'],x).fit(use_t=True,cov_type='HC1')
        test=summary_col([results],stars=True)
        table=test.tables[0].iloc[:14]
        results_temp=table.news_fraction.tolist()
        #obtain and format the coefficients
        coeffs=[a for a in results_temp if not "(" in a]
        coeffs_float=[float("".join([b for b in a if b!="*"])) for a in coeffs]
        coeffs_stars=[re.sub("[0-9,\.-]","",a) for a in coeffs]
        coeffs_rounded=[str(np.round(a,decimals=2)) for a in coeffs_float]
        coeffs=[coeffs_rounded[i]+coeffs_stars[i] for i in range(0,len(coeffs))]
        #obtain and format the standard errors
        standard_errors=[a for a in results_temp if "(" in a]
        standard_errors_float=[float("".join([b for b in a if not b in ["(",")"]])) for a in standard_errors]
        #calculate and format t-stats
        tstats=[coeffs_float[i]/standard_errors_float[i] for i in range(0,len(coeffs))]
        tstats=[str(np.round(a,decimals=2)) for a in tstats]
        #add everything to the output table
        reg_results.loc[count]=coeffs
        reg_results.loc[count+1]=tstats
        count=count+2
    
    column_one=[]
    column_two=[]
    for i in range(0,len(names_sectors_used)):
        column_one.append(names_sectors_used[i])
        column_one.append("")
        column_two.append('coeff')
        column_two.append("t-stat")
    reg_results['Sector']=column_one
    reg_results['Statistic']=column_two
    selector=['Sector','Statistic','const','delta_labor','delta_gdp','delta_tfp','abs_delta_labor','abs_delta_gdp','abs_delta_tfp']
    reg_results=reg_results[selector].set_index('Sector')
    reg_results.columns=(['Statistic','Const.','delta_labor','delta_gdp','delta_tfp','abs_delta_labor','abs_delta_gdp','abs_delta_tfp'])
    #print(reg_results)
    reg_results.to_latex('../outputs//regressions_news_macro_OLS.tex')
    
    
    
    
    
    
    
