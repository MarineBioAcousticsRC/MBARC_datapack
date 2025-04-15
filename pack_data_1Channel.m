%% Code to execute Full DataPacking for drives listed in reference file. 
%Adapted from "xwav_to_flac.m" code written by Katrina Johnson. 
%Note: Please ensure all dependencies are completed prior to starting. See
%SIO_PACE_README.pdf for setup and dependency instructions.

%How to use:
%1: Fill out first XXXXX columns of: "MBARC_PACE_DATA_IMPORT_1CHANNEL"
%2: (OPTIONAL): Edit fields in correct dataFillVariables m file.
%3: Ensure fields in section 1 below are edited to location of relevant sheets 
%4: Run.
%3.5 Verify no error messages/warnings in command window.
%4: Load data into PACE program. (See guide)

%% SECTION TO EDIT
%Dataset Packager (Who Did the packaging)
dataSetPackager = "Kasey Castello";

%Local File Paths
inputFile = "G:\Lab Work\DataPacking\MBARC_PACE_DATA_IMPORT_1CHANNEL_LMR.xlsx"; %Location of your edited spreadsheet
fullPathFlac = '"C:\Program Files\Flac\flac-1.3.2-win\win64\flac"'; %Location of saved Flac folder


%For Accessing Relevant Google Sheets
templateDocsLocation = 'G:\Lab Work\DataPacking\TemplateDocs'; %Location of where you stored the ltsa, tf, and xwav readmes.
hdsFile = "G:\Lab Work\DataPacking\HARPDataSummary_20250205.xlsx"; %Download and save a version of the HDS file google sheet. I tried to access this online but things got complicated.
tfDrive = "I:\Shared drives\MBARC_TF"; %Link to google drive.
tfFile = "G:\Lab Work\DataPacking\HARP_Hydrophones.xlsx"; %Link to TF documentation spreadsheet.

%For in-place packing. link to any empty folder on your machine. (KC: Find
%better way)
emptyFolder = "G:\Lab Work\DataPacking\TemplateDocs\empty";

%How often do you want FLAC steps to report it's progress
msgInterval = 20*60;  % To print status every x mins instead of every file. Change left number.

%Choose your project type. (1:GOM, 2: LMR, 3: CINMS ????) 
projectType = 2; 

%Compression Ratio (Will Be Used to Verify Enough Space on the Drive)
compressionRatio = 2 / 5.59; %Compression Ratio : (2 Tb post-flac * 5.59 tb after)

%% ESTABLISH CORRECT DATAFIELDS FOR DIFFERENT PROJECTS
%Sets variables for appropriate spreadsheet filling based on the project.
switch projectType
    case 1 %GOM
        run('metadata_GOM.m');
    case 2 %LMR
        run('metadata_LMR.m');
    case 3 %LMR
        run('metadata_CINMS.m');
    otherwise
end

%% CREATE END-DESTINATION FOLDERS.
data = readcell(inputFile);
hdOpts = detectImportOptions(hdsFile, 'PreserveVariableNames', true);
hdOpts = setvaropts(hdOpts, {'PreAmp' }, 'Type',  'string');
hdsData = readtable(hdsFile, hdOpts);

%Normalize Data to remove non alphanumeric characters. Useful for string
%comparison to site name in packing file.
normalizedDataIDs = regexprep(hdsData.Data_ID, '[^a-zA-Z0-9]', ''); % Remove non-alphanumeric
normalizedDataIDs = lower(normalizedDataIDs); % Convert to lowercase

%Extract the input and output data locations from the sheet
inputLocations = string(data(2:end, 1));  % Locations of the data to be flacked
inputLocations(inputLocations == "") = [];
outputLocations = string(data(2:end, 2)); % Desired location of the data to be packaged.
outputLocations(outputLocations == "") = [];
deploymentNames = string(data(2:end, 3)); % Desired location of the data to be packaged.
deploymentNames(deploymentNames == "") = [];

siteSuccess = zeros(1, length(inputLocations));

%Verify the output location has the right folders. If not, make them
for i=1:length(outputLocations)
    %Determining Row Data For Later Column Fills. 
    siteName = deploymentNames(i);

    % Normalize siteName
    normalizedSiteName = regexprep(siteName, '[^a-zA-Z0-9]', ''); % Remove non-alphanumeric
    normalizedSiteName = lower(normalizedSiteName); % Convert to lowercase

    %Retrieve the TF PDF from the hds file and place into the folder
    matchingRows = hdsData(contains(normalizedDataIDs, normalizedSiteName), :); % Find matching rows
    targetFolder = outputLocations(i) + collectionSTR + matchingRows.Data_ID;

    flacFolder = targetFolder + filesep + 'data' + filesep + 'acoustic_files';
    if ~isfolder(flacFolder)
        mkdir(flacFolder)
        fprintf('Created folder: %s\n', flacFolder);
    end
    docsFolder = targetFolder + filesep + 'data' + filesep + 'docs';
    if ~isfolder(docsFolder)
        mkdir(docsFolder)
        fprintf('Created folder: %s\n', docsFolder);
    end
    ltsaFolder = targetFolder + filesep + 'data' + filesep + 'other';
    if ~isfolder(ltsaFolder)
        mkdir(ltsaFolder)
        fprintf('Created folder: %s\n', ltsaFolder);
    end
    tfFolder = targetFolder + filesep + 'data' + filesep + 'calibration';
    if ~isfolder(tfFolder)
        mkdir(tfFolder)
        fprintf('Created folder: %s\n', tfFolder);
    end
end

clearvars flacFolder docsFolder ltsaFolder tfFolder i matchingRows targetFolder

%% SET UP DOCS FOLDER AND TF FOLDER
%Needed in Docs:LTSA_readme.docx, Transfer_Function_readme.docx,
%XWAV_readme.docx, Transfer Function.pdf.
% First 3 are from your templateDocs folder edited above.
% Only dynamic grabber is Transfer_Function.pdf.
constantFiles = ["LTSA_readme.docx", "Transfer_Function_readme.docx", "XWAV_readme.docx"];

%Prepare to index Google Drive TF folders later in section:
topFolders = dir(tfDrive);
topFolders = topFolders([topFolders.isdir] & ~startsWith({topFolders.name}, '.')); % Remove non-folders and hidden ones

for i = 1:length(inputLocations)
    % Define the current input directory
    inputDir = inputLocations(i);

    %Determining Row Data For Later Column Fills. 
    siteName = deploymentNames(i);

    % Normalize siteName
    normalizedSiteName = regexprep(siteName, '[^a-zA-Z0-9]', ''); % Remove non-alphanumeric
    normalizedSiteName = lower(normalizedSiteName); % Convert to lowercase

    %Retrieve the TF PDF from the hds file and place into the folder
    matchingRows = hdsData(contains(normalizedDataIDs, normalizedSiteName), :); % Find matching rows
    outDir = outputLocations(i) + collectionSTR + matchingRows.Data_ID + filesep + 'data' + filesep + 'docs' + filesep;
    outDirTF = outputLocations(i) + collectionSTR + matchingRows.Data_ID + filesep + 'data' + filesep + 'calibration' + filesep;

    % Ensure the output directory exists
    if ~isfolder(outDir)
        mkdir(outDir);
        fprintf('Created output folder: %s\n', outDir);
    end

   %Paste the 3 static reference files into the destination
   for j = 1:length(constantFiles)
       sourceFile = fullfile(templateDocsLocation, constantFiles(j));
       destinationFile = fullfile(outDir, constantFiles(j));

       % Check if the file exists in the templateDocs folder
        if exist(sourceFile, 'file')
            copyfile(sourceFile, destinationFile);
        else
            warning('Missing file "%s" in %s', constantFiles(j), templateDocsLocation);
            %Will help know if packing ready. 1: Docs Error. 2: LTSA Error. 3:TF Error. 4: SS Errror. 5: Flac Error
            siteSuccess(1, i) = -1;
        end
   end

    tfNum = matchingRows.PreAmp;
    tfNum = regexprep(tfNum, '[^0-9]', '');
    
    % Convert tfNum to numeric
    tfNumVal = str2double(tfNum);
    tfFound = false;
    for k = 1:length(topFolders)
        %Determine the upper and lower limits of the TF header files
        tokens = regexp(topFolders(k).name, '(\d+)-(\d+)', 'tokens');
        
        if ~isempty(tokens)
            range = str2double(tokens{1});
            lowerBound = range(1);
            upperBound = range(2);
            
            % Check if tfNum is within the range
            if tfNumVal >= lowerBound && tfNumVal <= upperBound
                % Construct the expected subfolder path and search for pdfs
                % there
                subFolder = fullfile(tfDrive, topFolders(k).name, tfNum);
                if exist(subFolder, 'dir')
                    pdfFiles = dir(fullfile(subFolder, '*.pdf'));
                    tfFiles = dir(fullfile(subFolder, '*.tf'));
    
                    if ~isempty(pdfFiles)
                        % Copy all PDFs found
                        for m = 1:length(pdfFiles)
                            sourceFile = fullfile(subFolder, pdfFiles(m).name);
                            destinationFile = fullfile(outDir, pdfFiles(m).name);
                            copyfile(sourceFile, destinationFile);
                            destinationFile = fullfile(outDirTF, pdfFiles(m).name);
                            copyfile(sourceFile, destinationFile);
                            tfFound = true;
                        end
                    end
                    if ~isempty(tfFiles)
                        % Copy all TFs found
                        for m = 1:length(tfFiles)
                            sourceFile = fullfile(subFolder, tfFiles(m).name);
                            destinationFile = fullfile(outDirTF, tfFiles(m).name);
                            copyfile(sourceFile, destinationFile);
                        end
                    end
                    break; % No need to check other folders
                end

            end
        end
    end
    if (~tfFound)
        warning('No transfer function found for %s. Please find and place in %s and %s folders before PACE.', siteName, outDir, outDirTF);
        siteSuccess(1, i) = -1;
    end
end

clearvars i j splitString constantFiles destinationFile lowerBound upperBound 
clearvars matchingRows outDir pdfFiles range siteName sourceFile subFolder
clearvars tfFound tfNum tfNumVal tokens topFolders inputDir k m normalizedSiteName outDirTf tfFiles

%% SET UP LTSA FOLDER.
%Grab the LTSAs off of the .xwav folders from the drives for the
% associated deployment
    
for i = 1:length(inputLocations)
    % Define the current input directory
    inputDir = inputLocations(i);

    %Determining Row Data For Later Column Fills. 
    siteName = deploymentNames(i);

    % Normalize siteName
    normalizedSiteName = regexprep(siteName, '[^a-zA-Z0-9]', ''); % Remove non-alphanumeric
    normalizedSiteName = lower(normalizedSiteName); % Convert to lowercase

    %Retrieve the TF PDF from the hds file and place into the folder
    matchingRows = hdsData(contains(normalizedDataIDs, normalizedSiteName), :); % Find matching rows
    outDir = outputLocations(i) + collectionSTR + matchingRows.Data_ID + filesep + 'data' + filesep + 'other' + filesep;
    

    % Ensure the output directory exists
    if ~isfolder(outDir)
        mkdir(outDir);
    end

    % Get the list of subdirectories and files in the input directory
    dirList = dir(inputDir);

    for iDir = 1:length(dirList)
        % Skip system directories "." and ".."
        if dirList(iDir).isdir && ~startsWith(dirList(iDir).name, '.')
            % Get LTSA files from the subdirectory
            thisList = dir(fullfile(inputDir, dirList(iDir).name, '*.ltsa'));
            
            % If LTSA files exist, copy them to the output directory
            if ~isempty(thisList)
                for k = 1:length(thisList)
                    sourceFile = fullfile(thisList(k).folder, thisList(k).name);
                    destinationFile = fullfile(outDir, thisList(k).name);

                    % Check if the file already exists in the destination
                    if exist(destinationFile, 'file')
                        % Compare file sizes to check if it was fully copied
                        sourceInfo = dir(sourceFile);
                        destInfo = dir(destinationFile);
                        
                        if sourceInfo.bytes == destInfo.bytes
                            continue; % Skip this file
                        else
                            fprintf('File exists but sizes differ, recopying: %s\n', sourceFile);
                        end
                    end

                    % Copy file if not present or sizes don't match
                    copyfile(sourceFile, destinationFile);
                end
            end
        end
    end
    % Filter directories that contain 'disk' in their name
    diskDirs = dirList([dirList.isdir]);  % Only directories
    diskDirs = diskDirs(contains({diskDirs.name}, 'disk', 'IgnoreCase', true));  % Contain 'disk'

    LTSA_size = length(dir(fullfile(outDir, '*.ltsa')));

    if(LTSA_size < length(diskDirs)-2)
        warning('Missing LTSAs in your %s source directory.\n', outDir);
        siteSuccess(1, i) = -1;
    end
end
clearvars inputDir outDir dirList LTSA_size destInfo
%% FILL OUT PACE SHEET 
% Extract column headers (assuming first row contains headers)
opts = detectImportOptions(inputFile, 'PreserveVariableNames', true);

%Define the datatypes to store pre-entry to PACE
opts = setvaropts(opts, {'DATA_COLLECTION_NAME', 'SITE', 'TITLE', 'TYPE', 'SUB_TYPE',  ...
    'DEPLOYMENT_ID', 'PROJECT', 'PLATFORM', 'INSTRUMENT', 'DEPLOYMENT_TITLE', 'DEPLOYMENT_PURPOSE', ...
    'DEPLOYMENT_DESCRIPTION', 'PUBLIC_RELEASE_TIME_ZONE', 'OTHER_PATH', 'DOCUMENTS_PATH', ...
    'SOURCE_PATH', 'SCIENTISTS', 'SOURCES', 'FUNDERS', 'DATASET_PACKAGER', 'CALIBRATION_PATH', ...
    'CALIBRATION_DESCRIPTION', 'PRE_DEPLOYMENT_CALIBRATION_TIMEZONE', 'SPONSORS', ...
    'SEA_AREA','QUALITY_ANALYST', 'QUALITY_ANALYSIS_OBJECTIVES', 'QUALITY_ANALYSIS_METHOD', ...
    'QUALITY', 'QUALITY_COMMENTS', 'INSTRUMENT_ID', 'PUBLIC_RELEASE_DATE', 'PRE_DEPLOYMENT_CALIBRATION_DATE' ...
    'DS_TIME_ZONE', 'DE_TIME_ZONE', 'CHANNEL_TZ', 'DEP_LAT','DEP_LONG', 'DATA_START', 'DATA_END', 'CHANNEL_START', ...
    'CHANNEL_END', 'DEPLOYMENT_TIME', 'RECOVERY_TIME', 'AUDIO_START_TIME', 'AUDIO_END_TIME'...
    'DEPLOYMENT_TIME_ZONE', 'RECOVERY_TIME_ZONE', 'AUDIO_START_TZ',  'AUDIO_END_TZ', 'DEPLOY_TYPE', 'SENSOR_NAME'},...
    'Type',  'string');
opts = setvartype(opts, {'SAMPLE_RATE', 'SAMPLE_BITS', 'DUTYCYCLE_DURATION', 'DUTY_CYCLE_INTERVAL', ...
    'MIN_FREQ', 'MAX_FREQ', 'DEPL_SEA_DEPTH', 'DEPL_INST_DEPTH', 'RECOVERY_LAT',...
    'RECOVERY_LONG', 'CHANNELNUMBER', 'RECOVERY_SEA_DEPTH', 'RECOVERY_INST_DEPTH'}, 'double'); 


data = readtable(inputFile, opts); % Apply import options
warnId = 'MATLAB:table:ModifiedAndSavedVarnames';
warnStruct = warning('off', warnId);
tfData = readtable(tfFile, VariableNamingRule="modify");
[rowCount, ~] = size(data);  % Get number of rows

for row = 1:rowCount
    %Determining Row Data For Later Column Fills. 
    siteName = deploymentNames(row);

    % Normalize siteName
    normalizedSiteName = regexprep(siteName, '[^a-zA-Z0-9]', ''); % Remove non-alphanumeric
    normalizedSiteName = lower(normalizedSiteName); % Convert to lowercase

    %Retrieve the TF PDF from the hds file and place into the folder
    matchingRows = hdsData(contains(normalizedDataIDs, normalizedSiteName), :); % Find matching rows
    tfNum = matchingRows.PreAmp;
    tfNum = regexprep(tfNum, '[^0-9]', '');

    % Columns that are not row-dependent
    data.SCIENTISTS(row) = myScientists;
    data.FUNDERS(row) = myFunders;
    data.SPONSORS(row) = mySponsors;
    data.PROJECT(row) = myProject;
    data.PLATFORM(row) = "Mooring";
    data.INSTRUMENT(row) = "HARP";
    data.SEA_AREA(row) = seaArea;
    data.DEPLOY_TYPE(row) = "Stationary Marine";
    data.SOURCES(row) = mySource;
    data.QUALITY_ANALYSIS_OBJECTIVES(row) = quality_Objectives;
    data.QUALITY_ANALYSIS_METHOD(row) = quality_Methods;
    data.DEPLOYMENT_PURPOSE(row) = purpose;
    data.CALIBRATION_DESCRIPTION(row) = "See TF Documentation";
    data.DATASET_PACKAGER(row) = dataSetPackager;
    data.PUBLIC_RELEASE_DATE(row) = datestr(datetime(year(datetime('today')), 12, 31), 'yyyy-mm-dd');
    data.PUBLIC_RELEASE_TIME_ZONE(row) = "UTC";
    data.PRE_DEPLOYMENT_CALIBRATION_TIMEZONE(row) = "UTC";
    data.DS_TIME_ZONE(row) = "UTC";
    data.DE_TIME_ZONE(row) = "UTC";
    data.CHANNEL_TZ(row) = "UTC";
    data.DEPLOYMENT_TIME_ZONE(row) = "UTC";
    data.RECOVERY_TIME_ZONE(row) = "UTC";
    data.AUDIO_START_TZ(row) = "UTC";
    data.AUDIO_END_TZ(row) = "UTC";
    data.TYPE(row) = "Raw";
    data.SUB_TYPE(row) = "Audio";
    data.MIN_FREQ(row) = 20;
    data.CHANNELNUMBER(row) = 1;
    data.SAMPLE_BITS(row) = 16;

    % Row Dependent Project identifiers
    data.DATA_COLLECTION_NAME(row) = collectionSTR + matchingRows.Data_ID;
    data.DEPLOYMENT_ID(row) = regexp(hdsData.Data_ID(row),'[0-9]*','match');
    data.PROJECT(row) = regexp(matchingRows.Data_ID,'^[a-zA-Z]*','match');
    data.SITE(row) = strrep(strrep(strrep(strrep(matchingRows.Data_ID , data.PROJECT(row),''), data.DEPLOYMENT_ID(row),''),'-',''),'_','');
    data.DEPLOYMENT_TITLE(row) = matchingRows.Data_ID;

    %Documents (Row Dependent Paths to the files saved in previous
    %sections)
    data.DOCUMENTS_PATH(row) = emptyFolder;
    data.SOURCE_PATH(row) = emptyFolder;
    data.OTHER_PATH(row) = emptyFolder;
    data.CALIBRATION_PATH(row) = emptyFolder;
    data.SENSOR_NAME(row) = matchingRows.PreAmp;

    %Row Dependent Data (mostly from HDS File)
    data.SAMPLE_RATE(row) = matchingRows.Sample_Rate*1000;
    data.DUTYCYCLE_DURATION(row) = matchingRows.Duty_Dur;
    data.DUTY_CYCLE_INTERVAL(row) = matchingRows.Cycle_Int - matchingRows.Duty_Dur;
    data.MAX_FREQ(row) = (matchingRows.Sample_Rate/2)*1000;
  
    %Latitudes and Longitudes
    lats = strrep(matchingRows.Latitude,' ','-');
    lats = regexp(lats,'-','split');
    latMat = 0;
    for iL  =1:length(lats)
        if size(lats{iL},2)>3
            latMat = NaN;
        else
            if strcmp(lats{iL}{3},'N')
                NS = 1;
            else
                NS = -1;
            end
        latMat = (str2double(lats{iL}{1})+(str2double(lats{iL}{2})/60))*NS;
        end
    end
    lons = strrep(matchingRows.Longitude,' ','-');
    lons = regexp(lons,'-','split');
    lonMat = 0;
    for iL  =1:length(lons)
        if size(lons{iL},2)>3
            lonMat = NaN;
        else
            if strcmp(lons{iL}{3},'E')
                EW = 1;
            else
                EW = -1;
            end
            lonMat = (str2double(lons{iL}{1})+(str2double(lons{iL}{2})/60))*EW;
        end
    end
    data.DEP_LAT(row) = latMat;
    data.RECOVERY_LAT(row) = latMat;
    data.DEP_LONG(row) = lonMat;
    data.RECOVERY_LONG(row) = lonMat;

    %Other Assorted Row Dependent Numbers
    data.INSTRUMENT_ID(row) = matchingRows.DL_ID;
    data.DEPL_SEA_DEPTH(row) = (-1) * matchingRows.Depth_m;
    data.RECOVERY_SEA_DEPTH(row) = (-1) * matchingRows.Depth_m;
    data.DEPL_INST_DEPTH(row) = (-1) * matchingRows.Depth_m + 20;
    data.RECOVERY_INST_DEPTH(row) = (-1) * matchingRows.Depth_m + 20;

    % Deployment time
    if isnat(matchingRows.Deploy_Date)
        data.DEPLOYMENT_TIME(row) = "NaN";
        warning('Deploy_Date missing for row %s', siteName);
        siteSuccess(1, i) = -1;
    else
        data.DEPLOYMENT_TIME(row) = datestr(matchingRows.Deploy_Date, 'yyyy-mm-ddTHH:MM:SS');
    end
    
    % Recovery time
    if isnat(matchingRows.Recovery_Date)
        data.RECOVERY_TIME(row) = "NaN";
        warning('Deploy_Date missing for row %s', siteName);
        siteSuccess(1, i) = -1;
    else
        data.RECOVERY_TIME(row) = datestr(matchingRows.Recovery_Date, 'yyyy-mm-ddTHH:MM:SS');
    end
    
    % Data start time
    if isnat(matchingRows.Data_Start_Date) || isnan(matchingRows.Data_Start_Time)
        data.DATA_START(row) = "NaN";
        data.CHANNEL_START(row) = "NaN";
        data.AUDIO_START_TIME(row) = "NaN";
        warning('Data start date/time missing for row %s', siteName);
    else
        fullStart = matchingRows.Data_Start_Date + matchingRows.Data_Start_Time;
        data.DATA_START(row) = datestr(fullStart, 'yyyy-mm-ddTHH:MM:SS');
        data.CHANNEL_START(row) = datestr(fullStart, 'yyyy-mm-ddTHH:MM:SS');
        data.AUDIO_START_TIME(row) = datestr(fullStart, 'yyyy-mm-ddTHH:MM:SS');
    end
    
    % Data end time
    if isnat(matchingRows.Data_End_Date) || isnan(matchingRows.Data_End_Time)
        data.DATA_END(row) = "NaN";
        data.CHANNEL_END(row) = "NaN";
        data.AUDIO_END_TIME(row) = "NaN";
        warning('Data end date/time missing for row %s', siteName);
    else
        fullEnd = matchingRows.Data_End_Date + matchingRows.Data_End_Time;
        data.DATA_END(row) = datestr(fullEnd, 'yyyy-mm-ddTHH:MM:SS');
        data.CHANNEL_END(row) = datestr(fullEnd, 'yyyy-mm-ddTHH:MM:SS');
        data.AUDIO_END_TIME(row) = datestr(fullEnd, 'yyyy-mm-ddTHH:MM:SS');
    end
    
    %Quality Control Data: Year Dependent
    if (data.AUDIO_END_TIME(row) < datetime(2022, 1, 1))
        data.QUALITY_ANALYST(row) = "Erin ONeill";
    else
        data.QUALITY_ANALYST(row) = 'Shelby Bloom';
    end

    data.QUALITY(row) = "Good";
    data.QUALITY_COMMENTS(row) = "No issues reported";

    % Assign Calibration Date from HARP_TF spreadsheet
    tfRow = tfData( string(tfData.S_N) == tfNum , :);
    if(height(tfRow) == 0 )
        warning("No transfer function found for %s. Saving Cal Date as NaT", siteName);
        data.PRE_DEPLOYMENT_CALIBRATION_DATE(row) = NaT;
        siteSuccess(1, row) = -1;
    else
        data.PRE_DEPLOYMENT_CALIBRATION_DATE(row) = datetime(tfRow.DateCalibratedYYMMDD(1), 'InputFormat', 'yyMMdd', 'Format', 'yyyy-MM-dd');
    end

    %Deployment Desription (Made from the Other Variables):
    data.DEPLOYMENT_DESCRIPTION(row) = sprintf("This dataset includes raw acoustic recordings from %s site %s from %s to %s. " + ...
    "In addition to the raw acoustic recordings, there are several associated files for these data which include " + ...
    "calibration files (transfer functions) and Long-term Spectral Averages (LTSAs) for sound exploration and accessibility. " + ...
    "Three readme files provide details on the acoustic recording's xwav format, LTSA format, and transfer function descriptions. " + ...
    "All recordings are collected in UTC. \n\nAmplitude calibration files called transfer functions are " + ...
    "associated with the specific HARP equipment used to collect each acoustic recording dataset. " + ...
    "Correct use of transfer functions is critical for providing absolute measured sound pressure received levels " + ...
    "in standard acoustic measurement units, and for comparing signals within and between deployments. " + ...
    "Transfer functions are estimates of a recording system's true sensitivity, and are being continuously" + ...
    " evaluated and improved by Scripps Institution of Oceanography researchers and are subject to change without notice. " + ...
    "Please review the Transfer_Function_readme before using this data.", data.PROJECT(row), data.DEPLOYMENT_TITLE(row),...
    data.AUDIO_START_TIME(row),data.AUDIO_END_TIME(row));
end

%Output this data to a spreadsheet ready for PACE:
outputFile = inputFile;

% Now append the new data, ensuring it starts from row 3
writetable(data, outputFile, 'WriteMode', 'overwrite', 'WriteVariableNames', true);

clearvars DATA_COMMENT destinationFile EW i iDir iL k latMat lats lonMat lons matchingRows myProject
clearvars myScientists myScientists mySource mySponsors normalizedSiteName NS opts purpose quality_Objectives
clearvars quality_Methods row rowCount seaArea siteName sourceFile sourceInfo splitString tfNum tfRow thisList outDirTF
%% TO FLAC ALL FILES. (Stolen/Modified from Katrina)
for i=1:length(inputLocations)
    fprintf('Beginning processing on DISK %s\n', deploymentNames(i));
    lastMsgTime = tic;  % Start timing

    %BEFORE BEGINNING FLAC, MAKE SURE TARGET HAS ENOUGH SPACE
    % Source and destination directories
    sourceDir = inputLocations(i); 
    [driveLetter, ~, ~] = fileparts(outputLocations(i)); % Extract drive portion
    if ~endsWith(driveLetter, '\')
        driveLetter = [driveLetter, '\'];
    end
    destinationDrive = driveLetter; 
    
    % Get list of files in source directory
    fileList = dir(fullfile(sourceDir, '**', '*')); % Includes subfolders
    fileSizes = [fileList.bytes]; % Extract file sizes
    totalFileSize = sum(fileSizes); % Compute total size of files to copy
    
    % Get available space on the destination drive
    fileObj = java.io.File(destinationDrive);
    availableSpace = fileObj.getUsableSpace(); % Bytes
    
    % Check if there's enough space
    if ~(availableSpace > (totalFileSize/compressionRatio))
        % Not enough space
        warning("Insufficient Space on Target Drive for FLAC Processing of %s", deploymentNames(i));
        siteSuccess(1, i) = -1;
        break
    end

    %FLAC Code
    cd(inputLocations(i)) % Modify this to be the source drive to read files from.
    dirList = dir;
    myStr = '%s --keep-foreign-metadata --output-prefix=%s %s';
    
    %Determining Row Data For Later Column Fills. 
    siteName = deploymentNames(i);

    % Normalize siteName
    normalizedSiteName = regexprep(siteName, '[^a-zA-Z0-9]', ''); % Remove non-alphanumeric
    normalizedSiteName = lower(normalizedSiteName); % Convert to lowercase

    %Retrieve the TF PDF from the hds file and place into the folder
    matchingRows = hdsData(contains(normalizedDataIDs, normalizedSiteName), :); % Find matching rows
    outDir = outputLocations(i) + collectionSTR + matchingRows.Data_ID + filesep + 'data' + filesep + 'acoustic_files' + filesep;

    if ~isfolder(outDir)
        mkdir(outDir)
    end
    %
    for iDir = 1:length(dirList)
        thisList = dir(fullfile(dirList(iDir).folder,dirList(iDir).name,'*.x.wav'));
        if isempty(thisList)
            continue
        end
        cd(fullfile(dirList(iDir).folder,dirList(iDir).name))
        nFiles = length(thisList);
        for iFile = 1:length(thisList)
            myCMD = sprintf(myStr,fullPathFlac,outDir,thisList(iFile).name);
            [status,cmdout] = system(char(myCMD));  
            % Check if it's been 15 minutes since last message
            if toc(lastMsgTime) > msgInterval
                fprintf('[%s] Still processing on disk %s. Currently on Folder %d: Done with file %0.0d of %0.0d.\n', datestr(now, 'dd-mmm-yyyy HH:MM:SS'), siteName, iDir,iFile,nFiles);
                lastMsgTime = tic;  % Reset timer
            end
            %fprintf('Folder %0.0f: Done with file %0.0f of %0.0f - %s\n',iDir,iFile,nFiles,thisList(iFile).name)
        end
    end

    fprintf('Completed processing on DISK %s\n', deploymentNames(i));
end

%Check that each flac was successful. If it wasn't, give the user a
%warning.
for i=1:length(inputLocations)
     %Determining Row Data For Later Column Fills. 
    siteName = deploymentNames(i);

    % Normalize siteName
    normalizedSiteName = regexprep(siteName, '[^a-zA-Z0-9]', ''); % Remove non-alphanumeric
    normalizedSiteName = lower(normalizedSiteName); % Convert to lowercase

    %Retrieve the TF PDF from the hds file and place into the folder
    matchingRows = hdsData(contains(normalizedDataIDs, normalizedSiteName), :); % Find matching rows
    outDir = outputLocations(i) + collectionSTR + matchingRows.Data_ID + filesep + 'data' + filesep + 'acoustic_files' + filesep;

    flacList = dir(outDir);
    for iF = 1:length(flacList)
        flacList(iF).name = flacList(iF).name(1:end-6);
    end
    inputDir = inputLocations(i) + "\**\*.x.wav";
    xwavList = dir(inputDir);
    for iX = 1:length(xwavList)
        xwavList(iX).name = xwavList(iX).name(1:end-5);
    end
    [~,missingIdx] = setdiff({xwavList.name},{flacList.name});
    if(~isempty(unique({xwavList(missingIdx).folder})) )
        warning("Flacing on disk %s has failed. Missing file(s). Please recheck.", siteName);
        siteSuccess(1, i) = -1;
    end
end
clearvars dirList myStr outDir thisList nFiles myCMD flacList inputDir xwavList normalizedDataIDs collectionSTR
%% END SUMMARY: 
% Give User a Warning for Each Site that Failed or tell them it is ready for PACE.

fprintf("--------------------------------------------------------\n");
fprintf("                    END CODE SUMMARY                    \n");
fprintf("--------------------------------------------------------\n");
for i=1:length(inputLocations)
    splitString = strsplit(inputLocations(i), filesep);  % Find last occurrence of '\'
    siteName = deploymentNames(i);

    if(siteSuccess(i) == -1)
        warning("At least one error occurred in preparing package for %s,\n Please review log for error messages and correct before PACE operation.", siteName);
    else
        fprintf("Package for %s successful. Ready for PACE.\n", siteName);
    end
end
fprintf("--------------------------------------------------------\n");
warning("NOTE: QUALITY DEFAULT VALUE GOOD/NO ISSUES FOR ALL SITES. PLEASE VERIFY BEFORE PACE");


