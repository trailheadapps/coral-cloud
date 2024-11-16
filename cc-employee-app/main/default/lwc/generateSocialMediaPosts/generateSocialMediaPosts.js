import { api, LightningElement } from 'lwc';
import generateSocialMediaPosts from '@salesforce/apex/SocialMediaPostsController.generateSocialMediaPosts';

export default class GenerateSocialMediaPosts extends LightningElement {
    twitterPost;
    linkedinPost;
    slackPost;
    error;
    showSpinner = false;
    @api recordId;

    async generateSocialMediaPosts() {
        this.showSpinner = true;
        try {
            const posts = await generateSocialMediaPosts({
                experienceSessionId: this.recordId
            });
            const parsedPosts = JSON.parse(posts);
            this.twitterPost = parsedPosts.twitter;
            this.linkedinPost = parsedPosts.linkedin;
            this.slackPost = JSON.stringify(parsedPosts.blockkit);
            this.error = undefined;
        } catch (error) {
            this.twitterPost = undefined;
            this.linkedinPost = undefined;
            this.error = error;
        } finally {
            this.showSpinner = false;
        }
    }
}
