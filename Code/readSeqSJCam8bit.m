function [header, data, ts] = readSeqSJCam8bit(filename,varargin)

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
OFB = {572,1,'ushort'};
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

if nargin==1
    frames = 1:header.NumFrames;
elseif nargin==2
    frames = varargin{1};
else
    error('Wrong number of inputs.')
end

if nargout > 1
    
    skip = 8192-rem(2*header.ImageHeight*header.ImageWidth+6,8192);

    m = memmapfile(filename, 'Offset',8192,...
   'Format', {'uint8' [header.ImageWidth,header.ImageHeight] 'img';'uint32' 1 'ts_sec';'uint16' 1 'ts_ms';'uint8' skip 'skip'});

    mData = m.Data(frames);
    
    data = permute(cat(3,mData.img),[2,1,3]);
    
    ts = ((double([mData.ts_sec]) + 0.001*double([mData.ts_ms]))/86400 + datenum(1970,1,1))';
    
end

