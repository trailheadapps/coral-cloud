import { LightningElement, api } from 'lwc';
import generateSocialMediaPosts from '@salesforce/apex/SocialMediaPostsController.generateSocialMediaPosts';

export default class GenerateSocialMediaPosts extends LightningElement {
    twitterPost;
    linkedinPost;
    slackPost;
    error;
    showSpinner = false;
    @api recordId;

    async handleGenerateClick() {
        this.showSpinner = true;
        this.twitterPost = undefined;
        this.linkedinPost = undefined;
        this.slackPost = undefined;
        this.error = undefined;
        try {
            const posts = await generateSocialMediaPosts({
                experienceSessionId: this.recordId
            });
            const parsedPosts = JSON.parse(posts);
            this.twitterPost = parsedPosts.twitter;
            this.linkedinPost = parsedPosts.linkedin;
            this.slackPost = JSON.stringify(parsedPosts.blockkit);
        } catch (error) {
            this.error = error;
        } finally {
            this.showSpinner = false;
        }
    }
}
