import { Application } from "@hotwired/stimulus"

/**
 * Stimulus Application Configuration
 * 
 * Initializes and configures the Stimulus application for the entire app.
 * This is the main entry point for all Stimulus controllers.
 */

// Start the Stimulus application
const application = Application.start()

// Configure Stimulus development experience
// Set to true for development debugging, false for production
application.debug = false

// Make Stimulus available globally for debugging
window.Stimulus = application

export { application }