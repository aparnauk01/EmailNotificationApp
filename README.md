# EmailNotificationApp

This website showcases my experiance, home projects and my learnings. This Project is used to host a portfolio static website using S3 Bucket ,Cloudfront and Route53.Secured it using AWS WAF.

# Architecture Components

Amazon S3 – Storage bucket where CSV files are uploaded.

Amazon S3 Event Notification – Triggers on file upload (e.g., .csv files).

AWS Lambda – Serverless function that processes the CSV and sends an email.

Amazon SES (Simple Email Service) or SNS (Simple Notification Service) – For sending the email.

<img src="EmailApp Architecture.png" alt="Architecture Diagram" width="500"/>
