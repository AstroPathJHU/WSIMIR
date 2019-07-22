%{
This function returns
cl - "correct location" given as [x,y] referenced from
the upper left hand corner of the reference image
maxMI - The average mutual information of pixel pairs at the "correct location" in the search space. 
and 
MMI - a matrix of mutual information values for each location evaluated.

im is the stationary, reference image and im2 is the floating image
size(im) - size(im2) should be positive and determines the search space.

st is the step size as [stepx stepy]
ss is subsampling, a fraction of the image pixels to sample from
Joshua Doyle, 07/2018
%}

function [cl,maxMI,MMI] = getNDJHRegistration(im,im2,st,ss,scale)

if ~exist('st','var')
    st = [1 1];
end
if ~exist('ss','var')
    ss = 1;
end
if ~exist('scale','var')
    scale = true;
end
format long;
% tic;
if scale
im = uint8(zeroAndScale(im,16));
im2 = uint8(zeroAndScale(im2,16));
end
[h1,w1,bands1] = size(im);
[h2,w2,bands2] = size(im2);
MMI = zeros(round((h1-h2+1)/st(2)),round((w1-w2+1)/st(1)),'single');
imReshape2 = reshape(im2,[],bands2)+1;
ndim = bands1+bands2;
maxMI = 0.0;
%%% Search area
%tic
%n = 0;
%------------
%Subsampling
if ss == 1
    np = h2*w2;
    p = 1:np;
end
if ss ~= 1
np = round(h2*w2*ss);
p = 1:round(1/ss):h2*w2;%ceil(rand(np,1)*size(imReshape2,1));
end
imReshape2 = imReshape2(p,:);
% tic;
% t = getCompTime(im,imReshape2,p,h2,w2,bands1,bands2,ndim,np)
% %t = toc;
% disp(['Estimated time to compute is ',num2str(t*((h1-h2)*w1/st(1)+(w1-w2)*h2/st(2)))]) 
% toc;
% tic;
ix = 0;
% tic;
for correctionX = 1:st(1):w1-w2+1%2*sr(1)+1
    ix = ix + 1;
    iy = 0;
    for correctionY = 1:st(2):h1-h2+1%2*sr(2)+1%startY-10:1:startY+10%100:(size(im,1)/4)%-size(im2,1))%correctY-10:1:correctY+10%
        iy = iy + 1;
        % tic;
        imReshape = reshape(im((correctionY):(correctionY+h2-1),(correctionX):(correctionX+w2-1),:),[],bands1) + 1;
        imReshape = imReshape(p,:);
%         toc;
%         tic;
        jhData = cast([imReshape imReshape2],'single');
        
        rzd = round(jhData);
        maxcol = max(rzd,[],1);
        mincol = min(rzd,[],1);
        rzd = rzd(:,:) - mincol + 1;
        histoSize = cast(maxcol - mincol+1,'uint64');
        dimIndex = getDimProd(histoSize);
        zdTracker = rzd(:,1:ndim);
        zdTracker(:,2:ndim) = zdTracker(:,2:ndim)-1;
        jhTracker = zdTracker(:,1:ndim)*dimIndex(1,1:ndim)';
        
        %jhTracker = sub2ind(histoSize,[rzd]);
        %jointHisto = spalloc(prod(cast(histoSize(1:ndim),'uint64')),1,h*w);%zeros(max(jhTracker(:)),1);
        jointHisto = zeros(cast(prod(histoSize(1:ndim)),'uint64'),1,'uint32');
        %jointHisto = cast(repmat(jointHisto,prod(histoSize(bands1+1:ndim)),1),'uint32');
        %Make histogram
       % jointHisto = zeros(256,256,bands);
        for x = 1:length(rzd(:,1))
            jointHisto(jhTracker(x)) = jointHisto(jhTracker(x)) + 1;
            %assignmentTracker(x) = jhTracker(x);
        end
        %sum(cast(jointHisto,'single')/(np))
        jointProb = reshape(cast(jointHisto,'single')/(np),histoSize(1:ndim));%/(h2*w2)
        marginalProbF = jointProb;
        marginalProbR = jointProb;
        for i1 = 1:bands1
        marginalProbF = sum(marginalProbF,i1);%zeros(256,bands);
        end
        for i1 = bands1+1:ndim
        marginalProbR = sum(marginalProbR,i1);%zeros(256,bands);
        end
        marginalProbF = reshape(marginalProbF,1,[]);
        marginalProbR = reshape(marginalProbR,[],1);
        marginalProd = reshape(marginalProbR*marginalProbF,histoSize);
        ratio = jointProb./(marginalProd);
        mI = jointProb.*log(ratio)/log(np);       %% ndim
        mutualInformation = sum(mI(~isnan(mI)))/(np); %average MI per pixel pair

       %miDisplay(correctionX,correctionY) = mutualInformation;
        if mutualInformation >= maxMI
            maxMI = mutualInformation;
            cl(1) = correctionX;
            cl(2) = correctionY;
        end
       %toc
       %mMI(round(correctionY/st(2)) + 1,round(correctionX/st(1)) + 1) = mutualInformation;
       MMI(iy,ix) = mutualInformation;
       % toc;
    end
end
% toc;
if ~exist('cl','var')
    cl = [0 0];
end
% [ma,mind] = max(MMI);
% [cl(
cl = cast(cl,'uint32');
end