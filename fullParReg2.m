%% fullParReg
%% Created by: Joshua Doyle
%% Edited by: Benjamin Green
%% ---------------------------------------------------------------
%% Description
%
%
%% ---------------------------------------------------------------
%
function [rd,ihcf] = fullParReg2(ihc,ifdir)
%
% open a parallel cluster
%
try
    clust = parcluster('BG3');
catch
    profileName = parallel.defaultClusterProfile();
    clust = parcluster(profileName);
end

%
% Check for component TIFF, IHC image and fine scale correction
%
[rd,ihcrs,ifpaths,b,h,w,scale,ihcscale] = checkVars(ihc,ifdir);

[bbim,ulb] = stitchTiles(b,scale,ifdir,ifpaths,1);

%
% Rough registration for HPFs to full slide.
% bbul is [x,y] of the bounding box ULH corner. ulb is the ULH
% corner of the MIF HPFs. bb are the corners of the
%
[bbul,bb,mimat,rotcor,ihcrs,rd] = getBB2(ihcrs,bbim(:,:,1),rd);

%
% Coarse rotation applied to IHC image
%
% ihcrs = imrotate(ihcrs,rotcor,'crop'); % USE CUBIC

%
% cl gives the ULH corner of the MIF HPFs relative to the IHC origin
% ulb is the upper left corner of each HPF relative to the ULC of the
% bounding box and bbul is the ULH of the calculated bounding box in getBB.
% Coordinates are given as [X,Y].
%
cl = double(ulb) + bbul-1;
rd.cl = cl;

%
% Boundary for all MIF HPFs
%
k = boundary(cl(:,1),cl(:,2));
%
% Number of sample images, minimum of 100 or total MIF HPFs.
%
nim = min(100,length(cl));
%
% Grid coordinates - the unique MIF HPF x's and y's
%
gx = unique(cl(:,1));
gy = unique(cl(:,2));
gc = reshape([repmat(gx',length(gy),1),repmat(gy,1,length(gx))],[],2);
%
% Count nim grid coor. within HPF ULC boundary and find corresponding HPF
%
gic = round(linspace(1,length(gc),nim));
[in,on] = inpolygon(gc(gic,1),gc(gic,2),cl(k,1),cl(k,2));
np = unique(knnsearch(cl,gc(gic(in|on),:)));

%
% While the number of HPFs, np, we counted within our boundary is less than
% desired, we increase the number of sampled grid coor., gc, and check
% again.
%
ngc = nim;
while length(np)<nim    
    ngc = ngc + 1;
    gic = round(linspace(1,length(gc),ngc));
    [in,on] = inpolygon(gc(gic,1),gc(gic,2),cl(k,1),cl(k,2));
    np = unique(knnsearch(cl,gc(gic(in|on),:)));
end
rd.np = np;

%
% Initial search border.
%
sb = [w h]/2;
rd.sb1 = sb;

% 
% Getting file names
%
files = cell(length(ifpaths),1);
for i1 = 1:length(ifpaths)
    files{i1} = ifpaths(i1).name;
end

%
% number of tasks = number of workers on our cluster.
%
numTasks = clust.NumWorkers;

%
% Here we assign the number of images, nn, to each worker. nn is filled
% from the minimum bin up
%
nn = zeros(numTasks,1);
while sum(nn) < length(np)
   nn(find(nn==min(nn),1)) = nn(find(nn==min(nn),1)) + 1; 
end
%
% For holding index of all nearest neighbor images that are assigned to each
% worker
%
NN = cell(numTasks,1);
%
% For all bounding boxes of the nearest neighbor images
%
M = cell(numTasks,1);
%
% Flag for remaining images
%
L = true(length(cl(np)),1);

for i1 = 1:numTasks
    %
    %  Index of all remaining images. Needed to assign and remove.
    %
    l = find(L==1);
    %
    % Index of all remaining nearest neighbors to the first remaining 
    %
    Idx = knnsearch(cl(np(L),:),cl(np(find(L==1,1)),:),'K',nn(i1));
    %
    % Assigning 
    %
    NN{i1} = np(l(Idx));
    % Removing
    L(l(Idx)) = 0;
    %
    % Bounding boxing
    %
    M{i1} = [min(cl((NN{i1}),:),[],1) max(cl((NN{i1}),:),[],1)];
end
rd.NN1 = NN;
rd.M1 = M;
rd.sb1 = sb;
fprintf(['Calculating initial transformation with ',int2str(length(np)),' sample images \n'])

% Here we create our tasks. 
tic;
% f = true(numTasks,1);
job = createJob(clust);
cr = cell(length(M),1);
for i1 = 1:numTasks
    if ~isempty(M{i1})
        cr{i1} = uint32([M{i1}(2)-2*sb(2),M{i1}(4)+rd.h+2*sb(2),...
                     M{i1}(1)-2*sb(1),M{i1}(3)+rd.w+2*sb(1)]);
        cr{i1}(cr{i1}<=0) = 1;
        if cr{i1}(2) > size(ihcrs,1)
            cr{i1}(2) = size(ihcrs,1);
        end
        if cr{i1}(4) > size(ihcrs,2)
            cr{i1}(4) = size(ihcrs,2);
        end
        ihcrs2 = ihcrs(cr{i1}(1):cr{i1}(2),cr{i1}(3):cr{i1}(4),:);
        tcl = [cl(NN{i1},1)-cast(cr{i1}(3)+1,class(cl)) ...
            cl(NN{i1},2)-cast(cr{i1}(1)+1,class(cl))];
        mf = files(NN{i1});
        createTask(job, @getreg, 3, {ihcrs2,tcl,ifdir,mf,sb});
%         f(i1) = 1;
    end
    % M{i1} should only be empty if there are less than numTasks number of
    % sample images, but here just in case, we want to hold that index so
    % when we reshape the product of our job below, our indexes match.
    if isempty(M{i1})
        createTask(job, @emptyTask, 0, {i1});
%         f(i1) = 0;
    end
end
submit(job);
wait(job);
y = fetchOutputs(job);
delete(job);
toc;
rd.yi = y;
% ty = y(f,:);

% Here we reshape the product of our job. Because the HPFs were assigned to
% each core by nearest neighbor search, we must use the NN assignments to
% re-place the job products in the correct order. miData contains the
% mutual information arrays for every scale interation (0.1-1.0 in 0.1 step
% increments) of each image. ccl contains the newly found correct
% registration coordinates of the ULH corner of each sample image, np.
% n=0;
miData = cell(length(np),1);
ccl = double(size(np));
for i1 = 1:length(y)
    if ~isempty(y{i1,1})
    for i2 = 1:length(y{i1,3})
%         n = n+1;
        miData{np==NN{i1}(i2)} = y{i1,3}{i2};
        ccl(np==NN{i1}(i2),:) = y{i1,2}{i2}(1:2) + double(cr{i1}([3 1]));
    end  
    end
end

conf = miConfidence2(miData);
rd.conf = conf;
rd.ccl =ccl;

% c = 0.99;
% rd.c = c;
% n = round(sum(conf>c));
c = 0.99;
n = sum(conf>c);
p = n/length(conf);
dc = 0.01;
while p<0.5%n <3   %p < 0.50
c = c - dc;
n = sum(conf>c);
p = n/length(conf);
end
T = calcIndTr(ccl,cl,c,conf,np,n); % n nearest neighbors sampled
rd.T = T;
rd.c = c;

% Calculate affine transformation for registrations with confidence > c
[ab,cd,e,f] = newtform(cl(np(conf>c),1:2),ccl(conf>c,1:2));

% tform the IHC image
tform = affine2d([ab(1) ab(2) e;cd(1) cd(2) f; 0 0 1]');
% Referencing the IHC image
Rin = imref2d(size(ihcrs));
ihcf = imwarp(ihcrs,Rin,tform,'OutputView',Rin); % USE CUBIC

wscl = (double(ulb) + double(bbul));% .* ihcscr./ihcscale;
rd.wscl = wscl;
%


% our final search border given by the max distance from the mean. The mean
% should be approximately equal to the affine transformation applied to the
% IHC image
% mp = mean(wscl,1);
% t
sb = min(100,2*ceil(max(abs(T(:,5:6)-mean(T(:,5:6)))) + 10));
% sb = [50 50];

numTasks = clust.NumWorkers;
% C = {'r','g','b','y','c','m','k','w'};
% nn = round(length(wscl)/numTasks);
while sum(nn) < length(wscl)
   nn(find(nn==min(nn),1)) = nn(find(nn==min(nn),1)) + 1; 
end
NN = cell(numTasks,1);
M = cell(numTasks,1);
% B = cell(numTasks,1);
L = true(length(wscl),1);
% figure,imshow(ihcrs);hold on
for i1 = 1:numTasks
    l = find(L==1);
    Idx = knnsearch(wscl(L,:),wscl(find(L==1,1),:),'K',nn(i1));
    NN{i1} = l(Idx);
    L(NN{i1}) = 0;
    %         q = round(rand(1)*length(C));
    %         q(q==0)=1;
    %         scatter(wscl(NN{i1},1),wscl(NN{i1},2),'MarkerEdgeColor', C{q})
    M{i1} = [min(wscl(NN{i1},:),[],1) max(wscl(NN{i1},:),[],1)];
    %         B{i1} = [repmat(M{i1}([1,3])',2,1) M{i1}([2,4,4,2])'];
    %         k = boundary(B{i1});
    %         plot(B{i1}(k,1),B{i1}(k,2), 'Color',C{q});
    
end
rd.NN2 = NN;
rd.M2 = M;
rd.sb2 = sb;
% hold off
fprintf(['Calculating final translation with ',int2str(length(files)),' images \n'])
tic
job = createJob(clust);
% f = true(numTasks,1);
cr = cell(length(M),1);
for i1 = 1:numTasks
    if ~isempty(M{i1})
        cr{i1} = [M{i1}(2)-2*sb(2) M{i1}(4)+rd.h+2*sb(2) ...
              M{i1}(1)-2*sb(1) M{i1}(3)+rd.w+2*sb(1)];
          cr{i1}(cr{i1}<1) = 1;
          if cr{i1}(2) > size(ihcf,1)
              cr{i1}(2) = size(ihcf,1);
          end
          if cr{i1}(4) > size(ihcf,2)
              cr{i1}(4) = size(ihcf,2);
          end
        ihcrs2 = ihcf(cr{i1}(1):cr{i1}(2),cr{i1}(3):cr{i1}(4),:);
        tcl =  [wscl(NN{i1},1)-cr{i1}(3)+1 ...
               wscl(NN{i1},2)-cr{i1}(1)+1];
%         tcl = [wscl(NN{i1},1)-(M{i1}(1)-sb(1))+1 ...
%                wscl(NN{i1},2)-(M{i1}(2)-sb(2))+1];
        mf = files(NN{i1});
        createTask(job, @getfinalreg, 3, {ihcrs2,tcl,ifdir,mf,sb});
%         f(i1) = 1;
    end
    if isempty(M{i1})
        createTask(job, @emptyTask, 0, {i1});
%         f(i1) = 0;
    end
end
submit(job);
wait(job);
y = fetchOutputs(job);
toc;
% rd.f = f;
% yt = y(f,:);
delete(job);
fcl = zeros(size(wscl));
% locl = zeros(size(wscl));
fmiData = cell(length(wscl),1);
for i1 = 1:length(y)
    if ~isempty(y{i1,1})
        for i2 = 1:length(y{i1,3})
            
            fmiData{NN{i1}(i2)} = y{i1,3}{i2};
%             locl(NN{i1},:) = y{i1,1}(:,:);
            
        end
        fcl(NN{i1},:) = double(y{i1,2}(:,1:2)) + double(cr{i1}([3 1])) - 1;
%                       + double([M{i1}(1) M{i1}(2)] ...
%                       - sb);
    end
end
rd.yf = y;
fconf = miConfidence2(fmiData);
rd.fconf = fconf;
% final MIF ULH corner
rd.regLoc = fcl;
% Initial ihc rotation
rd.ihcrot = rotcor;
% % final ihc scale
% % rd.ihcscr = ihcscr;
% final ihc affine tform
rd.ihcaff = tform;
end


