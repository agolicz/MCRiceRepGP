MCGPlannotator (Multi Criteria Gene Plant Annotator) performs functional annotation of genes using available multi-omics data, multi-criteria decision analysis, and machine learning.

Dependencies:
* Linux operating system
* python v2.7.5 or greater
* numpy, tested on v1.11.2
* R v3.4.0 or greater
* e1071, tested on v1.6-8
* caret, tested on v6.0-76
* ROCR, tested on v1.0-7
* DescTools, tested on v0.99.22
* mltools, tested on v0.3.3

To perform a test run, download the files from https://osf.io/78axs/ (mcgplannotator.rice.files.11012018.tgz). 
Place the files and scripts in a single directory and run ‘bash runMCGPlannotator.sh’

1. git clone https://github.com/agolicz/MCGPlannotator.git
2. Move mcgplannotator.rice.files.11012018.tgz into ./MCGPlannotator
3. tar -xvzf mcgplannotator.rice.files.11012018.tgz
4. bash runMCGPlannotator.sh

Default settings can be changed by modifying values within the SETTINGS section of runMCGPlannotator.sh
Alternatively, you may want to try the web application: http://mcgplannotator.com/rice

IMPORTANT: 
1. To invoke non-coding mode, IDs of non-coding genes have to start with ‘NC_’.
2. Please ensure that the genes IDs are consistent across all the files.
3. Make sure gene IDs are a single string with letters and numbers only [A-Z,a-z,0-9]. Especially no semicolons, commas and spaces in gene names. 
   
Not doing so may/will result in failure/unpredictable behaviour/errors.

Information about input file format can be found in input.files.info.txt

If you encounter any problems/errors or need more information, please open an Issue or email me at: agnieszka.golicz@unimelb.edu.au.

