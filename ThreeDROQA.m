% "Subcellular visualization and quantification by X-ray tube source µCT"

% 3DROQA MATLAB algorithm for in silico particle transformations, hyperpoloid
% rejection and tabulating data for statistics.
% More details in Online Methods.

% Required input data for the ThreeDROQA_MATLAB function (need to be loaded in Workspace or given in Command Window prior running): 

% segmented: 3D segmented binary data. 3D data can be loaded to MATLAB path for example by
% read_raw.m function. The same applies to the 3D grayscale data.

% grayscale: original 3D grayscale data.

% voxel_size: voxel size of the data.

% result_data: 1, if you want to output 3D filtered binary data of the accepted or rejected 
%                 particles to be saved in the current folder.   
%              0, if you do not want the 3D data to be saved.   

% accepted: 1, if you want accepted particles to be saved. 
%           0, if you want rejected particles to be saved.

% lower_limit: Lower limit for ellipsoid-to-voxels volume ratio rejection. 
% upper_limit: Upper limit for ellipsoid-to-voxels volume ratio rejection.


% Call this function in Command Window to start the process:
function ThreeDROQA(segmented, grayscale, voxel_size, result_data, accepted, lower_limit, upper_limit)

% Add iso2mesh to MATLAB path. 
p = [fileparts(which(mfilename('fullpath'))) filesep 'iso2mesh'];
addpath(genpath(p));

% Label segmented 3D data. 
segmented = bwconncomp(segmented);
segmented = uint16(labelmatrix(segmented));

% Determine the number of particles according to labels, background space (labelled as 0) is not counted.
np = max(segmented(:));

% Label for removed particles. 
rem = np + 1;

% Declare variable for counting hyperpoloids.
hyp = 0;

% Declare variable for calculating intensity data
intensity = 0;

% Declare result matrix.
res = zeros(np,14);

% To preserve computing resources, create bounding boxes for individual particles 
% to make the computation in small volumes.
bb = regionprops(segmented, 'BoundingBox');


% +++++ Run particle transformations and tabulations for all particles. +++++
for i = 1:np
    
    % Skip particle if width is 0.
    if(bb(i).BoundingBox(4)==0)
        continue;
    end
    
    % Select bounding box for current particle.
    ell1 = segmented(floor(bb(i).BoundingBox(2)):(floor(bb(i).BoundingBox(2))+bb(i).BoundingBox(5)+1), ...
        floor(bb(i).BoundingBox(1)):(floor(bb(i).BoundingBox(1))+bb(i).BoundingBox(4)+1), ...
        floor(bb(i).BoundingBox(3)):(floor(bb(i).BoundingBox(3))+bb(i).BoundingBox(6)+1));
    
    ell2 = grayscale(floor(bb(i).BoundingBox(2)):(floor(bb(i).BoundingBox(2))+bb(i).BoundingBox(5)+1), ...
        floor(bb(i).BoundingBox(1)):(floor(bb(i).BoundingBox(1))+bb(i).BoundingBox(4)+1), ...
        floor(bb(i).BoundingBox(3)):(floor(bb(i).BoundingBox(3))+bb(i).BoundingBox(6)+1));
    
    % Select only current particle in the bounding box.
    ell1=ell1==i;
    
    % Calculate mean intensity. 
    intensity = mean(ell2(ell1));
    
    % Use iso2mesh to create polygon particle.
    [node,elem,reg,hol]=v2s(ell1>0,0.5,1);
    
    % Orient nodes to have element normals to point outside. 
    [node,elem]=surfreorient(node,elem);
    
    % Calculate volume and area of polygon particle. 
    N = permute(node,[2 1]);
    E = permute(elem,[2 1]);
    [totalVolume,totalArea] = stlVolume(N,E);
    totalVolume_real = totalVolume*voxel_size^3;
    totalArea_real = totalArea*voxel_size^2;
   
    x = node(:,1);
    y = node(:,2);
    z = node(:,3);
    
    % Ellipsoid fitting. 
    [center, radii, evecs, v, chi2] = ellipsoid_fit_new([x,y,z]);
    
    % Continue to next particle if radii is complex or <0, particle is hyperpoloid.
    if((~(isreal(radii))) || (radii(1)<0))
        hyp = hyp+1;
        % Update matrix information.  
        if(result_data)
            if(accepted)
                % Remove rejected particle. 
                segmented = segmented.*uint16((~(segmented==i)));
            else 
                % Mark rejected particle. 
                segmented(segmented==i) = rem;
            end
        end
        continue;
    end
    
    %+++++Tabulate results+++++ 
    
	% Number of particle. 
	res(i-hyp,1) = i-hyp;
	
    % Volume of voxel particle.
    res(i-hyp,2) = nnz(ell1)*voxel_size^3;
    
	% Surface area of polygon particle.
    res(i-hyp,3) = totalArea_real;
	
    % Mean intensity of voxel particle. 
    res(i-hyp,4) = intensity;
	
    % Axel lengths (radii) of ellipsoid.
    res(i-hyp,5) = radii(1)*voxel_size; % max
    res(i-hyp,6) = radii(2)*voxel_size; % medium 
    res(i-hyp,7) = radii(3)*voxel_size; % min
    
	% Flatness.
    res(i-hyp,8) = radii(3)/radii(2);
    
	% Elongation.
    res(i-hyp,9) = radii(2)/radii(1);
    
	% Anisotrophy.
    res(i-hyp,10) = 1-radii(3)/radii(1);
   
	% Sphericity. 
    % If the calculation of the surface volume fails, the corresponding sphericity cell in Excel is left empty.
    res(i-hyp,11)= (pi^(1/3)*( 6* totalVolume_real)^(2/3))/totalArea_real;
    
	% Volume of ellipsoid.
    res(i-hyp,12) = (4/3)*pi*radii(3)*radii(2)*radii(1)*voxel_size^3;
    
	% Ellipsoid-to-voxels volume ratio.
    res(i-hyp,13) = res(i-hyp,12)/res(i-hyp,2); 
    

    
    if(result_data)
        % Remove particles outside the ellipsoid-to-voxels volume ratio limits.
        if(res(i-hyp,13) < lower_limit || (res(i-hyp,13) > upper_limit))
            % Update matrix information. 
            if(result_data)
                if(accepted)
                    % Remove rejected particle. 
                    segmented = segmented.*uint16((~(segmented==i)));
                else
                    % Mark rejected particle.
                    segmented(segmented==i) = rem;
                end
            end
        end
    end
end

% Number of hyperpoloids. 
res(1,14) = hyp;

% Remove zeros from the end.  
res((i-hyp+1):end,:) = [];

% Save the Excel file.

% Ask user the Excel file name.

startingFolder = pwd;
defaultFileName = fullfile(startingFolder, '*.xls');
[baseFileName, folder] = uiputfile(defaultFileName, 'Specify a file');

% Write results to the file. 
writecell({'#', 'vol', 'ar', 'int', 'Elong', 'Emed', 'Eshort', 'flat', 'elo', 'anis', 'sphe', 'ElliVolume', 'EV_SV', 'RejecHyper'}, baseFileName, 'Range', 'A1');
writematrix(res, baseFileName, 'Range', 'A2');

% Save binary data for further processing. 
if(result_data)
    if(accepted)
        segmented = segmented > 0;
        filename = 'result_volume_of_accepted.raw';
    else 
        segmented = segmented == rem;
        filename = 'result_volume_of_rejected.raw';
    end
    fid = fopen(filename, 'w');
    fwrite(fid, segmented, 'uint16');
    fclose(fid);
end
