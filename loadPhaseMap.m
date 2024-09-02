function [ebsd, grains]=loadPhaseMap(varargin)
% Load a phase map and create "ebsd" which can be used with some 
% of the avaiable tools for grain/grainboundary analysis
%
% Three cases are be distinguished.
%
% 1) Single phase,tightly packed no matrix ('single')
%    input:  boundary map - binary image ("white" boundaries, value should be 255)!
%    output: ebsd with grains of distinct, nonsense orientation and notIndexed 
%            at the boundaries
%
% 2) Single phase, particles in matrix ('matrix')
%    input:  phase map - binary image ("white" matrix, value should be 255)!
%    output: ebsd with matrix as nonIndexed and particles as indexed phase
%
% 3) poly phase ('poly')
%    input:  boundary map and phase map ("white" boundaries (=255), gv phases (1-254))
%    output: ebsd with phases, each grain with a distinct orientation and
%            notIndexed  at the boundaries, 
% 
% In the case of 'single' or 'poly' all grain should have distinct
% (non-sense) orientations which allow that the grain boundary "notIndexed"
% phase can be removed
%
% Input:
%  image(s) tif,png ... (black should be 0)
%  image model - single, matrix or poly
%
% Output:
%  ebsd, grains
%
% Syntax:
%  [ebsd, grains]=loadPhaseMap('grainboundarymap.tif','polyphasemap.tif','poly')
%
% NOTES: 
% 1) Images are expected to be 8-bit (greyscale) images
% 2) particles/grains shall be black (=0), boundaries shall be "white" (=255)
% 3) boundary maps should be 4-connected (pixel edges are touching), so
%    best to make sure boundaries are 2 pixels wide
% 4) any sort of orientation related information, orientations,
%    misorientations etc. is all non-sense !!! this is simply for the purpose
%    to derive grains and exploit some nice mtex functionality!
%

if ~ismember(varargin{end},{'single','matrix','poly'})
    error('Please specify an image model')
end

% some things that need to be defined but are somewhat meaningless
if check_option(varargin,'single') || check_option(varargin,'matrix')
    phases = double(imread(varargin{1}));
    nphase=1;
    % convert to 0,1
    id_phase=phases==0;
    phases(id_phase)=1;
    phases(~id_phase)=0;
end

if check_option(varargin,'poly')
    boundary = double(imread(varargin{1}));
    id_b=boundary~=0;
    boundary(id_b)=1;
    boundary(~id_b)=0;
    phases = double(imread(varargin{2}));
    
    if min(reshape(phases,[],1))==0
        phases = phases+1;
    end
    % intesect with boundary
    phases(boundary==1)=0;
    
    % get the number of phases
    uniphase = unique(phases);
    nphase=length(uniphase);
    tmpphase=zeros(size(phases));
    for j=1:nphase
        tmpphase(phases == uniphase(j))=j-1;
    end
    phases=tmpphase;
    
end

% put the fake ebsd together
% set up the phase
cs = {'notIndexed'};
for i=1:nphase
    cs{i+1}= crystalSymmetry('-1', 'mineral',['phase' num2str(i)]);
end

% set up x,y coordinates
[X, Y] = meshgrid(1:numel(phases(1,:)), 1:numel(phases(:,1)));

%define fake rot% set initial fake Eulers
faEu=reshape(zeros(size(phases)),1,[])';
o = rotation('Euler',faEu,faEu,faEu);
%assign X,Y coordinates
opt.x = reshape(X,1,[])';
opt.y = reshape(Y,1,[])';
opt.e = reshape(zeros(size(phases)),1,[])';
%create ebsd-object from rotation,mask, cs,ss and XY coordinates
% fake_ebsd = EBSD(o,reshape(phases,1,[])',cs,ss,'options',opt);
try
% this syntax works for mtex 5.11 and earlier (no ebsd.pos)
ebsd = EBSD(o,reshape(phases,1,[])',cs,opt);
catch
% this syntax is for mtex 6.0beta2 and later, i.e. from the feature/grain3d branch
ebsd = EBSD([opt.x(:) opt.y(:)], o,reshape(phases,1,[])',cs,opt);
end

%some silly way to define the unitcell - I don't know better
ebsd.unitCell = [-0.5 -0.5;0.5 -0.5; 0.5 0.5;-0.5  0.5];
ebsd = updateUnitCell(ebsd);

% postConditions - create (hopefully) distinct orientations for each grain
% note taht for really really large number of grains, segmentation later on
% might need to be done with a very small threshold
if check_option(varargin,'single') || check_option(varargin,'poly')
    [grains, ebsd.grainId]=ebsd.calcGrains;
    % add a fake prop for each grain, such that we can get rid of the
    % unindexed boundaries
    lp = linspace(1, 2*length(grains('indexed')), length(grains('indexed')));
    [~, p] = ismember(ebsd('indexed').grainId,grains('indexed').id);
    ebsd('indexed').prop.e = lp(p);

%     o=equispacedSO3Grid(cs{2},ss,'points',length(grains('indexed')));
%     fake_ebsd('indexed').rotations = rotation(o(grains('indexed').grainId));
end

% if grains are desired
if nargout == 2
    if check_option(varargin,'single') || check_option(varargin,'poly')
    %get rid of 2px ridges between grains
    ebsd = ebsd('indexed').gridify;
    % compute grains again
    [grains, ebsd.grainId]=ebsd.calcGrains('custom',ebsd.prop.e,'delta',1,'alpha',3);
    else
    [grains, ebsd.grainId]=ebsd.calcGrains;
    end
end

end
