# EmailNotificationApp

This project automates email sending by processing email addresses and messages from a CSV file uploaded to S3,using Lambda and SES for efficient delivery.

# Architecture Components

Amazon S3 – Storage bucket where CSV files are uploaded.

Amazon S3 Event Notification – Triggers on file upload (e.g., .csv files).

AWS Lambda – Serverless function that processes the CSV and sends an email.

Amazon SES (Simple Email Service) or SNS (Simple Notification Service) – For sending the email.

<img src="images/EmailApp Architecture.png" alt="Architecture Diagram" width="500"/>
