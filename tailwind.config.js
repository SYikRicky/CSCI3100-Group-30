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
        // 'custom' 是你自己起的類名，'Noto Sans TC' 必須與 Google Fonts 提供的一致
        'custom': ['"Saira Stencil One"','sans-serif'],
        },
    } 
  },
  plugins: [],
}