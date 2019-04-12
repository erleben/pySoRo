function success = writeToObjFile(filename, pcloud)
%WRITETOOBJFILE Summary of this function goes here
%   Detailed explanation goes here
    fileID = fopen(filename,'w');
    
    fprintf(fileID, '#Custrom pointCloud storage\n');
    fprintf(fileID, '#Keyword for PointCloud seperators denoted as #*\n');
    fprintf(fileID, 'p %d\n', length(pcloud));
    fprintf(fileID, 'n %d\n', length(pcloud));
    for i = 1:length(pcloud)
        for j = 1:length(pcloud{i}.Location)
            fprintf(fileID, "v %f %f %f\n", pcloud{i}.Location(j,:));
        end
        if i < length(pcloud)
            fprintf(fileID, "#*\n");
        end
    end
    fclose(fileID);
end

