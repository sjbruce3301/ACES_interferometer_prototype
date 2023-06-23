function [header, data, gains, offsets] = readImgFile(filename)

% Read science camera frames from WinIRC .img file

% open file and parse header
fid = fopen(filename,'r','l');
A = fread(fid,256,'uint16=>uint16');
header = parseHeader(A)


nPix = double(header.Xsize)*double(header.Ysize);

% read gains
fseek(fid,header.OffsetToPrimaryGainData,'bof');
A = fread(fid,nPix,'single=>single');
gains = transpose(reshape(A,header.Xsize,header.Ysize));

% read offsets
fseek(fid,header.OffsetToPrimaryOffsetData,'bof');
A = fread(fid,nPix,'single=>single');
offsets = transpose(reshape(A,header.Xsize,header.Ysize));

% read data
fseek(fid,header.OffsetToImageData,'bof');
A = fread(fid,inf,'uint16=>uint16');
data = permute(reshape(A,header.Xsize,header.Ysize,[]),[2,1,3]);

fclose(fid);


function header = parseHeader(A)

header.ByteSwap = A(1);
header.Xsize = A(2);
header.Ysize = A(3);
header.BytesPerPixel = A(4);
header.RowColOrder = A(5);
header.Yorigin = A(6);
header.Year = A(7);
header.Month = A(8);
header.Day = A(9);
header.Hour = A(10);
header.Minute = A(11);
header.Second = A(12);
header.IntensityCold = A(13);
header.TemperatureCold = typecast(A(14:15),'single');
header.IntensityHot = A(16);
header.TemperatureHot = typecast(A(17:18),'single');
header.TargetGain = typecast(A(19:20),'single');
header.Revision = A(21);
header.NumFrames = typecast(A(22:23),'uint32');
header.UL_Row = A(24);
header.UL_Col = A(25);
header.LR_Row = A(26);
header.LR_Col = A(27);
header.NumFramesSummed = A(28);
header.FrameRate = typecast(A(29:30),'single');
header.IntegrationTime = typecast(A(31:32),'single');
header.BuffBrdNumFrames = A(33:44);
header.BuffBrdNumSkip = A(45:56);
header.DataMin = A(57);
header.DataMax = A(58);
header.Gain1 = A(59);
header.Offset1 = A(60);
header.Gain2 = A(61);
header.Offset2 = A(62);
header.PixelType = A(63);
header.EmissivityCold = typecast(A(64:65),'single');
header.EmissivityHot = typecast(A(66:67),'single');
header.Irig = typecast(A(68:71),'uint8');
header.NumOutputs = A(72);
header.ExtraFrameHeaderSize = A(73);
header.NumMultiPtCalPts = A(74);
header.CalIntensity = A(75:94);
header.CalTemperature = typecast(A(95:134),'single');
header.szCalUnits = typecast(A(135:146),'uint8');
header.FrameGrabberTaps = A(147);
header.bNucStored = A(148);
header.ImagesPerSuperframe = A(149);
header.NumWindowSizes = A(150);
header.OffsetToExtraNucData = typecast(A(151:152),'uint32');
header.SizeOfExtraNucData = A(153);
header.OffsetToPrimaryGainData = typecast(A(154:155),'uint32');
header.OffsetToPrimaryOffsetData = typecast(A(156:157),'uint32');
header.OffsetToPrimaryDecomData = typecast(A(158:159),'uint32');
header.OffsetToImageData = typecast(A(160:163),'int64');
header.OffsetToNucIniData = typecast(A(164:165),'uint32');
header.MaxSizeOfCommentData = A(166);
header.OffsetToNextImageHeader = typecast(A(167:170),'int64');
header.OffsetToTimeData = typecast(A(171:174),'int64');
header.NumChunkHeaderBytes = typecast(A(175:176),'uint32');
header.FileTime = typecast(A(177:180),'uint64');
header.IntegrationTimes = typecast(A(181:196),'single');
header.ImageMetaDataStart = typecast(A(197:198),'uint32');
header.ImageMetaDataEnd = typecast(A(199:200),'uint32');
header.FpaType = A(201);
header.FpgaRev = A(202);
header.Firmware = A(203);
header.FirmwareRev = A(204);
header.ImageMetaDataLocation = A(205);
header.PlaybackOrientation = A(206);


