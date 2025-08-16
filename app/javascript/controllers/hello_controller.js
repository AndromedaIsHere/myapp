import { Controller } from "@hotwired/stimulus"

/**
 * Hello Controller
 * 
 * A simple demonstration controller that displays "Hello World!"
 * Used for testing Stimulus functionality.
 */
export default class extends Controller {
  /**
   * Initialize the controller when connected to the DOM
   */
  connect() {
    this.element.textContent = "Hello World!"
    console.log("Hello controller connected")
  }
  
  /**
   * Clean up when disconnected from the DOM
   */
  disconnect() {
    console.log("Hello controller disconnected")
  }
}