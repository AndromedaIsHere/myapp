# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"

# Add Fabric.js for canvas functionality
pin "fabric", to: "https://cdnjs.cloudflare.com/ajax/libs/fabric.js/5.3.0/fabric.min.js"
