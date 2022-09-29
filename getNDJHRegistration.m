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

if scale
im = round(double(zeroAndScale(im,16)));
im2 = round(double(zeroAndScale(im2,16)));
end
[h1,w1,bands1] = size(im);
[h2,w2,bands2] = size(im2);
MMI = zeros(round((h1-h2+1)/st(2)),round((w1-w2+1)/st(1)),'single');
imReshape2 = reshape(im2,[],bands2)+1;
ndim = bands1+bands2;
maxMI = 0.0;
%%% Search area

%------------
%Subsampling
if ss == 1
    np = h2*w2;
    p = 1:np;
end
if ss ~= 1
np = round(h2*w2*ss);
p = 1:round(1/ss):h2*w2;
end
imReshape2 = imReshape2(p,:);

ix = 0;

for correctionX = 1:st(1):w1-w2+1
    ix = ix + 1;
    iy = 0;
    for correctionY = 1:st(2):h1-h2+1
        iy = iy + 1;
% tic;
        imReshape = reshape(im((correctionY):(correctionY+h2-1),(correctionX):(correctionX+w2-1),:),[],bands1) + 1;
        imReshape = imReshape(p,:);

        jhData = cast([imReshape imReshape2],'single');
        
        rzd = round(jhData);
        maxcol = max(rzd,[],1);
        mincol = min(rzd,[],1);
        rzd = rzd(:,:) - mincol + 1;
        histoSize = cast(maxcol - mincol+1,'uint64');
        dimIndex = getDimProd(histoSize);
        zdTracker = rzd(:,1:ndim);
        zdTracker(:,2:ndim) = zdTracker(:,2:ndim)-1;
        jhTracker = uint64(zdTracker(:,1:ndim)*dimIndex(1,1:ndim)');
        jhTracker(jhTracker<1) = 1;

        jointHisto = zeros(cast(prod(histoSize(1:ndim)),'uint64'),1,'uint32');

        for x = 1:length(rzd(:,1))
            jointHisto(jhTracker(x)) = jointHisto(jhTracker(x)) + 1;
        end  
        
        jointProb = reshape(cast(jointHisto,'single')/(np),histoSize(1:ndim));%/(h2*w2)
        marginalProbF = jointProb;
        marginalProbR = jointProb;
        for i1 = 1:bands1
        marginalProbF = sum(marginalProbF,i1);
        end
        for i1 = bands1+1:ndim
        marginalProbR = sum(marginalProbR,i1);
        end
        marginalProbF = reshape(marginalProbF,1,[]);
        marginalProbR = reshape(marginalProbR,[],1);
        marginalProd = reshape(marginalProbR*marginalProbF,histoSize);
        ratio = jointProb./(marginalProd);
        mI = jointProb.*log(ratio)/log(np);       
        mutualInformation = sum(mI(~isnan(mI)))/(np); 
%}
%         mutualInformation = mutInfo(imReshape,imReshape2);
        if mutualInformation >= maxMI
            maxMI = mutualInformation;
            cl(1) = correctionX;
            cl(2) = correctionY;
        end

       MMI(iy,ix) = mutualInformation;
% toc;
    end
end

if ~exist('cl','var')
    cl = [0 0];
end

cl = cast(cl,'uint32');
end