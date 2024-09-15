import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CoralCloudHomePagePrompt extends LightningElement {
    type; //copilot || prompt-builder
    @api prompt = '';
    @api label = 'Create a Sales Email Prompt Template';
    @api step = 'Exercise 1 - Step 1';
    @api language;

    handleCopy() {
        const promptText = this.prompt;
        navigator.clipboard
            .writeText(promptText)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Text copied to clipboard',
                        variant: 'success'
                    })
                );
            })
            .catch((error) => {
                console.error('Failed to copy text: ', error);
            });
    }
}
