% This function takes the registered locations, ccl, and the original
% locations, cl, and calculates the local transformations for these points.
% This is done in a weighted manner by taking each point in turn and
% finding its 10 nearest neighbors. Then, we draw rays from the point of
% interest to each of its nearest neighbors and divide that ray into 10
% segments.We then use all of these points to calculate the local affine
% transformation. By interpolating points along the rays between points, we
% create a higher density of points nearest our point of interest.
%
% Author: Joshua Doyle, 08/2019 - e.rational.2.718@gmail.com


function T = calcIndTr(ccl,cl,c,conf,np,nn)

T = zeros(length(np(conf>c)),6);
[Idx,Dx] = knnsearch(ccl(conf>c,1:2),ccl(conf>c,1:2),'K',nn);
% ind = (conf>c);
dex = find(conf>c);
Dxref = zeros(length(dex),size(Idx,2));
Rreg = zeros(nn+1,size(Idx,2));
Rref = zeros(nn+1,size(Idx,2));
REG = [];%zeros(size(Rreg,1)*size(Rreg,2));
REF = [];

for i1 = 1:length(np(conf>c))
    Dxref(i1,:) = ((cl(np(dex(Idx(i1,:))),1)-cl(np(dex(Idx(i1,1))),1)).^2 +...
                   (cl(np(dex(Idx(i1,:))),2)-cl(np(dex(Idx(i1,1))),2)).^2).^0.5';
    thetareg = atan2(ccl(dex(Idx(i1,:)),2)-ccl(dex(Idx(i1,1)),2),...
                     ccl(dex(Idx(i1,:)),1)-ccl(dex(Idx(i1,1)),1));
    thetaref = atan2(cl(np(dex(Idx(i1,:))),2)-cl(np(dex(Idx(i1,1))),2),...
                     cl(np(dex(Idx(i1,:))),1)-cl(np(dex(Idx(i1,1))),1));
    for i2 = 2:length(thetareg)
    Rreg(:,i2) = 0:Dx(i1,i2)/nn:Dx(i1,i2);
    Rref(:,i2) = 0:Dxref(i1,i2)/nn:Dxref(i1,i2);
    end
    regx = reshape(Rreg,[],1).*cos(reshape(repmat(thetareg',size(Rreg,1),1),[],1));
    regy = reshape(Rreg,[],1).*sin(reshape(repmat(thetareg',size(Rreg,1),1),[],1));
    refx = reshape(Rref,[],1).*cos(reshape(repmat(thetaref',size(Rref,1),1),[],1));
    refy = reshape(Rref,[],1).*sin(reshape(repmat(thetaref',size(Rref,1),1),[],1));
    
    ref = [refx refy] + [cl(np(dex(Idx(i1,1))),1) cl(np(dex(Idx(i1,1))),2)];
    reg = [regx regy] + [ccl(dex(Idx(i1,1)),1) ccl(dex(Idx(i1,1)),2)];
  
    [ab,cd,e,f] = newtform(ref,reg);
    T(i1,:) = [ab' cd' [e;f]'];
    REG = [REG;reg];
    REF = [REF;ref];
%     
%         figure,scatter(ref(:,1),ref(:,2)),hold on, scatter(reg(:,1),reg(:,2),'x')
%     hold on, scatter(cl(np(dex(Idx(i1,1))),1),cl(np(dex(Idx(i1,1))),2),'x')
%     
end

end