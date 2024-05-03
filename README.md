<p align='center'>
<img src='https://github.com/waqarg2001/2024-AI-Challenge-MedScribe/blob/main/assets/medscribe%20logo.png' width=300 height=300 >
</p>

---

<h4 align='center'> MedScribe is an innovative mobile platform designed to optimize healthcare documentation and reduce physician burnout. Utilizing advanced Generative AI technologies, including the LLM <a href='https://mistral.ai/news/announcing-mistral-7b/'> Mistral 7B </a> and <a href='https://huggingface.co/liuhaotian/llava-v1.5-7b'>LLaVA 1.5 7B</a> models, MedScribe automates the transcription and categorization of doctor-patient interactions into standardized clinical <a href='https://en.wikipedia.org/wiki/SOAP_note'>SOAP notes </a> directly within its app environment.</h4>

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

## Architecture

The architecture of this project is inspired by the following architecture.

<p align='center'>
  <img src='' height=470 width=600>
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
