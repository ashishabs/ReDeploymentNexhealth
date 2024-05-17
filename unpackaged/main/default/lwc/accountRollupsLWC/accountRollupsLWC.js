import { LightningElement, wire,track,api} from 'lwc';
import fetchHierarchyDetails from '@salesforce/apex/AccountRollupsLwcController.fetchHierarchyDetails';

export default class AccountRollupsLWC extends LightningElement {

    @track RiskLocationCount;
    @track OpenSupportCasesCount;
    @track PracticeLocationCount;
    @track CurrentHiearchyLevel
    @api recordId

    @wire(fetchHierarchyDetails, {recordId: '$recordId'})
    wiredHierarchyDetails({ error, data }) {
        if (data) {
            this.RiskLocationCount = data.RiskLocationCountApex;
            this.OpenSupportCasesCount = data.OpenSupportCasesCountApex;
            this.PracticeLocationCount = data.PracticeLocationCountApex;
            this.CurrentHiearchyLevel = data.CurrentHiearchyTierLevel;
            this.error = undefined;
        } else if (error) {
            this.error = error;
        }
    }

    
  
}