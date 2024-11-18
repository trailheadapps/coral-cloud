import { LightningElement } from 'lwc';
import Toast from 'lightning/toast';
import importData from '@salesforce/apex/DataTreeImporter.importData';
import generateData from '@salesforce/apex/SampleDataGenerator.generateData';

export default class SampleData extends LightningElement {
    isImportActive = false;

    handleOnClick() {
        this.isImportActive = true;
        importData().then(() => {
            generateData()
                .then(() => {
                    this.isImportActive = false;
                    Toast.show({
                        label: 'Success',
                        message: 'Sample data imported successfully',
                        variant: 'success'
                    });
                })
                .catch((error) => {
                    this.isImportActive = false;
                    Toast.show({
                        label: 'Error',
                        message: error.body.message,
                        variant: 'error'
                    });
                });
        });
    }
}
