import { Controller } from "@hotwired/stimulus"

/**
 * Canvas Editor Controller
 * 
 * Provides a comprehensive drawing interface using Fabric.js with support for:
 * - Multiple brush types (Pencil, Circle, Spray, Eraser)
 * - Shape tools (Rectangle, Circle, Line, Text)
 * - File upload and canvas integration
 * - Keyboard shortcuts and UI feedback
 */
export default class extends Controller {
  static targets = ["canvas", "colorPicker", "brushSize", "dataField", "imageUpload"]
  
  // Configuration constants
  static CANVAS_CONFIG = {
    width: 800,
    height: 600,
    backgroundColor: 'white'
  }
  
  static BRUSH_CONFIG = {
    defaultColor: '#000000',
    defaultSize: 10,
    minEraserSize: 15,
    maxSize: 50
  }
  
  static SHAPE_CONFIG = {
    defaultStrokeWidth: 2,
    defaultPosition: { left: 100, top: 100 },
    defaultSize: { width: 100, height: 100, radius: 50 }
  }
  
  static TEXT_CONFIG = {
    defaultText: 'Type here',
    defaultFontSize: 20,
    defaultFontFamily: 'Arial'
  }

  // =============================================================================
  // LIFECYCLE METHODS
  // =============================================================================

  connect() {
    this.initializeState()
    
    if (!this.validateFabricJs()) {
      return
    }
    
    this.logDebugInfo()
    this.initializeCanvas()
  }

  disconnect() {
    this.cleanup()
  }

  // =============================================================================
  // INITIALIZATION METHODS
  // =============================================================================

  /**
   * Initialize controller state
   * @private
   */
  initializeState() {
    this.currentTool = 'draw'
    this.currentColor = this.constructor.BRUSH_CONFIG.defaultColor
    this.currentBrushSize = this.constructor.BRUSH_CONFIG.defaultSize
    this.keydownHandler = null
  }

  /**
   * Validate that Fabric.js is available
   * @private
   * @returns {boolean} True if Fabric.js is available
   */
  validateFabricJs() {
    if (typeof window.fabric === 'undefined') {
      console.error("Fabric.js is not loaded. Please ensure Fabric.js is included in your layout.")
      return false
    }
    return true
  }

  /**
   * Log debug information about Fabric.js
   * @private
   */
  logDebugInfo() {
    // Debug information available in development console if needed
    // Removed user-facing version display for cleaner UI
  }

  /**
   * Initialize the Fabric.js canvas
   * @private
   */
  initializeCanvas() {
    try {
      this.createFabricCanvas()
      this.configureCanvas()
      this.setupEventListeners()
      this.initializeUI()
      
      // Canvas initialized successfully
    } catch (error) {
      console.error("Error initializing canvas:", error)
    }
  }

  /**
   * Create and configure the Fabric.js canvas instance
   * @private
   */
  createFabricCanvas() {
    const config = this.constructor.CANVAS_CONFIG
    
    this.fabricCanvas = new window.fabric.Canvas(this.canvasTarget, {
      isDrawingMode: true,
      width: config.width,
      height: config.height
    })
  }

  /**
   * Configure canvas properties and default brush
   * @private
   */
  configureCanvas() {
    // Set background color
    this.fabricCanvas.setBackgroundColor(
      this.constructor.CANVAS_CONFIG.backgroundColor,
      this.fabricCanvas.renderAll.bind(this.fabricCanvas)
    )

    // Configure default brush
    this.fabricCanvas.freeDrawingBrush.width = this.currentBrushSize
    this.fabricCanvas.freeDrawingBrush.color = this.currentColor
  }

  /**
   * Initialize UI elements and status displays
   * @private
   */
  initializeUI() {
    this.updateToolStatus('Draw')
    this.updateBrushSizeDisplay()
  }

  // =============================================================================
  // EVENT LISTENER SETUP
  // =============================================================================

  /**
   * Set up all event listeners for controls and keyboard shortcuts
   * @private
   */
  setupEventListeners() {
    this.setupColorPickerListener()
    this.setupBrushSizeListener()
    this.setupKeyboardShortcuts()
  }

  /**
   * Set up color picker event listener
   * @private
   */
  setupColorPickerListener() {
    if (this.hasColorPickerTarget) {
      this.colorPickerTarget.addEventListener("change", (e) => {
        this.currentColor = e.target.value
        this.updateBrushProperties()
      })
    }
  }

  /**
   * Set up brush size slider event listener
   * @private
   */
  setupBrushSizeListener() {
    if (this.hasBrushSizeTarget) {
      this.brushSizeTarget.addEventListener("input", (e) => {
        this.currentBrushSize = parseInt(e.target.value, 10)
        this.updateBrushProperties()
        this.updateBrushSizeDisplay()
      })
    }
  }

  /**
   * Set up keyboard shortcuts
   * @private
   */
  setupKeyboardShortcuts() {
    this.keydownHandler = (e) => {
      if (e.key === 'Delete' && this.fabricCanvas.getActiveObject()) {
        e.preventDefault()
        this.deleteSelected()
      }
    }
    document.addEventListener('keydown', this.keydownHandler)
  }

  // =============================================================================
  // DRAWING TOOL METHODS
  // =============================================================================

  /**
   * Set drawing mode with pencil brush
   */
  setDrawMode() {
    this.setBrushType('pencil')
  }

  /**
   * Set circle brush mode
   */
  setCircleBrush() {
    this.setBrushType('circle')
  }

  /**
   * Set spray brush mode
   */
  setSprayBrush() {
    this.setBrushType('spray')
  }

  /**
   * Set brush type with fallback support
   * @param {string} brushType - Type of brush ('pencil', 'circle', 'spray')
   */
  setBrushType(brushType) {
    this.currentTool = 'draw'
    this.fabricCanvas.isDrawingMode = true
    
    const brush = this.createBrush(brushType)
    this.fabricCanvas.freeDrawingBrush = brush
    
    this.applyBrushProperties()
    this.updateToolStatus(`${this.capitalizeFirst(brushType)} Brush`)
  }

  /**
   * Create a brush instance with fallback support
   * @param {string} brushType - Type of brush to create
   * @returns {Object} Fabric.js brush instance
   * @private
   */
  createBrush(brushType) {
    const brushMap = {
      'pencil': () => new window.fabric.PencilBrush(this.fabricCanvas),
      'circle': () => window.fabric.CircleBrush 
        ? new window.fabric.CircleBrush(this.fabricCanvas)
        : new window.fabric.PencilBrush(this.fabricCanvas),
      'spray': () => window.fabric.SprayBrush
        ? new window.fabric.SprayBrush(this.fabricCanvas)
        : new window.fabric.PencilBrush(this.fabricCanvas)
    }
    
    const brushFactory = brushMap[brushType] || brushMap['pencil']
    return brushFactory()
  }

  /**
   * Enable eraser mode with native or fallback support
   */
  enableEraser() {
    this.currentTool = 'eraser'
    this.fabricCanvas.isDrawingMode = true
    
    const brush = this.createEraserBrush()
    this.fabricCanvas.freeDrawingBrush = brush
    
    const eraserSize = Math.max(this.currentBrushSize, this.constructor.BRUSH_CONFIG.minEraserSize)
    this.fabricCanvas.freeDrawingBrush.width = eraserSize
    
    this.updateToolStatus('Eraser')
  }

  /**
   * Create eraser brush with fallback
   * @returns {Object} Eraser brush instance
   * @private
   */
  createEraserBrush() {
    if (window.fabric.EraserBrush) {
      return new window.fabric.EraserBrush(this.fabricCanvas)
    } else {
      const brush = new window.fabric.PencilBrush(this.fabricCanvas)
      brush.color = '#FFFFFF'
      return brush
    }
  }

  // =============================================================================
  // SHAPE TOOL METHODS
  // =============================================================================

  /**
   * Add text to canvas
   */
  addText() {
    this.setShapeMode('text')
    
    const textConfig = this.constructor.TEXT_CONFIG
    const position = this.constructor.SHAPE_CONFIG.defaultPosition
    
    const text = new window.fabric.IText(textConfig.defaultText, {
      left: position.left,
      top: position.top,
      fontSize: textConfig.defaultFontSize,
      fill: this.currentColor,
      fontFamily: textConfig.defaultFontFamily
    })
    
    this.addShapeToCanvas(text)
    text.enterEditing()
    text.selectAll()
    
    this.updateToolStatus('Text')
  }

  /**
   * Add rectangle to canvas
   */
  addRectangle() {
    this.setShapeMode('rectangle')
    
    const position = this.constructor.SHAPE_CONFIG.defaultPosition
    const size = this.constructor.SHAPE_CONFIG.defaultSize
    
    const rect = new window.fabric.Rect({
      left: position.left,
      top: position.top,
      fill: 'transparent',
      stroke: this.currentColor,
      strokeWidth: this.constructor.SHAPE_CONFIG.defaultStrokeWidth,
      width: size.width,
      height: size.height
    })
    
    this.addShapeToCanvas(rect)
  }

  /**
   * Add circle to canvas
   */
  addCircle() {
    this.setShapeMode('circle')
    
    const position = this.constructor.SHAPE_CONFIG.defaultPosition
    const size = this.constructor.SHAPE_CONFIG.defaultSize
    
    const circle = new window.fabric.Circle({
      left: position.left,
      top: position.top,
      fill: 'transparent',
      stroke: this.currentColor,
      strokeWidth: this.constructor.SHAPE_CONFIG.defaultStrokeWidth,
      radius: size.radius
    })
    
    this.addShapeToCanvas(circle)
  }

  /**
   * Add line to canvas
   */
  addLine() {
    this.setShapeMode('line')
    
    const position = this.constructor.SHAPE_CONFIG.defaultPosition
    
    const line = new window.fabric.Line([
      position.left,
      position.top,
      position.left + 150,
      position.top
    ], {
      stroke: this.currentColor,
      strokeWidth: this.constructor.SHAPE_CONFIG.defaultStrokeWidth
    })
    
    this.addShapeToCanvas(line)
  }

  /**
   * Set canvas to shape mode and update tool state
   * @param {string} shapeType - Type of shape being added
   * @private
   */
  setShapeMode(shapeType) {
    this.currentTool = shapeType
    this.fabricCanvas.isDrawingMode = false
  }

  /**
   * Add shape to canvas and set as active object
   * @param {Object} shape - Fabric.js shape object
   * @private
   */
  addShapeToCanvas(shape) {
    this.fabricCanvas.add(shape)
    this.fabricCanvas.setActiveObject(shape)
    this.fabricCanvas.renderAll()
  }

  // =============================================================================
  // CANVAS MANAGEMENT METHODS
  // =============================================================================

  /**
   * Delete currently selected objects
   */
  deleteSelected() {
    const activeObjects = this.fabricCanvas.getActiveObjects()
    
    if (activeObjects.length === 0) {
      return
    }
    
    activeObjects.forEach(obj => this.fabricCanvas.remove(obj))
    this.fabricCanvas.discardActiveObject()
    this.fabricCanvas.renderAll()
    
    // Objects deleted successfully
  }

  /**
   * Clear entire canvas and reset to default state
   */
  clearCanvas() {
    this.fabricCanvas.clear()
    
    // Reset background
    this.fabricCanvas.setBackgroundColor(
      this.constructor.CANVAS_CONFIG.backgroundColor,
      this.fabricCanvas.renderAll.bind(this.fabricCanvas)
    )
    
    // Reset to draw mode
    this.setDrawMode()
    
    // Canvas cleared and reset to draw mode
  }

  // =============================================================================
  // FILE UPLOAD METHODS
  // =============================================================================

  /**
   * Handle image file upload to canvas
   * @param {Event} event - File input change event
   */
  handleImageUpload(event) {
    const file = event.target.files?.[0]
    
    if (!file) {
      return
    }
    
    if (!this.validateImageFile(file)) {
      this.showError('Please select a valid image file (JPG, PNG, GIF)')
      return
    }
    
    this.loadImageToCanvas(file)
  }

  /**
   * Validate uploaded file is an image
   * @param {File} file - File to validate
   * @returns {boolean} True if file is valid image
   * @private
   */
  validateImageFile(file) {
    return file.type.startsWith('image/')
  }

  /**
   * Load image file to canvas with proper scaling
   * @param {File} file - Image file to load
   * @private
   */
  loadImageToCanvas(file) {
    const reader = new FileReader()
    
    reader.onload = (e) => {
      window.fabric.Image.fromURL(e.target.result, (img) => {
        this.scaleAndPositionImage(img)
        this.addShapeToCanvas(img)
        
        // Image loaded to canvas successfully
        
        this.updateToolStatus('Image Uploaded')
        
        // Clear the file input to allow uploading the same file again
        event.target.value = ''
      })
    }
    
    reader.onerror = () => {
      this.showError('Failed to load image file')
    }
    
    reader.readAsDataURL(file)
  }

  /**
   * Scale and center image to fit canvas
   * @param {Object} img - Fabric.js image object
   * @private
   */
  scaleAndPositionImage(img) {
    const canvas = this.constructor.CANVAS_CONFIG
    const scaleX = canvas.width / img.width
    const scaleY = canvas.height / img.height
    const scale = Math.min(scaleX, scaleY, 1) // Don't upscale
    
    img.set({
      left: (canvas.width - img.width * scale) / 2,
      top: (canvas.height - img.height * scale) / 2,
      scaleX: scale,
      scaleY: scale
    })
  }

  // =============================================================================
  // FORM SUBMISSION METHODS
  // =============================================================================

  /**
   * Prepare canvas data for form submission
   * @param {Event} event - Form submit event
   */
  prepareSubmit(event) {
    const hasUploadedFile = this.checkForUploadedFile()
    
    if (hasUploadedFile) {
      this.handleFileSubmission()
    } else {
      this.handleCanvasSubmission()
    }
  }

  /**
   * Check if user uploaded a file instead of using canvas
   * @returns {boolean} True if file was uploaded
   * @private
   */
  checkForUploadedFile() {
    const fileInput = document.querySelector('input[type="file"][name="sketch[image]"]')
    return fileInput?.files?.length > 0
  }

  /**
   * Handle form submission with uploaded file
   * @private
   */
  handleFileSubmission() {
    if (this.hasDataFieldTarget) {
      this.dataFieldTarget.value = ''
    }
    // File upload detected - using uploaded file instead of canvas
  }

  /**
   * Handle form submission with canvas data
   * @private
   */
  handleCanvasSubmission() {
    if (!this.fabricCanvas || !this.hasDataFieldTarget) {
      return
    }
    
    try {
      const dataURL = this.fabricCanvas.toDataURL({
        format: 'png',
        quality: 0.8
      })
      
      this.dataFieldTarget.value = dataURL
      // Canvas data captured for submission
    } catch (error) {
      console.error('Failed to capture canvas data:', error)
      this.showError('Failed to capture canvas drawing')
    }
  }

  // =============================================================================
  // UI UPDATE METHODS
  // =============================================================================

  /**
   * Update brush properties on current brush
   * @private
   */
  updateBrushProperties() {
    if (!this.fabricCanvas.freeDrawingBrush) {
      return
    }
    
    this.fabricCanvas.freeDrawingBrush.width = this.currentBrushSize
    
    // Only update color if not in eraser mode
    if (this.currentTool !== 'eraser') {
      this.fabricCanvas.freeDrawingBrush.color = this.currentColor
    }
  }

  /**
   * Apply current brush properties to active brush
   * @private
   */
  applyBrushProperties() {
    if (this.fabricCanvas.freeDrawingBrush) {
      this.fabricCanvas.freeDrawingBrush.width = this.currentBrushSize
      this.fabricCanvas.freeDrawingBrush.color = this.currentColor
    }
  }

  /**
   * Update tool status display
   * @param {string} toolName - Name of current tool
   * @private
   */
  updateToolStatus(toolName) {
    const display = document.getElementById('current-tool-display')
    if (display) {
      display.textContent = `Current tool: ${toolName}`
    }
    
    this.updateActiveToolButton(toolName)
  }

  /**
   * Update active tool button highlighting
   * @param {string} toolName - Name of current tool
   * @private
   */
  updateActiveToolButton(toolName) {
    // Clear all active states
    document.querySelectorAll('.tool-button').forEach(btn => {
      btn.classList.remove('active')
    })
    
    // Set active button
    const buttonMap = {
      'Draw': 'draw-btn',
      'Pencil Brush': 'draw-btn',
      'Eraser': 'eraser-btn'
    }
    
    const buttonId = buttonMap[toolName]
    if (buttonId) {
      document.getElementById(buttonId)?.classList.add('active')
    }
  }



  /**
   * Update brush size display
   * @private
   */
  updateBrushSizeDisplay() {
    const display = document.getElementById('brush-size-display')
    if (display) {
      display.textContent = this.currentBrushSize
    }
  }

  // =============================================================================
  // UTILITY METHODS
  // =============================================================================

  /**
   * Capitalize first letter of string
   * @param {string} str - String to capitalize
   * @returns {string} Capitalized string
   * @private
   */
  capitalizeFirst(str) {
    return str.charAt(0).toUpperCase() + str.slice(1)
  }

  /**
   * Show error message to user
   * @param {string} message - Error message to display
   * @private
   */
  showError(message) {
    // In a real app, you might want to use a toast notification or modal
    alert(message)
  }

  /**
   * Clean up resources and event listeners
   * @private
   */
  cleanup() {
    if (this.fabricCanvas) {
      this.fabricCanvas.dispose()
    }
    
    if (this.keydownHandler) {
      document.removeEventListener('keydown', this.keydownHandler)
    }
    
    // Canvas editor controller cleaned up
  }
}