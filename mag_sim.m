%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  20200630, Christina Frieder
% 
%  mag1 - model of macroalgal growth in 1-D
%  volume-averaged; not tracking fronds
%
%  State Variables:
%    NO3, Concentration of nitrate in seawater, [umol NO3/m3]
%    NH4, Concentration of ammonium in seawater, [umol NH4/m3]
%    Ns, macroalgal stored nitrogen, [mg N/m3]
%    Nf, macroalgal fixed nitrogen, [mg N/m3]
%    DON, dissolved organic nitrogen, [mmol N/m3]
%    PON, particulate organic nitrogen, [mg N/m3]
%  Farm Design: 1 dimensional(depth, z) [meters]
%    1:dz:z_cult
%  Environmental input:
%    nitrate, ammonium, dissolved organic nitrogen: for uptake term
%    seawater velociity and wave period: for uptake term
%    temperature: for growth term
%    wave height: for mortality term
%    PAR and chla: for light attenuation
%  Data Source:
%    ROMS, 1-km grid solution for SCB 
%    NBDC for waves
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
% Directories containing input environmental data
dir_ROMS   = 'C:\Users\Christinaf\OneDrive - SCCWRP\macmods\github\mag1-mp-m3\envtl_data\SBCfarm_';
dir_WAVE   = 'C:\Users\Christinaf\OneDrive - SCCWRP\macmods\github\mag1-mp-m3\envtl_data\';

% Biological parameters used by MAG
global param % made global and used by most functions; nothing within code changes param values
param = param_macrocystis; % should have a file per species

% Simulation Input
for year = 1999:2004
    time = simtime([year 1 1; year 12 31]); % start time and stop time of simulation
    farm = farmdesign;  % loads 1-d farm
    
    % Load ENVT input for the year
    %envt = envt_testcase(farm,time); % mean 1999 conditions
    envt = envt_sb(farm,time,dir_ROMS,dir_WAVE); % Santa Barbara 
        
    % Seed the Farm (Initialize Biomass)
    % initial conditions (B,Q) set in farmdesign
    % [frond ID, depth]
    kelp = seedfarm(farm);
    
    % Simulation Output; preallocate space
    kelp_b = NaN(1,length(time.timevec_Gr)); % integrated biomass per growth time step
    Nf_nt = NaN(farm.nz,length(time.timevec_Gr));
    Ns_nt = NaN(farm.nz,length(time.timevec_Gr));


% MAG growth -> set up as dt_Gr loop for duration of simulation
for sim_hour = time.dt_Gr:time.dt_Gr:time.duration % [hours]

    gr_counter = sim_hour / time.dt_Gr;% growth counter
    envt_counter = ceil(gr_counter*time.dt_Gr/time.dt_ROMS); % ROMS counter

    %% DERIVED BIOLOGICAL CHARACTERISTICS
    kelp = kelpchar(kelp,farm);
    
    % Output
    Nf_nt(:,gr_counter) = kelp.Nf;
    Ns_nt(:,gr_counter) = kelp.Ns;
    temp_Nf = find_nan(kelp.Nf);  
    kelp_b(1,gr_counter) = trapz(farm.z_arr,temp_Nf)./param.Qmin./1e3; % kg-dry/m
    kelp_h(1,gr_counter) = kelp.height;
    clear temp_Nf
   
    %% DERIVED ENVT
    envt.PARz  = canopyshading(kelp,envt,farm,envt_counter);
    
    %% GROWTH MODEL
    % updates Nf, Ns with uptake, growth, mortality, senescence
    % calculates DON and PON
    kelp = mag(kelp,envt,farm,time,envt_counter);
    
    %% FROND INITIATION
    kelp = frondinitiation(kelp,envt,farm,time,gr_counter);
    kelp = frondsenescence(kelp,time,sim_hour);   
    
    
end
clear growth_step gr_counter envt_counter 

simid = sprintf('Y%d',year)
mag1.(simid).kelp_b = kelp_b;

end


%% Figure of Output
figure

    c=1;
    for year = 1999:2004
    simid = sprintf('Y%d',year)

    subplot(6,1,c)
    hold on
    plot(mag1.(simid).kelp_b,'r')
    title(year)
    ylabel('B (kg-dry/m2)')
    xlim([0 365])
    ylim([0 12])
    box on
    c=c+1;
    end
    
    
zs = farm.z_arr;
save('Ns_Nf', 'Ns_nt', 'Nf_nt', 'zs');
clear growth_step gr_counter envt_counter 


