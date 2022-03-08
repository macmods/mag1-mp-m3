
    romsgrdfile = 'C:\Users\Christinaf\OneDrive - SCCWRP\macmods\Data\ROMS_L2_SCB_AP\roms_grd.nc'
    global param % made global and used by most functions; nothing within code changes param values
    param = param_macrocystis; % should have a file per species
    farm = farmdesign;  % loads 1-d farm
    romsgrid_full = loadromsgrid;
    romsgrid_full = loadkelpmask(romsgrid_full,farm.z_cult);
    year = 1998
    time = simtime([year 1 1; year 12 31]); % start time and stop time of simulation
    msplit = [1 352; 353 705; 706 1058; 1059 1412];
    subgrid = 1;
    romsgrid1 = loadsubgrid(romsgrid_full,subgrid,msplit);
    subgrid = 2;
    romsgrid2 = loadsubgrid(romsgrid_full,subgrid,msplit);
        

Z1.h = nansum(foutd_mag.harvest_B,3)./1e3; % grams to kg-dry m-2
Z1.b = max(foutd_mag.biomass,[],3); % kg-dry m-2
Z2.h = nansum(foutd_mag.harvest_B,3)./1e3; % grams to kg-dry m-2
Z2.b = max(foutd_mag.biomass,[],3); % kg-dry m-2

figure
    
        minlon_rho = min(min(romsgrid_full.lon_rho)); maxlon_rho =  max(max(romsgrid_full.lon_rho));
        minlat_rho = min(min(romsgrid_full.lat_rho)); maxlat_rho =  max(max(romsgrid_full.lat_rho));

    % max B
    subplot(1,2,1)
        m_proj('mercator','lon_rho',[minlon_rho maxlon_rho],'lat_rho',[minlat_rho maxlat_rho]); %%% DEFINE THE LOCATION
        set(gcf, 'color', [1 1 1]);  
        hold on

        m_pcolor(romsgrid1.lon_rho,romsgrid1.lat_rho,Z1.b)
        m_pcolor(romsgrid2.lon_rho,romsgrid2.lat_rho,Z2.b)
        c1 = cmocean('algae');
        c1(1:3,:) = [1,1,1;1,1,1;1,1,1];
        colormap(c1)
        colorbar
        
        m_gshhs_h('Color','k')
        
        m_plot(romsgrid_full.lon_rho(:,1),romsgrid_full.lat_rho(:,1),'k')
        m_plot(romsgrid_full.lon_rho(:,end),romsgrid_full.lat_rho(:,end),'k')
        m_plot(romsgrid_full.lon_rho(1,:),romsgrid_full.lat_rho(1,:),'k')
        m_plot(romsgrid_full.lon_rho(end,:),romsgrid_full.lat_rho(end,:),'k')

        m_grid('linewi',1,'tickdir','out','FontSize',10) % 10,'xtick',2);  %%% PATCH THE LAND
        title('Max Annual Biomass')
        
    % harvested B
    subplot(1,2,2)
    
        m_proj('mercator','lon_rho',[minlon_rho maxlon_rho],'lat_rho',[minlat_rho maxlat_rho]); %%% DEFINE THE LOCATION
        set(gcf, 'color', [1 1 1]);  
        hold on

        m_pcolor(romsgrid1.lon_rho,romsgrid1.lat_rho,Z1.h)
        m_pcolor(romsgrid2.lon_rho,romsgrid2.lat_rho,Z2.h)
        c1 = cmocean('algae');
        c1(1:3,:) = [1,1,1;1,1,1;1,1,1];
        colormap(c1)
        colorbar
        
        m_gshhs_h('Color','k')
        
        m_plot(romsgrid_full.lon_rho(:,1),romsgrid_full.lat_rho(:,1),'k')
        m_plot(romsgrid_full.lon_rho(:,end),romsgrid_full.lat_rho(:,end),'k')
        m_plot(romsgrid_full.lon_rho(1,:),romsgrid_full.lat_rho(1,:),'k')
        m_plot(romsgrid_full.lon_rho(end,:),romsgrid_full.lat_rho(end,:),'k')

        m_grid('linewi',1,'tickdir','out','FontSize',10) % 10,'xtick',2);  %%% PATCH THE LAND
        title('Harvested B')
        
        
  figure
  h_all = [Z1.h; Z2.h];
  h_all(h_all == 0 ) = NaN;
  boxplot(h_all(:))      
        
        
figure
hold on
for mm = 1:352
for nn = 1:602
    plot(squeeze(foutd_mag.biomass(mm,nn,:)),'-','Color',0.7*[1 1 1])
end
end