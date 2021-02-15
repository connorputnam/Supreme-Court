# Supreme-Court
## Connor Putnam
<!-- badges: start -->
<!-- badges: end -->

The goal for this project was to first 


The first step in this project was to import the data, with the focus being on the questions regarding the United States Supreme Court. The data used can be found at the following Git repository: [supreme court transcripts](https://github.com/walkerdb/supreme_court_transcripts). The repo contains records for every supreme court case see by the justices of the United States Supreme Court. It is spread throughout 15,375 `JSON` files and takes up 3.17 GB. In order to make this usable for data analysis it must be converted into a data frame with the relevant information withdrawn.
Because of this only a sample of the orginial data used in provided in my repo under the `JSON files` folder, for the remaining data refer to the link provided above.

Once the data was obtained the **JSON** files needed to be converted to a more usable form, in this case **CSV**. Once this was done, questions needed to asked regarding what the purpose of this project is and what insights can be drawn. Once these questions were determined then the data was to be sorted and the desired information extracted. Lastly, visualizations were made to help answer these questions.

The data wrangling code for this project was done in python and can be found in the script titled `supreme_court_data_wrangling.py`. Some further data manuplication and visualizationw were done in R and can be found under the script titled `supreme_court_analysis_script.R`. A complete project report going over all the steps involved can be found in the Rmarkdown file `supreme_court_report.Rmd`. In addition the converted **JSON** can be found at `unnested_transcripts.csv`

R packages used:

  * `tidyverse`
  * `ggthemes`
  * `anytime`
  * `kableExtra`
  * `lubridate`
  * `pander`

Python packeges used:
  * `json`
  * `pandas`
  * `os`
  * `csv`