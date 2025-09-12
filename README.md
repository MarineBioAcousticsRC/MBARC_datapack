# MBARC_datapack
This repository contains tools designed to streamline the packaging of High-Frequency Acoustic Recording Package (HARP) data for archival with NOAA. It is built upon the file management systems employed by the Scripps Institution of Oceanography's MBARC program and may require modification for use outside of that environment, or for operation on Linux based systems. See sections below for first-time setup and running datapacking.

For inquiries, please contact: kcastello@ucsd.edu
#### Branch Management
Commits to main are restricted to the code owners. 

If code alteration is needed, please create your own branch and commit a pull request for code merge into main.

# Operation
Note: if this is your first time setting up and running datapacking on a new computer, please scroll down to "First Time Setup" and complete those steps before proceeding. 
## MATLAB 2023a
#### 1. Download xlsx versions of HARP Data Summary and HARP Hydrophone Data.
  In [MBARC_DataProcessing](https://drive.google.com/drive/folders/1e9KVtS-z6sY-vxUsHTDytJUbM9D3nDRP), download most recent HarpDataSummary file and save to same location as your .m code. In [MBARC_TF](https://drive.google.com/drive/folders/0ACl63NkjL8DlUk9PVA), download the most recent HARP_hydrophones and save to same location as .m code.

#### 2. Edit excel sheet fields. 
Fill out first 3 columns of MBARC_PACE_DATA_IMPORT_1CHANNEL template. (Note: all drives to be packaged at once should be from the same project type (EX: LMR/GOM/CINMS/etc)
  * Input Location: Drive to pull acoustic data from. Format (F:\ or F:\PS_12). 
  * Output Location: Drive you want to send to NCEI. Format (E:\)
  * Title of Drive: Name of site/deployment. (Format: CINMS_B_47 or PS_12)
![image](https://github.com/user-attachments/assets/3382d85b-dc6a-490d-9696-a92016931d3e)

#### 3. (OPTIONAL): Edit metadata in corresponding metadata_XXXX.m file. 
  Note: If you have a project that does not yet have a metadata_PROJECT.m file, you will need to make one. Copy and paste an existing file and edit necessary fields. The kinds of fields you will need to know are the project purpose, funders, sources, and scientists involved. Once you have made the metadata_PROJECT.m, open "pack_data_1Channel.m" In the second section, add a select case key to the list of available projects to pack.
  
![image](https://github.com/user-attachments/assets/ba3c2594-70f2-4056-a0bd-d61d255373cf)

#### 4. Edit Section 1 of "pack_data_1Channel.m"
Relevant Fields
  * dataSetPackager: Your Name
  * inputFile: Link to the spreadsheet you filled out in step 1.
  * fullPathFlac: Link to where you saved the flac folder during setup. (Format: *\flac-1.3.2-win\win64\flac)
  * templateDocsLocation: Link to where you saved the LTSA, xwav, and tf read me files. If you cloned the repository it will be [repopath]\templateDocs.
  * hdsFile: Link to where you saved the Harp Data Summary in step 1.
  * tfFile: Where you saved the HARP_Hyrdophones xlsx sheet in step 1. 
  * tfDrive: Link to your Google Drive desktop Transfer Function Folder. See setup below if not previously done linked. This location tends to change every time you put a new hard drive in your computer. (Format: *\Shared drives\MBARC_TF)
  * includeLTSA: True if you want to include the LTSA files, false otherwise. If you don't know ask the PI because this tends to be project-specific.
  * msgInterval (OPTIONAL): This is how often you want the program to report flac progress. Currently set to every 20 minutes.
  * projectType: Set to 1 for GOM datasets, 2 for LMR, 3 for CINMS. Currently, that's all I have programmed but can add more later.
  * compressionRatio: Probably won't change. Ratio of file sizes before and after flac. Used to verify space on target drive.
![image](https://github.com/user-attachments/assets/ffdab2e5-8960-47b1-b37f-28253dfb7aba)


#### 5. Run program 
Ensure all xlsx files are closed, then run pack_data_1Channel.m. If there are no issues in the data, it will look like this: 
![image](https://github.com/user-attachments/assets/3ba488d9-8eaf-4290-9330-35ea13376210)

If there are any issues in the packing process, an orange warning will be displayed. Review warning message and correct if desired before moving on to PACE packaging.
 
## PACE 
For a full PACE instructional, please review [PACE GUI Guide.pdf](https://github.com/user-attachments/files/19712695/PACE.GUI.Guide.pdf). 

#### 1. Review metadata (will only have to do once per project)
Click through each field (blue) in metadata and ensure that all of the people/places/organizations etc that you are entering for your project exist in PACE. If not, create them.
![image](https://github.com/user-attachments/assets/07a0d5c5-ecad-4663-a9d4-7a6574d4a051)

#### 2. Translate
Click "Package" -> translate and follow all prompts to translate your data to prepare for packing. (Note, if there are any errors, a warning box will come up. You may have to correct those errors and try retranslating again. It is common here for a person/project/organization to not exist yet. If this warning comes up, go back to step 1 and add the missing metadata under the correct type. Note these are not capital/space agnostic.
![image](https://github.com/user-attachments/assets/b12e1545-dc61-4f5d-8ed1-17854b90ff42)

### 3. Package. 
Check as many drives as you would like to package at once and click "Package Data". All drives will have to go to the same output drive, so only package deployments you want to end up on the same drive. Follow the prompts until the end to complete your package. When it says "Choose Directory" this is the drive you intend to send to NCEI. Should JUST be of the format (E:\). Once the directory is verified, a map will pop up. If this is the world area you expected, click "verify" to begin packing. Packing is complete once blue line in PACE is full and the chosen deployments go away from the "Packages" window. 
![image](https://github.com/user-attachments/assets/7429b12d-477d-4cb8-a595-061380878308)

### 4. Verify proper packing.
Go to the target drive and open the folder for the deployment you just packed. It should have a variety of text files. Open "manifest-md5.txt" and ensure that it has some .x.wav files in it. If so, you are done!

# First Time Setup
## 1. PACE Installation and Setup
#### 1. Installation
  1. Download appropriate GUI file from [here](https://github.com/CI-CMG/pace/releases). For MBARC, this was optimized for version 1.2.1. Download "pace-gui-Windows-X64-1.2.1.msi"
  2. Open downloaded file to launch installer and follow prompts to complete installation.
#### 2. Translator Setup
  1. Open PACE application and then close again.
  2. Clone into this git repository:
     ```
     git clone https://github.com/MarineBioAcousticsRC/MBARC_datapack.git
     ```
  3. Reopen PACE and then click the "Translators" tab and then "Create"
     ![image](https://github.com/MarineBioAcousticsRC/MBARC_datapack/blob/main/wikiImages/translator_create.png)
  4. Under name, enter "MBARC-1Channel."
  5. Select "Import Spreadsheet Headers"
  6. Navigate to where you made your cloned folder, and choose "MBARC_PACE_DATA_IMPORT_1CHANNEL.xlsx"
  7. Under package type, select "Audio"
  8. Use the dropdown options to choose fields as shown in the images below. Note red circles for which page and which dropdowns you will need to click. Note you will need to click "Add Entry" under "Quality" and "Add Channel" and "Add Sample Rate" under "Channels" in order to properly fill all fields. 
     ![image](https://github.com/MarineBioAcousticsRC/MBARC_datapack/blob/main/wikiImages/fields1.png)
     ![image](https://github.com/MarineBioAcousticsRC/MBARC_datapack/blob/main/wikiImages/fields2.png)
     ![image](https://github.com/MarineBioAcousticsRC/MBARC_datapack/blob/main/wikiImages/fields3.png)
     ![image](https://github.com/MarineBioAcousticsRC/MBARC_datapack/blob/main/wikiImages/fields4.png)
     ![image](https://github.com/MarineBioAcousticsRC/MBARC_datapack/blob/main/wikiImages/fields5.png)
     ![image](https://github.com/MarineBioAcousticsRC/MBARC_datapack/blob/main/wikiImages/fields6.png)
     ![image](https://github.com/MarineBioAcousticsRC/MBARC_datapack/blob/main/wikiImages/fields7.png)
     ![image](https://github.com/MarineBioAcousticsRC/MBARC_datapack/blob/main/wikiImages/fields8.png)
     ![image](https://github.com/MarineBioAcousticsRC/MBARC_datapack/blob/main/wikiImages/fields9.png)
     ![image](https://github.com/MarineBioAcousticsRC/MBARC_datapack/blob/main/wikiImages/fields10.png)
     ![image](https://github.com/MarineBioAcousticsRC/MBARC_datapack/blob/main/wikiImages/fields11.png)
     ![image](https://github.com/MarineBioAcousticsRC/MBARC_datapack/blob/main/wikiImages/fields12.png)
  9. Click "save"
## 2. FLAC Installation
  1. Download [flac-1.3.2-win](https://github.com/KaseyMCastello/MBARC_datapack/blob/main/flac-1.3.2-win-20250411T171703Z-001.zip).
  2. Unzip flac-1.3.2-win to C:\Program Files or D: data drive.
  3. Note location of your flac folder and add to MATLAB path.

## 3. Google Drive Setup (For MBARC)
_For correct MBARC operation, you should have access to the "MBARC_TF" and the "MBARC_DataProcessing" Google Drives. If you don't have access, request from Shelby_
1. Download appropriate Google Drive For Desktop file from [here](https://support.google.com/drive/answer/10838124?hl=en).
2. Follow instructions on Google Drive for Desktop to complete initial installation.
3. Open newly installed program. Once open, follow prompts to sign into your UCSD Google account.
4. This will make a mirrored drive on your computer. Go to the mirrored drive using file explorer.
5. Right-click MBARC_TF and choose "make available offline."
![Available Offline](https://github.com/user-attachments/assets/e48d532b-946f-4721-981c-7de33f96d1c2)


