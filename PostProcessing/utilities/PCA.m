function [mn, projection, varper] = PCA(data, k)

    num_obs = size(data,2);
    mn=mean(data);
    Inter=bsxfun(@minus, data, mn);
    S=Inter'*Inter/(num_obs-1);
    [LEV, eig_v]=eig(S);
    LEV=fliplr(LEV);
    projection = LEV(:,1:k);
    %projected=transpose(projection)*transpose(Inter);
    varper = cumsum(flipud(diag(eig_v)))/sum(eig_v(:));

end