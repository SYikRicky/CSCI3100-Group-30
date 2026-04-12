module.exports = {
  prefix: 'tw-',
  content: [
    "./app/views/**/*.{html,erb}",
    "./app/javascript/**/*.js",
    "./app/helpers/**/*.rb",  
  ],
  theme: { 
      extend: {
        fontFamily: {
        'custom': ['"Saira Stencil One"','sans-serif'],
        },
    } 
  },
  plugins: [],
}