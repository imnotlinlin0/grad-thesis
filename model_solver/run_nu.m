% RUN_NU - Solve the model for a grid of values of NU
%
% usage:
%
% >> run_nu
%
% NOTE: takes approximately 10 minutes on a quad-core iMac
%

nu_grid = [.25,.5,.75,1,1.25,1.5,2,2.3,2.4,2.5,3,3.5];

all = cell(1,length(nu_grid));    
parfor jj = 1:length(nu_grid)
    all{jj} = main_solve_regress(nu_grid(jj));
end

%Random news case
out_randnews =main_solve_regress(1.1, 'rnd');

%No weights case
out_nowghts =main_solve_regress(1.1, 'nwt');

%Ignore conditoning case
out_nocond = main_solve_regress(1.1,'ncnd');

save ../output_files/model_solution all out_randnews out_nowghts out_nocond nu_grid

