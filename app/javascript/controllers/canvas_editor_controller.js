import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="canvas-editor"
export default class extends Controller {
  static targets = ["canvas", "imageDataField", "drawBtn", "textBtn", "imageUpload", "clearBtn", "form"]

  connect() {
    this.fabricCanvas = new fabric.Canvas(this.canvasTarget, {
      isDrawingMode: true
    });
    this.registerEvents();
  }

  registerEvents() {
    this.drawBtnTarget.addEventListener("click", () => {
      this.fabricCanvas.isDrawingMode = true;
    });

    this.textBtnTarget.addEventListener("click", () => {
      this.fabricCanvas.isDrawingMode = false;
      const text = new fabric.IText('Type here', { left: 100, top: 100 });
      this.fabricCanvas.add(text);
      this.fabricCanvas.setActiveObject(text);
      text.enterEditing();
      text.selectAll();
    });

    this.imageUploadTarget.addEventListener("change", (e) => {
      const file = e.target.files[0];
      if (!file) return;
      const reader = new FileReader();
      reader.onload = (f) => {
        fabric.Image.fromURL(f.target.result, (img) => {
          img.set({ left: 150, top: 150, scaleX: 0.5, scaleY: 0.5 });
          this.fabricCanvas.add(img);
        });
      };
      reader.readAsDataURL(file);
    });

    this.clearBtnTarget.addEventListener("click", () => {
      this.fabricCanvas.clear();
    });

    this.formTarget.addEventListener("submit", (e) => {
      const dataURL = this.fabricCanvas.toDataURL({ format: 'png' });
      this.imageDataFieldTarget.value = dataURL;
    });
  }
} 