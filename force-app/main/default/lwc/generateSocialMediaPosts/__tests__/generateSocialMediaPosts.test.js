import { createElement } from 'lwc';
import GenerateSocialMediaPosts from 'c/generateSocialMediaPosts';
import generateSocialMediaPosts from '@salesforce/apex/SocialMediaPostsController.generateSocialMediaPosts';

const mockPosts = require('./data/generateSocialMediaPosts.json');

// Mock getExperienceSessionsForDate imperative Apex method call
jest.mock(
    '@salesforce/apex/SocialMediaPostsController.generateSocialMediaPosts',
    () => ({
        default: jest.fn()
    }),
    { virtual: true }
);

// Mock error for imperative Apex call
const MOCK_APEX_ERROR = {
    body: { message: 'An internal server error has occurred' },
    ok: false,
    status: 400,
    statusText: 'Bad Request'
};

describe('c-generate-social-media-posts', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    // Helper function to wait until the microtask queue is empty. This is needed for promise
    // timing when calling imperative Apex.
    async function flushPromises() {
        return Promise.resolve();
    }

    it('generates and renders posts when generate button is clicked', async () => {
        // Assign mock value for resolved Apex promise
        const mockPostsJsonString = JSON.stringify(mockPosts);
        generateSocialMediaPosts.mockResolvedValue(mockPostsJsonString);

        const element = createElement('c-generate-social-media-posts', {
            is: GenerateSocialMediaPosts
        });
        document.body.appendChild(element);

        // Click button
        const buttonEl = element.shadowRoot.querySelector('lightning-button');
        buttonEl.click();

        // Wait for any asynchronous DOM updates
        await flushPromises();

        // Validate displayed values agains mock data
        const textAreaEls =
            element.shadowRoot.querySelectorAll('lightning-textarea');
        expect(textAreaEls.length).toBe(3);
    });

    it('renders the "Try Again!" button when the Apex method returns an error', async () => {
        // Assign mock value for rejected Apex promise
        generateSocialMediaPosts.mockRejectedValue(MOCK_APEX_ERROR);

        // Create component
        const element = createElement('c-generate-social-media-posts', {
            is: GenerateSocialMediaPosts
        });
        document.body.appendChild(element);

        // Click button
        const buttonEl = element.shadowRoot.querySelector('lightning-button');
        buttonEl.click();

        // Wait for any asynchronous DOM updates
        await flushPromises();

        const buttonTryAgainEl =
            element.shadowRoot.querySelector('lightning-button');
        expect(buttonTryAgainEl.label).toEqual('Try again!');
    });

    it('is accessible', async () => {
        // Create component
        const element = createElement('c-generate-social-media-posts', {
            is: GenerateSocialMediaPosts
        });
        document.body.appendChild(element);

        // Wait for any asynchronous DOM updates
        await flushPromises();

        // Check accessibility
        await expect(element).toBeAccessible();
    });
});
