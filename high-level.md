## High Level question

### Case: Secure Database Access

The first part of this question is around end-to-end auditing of the database processes. 

This can be achieved in two ways when using Azure Database. 

Firstly enabling Postgres native auditing capabilities through `pgAudit`. Which will allow us to capture all DB operations.

Then leveraging`Azure Monitor` will allow you collect those db operation logs, Azure Monitor can be configured to trigger alerts based on specific audit log entries.
You are able to store and manage audit logs in a Log Analytics workspace within Azure Monitor.


The second option is less Azure specific,

It entails configuring Debezium to stream the database changes to a Kafka topic.
This will allow us to capture all changes to the database in real-time.
We can then use Kafka Connect to stream the data to a sink, such as a data lake.

---

The second part of the question is around rotating database user passwords every 30 days.

I would suggest making use of Azure AD to manage the database users. This will allow us to enforce password policies around password rotation and strength.

Internal users and applications authenticate via Azure AD. Azure AD ensures that user management is centralized, this allows data security personnel to approve user requests as well as provides ease-of-management.  

Utilize Azure Key Vault.
 - Store database credentials for application accounts securely in Azure Key Vault. This centralizes the management of secrets and allows secure access to them by applications.

Utilize Azure Logic Apps
 - Implement a scheduled Logic App to automate the password rotation process every 30 days, or when application account passwords are about to expire.

The Logic App can be configured to:
- Generate a new strong password.
- Update the password in Azure Database for PostgreSQL.
- Update the credentials stored in Azure Key Vault.
- Notify relevant stakeholders about the password change.


Link to diagram: https://whimsical.com/cfp-interview-question-DkrB63UN3MYe9KUjtxCmPY

## Considerations:

### Zero Downtime

Ensure that password rotation and user creation processes are non-intrusive and do not affect the availability of the database services.
Utilize connection pooling and retry logic inside the applications to handle authentication changes gracefully.

### Tools used
I wanted to stick to solutions that were out of the box solutions, handily Azure provides a lot of this functionality through various resources.

Azure Active Directory is used for user management, and can be used to enforce password policies, such as password rotation.

Azure Key Vault is great for sharing secrets securely to authenticated applications, and as such should definitely be used for distributing database credentials.

Azure Logic Apps are great for automating processes, on events or on schedules, and can be used to automate the password rotation process.

Azure Monitor can be used to collect and analyze logs, and can be used to trigger alerts based on specific audit log entries.

Debezium + Kafka can be used to stream database changes to a sink, such as a data lake, for further analysis.

