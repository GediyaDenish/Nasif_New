/** @type {import('tailwindcss').Config} */
const colors = require('tailwindcss/colors')
module.exports = {
  prefix: 'tw-',
  content: [
    "./src/app/components/**/*.{html,ts}",
    "./src/app/modules/**/**/*.{html,ts}",
    "./src/app/modules/**/*.{html,ts}",
  ],
  theme: {
    colors: {
      'primary' : {
        100: '#e7e7e7',
        200: '#d1d1d1',
        300: '#b0b0b0',
        400: '#888888',
        500: '#6d6d6d',
        600: '#5d5d5d',
        700: '#4f4f4f',
        800: '#454545',
        900: '#3d3d3d',
        950: '#000000',
      },
      transparent: 'transparent',
      black: colors.black,
      white: colors.white,
      gray: colors.gray,
      emerald: colors.emerald,
      indigo: colors.indigo,
      yellow: colors.yellow,
      red: colors.red,
      blue: colors.blue,
      amber: colors.amber,
      green: colors.green
    },
    extend: {
      height: {
        page: 'calc(100vh - 60px)',
        content: 'calc(100vh - 60px - 90px)',
        table: 'calc(100vh - 60px - 90px - 56px)',
        support: 'calc(100vh - 60px - 42px - 56px)',
        dassboardList: '600px'
      },
      width:{
        support: '33.333333%'
      },
      maxWidth:{
        supportMsg: '90%'
      },
      minWidth:{
        support: '33.333333%'
      },
      
      visibility: ["group-hover"],
      display: ["group-hover"],
      gridTemplateColumns: {
        '16': 'repeat(16, minmax(0, 1fr))'
      }
    }
  },
  plugins: [],
}
