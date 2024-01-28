# DocLinkr

**Authors:** Sadnam Sakib Apurbo, Zaara Zabeen Arpa, Nazia Karim Khan Oishee

## Overview

This is the main branch for DocLinkr.Commits from individual branches are pushed and merged here after each iteration.

## Features

- **Role Based Authentication:**
  - The app has separate doctor and patient roles.
  - Firebase authentication was used to implement sign in features including Google OAuth.

- **Appointment Scheduling:**
  - Doctors can efficiently manage their appointments through the app.They can create,edit or delete their slots.
  - Patients can conveniently book appointments with their preferred doctors.
    
- **Notifications:**
  - Firebase messaging has been used to handle notifications
  - Patients get notifications for medication reminder and tracker reminder.

- **Emergency Response:**
  - Doctors can respond to emergencies promptly through the application.
  - Patients can request emergencies and get help from the doctor through messaing and video calling.

- **Medical History:**
  - Patients can securely store and access their medical reports within the app.
  - They can also share their reports and any stored files with their appointed doctor.

- **Health Condition Tracking:**
  - Users can keep a daily track of their health condition, enabling better healthcare management.
  - As of now we have implemented a kidney disease tracker.Which consists of :
    - Tracking water intake , urine condition , protein intake , weight measurement , blood pressure.
    - For protein calculation we have used nutritionix api to get protein value for different food.
      
- **Prescribing Medicines:**
  - Doctors can prescribe medicines to the patient during the appointment.
  - The medicine information was taken from a kaggle dataset which contained general medicine information of bangladeshi medicines.

- **Payment:**
  - We used SSLCOMMERZE sandbox to implement payment feature.
  - As of now it is still a dummy feature but in future we can use the original SSLCOMMERZE api and integrate it. 

- **Medication Reminders:**
  - Patients receive timely reminders for medications, ensuring adherence to prescribed treatments.
  - They can also generate PDF of all of their medicines.
  - Patients will be able to view the information of the prescribed medicine such as remaining days , time of intake etc.

- **Virtual Consultation:**
  - Patients can schedule online appointments with doctors, providing flexibility and convenience.
  - We have used AGORA video calling uikit to implement video calling feature.
  - This feature has also not been finalized.As we need to refresh the token each day for the free video calling feature from AGORA.

## Technological Stack

<img src="https://logowik.com/content/uploads/images/flutter5786.jpg" width="100" /><img src="https://cdn4.iconfinder.com/data/icons/google-i-o-2016/512/google_firebase-2-512.png" width="100" /><img src="https://cdn.icon-icons.com/icons2/3053/PNG/512/android_studio_alt_macos_bigsur_icon_190395.png" width="100" />

## Setup

1. **Install Android Studio**
   - Download and install android studio from this [link](https://developer.android.com/studio).

2. **Install Flutter Plugin**
   - Install the flutter plugin from the plugins section inside android studio.
3. **Setup Firebase App**
   - Setup your firebase applciation by creating a new project in firebase console.
   - [This article from medium shows the necessary steps to create a new project in firebase](https://medium.com/firebase-ninja/how-to-add-new-apps-to-a-firebase-project-39b1223d04a3#:~:text=Add%20new%20Firebase%20app%20step,existing%20apps%20grouped%20by%20platform.)
4. **Setup firebase with flutter**
   - [Follow firebase documentation to setup firebase app with flutter](https://firebase.google.com/docs/flutter/setup?platform=android)
6. **Resolve Dependencies**
   - After initialization , runn this command in the flutter console inside android studio :
     ```
     flutter pub get
     ```
7. **Run App**
   - Run the app using this command :
     ```
     flutter run
     ```
## **Installing App On Your Phone**
  - Build the release version of the app
    ```
    flutter build --release
    ```
  - The release version of apk will be located at [root_folder/build/app/outputs/flutter-apk]
  - Copy and install the app on your phone and use it.

## **Downloading The App**
  - The app has not been deployed for mass usage yet.
  - It will soon be uploaded on platforms such as google playstore and galaxy store.
      
## License

This project is licensed under the [MIT License](LICENSE).


