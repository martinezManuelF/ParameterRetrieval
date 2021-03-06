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

ero = 3.05;
ere = 4.7917;

% HIGH RESOLUTION GRID
Nx = 1024;
Ny = 1024;

% PWEM PARAMETERS
PQ.P    = 11;
PQ.Q    = 11;
MODE.EM = 'H';

% NUMBER OF POINTS IN BAND DIAGRAM
NP = 50;

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

% BUILD INHOMOGENEOUS UNIT CELL
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
DEV.ER(nx3:nx4,ny2:Ny)  = er1;

% BUILD HOMOGENEOUS DEVICE
DEV1.ER = ones(Nx,Ny);
DEV1.UR = ones(Nx,Ny);
if (MODE.EM == 'E')
    DEV1.ER = ere * DEV1.ER;
elseif (MODE.EM == 'H')
    DEV1.ER = ere * DEV1.ER;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% BEGIN PWEM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% COMPUTE BLOCH WAVE VECTORS

% Reciprocal Lattice Vectors
T1 = (2*pi/a) * [1 ; 0];
T2 = (2*pi/a) * [0 ; 1];

% Key points of symmetry
G = [0 ; 0];
X = 0.5.*T1;
M = 0.5*T1 + 0.5.*T2;

% Generate list of Bloch Wave Vectors
L1      = norm(X-G);
L2      = norm(M-X);
L3      = norm(M-G);
NP1     = NP;
NP2     = round(NP1*L2/L1);
NP3     = round(NP1*L3/L1);

bx = [ linspace(G(1),X(1),NP1), linspace(X(1),M(1),NP2) , ...
        linspace(M(1),G(1),NP3) ];
by = [ linspace(G(2),X(2),NP1), linspace(X(2),M(2),NP2) , ...
        linspace(M(2),G(2),NP3) ];
BETA = [ bx ; by ];

DEV.LATTICE     = a;
DEV1.LATTICE    = a;

% PERFORM SIMULATION
[WNIH,KoIH] = pwem2d(DEV,BETA,PQ,MODE); % SUPER CELL
[WNH,KoH]   = pwem2d(DEV1,BETA,PQ,MODE);% HOMOGENIZED CELL

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% POST-PROCESS DATA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h = plot([1:length(bx)],WNH,'.r','LineWidth',1.5);
hold on;
h1 = plot([1:length(bx)],WNIH,'*b','LineWidth',1.5);
set([h1],'MarkerSize',3);
set(h,'MarkerSize',10);
hold off;
ylim([0 0.5]);
xlim([1 length(bx)]);
h2 = get(h(1),'Parent');
set(h2,'FontSize',13,'LineWidth',1.5);
title([MODE.EM '$\textrm{ Mode}$'],'FontSize',16,'Interpreter','LaTex')

% Format x-Axis
XT = [1 NP1 NP1+NP2 length(bx)];
XL = {'\Gamma','X','M','\Gamma','Interpreter','LaTex'};
set(h2,'XTick',XT,'XTickLabel',XL);
xlabel('Bloch Wave Vector ($\vec{\beta}$)','Interpreter','LaTex','FontSize',14);

% Format y-Axis
ylabel('Normalized Frequency $\frac{\omega a}{2\pi c_0}$','Interpreter',...
    'LaTex','FontSize',14,'Rotation',90);

% Add Legend
l = legend([h(1) h1(1)],'Homogeneous Unit Cell','Unit Cell','Location','Best');
set(l(1),'Box','off');
