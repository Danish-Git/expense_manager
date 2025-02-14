# Expense Manager



## Index of the documentation

1.  [Introduction](#introduction)
2.  [Code Architecture](#code-architecture)
3.  [Database Structure](#database-structure)
4.  [App Flow Chart](#app-flow-chart)
5.  [Installation](#installation)
6.  [Features](#features-of-the-application)
7.  [Unit and Widget Test Cases](#unit-and-widget-test-cases)

##
## Introduction

Is an application to keep track of your daily expenses. It also have multiple languages support to make it more user friendly

##
## Code Architecture

Clean architecture revolves around separating code into layers, each with a distinct responsibility. The primary layers include:

1.  **Application Layer**: The application layer contains the application's core business logic. It serves as an intermediary between the presentation and domain layers, coordinating data flow and enforcing business rules.

2.  **Data Layer**: This layer manages data storage, retrieval, and interactions with external APIs. It encompasses repositories, data sources, and API clients.

3.  **Domain Layer**: The domain layer defines the fundamental business logic and domain models of the application. It remains independent of specific UI frameworks or databases, ensuring high reusability and testability.
  
4.  **Presentation Layer**: This layer concerns itself with the user interface and interactions. It includes global widgets, screens, and controllers responsible for user input and data display.


<img width="668" alt="Screenshot 2024-07-09 at 8 34 10 PM" src="https://github.com/Danish-Git/expense_manager/assets/79436114/582df4ac-28a1-41d3-a8f2-b19622f3599d">

##
## Database Structure

The application uses SQLite for data storage. Below is the structure of the database:

<img width="727" alt="Screenshot 2024-07-09 at 9 09 36 PM" src="https://github.com/Danish-Git/expense_manager/assets/79436114/e21577a2-1775-41a9-a754-6de0511eae28">

##
## App Flow Chart

Below is a flow chart illustrating the app's workflow:

![app-flow-chart](https://github.com/Danish-Git/expense_manager/assets/79436114/6c2dcf20-a0a0-4f0c-a156-f5621d2e6ab9)


##
## Installation

This project is based on Flutter framework.

For help getting started with Flutter setup, view the [online documentation](https://docs.flutter.dev/get-started/install), which offers tutorials, guidance on mobile development.

This project is based latest configuration (for now) of flutter framework. Please refer to the attached flutter doctor summery


    apple@ expense_manager % flutter doctor  
    Doctor summary (to see all details, run flutter doctor -v):  
    [✓] Flutter (Channel stable, 3.22.2, on macOS 14.4.1)  
    [✓] Android toolchain - develop for Android devices (Android SDK version 34.0.0)  
    [✓] Xcode - develop for iOS and macOS (Xcode 15.4)  
    [✓] Chrome - develop for the web  
    [✓] Android Studio (version 2024.1,1)  
    [✓] VS Code (version 1.90.2)  
    [✓] Network resources  
      
    • No issues found!
You may proceed with clonnong the project and making project up and running you may follow the following steps

-   **Navigate to the Project Directory:**
    -   Once the cloning process is complete, navigate into the project directory: `cd <project_directory>`
    -   Replace `<project_directory>` with the name of the directory created during cloning.
-   **Check Flutter Dependencies:**
    -   Ensure that the Flutter dependencies are up to date. Run: `flutter pub get`

-   **Open in IDE:**
    -   Open the project in your preferred IDE or code editor (e.g., VS Code, Android Studio).

-   **Run the Project:**
    -   Connect an emulator/device or use an existing one that is running.
    -   Run the Flutter project using:  `flutter run`
    -   This command builds and deploys the Flutter project on your connected device or emulator.

-   **Verify Setup:**
    -   Once the project builds successfully, you should see the app running on your emulator/device.
 

##
## Features of The Application

### 1. Responsive UI

This application has fully responsive user interface, ensuring a seamless experience across a wide range of devices, from smartphones and tablets.

- #### *Expense History Screen*
| Large Tablet | Small Tablet | Mobile |
|--|--|--|
| ![Screenshot_1720529777](https://github.com/Danish-Git/expense_manager/assets/79436114/6cbf3687-149d-40ac-a9ec-3b1e0145eafa) |  ![Screenshot_1720529762](https://github.com/Danish-Git/expense_manager/assets/79436114/1bfb8ec3-9eb0-4bd2-bcfe-26e95819f264)  |  ![Screenshot_1720529800](https://github.com/Danish-Git/expense_manager/assets/79436114/4e9d118c-fda4-4ec0-bce6-c9dc5e87cb74)  |

- #### *Add / Edit Expense Form*
| Large Tablet | Small Tablet | Mobile |
|--|--|--|
| ![Screenshot_1720526239](https://github.com/Danish-Git/expense_manager/assets/79436114/e1076f60-8c16-4fa0-9c1a-a1887c2bfac7) | ![Screenshot_1720526463](https://github.com/Danish-Git/expense_manager/assets/79436114/e290a5fe-d088-466e-9c3e-2c218e84c7de) | ![Screenshot_1720526243](https://github.com/Danish-Git/expense_manager/assets/79436114/899b92f6-95bf-4205-86bf-883385667c63) |

- #### *Settings Screen*
| Large Tablet | Small Tablet | Mobile |
|--|--|--|
| ![Screenshot_1720532888](https://github.com/Danish-Git/expense_manager/assets/79436114/d473911a-5bec-47b5-9c7e-a625cbfbde24) | ![Screenshot_1720526490](https://github.com/Danish-Git/expense_manager/assets/79436114/38a5d2c7-18d5-4aa5-b784-80ee9d612463) | ![Screenshot_1720526303](https://github.com/Danish-Git/expense_manager/assets/79436114/5b37467b-bc95-4757-8bd9-438f722dd4e5) |


#### 2. Multi-language Support

This application supports English and Urdu languages. This feature allows users to choose their preferred language, enhancing usability and accessibility.

- #### *Expense History Screen (Urdu)*
| Large Tablet | Small Tablet | Mobile |
|--|--|--|
| ![Screenshot_1720533909](https://github.com/Danish-Git/expense_manager/assets/79436114/42dd60e2-f550-4d97-91da-43205bb25bfe) | ![Screenshot_1720533978](https://github.com/Danish-Git/expense_manager/assets/79436114/1662c169-d627-43b3-82de-a1b86358d465) | ![Screenshot_1720534016](https://github.com/Danish-Git/expense_manager/assets/79436114/0ace565f-a08f-45b6-84ad-a60a9409c1a3) |

- #### *Add / Edit Expense Form (Urdu)*
| Large Tablet | Small Tablet | Mobile |
|--|--|--|
| ![Screenshot_1720533960](https://github.com/Danish-Git/expense_manager/assets/79436114/9d00cab3-d097-4cce-9c2d-8d8a7952b81f) | ![Screenshot_1720533986](https://github.com/Danish-Git/expense_manager/assets/79436114/df6ec750-c0f1-4432-b570-7ffa480334d0) | ![Screenshot_1720534025](https://github.com/Danish-Git/expense_manager/assets/79436114/74fd2849-760d-4059-9d63-ed4ff25f6cb0) |

- #### *Settings Screen (Urdu)*
| Large Tablet | Small Tablet | Mobile |
|--|--|--|
| ![Screenshot_1720533869](https://github.com/Danish-Git/expense_manager/assets/79436114/6e837275-7069-4309-ba16-61eac8450e89) | ![Screenshot_1720526497](https://github.com/Danish-Git/expense_manager/assets/79436114/9ef85c89-2131-495d-aca4-c3769c0d9423) | ![Screenshot_1720526549](https://github.com/Danish-Git/expense_manager/assets/79436114/75205c41-6f60-4325-8703-55ec2e8b8289) |


### 3. Reminder to Add Expense

This application includes a feature that allows users to set reminders to add their expenses. This feature ensures that users stay on top of their financial tracking by sending notifications at the scheduled times.

- #### *Notification*
| Tablet | Mobile |
|--|--|
| ![Screenshot_1720526440](https://github.com/Danish-Git/expense_manager/assets/79436114/fe827874-6086-4399-9895-139a8ab05400) | ![Screenshot_1720526367](https://github.com/Danish-Git/expense_manager/assets/79436114/86a7d8ad-a011-4ec0-99a6-77ad259b4fd0) |


##
## Unit and Widget Test Cases

Ensuring the reliability and correctness of our application is a top priority. We have implemented comprehensive unit and widget test cases to verify that our application behaves as expected.

Key aspects of our testing strategy include:

### 1. Unit Tests: 

Focused on testing individual functions, methods, and classes to ensure they work correctly in isolation. Example:

<img width="1081" alt="Screenshot 2024-07-10 at 1 17 13 AM" src="https://github.com/Danish-Git/expense_manager/assets/79436114/bc1c0e8e-effa-40a6-9eeb-da2292292928">



### 2. Widget Tests: 

Focused on testing the UI components and their interactions. These tests ensure that widgets render correctly and respond to user input as expected. Example:

<img width="1081" alt="Screenshot 2024-07-10 at 1 21 21 AM" src="https://github.com/Danish-Git/expense_manager/assets/79436114/7519ceba-92fa-42d1-8d4a-c81b43c46e85">

#

There are a total of 56 test cases, combining both unit and widget tests. To run the tests, use the following command: `flutter test`
