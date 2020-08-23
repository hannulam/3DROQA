% function for reading .raw file. 
% input: filename and data dimensions
% output: 3d data array
function f = read_raw(filename, xc, yc, zc) 

fid = fopen(filename,'r');

%[f,count] = fread(fid,'uint16=>uint16');
[f,count] = fread(fid,'uint8=>uint8');

f = reshape(f,xc,yc,zc);

fclose(fid);