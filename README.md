<p align='center'>
<img src='https://github.com/waqarg2001/2024-AI-Challenge-MedScribe/blob/main/assets/medscribe%20logo.png' width=250 height=250 >
</p>

---

<h4 align='center'> MedScribe is mobile platform designed to optimize healthcare documentation and reduce physician burnout. Utilizing Gen AI technologies, including the LLMs <a href='https://mistral.ai/news/announcing-mistral-7b/'> Mistral 7B </a> and <a href='https://huggingface.co/liuhaotian/llava-v1.5-7b'>LLaVA 1.5 7B</a> models, it automates the transcription and categorization of doctor-patient interactions into standardized clinical <a href='https://en.wikipedia.org/wiki/SOAP_note'>SOAP notes </a> directly within its app environment.</h4>

<p align='center'>
<img src="https://i.ibb.co/KxfMMsP/built-with-love.png" alt="built-with-love" border="0">
<img src="https://i.ibb.co/MBDK1Pk/powered-by-coffee.png" alt="powered-by-coffee" border="0">
<img src="https://i.ibb.co/CtGqhQH/cc-nc-sa.png" alt="cc-nc-sa" border="0">
</p>

<p align="center">
  <a href="#overview">Overview</a> •
  <a href="#tools">Tools</a> •
  <a href="#setup-guide">Setup Guide</a> •
  <a href="#license">License</a>
</p>


## Overview

<p>MedScribe is a mobile application that enhances healthcare documentation by automatically transcribing doctor-patient interactions into SOAP notes, which are then stored as part of the patient's history within the app. The app utilizes advanced AI technologies, specifically LLM Mistral 7B and LLaVA 1.5 7B models, to ensure the accuracy and efficiency of data processing. This reduces the time healthcare providers spend on Electronic Health Records (EHRs), helping to alleviate physician burnout and improve patient care. For more details on how MedScribe works and its benefits, please check the project <a href='https://github.com/waqarg2001/2024-AI-Challenge-MedScribe/blob/main/docs/MedScribe%20Report.pdf'> report</a> provided in this repository.</p>



The repository directory structure is as follows:

```
├── README.md          <- The top-level README for developers using this project. 
| 
├── assets             <- Contains assets used to build this readme.md.
│
├── data               <- Data used during the testing of application/notebooks.
│   ├── CAR0001.mp3           <- Doctor-Patient conversation recording used in notebooks
|         
├── demo                  <- Contains demo video of the application
│
│
├── docs                           <- Contains documentation related to the application.
│   ├── MedScribe Report.pdf       <- Project report according to competition guidelines
│
│
├── src                       <- Project report according to competition guidelines
│   ├── notebooks             <- Jupter notebooks which contain llm trainings and speech to text(diarization).
│       ├── Image_Analysis_LLM.ipynb      <- Llava model training
│       │
│       ├── Mistral_Fine_Tuning.ipynb     <- Mistral 7b model finetuning
│       │ 
│       ├── SOAP_Inference.ipynb     <- Mistral model inference (SOAP notes)
│       │
│       ├── WhisperX - Speech Diarization.ipynb     <- Speech to text and diarization of conversation
│
├──

```

## Tools 

To build this project, the following tools were used:

- Flutter
- Python
- Node JS
- Flask
- PostgreSQL
- AWS Sagemaker
- Google Cloud Functions
- Google Bucket
- Google Kubernetes Engine
- GPU

## Setup Guide 


To set up and test the MedScribe mobile application, follow these steps:

- <b>Download and Install the APK</b>:
The MedScribe application is distributed as an APK file. You can download the APK from the repository and install it on your Android device. Make sure you have allowed installations from unknown sources in your device's settings.

- <b>Test the Application</b>:
Once the app is installed, you can launch it and begin testing its features. Since all the models and databases are hosted online, the app should work seamlessly, allowing you to explore its functionalities, such as transcribing doctor-patient interactions into SOAP notes and analyzing diagnostic reports.

- <b>Explore the Notebooks</b>:
If you want to understand how the AI models were trained and fine-tuned, you can review the Jupyter notebooks provided in the src/notebooks directory. These notebooks cover the training and fine-tuning processes for the different models used in MedScribe.
To run these notebooks, you can use Google Colab or any environment that provides GPU support. These notebooks require a GPU instance for efficient processing.

By following this setup guide, you should be able to test and explore the MedScribe application, as well as delve into the underlying AI models that power its features.





## License

<a href = 'https://creativecommons.org/licenses/by-nc-sa/4.0/' target="_blank">
    <img src="https://i.ibb.co/mvmWGkm/by-nc-sa.png" alt="by-nc-sa" border="0" width="88" height="31">
</a>

This license allows reusers to distribute, remix, adapt, and build upon the material in any medium or format for noncommercial purposes only, and only so long as attribution is given to the creator. If you remix, adapt, or build upon the material, you must license the modified material under identical terms.



