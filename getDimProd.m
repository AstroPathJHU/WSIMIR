function dimProd = getDimProd(histoSize)
dimProd = zeros(size(histoSize));
for id = 1:size(histoSize,2)
    idM = id-1;    
    dimProd(id) = prod(histoSize(1:idM));    
end
end




