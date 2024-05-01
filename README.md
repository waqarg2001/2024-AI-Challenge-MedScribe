<p align='center'>
<img src='https://github.com/waqarg2001/Coivid-19-DE-Project/blob/main/Resources/Logo.png' width=630 height=290 >
</p>

---

<h4 align='center'> Utilisation of <a href='https://azure.microsoft.com/en-us' target='_blank'>Azure Cloud Services</a> to architect and orchestrate data pipeline(weekly) to perform ETL on Covid-19 dataset of European countries extracted from <a href='https://www.ecdc.europa.eu/en/covid-19/data'>European Centre for Disease Prevention and Control</a> </h4>

<p align='center'>
<img src="https://i.ibb.co/KxfMMsP/built-with-love.png" alt="built-with-love" border="0">
<img src="https://i.ibb.co/MBDK1Pk/powered-by-coffee.png" alt="powered-by-coffee" border="0">
<img src="https://i.ibb.co/CtGqhQH/cc-nc-sa.png" alt="cc-nc-sa" border="0">
</p>

<p align="center">
  <a href="#overview">Overview</a> •
  <a href="#tools">Tools</a> •
  <a href="#architecture">Architecture</a> •
  <a href="#support">Support</a> •
  <a href="#license">License</a>
</p>


## Overview

<p>The European Centre for Disease Prevention and Control (ECDC) was established in 2005. It is an EU agency aimed at strengthening Europe's defenses against infectious diseases.</p>

Covid 19 Analysis is a comprehensive project that harnesses the capabilities of Azure services to collect, analyze, and visualize essential COVID-19 data while ensuring robust security through Azure Key Vault and Azure Service Principals. This project seamlessly retrieves data from the European Centre for Disease Prevention and Control (ECDC) and combines it with population data for a comprehensive analysis of the pandemic's impact. Data is ingested into Azure Data Lake Gen2, which acts as a centralized storage repository, and then undergoes transformations and exploratory analysis using Azure Dataflow and Azure Databricks. To maintain stringent security, Azure Key Vault is employed to securely manage and store sensitive credentials and secrets. Processed data is stored in an Azure SQL Database for efficient querying, and Azure Data Lake Gen2 is used for intermediate and refined datasets. The project includes the use of Power Bi for showcasing the spread and testing of Covid 19 in European countries.

The repository directory structure is as follows:

```
├── README.md          <- The top-level README for developers using this project. 
| 
├── Data             <- Contains data extracted, processed, and used throughout the project.
│   ├── Raw          <- Contains raw data folders
│   │
│   ├── Processed    <- Contains processed data acquired through databricks spark notebooks and azre data flow.
│   │
│   ├── Lookup       <- Contains look up files used for population and country info.
│   │
│   ├── Config       <- Contains file used to automate the extraction part for ADF.
│
│
├── Databricks Notebooks         <- Scripts to aggregate and transform data
│   ├── configuration           <- Contains configurations used for mounting ADLS and azure key vault.
│   │
│   ├── transformation          <- Contains transformation notebooks 
|         
├── Resources                  <- Resources for readme file.
```

## Tools 

To build this project, the following tools were used:

- Azure Databricks
- Azure KeyVault
- Azure Active Directory
- Azure DataLake Gen 2
- Azure Data Factory
- Azure SQL Database
- Power Bi
- Pyspark
- SQL
- Git

## Architecture

The architecture of this project is inspired by the following architecture.

<p align='center'>
  <img src='https://github.com/waqarg2001/Coivid-19-DE-Project/blob/main/Resources/architecture_diagram.png' height=470 width=600>
</p>  



## Support

If you have any doubts, queries, or suggestions then, please connect with me on any of the following platforms:

[![Linkedin Badge][linkedinbadge]][linkedin] 
[![Gmail Badge][gmailbadge]][gmail]


## License

<a href = 'https://creativecommons.org/licenses/by-nc-sa/4.0/' target="_blank">
    <img src="https://i.ibb.co/mvmWGkm/by-nc-sa.png" alt="by-nc-sa" border="0" width="88" height="31">
</a>

This license allows reusers to distribute, remix, adapt, and build upon the material in any medium or format for noncommercial purposes only, and only so long as attribution is given to the creator. If you remix, adapt, or build upon the material, you must license the modified material under identical terms.



<!--Profile Link-->
[linkedin]: https://www.linkedin.com/in/waqargul
[gmail]: mailto:waqargul6@gmail.com

<!--Logo Link -->
[linkedinbadge]: https://img.shields.io/badge/waqargul-0077B5?style=for-the-badge&logo=linkedin&logoColor=white
[gmailbadge]: https://img.shields.io/badge/Gmail-D14836?style=for-the-badge&logo=gmail&logoColor=white
