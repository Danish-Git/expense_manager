# High Level Architecture Overview

The Personal Financial Intelligence application is a mobile-first platform divided into clear functional boundaries.

## Flutter Application
The mobile frontend provides the user interface and coordinates presentation logic. It does not contain direct database access.

## FastAPI Backend
The Python backend exposes REST API endpoints and encapsulates all core business logic and database interactions.

## PostgreSQL
The primary relational database and the sole source of truth for all application state. 

## Firebase Authentication
Manages user identity and issues tokens. The backend relies on this for authenticated requests.

## Firebase Storage
Handles document and file uploads/downloads.

## Firebase Cloud Messaging
Delivers push notifications to the Flutter client.

## Firebase Crashlytics
Provides application stability monitoring and crash reporting for the mobile client.
