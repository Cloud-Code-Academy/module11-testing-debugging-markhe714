@isTest
private class LeadTriggerhandlerTest {

    @isTest
    static void handleTitleNormalizationTest() {

        List<String> keyTitles = new List<String> {
            'vp', 'v.p.', 'vice president',
            'mgr', 'manage', 'head of department',
            'exec', 'chief', 'head',
            'assist', 'deputy', 'jr'
        };

        //Test Inserts
        List<Lead> leadToBeCreated = new List<Lead>();

        Integer index = 1;

        for (String keyTitle : keyTitles) {
            Lead currentLead = new Lead ();
            currentLead.Company = 'Company ' + index;
            currentLead.LastName = 'LastName ' + index;
            currentLead.FirstName = 'FirstName ' + index;
            currentLead.Title = keyTitle;
            leadToBeCreated.add(currentLead);
            index++;
        }

        insert leadToBeCreated;

        Set<Id> newLeadIDs1 = new Set<Id>();

        for (Lead l : leadToBeCreated) {
            newLeadIDs1.add(l.Id);
        }

        List<Lead> newLeads1 = [SELECT Id, Company, Title FROM Lead WHERE Id IN :newLeadIDs1];

        for (Lead l : newLeads1){
            if (l.Company == 'Company 1' || l.Company == 'Company 2' || l.Company == 'Company 3') {
                Assert.areEqual('Vice President', l.Title, 'New Title Should be Vice President');
            } else if (l.Company == 'Company 4' || l.Company == 'Company 5' || l.Company == 'Company 6') {
                Assert.areEqual('Manager', l.Title, 'New Title Should be Manager');
            } else if (l.Company == 'Company 7' || l.Company == 'Company 8' || l.Company == 'Company 9') {
                Assert.areEqual('Executive', l.Title, 'New Title Should be Executive');
            } else {
                Assert.areEqual('Assistant', l.Title, 'New Title Should be Assistant');
            }
        }


        //Test Updates
        Integer newIndex = 101;
        Map<Integer, String> newIndexToKeyTitle = new Map<Integer, String>();
        List<Lead> newLeads2 = New List<Lead>();

        for (String keyTitle : keyTitles) {
            newIndexToKeyTitle.put(newIndex, keyTitle);
            Lead currentLead = new Lead();
            currentLead.Company = 'Company ' + newIndex;
            currentLead.LastName = 'LastName ' + newIndex;
            currentLead.FirstName = 'FirstName ' + newIndex;
            currentLead.Title = 'Random Number ' + newIndex;
            newLeads2.add(currentLead);
            newIndex++;
        }

        insert newLeads2;

        Set<Id> newLeadIDs2 =  new Set<Id>();

        for (Lead l : newLeads2) {
            newLeadIDs2.add(l.Id);
        }

        List<Lead> leadsToUpdateNewTitle = [SELECT Id, Company, Title FROM Lead WHERE Id IN :newLeadIDs2];

        for (Lead l : leadsToUpdateNewTitle) {
            for (Integer i = 101; i < 113; i++) {
                if (l.Company == 'Company ' + i) {
                    l.Title = newIndexToKeyTitle.get(i);
                }
            }
        }

        update leadsToUpdateNewTitle;

        List<Lead> leadsAfterUpdate = [SELECT Id, Company, Title FROM Lead WHERE Id IN :newLeadIDs2];

        for (Lead l : leadsAfterUpdate) {
            if (l.Company == 'Company 101' || l.Company == 'Company 102' || l.Company == 'Company 103') {
                Assert.areEqual('Vice President', l.Title, 'New Title Should be Vice President');
            } else if (l.Company == 'Company 104' || l.Company == 'Company 105' || l.Company == 'Company 106') {
                Assert.areEqual('Manager', l.Title, 'New Title Should be Manager');
            } else if (l.Company == 'Company 107' || l.Company == 'Company 108' || l.Company == 'Company 109') {
                Assert.areEqual('Executive', l.Title, 'New Title Should be Executive');
            } else {
                Assert.areEqual('Assistant', l.Title, 'New Title Should be Assistant');
            }
        }


        //Test Null Title 
        Lead leadWithoutTitle = new Lead (Company = 'TestCompanyWithoutTitle', FirstName = 'FirstNameWithoutTitle', LastName = 'LastNameWithoutTitle');
        insert leadWithoutTitle;
        Lead leadAfterInsert = [SELECT Id, Title FROM Lead WHERE Id = :leadWithoutTitle.Id];
        Assert.areEqual(NULL, leadAfterInsert.Title, 'Title should be NUll');


        //Test Negative cases
        Lead leadWithNegativeTitle = new Lead (Company = 'TestCompanyWithNegativeTitle', FirstName = 'FirstNameWithNegativeTitle', LastName = 'LastNameWithNegativeTitle', Title = 'Negative Title');
        insert leadWithNegativeTitle;
        Lead leadAfterInsertNegative = [SELECT Id, Title FROM Lead WHERE Id = :leadWithNegativeTitle.Id];
        Assert.areEqual('Negative Title', leadAfterInsertNegative.Title, 'Title should be Negative Title');
    }


    @isTest
    static void handleAutoLeadScoringTest() {
        //TEST: Score = 3+5+10 (Insert and Update)
        Lead newLead1 = New Lead(
            Company = 'Company 1', LastName = 'LastName 1', 
            LeadSource = 'Web', Email = 'test1@email.com',
            Phone = '1231231234', Industry = 'Technology'
            );
        insert newLead1;
        Lead newLead1AfterInsert = [SELECT Id, Lead_Score__c FROM Lead WHERE Id = :newLead1.Id];
        Assert.areEqual(18, newLead1AfterInsert.Lead_Score__c, 'The Lead Score should be 18');

        newLead1AfterInsert.LeadSource = 'Other';
        newLead1AfterInsert.Email = '';
        newLead1AfterInsert.Phone = '';
        newLead1AfterInsert.Industry = 'Other';
        update newLead1AfterInsert;
        Lead newLead1AferUpdate1 = [SELECT Id, Lead_Score__c FROM Lead WHERE Id = :newLead1.Id];
        Assert.areEqual(0, newLead1AferUpdate1.Lead_Score__c, 'The Lead Score should be 0');

        newLead1AferUpdate1.LeadSource = 'Web';
        newLead1AferUpdate1.Email = 'test1@email.com';
        newLead1AferUpdate1.Phone = '1231231234';
        newLead1AferUpdate1.Industry = 'Technology';
        update newLead1AferUpdate1;
        Lead newLead1AferUpdate2 = [SELECT Id, Lead_Score__c FROM Lead WHERE Id = :newLead1.Id];
        Assert.areEqual(18, newLead1AferUpdate2.Lead_Score__c, 'The Lead Score should be 18');



        //TEST: Score = 5+10 (Insert and Update)
        Lead newLead7 = New Lead(
            Company = 'Company 7', LastName = 'LastName 7', 
            Phone = '1231231234', Industry = 'Technology'
            );
        insert newLead7;
        Lead newLead7AfterInsert = [SELECT Id, Lead_Score__c FROM Lead WHERE Id = :newLead7.Id];
        Assert.areEqual(15, newLead7AfterInsert.Lead_Score__c, 'The Lead Score should be 15');

        newLead7AfterInsert.Phone = '';
        newLead7AfterInsert.Industry = 'Other';
        update newLead7AfterInsert;
        Lead newLead7AferUpdate1 = [SELECT Id, Lead_Score__c FROM Lead WHERE Id = :newLead7.Id];
        Assert.areEqual(0, newLead7AferUpdate1.Lead_Score__c, 'The Lead Score should be 0');

        newLead7AferUpdate1.Phone = '1231231234';
        newLead7AferUpdate1.Industry = 'Technology';
        update newLead7AferUpdate1;
        Lead newLead7AferUpdate2 = [SELECT Id, Lead_Score__c FROM Lead WHERE Id = :newLead7.Id];
        Assert.areEqual(15, newLead7AferUpdate2.Lead_Score__c, 'The Lead Score should be 15');

        //TEST: Score = 3+10 (Insert and Update)
        Lead newLead8 = New Lead(
            Company = 'Company 8', LastName = 'LastName 8', 
            LeadSource = 'Web', Email = 'test1@email.com',
            Industry = 'Technology'
            );
        insert newLead8;
        Lead newLead8AfterInsert = [SELECT Id, Lead_Score__c FROM Lead WHERE Id = :newLead8.Id];
        Assert.areEqual(13, newLead8AfterInsert.Lead_Score__c, 'The Lead Score should be 13');

        newLead8AfterInsert.LeadSource = 'Other';
        newLead8AfterInsert.Email = '';
        newLead8AfterInsert.Industry = 'Other';
        update newLead8AfterInsert;
        Lead newLead8AferUpdate1 = [SELECT Id, Lead_Score__c FROM Lead WHERE Id = :newLead8.Id];
        Assert.areEqual(0, newLead8AferUpdate1.Lead_Score__c, 'The Lead Score should be 0');

        newLead8AferUpdate1.LeadSource = 'Web';
        newLead8AferUpdate1.Email = 'test1@email.com';
        newLead8AferUpdate1.Industry = 'Technology';
        update newLead8AferUpdate1;
        Lead newLead8AferUpdate2 = [SELECT Id, Lead_Score__c FROM Lead WHERE Id = :newLead8.Id];
        Assert.areEqual(13, newLead8AferUpdate2.Lead_Score__c, 'The Lead Score should be 13');

        //TEST: Score = 3+5 (Insert and Update)
        Lead newLead2 = New Lead(
            Company = 'Company 2', LastName = 'LastName 2', 
            LeadSource = 'Web', Email = 'test1@email.com',
            Phone = '1231231234'
            );
        insert newLead2;
        Lead newLead2AfterInsert = [SELECT Id, Lead_Score__c FROM Lead WHERE Id = :newLead2.Id];
        Assert.areEqual(8, newLead2AfterInsert.Lead_Score__c, 'The Lead Score should be 8');

        newLead2AfterInsert.LeadSource = 'Other';
        newLead2AfterInsert.Email = '';
        newLead2AfterInsert.Phone = '';
        update newLead2AfterInsert;
        Lead newLead2AferUpdate1 = [SELECT Id, Lead_Score__c FROM Lead WHERE Id = :newLead2.Id];
        Assert.areEqual(0, newLead2AferUpdate1.Lead_Score__c, 'The Lead Score should be 0');

        newLead2AferUpdate1.LeadSource = 'Web';
        newLead2AferUpdate1.Email = 'test1@email.com';
        newLead2AferUpdate1.Phone = '1231231234';
        update newLead2AferUpdate1;
        Lead newLead2AferUpdate2 = [SELECT Id, Lead_Score__c FROM Lead WHERE Id = :newLead2.Id];
        Assert.areEqual(8, newLead2AferUpdate2.Lead_Score__c, 'The Lead Score should be 8');

        //TEST: Score = 3 (Insert and Update)
        Lead newLead3 = New Lead(
            Company = 'Company 3', LastName = 'LastName 3', 
            LeadSource = 'Web', Email = 'test1@email.com'
            );
        insert newLead3;
        Lead newLead3AfterInsert = [SELECT Id, Lead_Score__c FROM Lead WHERE Id = :newLead3.Id];
        Assert.areEqual(3, newLead3AfterInsert.Lead_Score__c, 'The Lead Score should be 3');

        newLead3AfterInsert.LeadSource = 'Other';
        newLead3AfterInsert.Email = '';
        update newLead3AfterInsert;
        Lead newLead3AferUpdate1 = [SELECT Id, Lead_Score__c FROM Lead WHERE Id = :newLead3.Id];
        Assert.areEqual(0, newLead3AferUpdate1.Lead_Score__c, 'The Lead Score should be 0');

        newLead3AferUpdate1.LeadSource = 'Web';
        newLead3AferUpdate1.Email = 'test1@email.com';
        update newLead3AferUpdate1;
        Lead newLead3AferUpdate2 = [SELECT Id, Lead_Score__c FROM Lead WHERE Id = :newLead3.Id];
        Assert.areEqual(3, newLead3AferUpdate2.Lead_Score__c, 'The Lead Score should be 3');

        //TEST: Score = 5 (Insert and Update)
        Lead newLead4 = New Lead(
            Company = 'Company 4', LastName = 'LastName 4', 
            Phone = '1231231234'
            );
        insert newLead4;
        Lead newLead4AfterInsert = [SELECT Id, Lead_Score__c FROM Lead WHERE Id = :newLead4.Id];
        Assert.areEqual(5, newLead4AfterInsert.Lead_Score__c, 'The Lead Score should be 5');


        newLead4AfterInsert.Phone = '';
        update newLead4AfterInsert;
        Lead newLead4AferUpdate1 = [SELECT Id, Lead_Score__c FROM Lead WHERE Id = :newLead4.Id];
        Assert.areEqual(0, newLead4AferUpdate1.Lead_Score__c, 'The Lead Score should be 0');


        newLead4AferUpdate1.Phone = '1231231234';
        update newLead4AferUpdate1;
        Lead newLead4AferUpdate2 = [SELECT Id, Lead_Score__c FROM Lead WHERE Id = :newLead4.Id];
        Assert.areEqual(5, newLead4AferUpdate2.Lead_Score__c, 'The Lead Score should be 5');

        //TEST: Score = 10 (Insert and Update)
        Lead newLead5 = New Lead(
            Company = 'Company 5', LastName = 'LastName 5', 
            Industry = 'Technology'
            );
        insert newLead5;
        Lead newLead5AfterInsert = [SELECT Id, Lead_Score__c FROM Lead WHERE Id = :newLead5.Id];
        Assert.areEqual(10, newLead5AfterInsert.Lead_Score__c, 'The Lead Score should be 10');

        newLead5AfterInsert.Industry = 'Other';
        update newLead5AfterInsert;
        Lead newLead5AferUpdate1 = [SELECT Id, Lead_Score__c FROM Lead WHERE Id = :newLead5.Id];
        Assert.areEqual(0, newLead5AferUpdate1.Lead_Score__c, 'The Lead Score should be 0');

        newLead5AferUpdate1.Industry = 'Technology';
        update newLead5AferUpdate1;
        Lead newLead5AferUpdate2 = [SELECT Id, Lead_Score__c FROM Lead WHERE Id = :newLead5.Id];
        Assert.areEqual(10, newLead5AferUpdate2.Lead_Score__c, 'The Lead Score should be 10');

        //TEST: Score = 0 (Insert)
        Lead newLead6 = New Lead(
            Company = 'Company 6', LastName = 'LastName 6', 
            LeadSource = 'Web'
            );
        insert newLead6;
        Lead newLead6AfterInsert = [SELECT Id, Lead_Score__c FROM Lead WHERE Id = :newLead6.Id];
        Assert.areEqual(0, newLead6AfterInsert.Lead_Score__c, 'The Lead Score should be 0');
    }    

    @isTest
    static void handleLeadAutoConvertTest() {
        //Create test account and contacts
        Account account = new Account(Name = 'Test Account');
        insert account;
        Contact contact1 = new Contact(AccountId = account.Id, LastName = 'LastName 1', Email = 'contact1@email.com');
        insert contact1;
        Contact contact2A = new Contact(AccountId = account.Id, LastName = 'LastName 2A', Email = 'contact2@email.com'); 
        insert contact2A;
        Contact contact2B = new Contact(AccountId = account.Id, LastName = 'LastName 2B', Email = 'contact2@email.com');
        insert contact2B;

        //Lead with 1 Matched Contact (Insert)
        Lead lead1 = new Lead(Company = 'Lead Company 1', LastName = 'LastName 1', Email = 'contact1@email.com');
        insert lead1;
        Lead convertedLead1 = [SELECT Id, IsConverted, ConvertedContactId FROM Lead WHERE Id = :lead1.Id];
        Assert.areEqual(TRUE, convertedLead1.IsConverted, 'This lead should have been converted');
        Assert.areEqual(contact1.Id, convertedLead1.ConvertedContactId, 'This lead should have been converted to contact1');

        //Lead with 2 Matched Contacts (Insert)
        Lead lead2 = new Lead(Company = 'Lead Company 2', LastName = 'LastName 2', Email = 'contact2@email.com');
        insert lead2;
        Lead notConvertedLead2 = [SELECT Id, IsConverted, ConvertedContactId FROM Lead WHERE Id = :lead2.Id];
        Assert.areEqual(FALSE, notConvertedLead2.IsConverted, 'This lead should not be converted since there are two matching contacts with the same email.');
    
        //Lead with 0 Matched Contacts (Insert)
        Lead lead3 = new Lead(Company = 'Lead Company 3', LastName = 'LastName 3', Email = 'contact3@email.com');
        insert lead3;
        Lead notConvertedLead3 = [SELECT Id, IsConverted, ConvertedContactId FROM Lead WHERE Id = :lead3.Id];
        Assert.areEqual(FALSE, notConvertedLead3.IsConverted, 'This lead should not be converted since there are no matching contacts with the same email.');
    
        //Lead with 1 Matched Contact (Update)
        Lead lead4 = new Lead(Company = 'Lead Company 4', LastName = 'LastName 4', Email = 'contact4@email.com');
        insert lead4;

        lead4.Email = 'contact1@email.com';
        update lead4;

        Lead convertedLead4 = [SELECT Id, IsConverted, ConvertedContactId FROM Lead WHERE Id = :lead4.Id];
        Assert.areEqual(TRUE, convertedLead4.IsConverted, 'This lead should have been converted');
        Assert.areEqual(contact1.Id, convertedLead4.ConvertedContactId, 'This lead should have been converted to contact1');

        //Lead with 2 Matched Contact (Update)
        Lead lead5 = new Lead(Company = 'Lead Company 5', LastName = 'LastName 5', Email = 'contact5@email.com');
        insert lead5;

        lead5.Email = 'contact2@email.com';
        update lead5;

        Lead notConvertedLead5 = [SELECT Id, IsConverted, ConvertedContactId FROM Lead WHERE Id = :lead5.Id];
        Assert.areEqual(FALSE, notConvertedLead5.IsConverted, 'This lead should not be converted since there are two matching contacts with the same email.');
    
        //Lead with 0 Matched Contact (Update)
        Lead lead6 = new Lead(Company = 'Lead Company 6', LastName = 'LastName 6', Email = 'contact6@email.com');
        insert lead6;

        lead6.Email = 'contact7@email.com';
        update lead6;

        Lead notConvertedLead6 = [SELECT Id, IsConverted, ConvertedContactId FROM Lead WHERE Id = :lead6.Id];
        Assert.areEqual(FALSE, notConvertedLead6.IsConverted, 'This lead should not be converted since there are no matching contacts with the same email.');   
    }

}