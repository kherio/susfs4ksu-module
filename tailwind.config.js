/** @type {import('tailwindcss').Config} */

module.exports = {
  content: [
    "./*.html",
    "./*.{js,ts,jsx,tsx}",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {},
  },
  plugins: [
    require('daisyui'),
  ],
  daisyui: {
    themes: [
      {
        susfs: {
          "primary": "#6c8cff",
          "primary-content": "#0b0e14",
          "secondary": "#8b95a7",
          "accent": "#6c8cff",
          "neutral": "#1c212b",
          "neutral-content": "#e6e9ef",
          "base-100": "#0d1017",
          "base-200": "#151922",
          "base-300": "#1e2430",
          "base-content": "#e6e9ef",
          "info": "#5aa9ff",
          "success": "#3ecf8e",
          "warning": "#f5b94a",
          "error": "#f0626b",
        },
      },
    ],
    darkTheme: "susfs",
  },
}
