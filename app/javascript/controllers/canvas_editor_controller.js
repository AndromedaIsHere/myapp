import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="canvas-editor"
export default class extends Controller {
  static targets = ["canvas", "imageDataField", "drawBtn", "textBtn", "imageUpload", "clearBtn", "form"]

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

    this.drawBtnTarget.addEventListener("click", () => {
      console.log("Draw mode activated");
      this.fabricCanvas.isDrawingMode = true;
    });

    this.textBtnTarget.addEventListener("click", () => {
      console.log("Text mode activated");
      this.fabricCanvas.isDrawingMode = false;
      const text = new window.fabric.IText('Type here', { 
        left: 100, 
        top: 100,
        fontSize: 20,
        fill: 'black'
      });
      this.fabricCanvas.add(text);
      this.fabricCanvas.setActiveObject(text);
      text.enterEditing();
      text.selectAll();
    });

    this.imageUploadTarget.addEventListener("change", (e) => {
      console.log("Image upload triggered");
      const file = e.target.files[0];
      if (!file) return;
      
      const reader = new FileReader();
      reader.onload = (f) => {
        window.fabric.Image.fromURL(f.target.result, (img) => {
          img.set({ 
            left: 150, 
            top: 150, 
            scaleX: 0.5, 
            scaleY: 0.5 
          });
          this.fabricCanvas.add(img);
          this.fabricCanvas.renderAll();
        });
      };
      reader.readAsDataURL(file);
    });

    this.clearBtnTarget.addEventListener("click", () => {
      console.log("Clearing canvas");
      this.fabricCanvas.clear();
    });

    this.formTarget.addEventListener("submit", (e) => {
      console.log("Form submitting, capturing canvas data");
      if (this.fabricCanvas) {
        const dataURL = this.fabricCanvas.toDataURL({ 
          format: 'png',
          quality: 0.8
        });
        this.imageDataFieldTarget.value = dataURL;
        console.log("Canvas data captured");
      }
    });
  }

  disconnect() {
    console.log("Canvas editor controller disconnected");
    if (this.fabricCanvas) {
      this.fabricCanvas.dispose();
    }
  }
} 