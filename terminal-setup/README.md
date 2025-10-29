# Windows Terminal Color Schemes for Starship

This document provides Windows Terminal color schemes that work beautifully with the included Starship configuration.

## Required Font

**MesloLGS NF** - This is the same Nerd Font used by Powerlevel10k and provides all the glyphs and icons.

- Download: https://github.com/ryanoasis/nerd-fonts/releases/latest
- Look for `Meslo.zip` or search for "MesloLGS"
- Install the TTF files on Windows
- In Windows Terminal, edit your WSL profile and set "Font face" to `MesloLGS NF`

## Recommended Color Schemes

### 1. Dracula (High Contrast, Vibrant)

Perfect for the starship config colors. Add this to your Windows Terminal `settings.json` in the `schemes` array:

```json
{
  "name": "Dracula",
  "background": "#282a36",
  "foreground": "#f8f8f2",
  "black": "#21222c",
  "blue": "#6272a4",
  "cyan": "#8be9fd", 
  "green": "#50fa7b",
  "purple": "#bd93f9",
  "red": "#ff5555",
  "yellow": "#f1fa8c",
  "white": "#f8f8f2",
  "brightBlack": "#6272a4",
  "brightBlue": "#6272a4", 
  "brightCyan": "#8be9fd",
  "brightGreen": "#50fa7b",
  "brightPurple": "#bd93f9",
  "brightRed": "#ff6b6b",
  "brightYellow": "#f1fa8c",
  "brightWhite": "#ffffff"
}
```

### 2. One Dark (Balanced, Developer-Friendly)

Excellent for long coding sessions with good contrast:

```json
{
  "name": "One Dark",
  "background": "#1e2127",
  "foreground": "#abb2bf",
  "black": "#1e2127",
  "blue": "#61afef",
  "cyan": "#56b6c2",
  "green": "#98c379",
  "purple": "#c678dd",
  "red": "#e06c75",
  "yellow": "#e5c07b",
  "white": "#abb2bf",
  "brightBlack": "#5c6370",
  "brightBlue": "#61afef",
  "brightCyan": "#56b6c2", 
  "brightGreen": "#98c379",
  "brightPurple": "#c678dd",
  "brightRed": "#e06c75",
  "brightYellow": "#e5c07b",
  "brightWhite": "#ffffff"
}
```

### 3. Nord (Cool, Muted)

Clean and minimal, similar to many macOS themes:

```json
{
  "name": "Nord",
  "background": "#2e3440",
  "foreground": "#d8dee9",
  "black": "#3b4252",
  "blue": "#81a1c1",
  "cyan": "#88c0d0",
  "green": "#a3be8c",
  "purple": "#b48ead",
  "red": "#bf616a",
  "yellow": "#ebcb8b",
  "white": "#e5e9f0",
  "brightBlack": "#4c566a",
  "brightBlue": "#81a1c1",
  "brightCyan": "#8fbcbb",
  "brightGreen": "#a3be8c", 
  "brightPurple": "#b48ead",
  "brightRed": "#bf616a",
  "brightYellow": "#ebcb8b",
  "brightWhite": "#eceff4"
}
```

### 4. Tokyo Night (Modern, Purple Accents)

Popular modern theme with excellent readability:

```json
{
  "name": "Tokyo Night",
  "background": "#1a1b26",
  "foreground": "#c0caf5",
  "black": "#15161e",
  "blue": "#7aa2f7",
  "cyan": "#7dcfff",
  "green": "#9ece6a",
  "purple": "#bb9af7",
  "red": "#f7768e",
  "yellow": "#e0af68",
  "white": "#a9b1d6",
  "brightBlack": "#414868",
  "brightBlue": "#7aa2f7",
  "brightCyan": "#7dcfff",
  "brightGreen": "#9ece6a",
  "brightPurple": "#bb9af7",
  "brightRed": "#f7768e",
  "brightYellow": "#e0af68",
  "brightWhite": "#c0caf5"
}
```

## How to Apply

1. Open Windows Terminal settings (Ctrl+Shift+,)
2. Click "Open JSON file" in the bottom left
3. Add your chosen color scheme to the `schemes` array
4. In your WSL profile, set:
   - `"colorScheme": "Dracula"` (or your chosen scheme name)
   - `"fontFace": "MesloLGS NF"`
5. Save and restart Windows Terminal

## Example Profile Section

```json
{
  "guid": "{your-wsl-guid}",
  "name": "Ubuntu",
  "source": "Windows.Terminal.Wsl",
  "fontFace": "MesloLGS NF",
  "fontSize": 10,
  "colorScheme": "Dracula",
  "cursorShape": "bar"
}
```

## Color Matching

The starship config uses these color values that work well with all the above schemes:

- Directory: `#79D4FF` (cyan-ish)
- Git branch: `#C792EA` (purple) 
- Git status: `#F07178` (coral)
- Python: `#8BE9FD` (light blue)
- Node.js: `#F9E2AF` (pale yellow)
- Username: `#FFB86C` (soft orange)
- Success prompt: `#A6E22E` (green)
- Error prompt: `#FF6B6B` (red)

These colors are designed to be readable and pleasant across all the recommended terminal color schemes.