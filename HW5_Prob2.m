%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FILENAME:         HW5_Prob2.m
% COURSE:           EE5322--21st Century Electromagnetics
% INSTRUCTOR:       Raymond C. Rumpf
% NAME:             Manuel F. Martinez
% SEMESTER:         Spring 2018
% DUE DATE:         03/08/2018
% LAST MODIFIED:    03/08/2018
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% INTIALIZE MATLAB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% RESTORE STATE
clear all;
close all;
clc;

% UNITS
meters      = 1;
centimeters = 1e-2 * meters;
millimeters = 1e-3 * meters;
degrees     = pi/180;
seconds     = 1;
hertz       = 1/seconds;
gigahertz   = 1e9 * hertz;

% CONSTANTS
e0 = 8.85418782e-12;
u0 = 1.25663706e-6;
N0 = sqrt(u0/e0);
c0 = 299792458 * meters/seconds;

% OPEN FIGURE WINDOW
figure('Color','w');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DASHBOARD
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% UNIT CELL PARAMETERS
a   = 1.0 * centimeters;
w   = 6.0 * millimeters;
t   = 1.0 * millimeters;
er1 = 9.5;
er2 = 1.0;

% HIGH RESOLUTION GRID
Nx = 1024;
Ny = 1024;

% PWEM PARAMETERS
PQ.P    = 51;
PQ.Q    = 51;
MODE.EM = ['E' 'H'];

% ATTENUATION FACTOR
Betamax = (pi/a)*[1;0];
bMin = 0.0001;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% BUILD UNIT CELL ONTO HIGH RESOLUTION REAL-SPACE GRID
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% INITIAL GUESS AT RESOLUTION
dx = a/Nx;
dy = a/Ny;

% SNAP GRID TO CRITICAL DIMENSIONS
nx = ceil(t/dx);
dx = t/nx;
ny = ceil(t/dy);
dy = t/ny;

% CONSTRUCT AXES
xa = [0:Nx-1]*dx; xa = xa - mean(xa);
ya = [0:Ny-1]*dy; ya = ya - mean(ya);

% BUILD UNIT CELL
DEV.UR  = ones(Nx,Ny);
DEV.ER  = er2 * ones(Nx,Ny);

% CALCULATE START AND STOP INDICES
nx  = Nx/2;
nx1 = (Nx - (w/dx))/2 - 1;
nx2 = nx1 + (w/dx);
nx3 = nx - ceil(t/2/dx) + 1;
nx4 = nx + ceil(t/2/dx);
ny  = Ny/2;
ny1 = (Ny - (w/dy))/2 - 1;
ny2 = ny1 + (w/dy);
ny3 = ny - ceil(t/2/dy) + 1;
ny4 = ny + ceil(t/2/dy);

DEV.ER(nx1:nx2,ny1:ny2) = er1;
DEV.ER(1:nx1,ny3:ny4)   = er1;
DEV.ER(nx2:Nx,ny3:ny4)  = er1;
DEV.ER(nx3:nx4,1:ny1)   = er1;
DEV.ER(nx3:nx4,ny2:Ny)   = er1;

% % VISUALIZE SUPER CELL
c = imagesc(xa,ya,DEV.ER');
axis equal tight;
title('$\textrm{Unit Cell}$','Interpreter','LaTex','FontSize',15);
colormap(gray);
colorbar;
c = get(c,'Parent');
set(c,'FontSize',12);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% BEGIN PWEM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% COMPUTE BLOCH WAVE VECTORS
BETA = bMin.*Betamax;

DEV.LATTICE = a;

% PERFORM SIMULATION
for n = 1 : length(MODE.EM);
    switch MODE.EM(n)
        case 'E'
            [WN,Ko] = pwem2d(DEV,BETA,PQ,MODE.EM(n));
            
            % EXTRACT REFRACTIVE INDEX
            ne = norm(BETA)/real(sqrt(min(Ko)));
        case 'H'
            [WN,Ko] = pwem2d(DEV,BETA,PQ,MODE.EM(n));
            
            % EXTRACT REFRACTIVE INDEX
            no = norm(BETA)/real(sqrt(min(Ko)));
    end
end

% EXTRACT PROPERTIES
eo = no^2
ee = ne^2

a = sqrt(eo/ee)
e = sqrt(eo*ee)