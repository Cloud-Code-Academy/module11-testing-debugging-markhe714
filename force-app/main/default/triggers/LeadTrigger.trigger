/*
 * The `LeadTrigger` is designed to automate certain processes around the Lead object in Salesforce. 
 * This trigger invokes various methods from the `LeadTriggerHandler` class based on different trigger 
 * events like insert and update.
 * 
 * Here's a brief rundown of the operations:
 * 1. BEFORE INSERT and BEFORE UPDATE:
 *    - Normalize the Lead's title for consistency using `handleTitleNormalization` method.
 *    - Score leads based on certain criteria using the `handleAutoLeadScoring` method.
 * 2. AFTER INSERT and AFTER UPDATE:
 *    - Check if the Lead can be auto-converted using the `handleLeadAutoConvert` method.
 *
 * Students should note:
 * - This trigger contains intentional errors that need to be identified and corrected.
 * - It's essential to test the trigger thoroughly after making any changes to ensure its correct functionality.
 * - Debugging skills will be tested, so students should look out for discrepancies between the expected and actual behavior.
 */
trigger LeadTrigger on Lead(before insert, before update, after insert, after update) {
	switch on Trigger.operationType {
		when BEFORE_INSERT {
			LeadTriggerHandler.handleTitleNormalization(Trigger.new);
			LeadTriggerHandler.handleAutoLeadScoring(Trigger.new);
		}
		when BEFORE_UPDATE {
			LeadTriggerHandler.handleTitleNormalization(Trigger.new);
			LeadTriggerHandler.handleAutoLeadScoring(Trigger.new);
		}
		when AFTER_INSERT {
			// LeadTriggerHandler.handleLeadAutoConvert(Trigger.new); (Original Code)

			// Check if lead's Email is populated;
			List<Lead> leadsToAutoConvert = new List<Lead>();
			for (Lead l : Trigger.new) {
				if (l.Email != NULL) {
					leadsToAutoConvert.add(l);
				}
			}
			if (!leadsToAutoConvert.isEmpty()) {
				LeadTriggerHandler.handleLeadAutoConvert(leadsToAutoConvert);				
			}
		}
		when AFTER_UPDATE {
			// LeadTriggerHandler.handleLeadAutoConvert(Trigger.new); (Original Code)

			// Check if lead's Email is updated AND IsConverted != TRUE
			List<Lead> leadsToAutoConvert = new List<Lead>();
			for (Lead l : Trigger.new) {
				if (l.Email != Trigger.oldMap.get(l.Id).Email && l.IsConverted != TRUE) {
					leadsToAutoConvert.add(l);
				}
			}
			if (!leadsToAutoConvert.isEmpty()) {
				LeadTriggerHandler.handleLeadAutoConvert(leadsToAutoConvert);				
			}
		}
	}
}