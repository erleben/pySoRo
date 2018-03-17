function im = blob(I, sigma)

I=double(I);
[M,N]=size(I);

II=@(x,y,tau) (x^2-tau^2)*exp(-(x^2+y^2)/(2*tau^2))/2*tau^3;
filter=zeros(M,N);
m=floor(M/2);
n=floor(N/2);


for tau=sigma
    for i=-m:m
        for j=-n:n
            filter(i+m+1,j+n+1)=II(i,j,tau);
        end
    end
    im=fftshift(ifft2(fft2(I).*fft2(filter,M,N)));
    
end





end

