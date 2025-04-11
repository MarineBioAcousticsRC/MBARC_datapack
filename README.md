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

## C. Preparing
#### 1. Download xlsx versions of HARP Data Summary and HARP Hydrophone Data.
  In [MBARC_DataProcessing](https://drive.google.com/drive/folders/1e9KVtS-z6sY-vxUsHTDytJUbM9D3nDRP), download most recent HarpDataSummary file and save to same location as your .m code. In [MBARC_TF](https://drive.google.com/drive/folders/0ACl63NkjL8DlUk9PVA), download the most recent HARP_hydrophones and save to same location as .m code.

#### 2. Edit excel sheet fields. 
Fill out first 3 columns of MBARC_PACE_DATA_IMPORT_1CHANNEL template.
  * Input Location: Drive to pull acoustic data from. Format (F:\ or F:\PS_12). 
  * Output Location: Drive you want to send to NCEI. Format (E:\)
  * Title of Drive: Name of site/deployment. (Format: CINMS_B_47 or PS_12)
![image](https://github.com/user-attachments/assets/3382d85b-dc6a-490d-9696-a92016931d3e)


#### 2. Edit Section 1 of "pack_data_1Channel.m"
Relevant Fields
  * dataSetPackager: Your Name
  * inputFile: Link to the spreadsheet you filled out in step 1.
  * fullPathFlac: Link to where you saved the flac folder during setup. (Format: *\flac-1.3.2-win\win64\flac)
  * 
![image](https://github.com/user-attachments/assets/ffdab2e5-8960-47b1-b37f-28253dfb7aba)



## Using PACE
## D. Using PACE

## End Results
## E. End Results
