# MBARC_datapack
This repository contains tools designed to streamline the packaging of High-Frequency Acoustic Recording Package (HARP) data for archival with NOAA. It is built upon the file management systems employed by the Scripps Institution of Oceanography's MBARC program and may require modification for use outside of that environment, or for operation on Linux based systems.

For inquiries, please contact: kcastello@ucsd.edu

## A. Branch Management
Commits to main are restricted to the code owners. 

If code alteration is needed, please create your own branch and commit a pull request for code merge into main.

## B. Setup

### 1. PACE Installation
#### 1. PACE Installation
  1. Download appropriate GUI file from [here](https://github.com/CI-CMG/pace/releases/tag/v1.0.2). For MBARC, this should be "pace-gui-Windows-X64-1.0.2.msi"
  2. Open downloaded file to launch installer and follow prompts to complete installation.
  3. Copy and paste premade translator into your PACE.
       * 

#### 2. FLAC Installation
  1. Download [flac-1.3.2-win](https://github.com/KaseyMCastello/MBARC_datapack/blob/main/flac-1.3.2-win-20250411T171703Z-001.zip).
  2. Unzip flac-1.3.2-win to C:\Program Files or D: data drive.
  3. Note location of your flac folder and add to MATLAB path.

#### 3. Google Drive Setup (For MBARC)
_For correct MBARC operation, you should have access to the "MBARC_TF" and the "MBARC_DataProcessing" Google Drives. If you don't have access, request from Shelby_
1. Download appropriate Google Drive For Desktop file from [here](https://support.google.com/drive/answer/10838124?hl=en).
2. Follow instructions on Google Drive for Desktop to complete initial installation.
3. Open newly installed program. Once open, follow prompts to sign into your UCSD Google account.
4. This will make a mirrored drive on your computer. Go to the mirrored drive using file explorer.
5. Right-click MBARC_TF and choose "make available offline."
![Available Offline](https://github.com/user-attachments/assets/e48d532b-946f-4721-981c-7de33f96d1c2)

## C. Preparation
#### 1. Download xlsx versions of HARP Data Summary and HARP Hydrophone Data.
  In [MBARC_DataProcessing](https://drive.google.com/drive/folders/1e9KVtS-z6sY-vxUsHTDytJUbM9D3nDRP), download most recent HarpDataSummary file and save to same location as your .m code. In [MBARC_TF](https://drive.google.com/drive/folders/0ACl63NkjL8DlUk9PVA), download the most recent HARP_hydrophones and save to same location as .m code.

#### 2. Edit excel sheet fields. 
Fill out first 3 columns of MBARC_PACE_DATA_IMPORT_1CHANNEL template. (Note: all drives to be packaged at once should be from the same project type (EX: LMR/GOM/CINMS/etc)
  * Input Location: Drive to pull acoustic data from. Format (F:\ or F:\PS_12). 
  * Output Location: Drive you want to send to NCEI. Format (E:\)
  * Title of Drive: Name of site/deployment. (Format: CINMS_B_47 or PS_12)
![image](https://github.com/user-attachments/assets/3382d85b-dc6a-490d-9696-a92016931d3e)

#### 3. Create directory for readMe files. 
Ensure the below read me files exist in one folder.
![image](https://github.com/user-attachments/assets/ac005377-607a-4369-b5c9-09320b318535)


#### 3. Edit Section 1 of "pack_data_1Channel.m"
Relevant Fields
  * dataSetPackager: Your Name
  * inputFile: Link to the spreadsheet you filled out in step 1.
  * fullPathFlac: Link to where you saved the flac folder during setup. (Format: *\flac-1.3.2-win\win64\flac)
  * templateDocsLocation: Link to where you saved the LTSA, xwav, and tf read me files. Can be current directory.
  * hdsFile: Link to where you saved the Harp Data Summary in step 1.
  * tfFile: Where you saved the HARP_Hyrdophones xlsx sheet in step 1. 
  * tfDrive: Link to your Google Drive desktop. (Format: *\Shared drives\MBARC_TF)
  * emptyFolder: Link this to any empty folder on your machine. (Workaround for packing in place).
  * msgInterval (OPTIONAL): This is how often you want the program to report flac progress. Currently set to every 20 minutes.
  * projectType: Set to 1 for GOM datasets, 2 for LMR, 3 for CINMS. Currently, that's all I have programmed but can add more later.
  * compressionRatio: Probably won't change. Ratio of file sizes before and after flac. Used to verify space on target drive.
![image](https://github.com/user-attachments/assets/ffdab2e5-8960-47b1-b37f-28253dfb7aba)

#### 4. (OPTIONAL): Edit metadata in corresponding metadata_XXXX.m file. 
  Note: If you have a project that does not yet have a metadata_PROJECT.m file, you will need to make one. Copy and paste an existing file and edit necessary fields. You will then have to edit section 2 of pack_data_1Channel.m. Add a case to run the file you just made and change projectType in section 1 to the case that you added.
![image](https://github.com/user-attachments/assets/ba3c2594-70f2-4056-a0bd-d61d255373cf)

#### 5. Run program 
Ensure all xlsx files are closed, then run pack_data_1Channel.m. If there are no issues in the data, it will look like this: 
![image](https://github.com/user-attachments/assets/3ba488d9-8eaf-4290-9330-35ea13376210)

If there are any issues in the packing process, an orange warning will be displayed. Review warning message and correct if desired before moving on to PACE.
 
## D. PACE Operation
For a full PACE instructional, please review [PACE GUI Guide.pdf](https://github.com/user-attachments/files/19712695/PACE.GUI.Guide.pdf). 


## End Results

## E. End Results
