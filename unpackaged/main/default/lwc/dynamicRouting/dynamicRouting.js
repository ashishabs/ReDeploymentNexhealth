import { LightningElement, wire, api } from 'lwc';
import getPermissionRecords from '@salesforce/apex/DynamicRoutingController.getPermissionRecords';
import getFieldSetInfo from '@salesforce/apex/DynamicRoutingController.getFieldSetInfo';

export default class DynamicRouting extends LightningElement {
    columns = [];
    records = [];

    @api recordId;

    @wire(getFieldSetInfo) 
    wiredFieldSetInfo({ data, error }) {
        if(data) {
            this.generateColumns(data); 
        } else if(error) {
            console.error(error);
        }
    }

    @wire(getPermissionRecords, { caseId: '$recordId' }) 
    wiredPermissions({ data, error }) {
        if(data) {
            this.records = data;
        } else if(error) {
            console.error(error);
        }
    }

    generateColumns(fieldSetInfo) {
        if(fieldSetInfo && fieldSetInfo.length > 0) {
            this.columns = fieldSetInfo.map(field => ({
                label: field.label, 
                fieldName: field.fieldPath,
                type: 'text' 
            }));
        }
    }
}