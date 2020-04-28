
function patch_default_font {
  message "Patch default font"
  exec_command "sed -i \"s|\\\"Lato\\\", ||\" canvas-lms/app/stylesheets/base/_variables.scss"
}

patch_default_font