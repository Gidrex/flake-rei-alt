-- Picker presets: text files only, buffer-dir scoping.
local M = {}

-- Binary formats hidden from the file pickers (images, docs, archives,
-- media, fonts, executables); everything else is treated as text.
M.files_exclude = {
  "*.png",
  "*.jpg",
  "*.jpeg",
  "*.webp",
  "*.gif",
  "*.bmp",
  "*.ico",
  "*.svg",
  "*.avif",
  "*.tif",
  "*.tiff",
  "*.heic",
  "*.pdf",
  "*.doc",
  "*.docx",
  "*.xls",
  "*.xlsx",
  "*.ppt",
  "*.pptx",
  "*.odt",
  "*.zip",
  "*.tar",
  "*.gz",
  "*.bz2",
  "*.xz",
  "*.7z",
  "*.rar",
  "*.zst",
  "*.mp3",
  "*.wav",
  "*.ogg",
  "*.flac",
  "*.m4a",
  "*.mp4",
  "*.mkv",
  "*.webm",
  "*.avi",
  "*.mov",
  "*.ttf",
  "*.otf",
  "*.woff",
  "*.woff2",
  "*.exe",
  "*.msi",
  "*.dmg",
  "*.iso",
  "*.db",
  "*.sqlite",
  "*.sqlite3",
  "*.pyc",
  "*.class",
  "*.o",
  "*.so",
  "*.dll",
}

function M.files()
  Snacks.picker.files({ exclude = M.files_exclude })
end

function M.files_here()
  local dir = vim.fn.expand("%:p:h")
  if dir == "" then
    dir = vim.fn.getcwd()
  end
  Snacks.picker.files({ dirs = { dir }, exclude = M.files_exclude })
end

return M
