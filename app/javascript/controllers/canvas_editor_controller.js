import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="canvas-editor"
export default class extends Controller {
  static targets = ["canvas", "colorPicker", "brushSize", "dataField"]

  connect() {
    console.log("Canvas editor controller connected");
    // Add small delay to ensure Fabric.js is fully loaded
    setTimeout(() => {
      this.initializeFabric();
    }, 100);
  }

  initializeFabric() {
    // Check if fabric is available
    if (typeof window.fabric === 'undefined') {
      console.error("Fabric.js not loaded");
      // Try again after a longer delay
      setTimeout(() => {
        this.initializeFabric();
      }, 500);
      return;
    }

    try {
      console.log("Initializing Fabric.js canvas...");
      this.fabricCanvas = new window.fabric.Canvas(this.canvasTarget, {
        isDrawingMode: true,
        width: 800,
        height: 600
      });
      
      // Set default drawing brush
      this.fabricCanvas.freeDrawingBrush.width = 10;
      this.fabricCanvas.freeDrawingBrush.color = "#000000";
      
      console.log("Canvas initialized successfully");
      this.setupEventListeners();
    } catch (error) {
      console.error("Error initializing canvas:", error);
    }
  }

  setupEventListeners() {
    if (!this.fabricCanvas) {
      console.error("Canvas not initialized");
      return;
    }

    // Color picker change
    if (this.hasColorPickerTarget) {
      this.colorPickerTarget.addEventListener("change", (e) => {
        this.fabricCanvas.freeDrawingBrush.color = e.target.value;
      });
    }

    // Brush size change
    if (this.hasBrushSizeTarget) {
      this.brushSizeTarget.addEventListener("input", (e) => {
        const size = parseInt(e.target.value, 10);
        this.fabricCanvas.freeDrawingBrush.width = size;
        // Update display
        const display = document.getElementById('brush-size-display');
        if (display) display.textContent = size;
      });
    }
  }

  // Tool methods
  setDrawMode() {
    console.log("Draw mode activated");
    this.fabricCanvas.isDrawingMode = true;
  }

  addRectangle() {
    console.log("Adding rectangle");
    this.fabricCanvas.isDrawingMode = false;
    const rect = new window.fabric.Rect({
      left: 100,
      top: 100,
      fill: 'transparent',
      stroke: this.colorPickerTarget?.value || '#000000',
      strokeWidth: 2,
      width: 100,
      height: 100
    });
    this.fabricCanvas.add(rect);
  }

  addCircle() {
    console.log("Adding circle");
    this.fabricCanvas.isDrawingMode = false;
    const circle = new window.fabric.Circle({
      left: 100,
      top: 100,
      fill: 'transparent',
      stroke: this.colorPickerTarget?.value || '#000000',
      strokeWidth: 2,
      radius: 50
    });
    this.fabricCanvas.add(circle);
  }

  clearCanvas() {
    console.log("Clearing canvas");
    this.fabricCanvas.clear();
  }

  prepareSubmit(event) {
    console.log("Form submitting, capturing canvas data");
    if (this.fabricCanvas) {
      const dataURL = this.fabricCanvas.toDataURL({ 
        format: 'png',
        quality: 0.8
      });
      this.dataFieldTarget.value = dataURL;
      console.log("Canvas data captured");
    }
  }

  disconnect() {
    console.log("Canvas editor controller disconnected");
    if (this.fabricCanvas) {
      this.fabricCanvas.dispose();
    }
  }
} 