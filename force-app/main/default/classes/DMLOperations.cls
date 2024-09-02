/**
 * The DMLOperations class serves as a deep dive into Data Manipulation Language (DML) in Apex.
 * It covers fundamental DML operations such as insert, update, upsert, and delete.
 *
 * This class introduces developers to the concept of manipulating Salesforce records in Apex.
 * It discusses how to use DML operations to create, update, and delete records.
 * This class uses standard Salesforce objects like Account, Contact, and Opportunity for demonstration.
 *
 * Topics covered in this class include:
 * - Understanding how to use insert DML operation to create records in Salesforce.
 * - Understanding how to use update and upsert DML operations to update existing records in Salesforce.
 * - Understanding how to use delete DML operation to remove records from Salesforce.
 *
 * Users of this class can expect to gain a strong understanding of DML operations in Apex and
 * be prepared for more advanced topics in Salesforce development.
 *
 * The methods within this class serve as practical examples of different DML operations,
 * allowing developers to learn through practice and examples.
 *
 * @author Mark He
 */


public with sharing class DMLOperations {

    /**
     * Question 1
     * Create a new Account object and inserts it into the database.
     * The Account will have a random name for uniqueness.
     * @return The Id of the newly created Account.
     */
    public static Id insertNewAccount() {
        // Create a new Account instance
        Account newAccount = new Account(Name = 'Random Name');
        // Set some fields on the Account
        newAccount.Type = 'Customer - Direct';
        // Insert the Account into the database
        insert newAccount;
        // Return the Id of the newly created Account
        return newAccount.Id;
    }

    /**
     * Question 2
     * Create a new Account with the specified name and industry provided.
     * @param name The name of the account to be created.
     * @param industry The industry of the account to be created.
     */
    public static void createAccount(String name, String industry) {
        // Create a new Account and set the fields inline
        Account newAccount = new Account(Name = name, Industry = industry);
        // Insert the Account
        insert newAccount;
    }

    
    /**
     * Question 3
     * Create a new Contact and link it to the Account id provided then inserts it into the database.
     * @param accountId The Id of the Account to link the Contact to.
     * @return The Id of the newly created Contact.
     */
    public static Id insertNewContact(Id accountId) {
        // Create a new Contact instance
        Contact newContact = new Contact();
        // Set some fields on the Contact
        newContact.FirstName = 'TestFirst';
        newContact.LastName = 'TestLast';
        // Set the AccountId field to the given accountId
        newContact.AccountId = accountId;
        // Insert the Contact into the database
        insert newContact;
        // Return the Id of the newly created Contact
        return newContact.Id;
    }

    /**
     * Question 4
     * Update the last name of a Contact in the database.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param contactId The Id of the Contact to update.
     * @param newLastName The new last name for the Contact.
     */
    public static void updateContactLastName(Id contactId, String newLastName) {
        // Retrieve the Contact from the database
        // [SELECT Id FROM Contact WHERE Id = :contactId]
        Contact contactToBeUpdated = [SELECT Id FROM Contact WHERE Id = :contactId];
        // Update the Contact's last name
        contactToBeUpdated.LastName = newLastName;
        // Update the Contact in the database
        update contactToBeUpdated;
    }

    /**
     * Question 5
     * Update the stage of an Opportunity in the database.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param oppId The Id of the Opportunity to update.
     * @param newStage The new stage for the Opportunity.
     */
    public static void updateOpportunityStage(Id oppId, String newStage) {
        // Retrieve the Opportunity from the database
        // [SELECT Id FROM Opportunity WHERE Id = :oppId]
        Opportunity oppToBeUpdated = [SELECT Id FROM Opportunity WHERE Id = :oppId];
        // Update the Opportunity's stage
        oppToBeUpdated.StageName = newStage;
        // Update the Opportunity in the database
        update oppToBeUpdated;
    }

    /**
     * Question 6
     * Update the Account's Name and Industry given an Account Id.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param accountId The Id of the account to be updated.
     * @param newName The new name for the account.
     * @param newIndustry The new industry for the account.
     */
    public static void updateAccountFields(Id accountId, String newName, String newIndustry) {
        // Query the account
        // [SELECT Id FROM Account WHERE Id = :accountId]
        Account accountToBeUpdate = [SELECT Id FROM Account WHERE Id = :accountId];
        // Update the Account with the given Id with the new name and industry
        accountToBeUpdate.Name = newName;
        accountToBeUpdate.Industry = newIndustry;
        update accountToBeUpdate;
    }


    /**
     * Question 7
     * Create or updates an Opportunities
     * The Opportunity's Stage is set to Qualification.
     * The Opportunity's Close Date is set to 3 months from today.
     * The Opportunity's Amount is set to 50000.
     * @param list of Opportunities to be changed then upserted.
     */
    public static void upsertOpportunityList(List<Opportunity> opportunities) {
        // Loop through each Opportunity in the list
            // Set the Opportunity's Stage to Qualification
            // Set the Opportunity's Close Date to 3 months from today
            // Set the Opportunity's Amount to 50000
        for (Opportunity opp : opportunities) {
            opp.StageName = 'Qualification';
            opp.CloseDate = System.today().addMonths(3);
            opp.Amount = 50000;
        }
        // Upsert the opportunities List so that records are either updated or created
        upsert opportunities;
    }

    /**
     * Question 8
     * Insert or updates opportunities from list of names.
     * Associate the Opportunities with account that has the name accountName.
     * There should be an Opportunity for each name provided in the list.
     * HINT: The account may or may not exists in the database but is required for opportunity creation. Consider how upsert operation can help with this.
     * @param accountName The name of the Account.
     * @param oppNames The list of Opportunity names.
     */
    public static void upsertOpportunities(String accountName, List<String> oppNames) {
        // Loop through each Opportunity name
        // Create an Opportunity with the given name
        // Add the Opportunity to the list

        // Case 1: Found existing Account with the given accountName -> assign Account Id to accountRecord variable
        // Case 2: Create a new Account record with the given accountName
        List<Account> accountList = [SELECT Id FROM Account WHERE Name = :accountName Limit 1];
        Account accountRecord = new Account();

        if (!accountList.isEmpty()) {
            accountRecord.Id = accountList.get(0).Id;
        } else {
            accountRecord.Name = accountName;
        }
        upsert accountRecord;

        // Case 1a: Some Opportunity records (existingOpportunities) already exist with the given names -> Assign accountRecord.Id to those opportunities
        // Case 1b: Some Opportunity records (newOppRecords) do not exist with the given names -> Create new Opportunity records with the given names -> Assign accountRecord.Id to new opportunities 
        // Case 2: For all the given OppNames, create new opportunities -> Assign accountRecord.Id to those opportunities
        List<Opportunity> existingOpportunities = new List<Opportunity>();
        if (!oppNames.isEmpty()) {
            existingOpportunities = [SELECT Id, Name, AccountId FROM Opportunity WHERE Name IN :oppNames];
        }
        List<String> existingOppNames = new List<String>();
        List<String> newOppNames = new List<String>();
        List<Opportunity> newOppRecords = new List<Opportunity>();
        if (!existingOpportunities.isEmpty()) {
            for (Opportunity currentOppRecord : existingOpportunities) {
                if (currentOppRecord.AccountId != accountRecord.Id) {
                    currentOppRecord.AccountId = accountRecord.Id;
                }
                existingOppNames.add(currentOppRecord.Name);
            }     
            upsert existingOpportunities;
            for (String currentOppName1 : oppNames) {
                if (!existingOppNames.contains(currentOppName1)) {
                    newOppNames.add(currentOppName1);

                }
            }
            for (String newOppName : newOppNames) {
                Opportunity newOppRecord = new Opportunity();
                newOppRecord.AccountId = accountRecord.Id;
                newOppRecord.Name = newOppName;
                newOppRecord.StageName = 'Prospecting';
                newOppRecord.CloseDate = System.today()+30;
                newOppRecords.add(newOppRecord);
            }
            upsert newOppRecords;      
        }else {
            for (String currentOppName2 : oppNames) {
                Opportunity newOppRecord = new Opportunity();
                newOppRecord.AccountId = accountRecord.Id;
                newOppRecord.Name = currentOppName2;
                newOppRecord.StageName = 'Prospecting';
                newOppRecord.CloseDate = System.today()+30;
                newOppRecords.add(newOppRecord);
            }
            upsert newOppRecords;
        }
    }
    
    /**
     * Question 9
	 * Upserts an Account with the specified name.
	 * If an Account with the given name already exists, update the description to "Updated Account".
	 * If no such Account exists, it creates a new one and sets the description to "New Account".
	 * @param accountName The name of the Account to be upserted.
	 * @return The Account that was upserted.
	 */
	public static Account upsertAccount(String accountName) {
		// Query for the Account
		List<Account> accounts = [SELECT Id FROM Account WHERE Name = :accountName];
        Account accountUpsert = new Account();
		// if the Account exists, update the description
        if (!accounts.isEmpty()) {
            accountUpsert = accounts.get(0);
            accountUpsert.Description = 'Updated Account';
        }
		// otherwise, create a new Account and set the description
        else{
            accountUpsert.Name = accountName;
            accountUpsert.Description = 'New Account';
        }
		// Upsert the Account
        upsert accountUpsert;
        return accountUpsert;
        }


    /**
     * Question 10
	 * Manage the association between Contacts and Accounts
	 * Ensure that for each Contact in the provided list, there is a corresponding Account Name that matches the Contact's last name.
	 * If such an Account does not exist, the method creates it; if it does, the method ensures the Contact is associated with it. (Hint: use previous upsertAccount method - this may cause bad practices but for learning purposes it's okay.)
     * Example Contact.LastName = 'Doe' Link to Account.Name = 'Doe' 
     * Example Contact.LastName = 'Jane' Link to Account.Name = 'Jane'
	 * @param contactsToUpsert List of Contacts to be upserted and linked to accounts.
	 */
	public static void upsertAccountsWithContacts(List<Contact> contactsToUpsert) {
		// Loop through each Contact
		// Extract the Account Name from Contact's LastName
		// Get the account based on the name or create one if it doesn't exist
		// Link the Contact to its Account using the Account Id
		// Upsert the Contacts

        List<String> contactLastNames = new List<String>();
        for (Contact currentContact : contactsToUpsert) {
            contactLastNames.add(currentContact.LastName);
        }

        List<Account> existingAccountList = [SELECT Id, Name FROM Account WHERE Name in :contactLastNames];

        List<Account> newAccountList = new List<Account>();

        List<Contact> contactsNeedsAccountIdUpdated = new List<Contact>();

        List<Contact> contactsNeedsNewAccount = new List<Contact>();


        // Create a list of of Contacts that need to have Account Id updated. 
        if (!existingAccountList.isEmpty()) {
            for (Account currentAccount1 : existingAccountList) {
                for (Contact currentContact1 : contactsToUpsert) {
                    if ((currentContact1.LastName == currentAccount1.Name)) {
                        currentContact1.AccountId = currentAccount1.Id;
                        contactsNeedsAccountIdUpdated.add(currentContact1);
                        break;
                    }
                }
            }
        }

        // Update Contacts' Account Id with existing accounts. 
        // Create a list of Contacts that need to a new account created.
        if (!contactsNeedsAccountIdUpdated.isEmpty()) {
            upsert contactsNeedsAccountIdUpdated;
            for (Contact currentContact2 : contactsToUpsert) {
                if (!contactsNeedsAccountIdUpdated.contains(currentContact2)) {
                    contactsNeedsNewAccount.add(currentContact2);
                }
            }
        }
        // Create new Accounts and assign them to Contacts
        if (!contactsNeedsNewAccount.isEmpty()) {
            for (Contact currentContact3 : contactsNeedsNewAccount) {
                Account newAccount = new Account();
                newAccount.Name = currentContact3.LastName;
                newAccount.Id = Null;
                newAccountList.add(newAccount);
            }
            insert newAccountList;

            for (Contact currentContact4 : contactsNeedsNewAccount) {
                for (Account currentAccount4 : newAccountList) {
                    if (currentAccount4.Name == currentContact4.LastName) {
                        currentContact4.AccountId = currentAccount4.Id;
                    }
                }
            }
            upsert contactsNeedsNewAccount;
        }
	}

    /**
     * Question 11
     * Insert a list of Leads and then deletes them.
     * @param leadNames The list of Lead names to be inserted.
     */
    public static void insertAndDeleteLeads(List<String> leadNames) {
        List<Lead> leadsList = new List<Lead>();
        // Loop through each Lead name
        for (String currentLeadName : leadNames) {
            Lead leadRecord = new Lead();
            leadRecord.LastName = currentLeadName;
            leadRecord.Company = currentLeadName + ' Company';
            leadsList.add(leadRecord);
        }
        // Insert the Leads
        insert leadsList;
        // Delete the Leads
        delete leadsList;
    }


    /**
     * Question 12
     * Dynamically create the number of cases and relate it to the accountId, then deletes them.
     * @param accountId The account for which the cases will be created and then deleted.
     * @param numOfCases The number of cases to create.
     */
    public static void createAndDeleteCases(String accountId, Integer numOfCases) {
        List<Case> caseList = new List<Case>();
        // Insert the cases
        for (Integer i = 1; i < numOfCases; i++) {
            Case caseRecord = new Case(AccountId = accountId);
            caseList.add(caseRecord);
        }
        insert caseList;
        // Delete the cases
        delete caseList;
    }
}