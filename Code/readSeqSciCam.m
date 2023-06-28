function [header, data, ts] = readSeqSciCam(filename)

% Read science camera frames from StreamPix sequence

fid = fopen(filename,'r','l');

%% Read header

% Header version
OFB = {28,1,'long'};
fseek(fid,OFB{1}, 'bof');
header.Version = fread(fid, OFB{2}, OFB{3});

% Header size
OFB = {32,1,'long'};
fseek(fid,OFB{1}, 'bof');
header.HeaderSize = fread(fid,OFB{2},OFB{3});

% Header description
OFB = {592,1,'long'};
fseek(fid,OFB{1}, 'bof');
DescriptionFormat = fread(fid,OFB{2},OFB{3})';
OFB = {36,512,'ushort'};
fseek(fid,OFB{1}, 'bof');
header.Description = fread(fid,OFB{2},OFB{3})';
if DescriptionFormat == 0 % Unicode
    header.Description = native2unicode(header.Description);
elseif DescriptionFormat == 1 % ASCII
    header.Description = char(header.Description);
end

% Image characteristics
OFB = {548,24,'uint32'};
fseek(fid,OFB{1}, 'bof');
tmp = fread(fid,OFB{2},OFB{3}, 0);
header.ImageWidth = tmp(1);
header.ImageHeight = tmp(2);
header.ImageBitDepth = tmp(3);
header.ImageBitDepthTrue = tmp(4);
header.ImageSizeBytes = tmp(5);
vals = [0,100,101,133,200:100:900];
fmts = {'Unknown','Monochrome','Raw Bayer','Mono 12 Packed','BGR','Planar','RGB',...
    'BGRx', 'YUV422', 'UVY422', 'UVY411', 'UVY444'};
header.ImageFormat = fmts{vals == tmp(6)};

% Number of frames
OFB = {572,1,'uint'};
fseek(fid,OFB{1}, 'bof');
header.NumFrames = fread(fid,OFB{2},OFB{3});

% Origin 
OFB = {576,1,'ushort'};
fseek(fid,OFB{1}, 'bof');
header.Origin = fread(fid,OFB{2},OFB{3});

% True image size
OFB = {580,1,'ulong'};
fseek(fid,OFB{1}, 'bof');
header.TrueImageSize = fread(fid,OFB{2},OFB{3});

% Frame rate
OFB = {584,1,'double'};
fseek(fid,OFB{1}, 'bof');
header.FrameRate = fread(fid,OFB{2},OFB{3});

fclose(fid);

%% Read data and timestamps

if nargout > 1
    
    num_frames = header.NumFrames;
    num_pix = header.ImageHeight*header.ImageWidth;
    
    data = zeros(num_pix,num_frames,'uint16');                                               

	fid = fopen(filename,'r','l');
	fseek(fid,8192,'bof');
    
	A = fread(fid,inf,'uint8=>uint8');
    
    fclose(fid);
    
    A = reshape(A,[],num_frames);
    s = uint16(reshape(A(1:2*num_pix,:),2,[],num_frames));
    data = 256*s(2,:,:)+s(1,:,:);
    data = reshape(data,header.ImageWidth,header.ImageHeight,num_frames);
    ts_sec = double(A(2*num_pix+(1:4),:))';
    ts_ms = double(A(2*num_pix+(5:6),:))';
    ts_sec = ts_sec(:,1)+256*ts_sec(:,2)+256^2*ts_sec(:,3)+256^3*ts_sec(:,4);
    ts_ms = ts_ms(:,1)+256*ts_ms(:,2);
    
    ts = (ts_sec + 0.001*ts_ms)/86400 + datenum(1970,1,1);
end


