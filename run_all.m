% RUN_ALL - Runs all of the replication files for calibrating and solving
% the model in "Sectoral Media Focus and Aggregate Fluctuations" by 
% Chahrour, Pitschner, Nimark (2021) 
%
% >> run_all


%% Arrange the path
setup
t0 = tic;

%% Section 4 Figures
disp('Compiling Figures for Section 4...')
cd Section4
make_figures
cd ..

%% BEA IO tables
disp('Compiling IO tables from BEA...')
cd BEA_io/
import_use_table
cd ..

%% BLS productivty series
disp('Compiling sectoral TFP timeseries from BLS multifactor...')
cd BLS_multifactor/
import_bls_data
cd ..

%% GDP and HOURS data
disp('Compiling GDP and HRS from 1987-2018...');
cd gdp_stats/
load_basic_data
cd ..

%% SVAR data
disp('Compiling data for SVAR...')
cd SVAR_data
load_all
cd ..

%% Estimate news weights
disp('Estimating news weight function (~10 minutes)...')
cd news_selection_function/
nsf_calibrator
cd ..

%% Solve full model/make figures
disp('Solving model for a grid of NU (~5 minutes with 8 cores)...')
cd model_solver/
parpool
run_nu
make_figures
cd ..


%% Perform the SVAR exercise in Section 7
disp('Performing SVAR exercise (~10 minutes)...')
cd SVAR_approach/
SVAR
make_figures
cd ..

