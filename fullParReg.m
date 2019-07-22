function [rd,ihcf] = fullParReg(ihc,ifdir)
profileName = parallel.defaultClusterProfile();
clust = parcluster(profileName);
numTasks = 2*clust.NumWorkers;

[rd,ihcrs,ifpaths,b,h,w,scale,ihcscale] = checkVars(ihc,ifdir);   % Check for component TIFF, IHC image and fine scale correction
%b = cast(reshape(cell2mat(rd.micronLoc),2,[]),'uint32')';
rd.h = h;
rd.w = w;
[bbul,ulb,bb,mimat,bbim,rotcor] = getBB(b,ihcrs,h,w,scale,ifpaths,ifdir);    % Rough registration for HPFs to full slide.
toc;
ihcrs = imrotate(ihcrs,rotcor,'crop');      % Coarse rotation applied to IHC image
nim = numTasks;                             % Number of images for calculating transformation
np = round(rand(nim,1)*length(ifpaths));    % Random nim images
%np = round(rand(nim,1)*length(regData.opal{nim2}.filename));
ss = [w h];
sb = [w/2 h/2];                             % Initial search border.
nits = 5;                                   % Number of iterations to calculate registration
scst = 0.5/(nits-1);                        % Step for resizing images. Starts at


files = cell(length(ifpaths),1);
for i1 = 1:length(ifpaths)
    files{i1} = ifpaths(i1).name;
end

fmiDat = cell(size(np,1),nits);             % For storing MI data
cl = double(ulb(np,:)) + bbul;               % ulb is the upper left corner of each HPF relative to the ULC of the bounding box
tic;
job = createJob(clust);
for i1 = 1:numTasks
       cr = uint32([cl(i1,2)-sb(2),cl(i1,2)+ss(2)+sb(2)-1,... % bounds for cropping
            cl(i1,1)-sb(1),cl(i1,1)+ss(1)+sb(1)-1]);
        cr(cr<=0) = 1;
        if cr(2) > size(ihcrs,1)
            cr(2) = size(ihcrs,2);
        end
        if cr(4) > size(ihcrs,2)
            cr(4) = size(ihcrs,2);
        end
        ihcrs2 = ihcrs(cr(1):cr(2),cr(3):cr(4),:);
        tcl = [sb(1) sb(2)];  % temporary cl relative to cropped ulh corner
        % getinitreg returns correct location relative to ULH corner of
        % cropped image, the ULH corner of cropped image, the MI data for
        % each registration step, the correct scale, and the max MI for the
        % registration associated with the coorect scale (interesting plot).
   createTask(job, @getinitreg, 5, {ihcrs2,tcl,ifdir,files,np,i1}); %% look at sub2ind for ndjh
end
submit(job);
wait(job);
y = fetchOutputs(job);
toc;
delete(job);
sca = cell2mat(y(:,4));
ihcscr = mean(sca);

ccl = cell2mat(y(:,2));
ccl(:,1:2) = cl(:,1:2) - sb + ccl(:,1:2).*ihcscale./cell2mat(y(:,4));               % Correct location from reg FOR to WS FOR

ihcrs = imresize(ihcrs,[size(ihcrs,1)*ihcscale/ihcscr(2) size(ihcrs,2)*ihcscale/ihcscr(1)]);
[ab,cd,e,f] = newtform(cl(:,1:2),ccl(:,1:2));           % Calculate affine transformation
tform = affine2d([ab(1) ab(2) e;cd(1) cd(2) f; 0 0 1]'); %% tform the IHC images
Rin = imref2d(size(ihcrs)); %% Referencing the IHC image
ihcf = imwarp(ihcrs,Rin,tform,'OutputView',Rin);
wscl = (double(ulb) + double(bbul)) * ihcscale./ihcscr;

toc;




tic;
sb = 10;
st = length(files)/numTasks;
trm = zeros(length(files),2);
job = createJob(clust);
for i1 = 1:numTasks
    strt = round(st*(i1-1))+1;
    stp = round(st*i1);
    ms = [min(wscl(strt:stp,2)),max(wscl(strt:stp,2))+h,min(wscl(strt:stp,1)),max(wscl(strt:stp,1))+w];
    trm(strt:stp,:) = repmat([ms(3),ms(1)],stp-strt+1,1);
       cr = uint32([ms(1)-sb,ms(2)+sb,...
            ms(3)-sb,ms(4)+sb]);
        cr(cr<=0) = 1;
        ihcrs2 = ihcf(cr(1):cr(2),cr(3):cr(4),:);
        tcl = [wscl(strt:stp,1)-ms(3)+sb wscl(strt:stp,2)-ms(1)+sb];% [sb(1) sb(2)]; % temporary cl relative to cropped ul corner
  mf = files(strt:stp);
        createTask(job, @getfinalreg, 3, {ihcrs2,tcl,ifdir,mf,sb}); %% look at sub2ind for ndjh
end
submit(job);
wait(job);
y = fetchOutputs(job);
toc;
delete(job);
toc;
fcl = double(cell2mat(y(:,2)));
fcl(:,1:2) = trm(:,1:2) - sb + fcl(:,1:2) - 1;

rd.regLoc = fcl;  % final MIF ULH corner
rd.ihcrot = rotcor; % Initial ihc rotation
rd.ihcscr = ihcscr; % final ihc scale
rd.ihcaff = tform;  % final ihc affine tform


