C = [0.1,0.1,0.8];
T = [0.8,0.3,0.1];
I= imread('football.jpg');
imshow(I);
X=ginput();
X = int8(X);
C(1) = I(X(1,2),X(1,1),1);
C(2) = I(X(1,2),X(1,1),2);
C(3) = I(X(1,2),X(1,1),3);

T(1) = I(X(2,2),X(2,1),1);
T(2) = I(X(2,2),X(2,1),2);
T(3) = I(X(2,2),X(2,1),3);

v = [];
rgbs = [];
ind = 1;
for r = 0:0.1:1
    for g = 0:0.1:1
        for b = 0:0.1:1
            rgb = [r,g,b];
            rgb = rgb/sum(rgb);
            v(ind) = sum(C.*rgb)-sum(T.*rgb);
            rgbs(ind,:)= rgb;
            ind = ind + 1;
        end
    end
end

[i,j] = max(v);
rgb = rgbs(j,:);

II = I(:,:,1)*rgb(1)+I(:,:,2)*rgb(2)+I(:,:,3)*rgb(3);
subplot(2,1,1);
imshow(rgb2gray(I));
subplot(2,1,2);
imshow(II);
imshow(II)