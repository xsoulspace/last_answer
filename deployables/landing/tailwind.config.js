/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./build/**/*.{js,ts,jsx,tsx,html}"],
  theme: {
    extend: {},
  },

  plugins: [require("@tailwindcss/forms"), require("@tailwindcss/typography")],
};
