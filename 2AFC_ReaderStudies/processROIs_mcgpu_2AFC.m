% processROIs_mcgpu_2AFC.m
%
% This script processes pre-extracted signal present ROIs from MC-GPU
% simulated images for 2AFC presentation in the Foursquares program. This
% script does three main things:
%       1. Convert the images from .tif format to .dcm - The sccript
%       expects .tif files, but this can be changed to whatever you have
%
%       2. Randomize them for each window - Randomly assigns the ROIs of each
%       dataset to Window 1 or 2
%
%       3. Create black ROIs for the other 2 windows - because Foursquares
%       for 4AFCs, the remaining Windows 3 and 4 have black (empty) ROIs
%
% Whichever images are used as Choice 1 will be assigned Truth. 
%
% L. Ikejimba, FDA, April 2021
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear



%% %%%%%%%%%%%%%%%%%%%% Convert Saved ROIs to DICOM %%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%% CHOICE 1 %%%
fileExt = '*.tif';
inputPath_choice1 = '/Users/nickneirotti/Documents/MATLAB/s_blankROI/';
outputPath_choice1 = '/Users/nickneirotti/Documents/MATLAB/blank/sROI/';

%Read in ROIs
allFiles = dir([inputPath_choice1, fileExt]);
numFiles = length(allFiles);
%get size of first image
imInfo = imfinfo([inputPath_choice1, allFiles(1).name]);
numSlices = length(imInfo);
imStack = uint16(zeros(imInfo(1).Height, imInfo(1).Width, numFiles));
imNameStack = cell(numFiles,1);
trialCount = 0;
for k = 1:numFiles
    imStack(:,:,k) = imread([inputPath_choice1, allFiles(k).name]);
    imNameStack{k,1} = allFiles(k).name;
    
    trialCount = trialCount + 1;
    trialNum = sprintf('%04d',trialCount);
    roiFolderName = [trialNum, '_', imNameStack{k,1}(1:end-4), '_t/'];
    if ~exist([outputPath_choice1, roiFolderName,'/'], 'dir')
        mkdir([outputPath_choice1, roiFolderName,'/'])
    end
    %Save all slices
    for sliceNum = 1:numSlices
        roiName_imageFile = strcat(trialNum, '_', imNameStack{k,1}(1:end-4),'-slice',sprintf('%02d',sliceNum),'.dcm');
        dicomwrite(imStack(:,:,k),[outputPath_choice1,roiFolderName,roiName_imageFile], 'PhotometricInterpretation', 'MONOCHROME1');
        %dicomwrite(imStack(:,:,k),[outputPath,roiFolderName,roiName_imageFile]);
        fprintf(['Saved ROI ',roiName_imageFile,' in folder \n\t..',roiFolderName,'\n'])
    end %ROI slice
    fprintf(['\n....\n'])
end

clear

%%%%%%%%%%%%%%%%%%%% CHOICE 2 %%%
fileExt = '*.tif';
inputPath_choice2 = '/Users/nickneirotti/Documents/MATLAB/blank/l_blankROI/';
outputPath_choice2 = '/Users/nickneirotti/Documents/MATLAB/blank/lROI/';

%Read in ROIs
allFiles = dir([inputPath_choice2, fileExt]);
numFiles = length(allFiles);
%get size of first image
imInfo = imfinfo([inputPath_choice2, allFiles(1).name]);
numSlices = length(imInfo);
imStack = uint16(zeros(imInfo(1).Height, imInfo(1).Width, numFiles));
imNameStack = cell(numFiles,1);
trialCount = 0;
for k = 1:numFiles
    imStack(:,:,k) = imread([inputPath_choice2, allFiles(k).name]);
    imNameStack{k,1} = allFiles(k).name;
    
    trialCount = trialCount + 1;
    trialNum = sprintf('%04d',trialCount);
    roiFolderName = [trialNum, '_', imNameStack{k,1}(1:end-4), '_f/'];
    if ~exist([outputPath_choice2, roiFolderName,'/'], 'dir')
        mkdir([outputPath_choice2, roiFolderName,'/'])
    end
    %Save all slices
    for sliceNum = 1:numSlices
        roiName_imageFile = strcat(trialNum, '_', imNameStack{k,1}(1:end-4),'-slice',sprintf('%02d',sliceNum),'.dcm');
        dicomwrite(imStack(:,:,k),[outputPath_choice2,roiFolderName,roiName_imageFile], 'PhotometricInterpretation', 'MONOCHROME1');
        %dicomwrite(imStack(:,:,k),[outputPath,roiFolderName,roiName_imageFile]);
        fprintf(['Saved ROI ',roiName_imageFile,' in folder \n\t..',roiFolderName,'\n'])
    end %ROI slice
    fprintf(['\n....\n'])
end

%% %%%%%%%%%%%%%%%%%%%% Randomize Outputs: 2AFC %%%%%%%%%%%%%%%%%%%%
% Note, in this section "signal" = choice 1 and "background" = choice 2
% I was going to go back and change all variable names, but I dont' want to
% break anything.


vms_prompt = '\fontsize{15} Specify Name for 4AFC study Dataset ';
opts.Interpreter = 'tex';
uinput_outputFname = inputdlg(vms_prompt, 'Name for Dataset ', 1, {'3SizeMCReaderStudy'}, opts);
outputFname = uinput_outputFname{1};

outputPath_vms = [outputFname, '/'];
numAFC = 2;
randPct = 1/numAFC;
windowPrefix = 'Window';
homeDir = '/Users/nickneirotti/Documents/MATLAB/';


%Select input and output directories
disp('Select Directory containing Signal Present images...')
signalFilePath = uigetdir(homeDir, 'Select Directory containing Signal Present images');
disp('Select Directory containing Background images...')
backgroundFilePath = uigetdir(signalFilePath, 'Select Directory containing Background images');
allSignalFiles = dir(fullfile( strcat( signalFilePath,'/', '*' , '_t') ) );
allBkgdFiles = dir(fullfile( strcat( backgroundFilePath,'/', '*', '_f') ) );


%Randomly sort signal present ROIs to each window
numSignalFiles = length(allSignalFiles);
numTrueInEachWindow = zeros(1,numAFC);
pctTrueInEachWindow = 1;%ones(4,4);
while any(abs(randPct - pctTrueInEachWindow) > 0.03) %Make number of signal present ROIs in each window is within X% of random chance
    
    windowRands = zeros(numAFC, numSignalFiles);
    for signalFileNum = 1:numSignalFiles
        windowRands(:,signalFileNum) = randsample(1:numAFC, numAFC)';
    end
    for n = 1:numAFC
        numTrueInEachWindow(1,n) = length(find(windowRands(1,:) == n));
    end
    pctTrueInEachWindow = numTrueInEachWindow ./ numSignalFiles;
    
end
sprintf(['For ',outputFname,': Allocation of truth image to each window is ',num2str(pctTrueInEachWindow),'.'])

%Randomly match up signal and 3 background images
%allBkgdFiles = dir(fullfile( strcat( backgroundFilePath, '*', '_f') ) );
randBkgdSort = randsample(length(allBkgdFiles),length(allBkgdFiles));
randSignalSort = randsample(length(allSignalFiles),length(allSignalFiles));



%%%%%%%%%%%%%%%%%%%% TESTING AND TRAINING ROIS

%Choose directory containing folders for Testing and Training ROIs
disp('Select Directory containing  TESTING and TRAINING Folders...')
afcFoldersPath = uigetdir(signalFilePath, 'Select Directory containing TESTING and TRAINING Folders');
testingDirPath = strcat(afcFoldersPath, '/', 'TestingROIs/');
testingOutputPath = [testingDirPath, '/', outputPath_vms];
trainingDirPath = strcat(afcFoldersPath, '/', 'TrainingROIs/');
trainingOutputPath = [trainingDirPath,'/', outputPath_vms];


%%%%%%%%%% TESTING ROIS
%testingDirPath = uigetdir(signalFilePath, 'Select output folder for TESTING ROIs');
if ~exist(testingOutputPath, 'dir')
    mkdir(testingOutputPath);
end
for dirNum = 1:numAFC %Make 4 folders: 1 for each AFC window
    if ~exist([testingOutputPath,windowPrefix,num2str(dirNum)], 'dir')
        mkdir([testingOutputPath,windowPrefix,num2str(dirNum)]);
    end
end

for signalFileNum = 1:numSignalFiles-10
    
    trialNum = sprintf('%04d', signalFileNum); %make trial number
    windowAllocation = cellstr([ repmat('Window',numAFC,1), num2str(windowRands(:, signalFileNum)) ]); %get window allocations
    
    %Rename and write Signal File
    windowNum = 1;
    signalFileFolder_orig = allSignalFiles(randSignalSort(signalFileNum));
    signalFileROIs_orig = dir(fullfile([signalFileFolder_orig(windowNum).folder,'/', signalFileFolder_orig(windowNum).name,'/','*.dcm']));
    signalFileFolder_new = strcat(trialNum,'_',signalFileFolder_orig.name(6:end));
    mkdir([testingOutputPath, windowAllocation{1},'/',signalFileFolder_new,'/'])
    
    for signalFileSliceNum = 1:length(signalFileROIs_orig)
        signalFileSliceName_orig = signalFileROIs_orig(signalFileSliceNum).name;
        signalFileSliceName_new = strcat(trialNum,'_',signalFileSliceName_orig(6:end));
        %dicomwrite(  dicomread([signalFileROIs_orig(signalFileSliceNum).folder,'/', signalFileSliceName_orig]) , [testingOutputPath, windowAllocation{1},'/',signalFileFolder_new,'/',signalFileSliceName_new] , dicominfo([signalFileROIs_orig(signalFileSliceNum).folder,'/', signalFileSliceName_orig]) , 'PhotometricInterpretation', 'MONOCHROME1');
        dicomwrite(  dicomread([signalFileROIs_orig(signalFileSliceNum).folder,'/', signalFileSliceName_orig]) , [testingOutputPath, windowAllocation{1},'/',signalFileFolder_new,'/',signalFileSliceName_new] , dicominfo([signalFileROIs_orig(signalFileSliceNum).folder,'/', signalFileSliceName_orig]));
    end %ROI slice
    
    %Rename and write Background Files
    bStart = (numAFC-1)*(signalFileNum-1) + 1;
    bkgdFilesFolders_orig = allBkgdFiles(randBkgdSort(bStart:bStart + (numAFC-1) - 1));
    for windowNum = 1:numAFC-1
        
        bkgdFileROIs_orig = dir(fullfile([bkgdFilesFolders_orig(windowNum).folder,'/', bkgdFilesFolders_orig(windowNum).name,'/','*.dcm']));
        bkgdFileFolder_new = strcat(trialNum,'_',bkgdFilesFolders_orig(windowNum).name(6:end));
        mkdir([testingOutputPath, windowAllocation{windowNum+1},'/',bkgdFileFolder_new,'/'])
        for bkgdFileSliceNum = 1:length(bkgdFileROIs_orig)
            bkgdFileSliceName_orig = bkgdFileROIs_orig(bkgdFileSliceNum).name;
            bkgdFileSliceName_new = strcat(trialNum,'_',bkgdFileSliceName_orig(6:end));
            %dicomwrite(dicomread([bkgdFileROIs_orig(bkgdFileSliceNum).folder,'/',bkgdFileSliceName_orig]),[testingOutputPath, windowAllocation{windowNum+1},'/',bkgdFileFolder_new,'/',bkgdFileSliceName_new],dicominfo([bkgdFileROIs_orig(bkgdFileSliceNum).folder,'/',bkgdFileSliceName_orig]));
            dicomwrite(  dicomread([bkgdFileROIs_orig(bkgdFileSliceNum).folder,'/',bkgdFileSliceName_orig]) , [testingOutputPath, windowAllocation{windowNum+1},'/',bkgdFileFolder_new,'/',bkgdFileSliceName_new] , dicominfo([bkgdFileROIs_orig(bkgdFileSliceNum).folder,'/',bkgdFileSliceName_orig]));
        end %ROI slice
    end %for each window
    
    disp(['Saved ROIs for ',outputFname,', TESTING trial ',trialNum])
    
end %for signalFileNum, number of signal present images, i.e. number of trials



%%%%%%%%%% TRAINING ROIS
%trainingDirPath = uigetdir(homeDir, 'Select output folder for TRAINING ROIs');
if ~exist(trainingOutputPath, 'dir')
    mkdir(trainingOutputPath);
end
for dirNum = 1:numAFC %Make 4 folders: 1 for each AFC window
    if ~exist([trainingOutputPath,windowPrefix,num2str(dirNum)], 'dir')
        mkdir([trainingOutputPath,windowPrefix,num2str(dirNum)]);
    end
end

for signalFileNum = (numSignalFiles-9):numSignalFiles
    
    trialNum = sprintf('%04d', signalFileNum); %make trial number
    windowAllocation = cellstr([ repmat('Window',numAFC,1), num2str(windowRands(:, signalFileNum)) ]); %get window allocations
    
    %Rename and write Signal File
    windowNum = 1;
    signalFileFolder_orig = allSignalFiles(randSignalSort(signalFileNum));
    signalFileROIs_orig = dir(fullfile([signalFileFolder_orig(windowNum).folder,'/', signalFileFolder_orig(windowNum).name,'/','*.dcm']));
    signalFileFolder_new = strcat(trialNum,'_',signalFileFolder_orig.name(6:end));
    mkdir([trainingOutputPath, windowAllocation{1},'/',signalFileFolder_new,'/'])
    
    for signalFileSliceNum = 1:length(signalFileROIs_orig)
        signalFileSliceName_orig = signalFileROIs_orig(signalFileSliceNum).name;
        signalFileSliceName_new = strcat(trialNum,'_',signalFileSliceName_orig(6:end));
        dicomwrite(dicomread([signalFileROIs_orig(signalFileSliceNum).folder,'/', signalFileSliceName_orig]),[trainingOutputPath, windowAllocation{1},'/',signalFileFolder_new,'/',signalFileSliceName_new],dicominfo([signalFileROIs_orig(signalFileSliceNum).folder,'/', signalFileSliceName_orig]));
    end %ROI slice
    
    %Rename and write Background Files
    bStart = (numAFC-1)*(signalFileNum-1) + 1;
    bkgdFilesFolders_orig = allBkgdFiles(randBkgdSort(bStart:bStart + (numAFC-1) - 1));
    for windowNum = 1:numAFC-1
        
        bkgdFileROIs_orig = dir(fullfile([bkgdFilesFolders_orig(windowNum).folder,'/', bkgdFilesFolders_orig(windowNum).name,'/','*.dcm']));
        bkgdFileFolder_new = strcat(trialNum,'_',bkgdFilesFolders_orig(windowNum).name(6:end));
        mkdir([trainingOutputPath, windowAllocation{windowNum+1},'/',bkgdFileFolder_new,'/'])
        for bkgdFileSliceNum = 1:length(bkgdFileROIs_orig)
            bkgdFileSliceName_orig = bkgdFileROIs_orig(bkgdFileSliceNum).name;
            bkgdFileSliceName_new = strcat(trialNum,'_',bkgdFileSliceName_orig(6:end));
            dicomwrite(dicomread([bkgdFileROIs_orig(bkgdFileSliceNum).folder,'/',bkgdFileSliceName_orig]),[trainingOutputPath, windowAllocation{windowNum+1},'/',bkgdFileFolder_new,'/',bkgdFileSliceName_new],dicominfo([bkgdFileROIs_orig(bkgdFileSliceNum).folder,'/',bkgdFileSliceName_orig]));
        end %ROI slice
    end %for each window
    
    disp(['Saved ROIs for ',outputFname,', TRAINING trial ',trialNum])
    
end %for signalFileNum, number of signal present images, i.e. number of trials


disp('All Done!')

%%
%%%%%%%%%%% MAKE BLACK ROIS FOR OTHER WINDOWS

%%%%%%%%%% Testing ROIS
testingOutputPath = ['/Users/nickneirotti/Documents/MATLAB/',outputPath_vms];
%roi_x = 353;
%roi_y = 353;
roi_x = 537;
roi_y = 537;
blankROI = uint16(zeros(roi_x, roi_y));

if ~exist(testingOutputPath, 'dir')
    mkdir(testingOutputPath);
end
for dirNum = 3:4 %Make 4 folders: 1 for each AFC window
    if ~exist([testingOutputPath,windowPrefix,num2str(dirNum)], 'dir')
        mkdir([testingOutputPath,windowPrefix,num2str(dirNum)]);
    end
end

for signalFileNum = 1:numSignalFiles-10
    
    trialNum = sprintf('%04d', signalFileNum); %make trial number
    for windowNum = 3:4 
        blankROIfname = strcat(trialNum,'_blankROI_f');
        mkdir([testingOutputPath, windowPrefix,num2str(windowNum),'/',blankROIfname,'/'])
        dicomwrite(blankROI, [testingOutputPath, windowPrefix,num2str(windowNum),'/',blankROIfname,'/',blankROIfname,'.dcm']); 
    end %for each window
    
    disp(['Saved ROIs for ',blankROIfname,', Testing trial ',trialNum])
    
end %for signalFileNum, number of signal present images, i.e. number of trials




%%%%%%%%%% Training ROIS
blankROI = uint16(zeros(imInfo(1).Width, imInfo(1).Height));

if ~exist(trainingOutputPath, 'dir')
    mkdir(trainingOutputPath);
end
for dirNum = 3:4 %Make 4 folders: 1 for each AFC window
    if ~exist([trainingOutputPath,windowPrefix,num2str(dirNum)], 'dir')
        mkdir([trainingOutputPath,windowPrefix,num2str(dirNum)]);
    end
end

for signalFileNum = (numSignalFiles-9):numSignalFiles
    
    trialNum = sprintf('%04d', signalFileNum); %make trial number
    for windowNum = 3:4 
        blankROIfname = strcat(trialNum,'_blankROI_f');
        mkdir([trainingOutputPath, windowPrefix,num2str(windowNum),'/',blankROIfname,'/'])
        dicomwrite(blankROI, [trainingOutputPath, windowPrefix,num2str(windowNum),'/',blankROIfname,'/',blankROIfname,'.dcm']); 
    end %for each window
    
    disp(['Saved ROIs for ',blankROIfname,', TRAINING trial ',trialNum])
    
end %for signalFileNum, number of signal present images, i.e. number of trials


disp('All Done!')
