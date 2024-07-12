/* eslint no-console: 0 */
// Run this example by adding <%= javascript_pack_tag 'hello_vue' %> (and
// <%= stylesheet_pack_tag 'hello_vue' %> if you have styles in your component)
// to the head of your layout file,
// like app/views/layouts/application.html.erb.
// All it does is render <div>Hello Vue</div> at the bottom of the page.

import Vue from 'vue';
import App from '../app.vue';
import { BootstrapVue, BootstrapVueIcons } from 'bootstrap-vue';
import 'bootstrap/dist/css/bootstrap.css';

Vue.use(BootstrapVue);
Vue.use(BootstrapVueIcons);

let prefix = '/';
if (process.env.NODE_ENV !== 'development') {
  prefix = '/real_smile/';
}
Vue.prototype.$basePrefix = prefix;

Vue.prototype.$SOURCES = {
  0: 'Not indicated',
  1: 'Radio advertisement',
  2: 'TV advertisement',
  3: 'Podcast',
  4: 'Billboard / sign / poster / pamphlet / newspaper advertisement',
  5: 'Newspaper article / magazine article / newsletter',
  6: 'Social media advertisement',
  7: 'Social media post / discussion',
  8: 'Friend / family member / acquaintance',
  9: 'Local organization',
  10: 'Local organization or peer educator',
  11: 'Other',
  12: 'VTC Team CBO',
  13: 'FTM Vietnam Organization',
  14: 'CSAGA',
  15: 'BE+ Clun in University of Social Sciences and Humanities (HCMUSSH)',
  16: 'Event Club in Van Lang University',
  17: 'Club in Can Tho University',
  18: 'RMIT University Vietnam',
  19: 'YKAP Vietnam',
  20: 'Song Tre Son La',
  21: 'The Leader House An Giang',
  22: 'Vuot Music Video',
  23: 'Motive Agency',
  24: 'Social work Club from University of Labour and Social Affairs 2',
  25: 'Influencers',
  26: 'Instagram',
  27: 'Parade',
  28: 'Conference / webinar',
  29: 'Subway exposition',
  30: 'University Events',
  31: 'Reference Centers',
  32: 'Community Sport Teams',
  33: 'LGBTI shelters',
  34: 'Dating app',
  35: 'WhatsApp / Telegram',
  36: 'TikTok',
  37: 'Twitter / X',
};

Vue.prototype.$SGM_LABELS = {
  'non-binary person': 'Non-binary People',
  'transgender woman': 'Transgender Women',
  'transgender man': 'Transgender Men',
  'woman attracted to women': 'Women Attracted To Women',
  'man attracted to men': 'Men Attracted To Men',
  'multi-attracted woman': 'Multi-Attracted Women',
  'multi-attracted man': 'Multi-Attracted Men',
};

Vue.prototype.$COLORS = {
  Kenya: '#006600',
  'Kenya (cumulative)': '#000000',
  Vietnam: '#DA251D',
  'Vietnam (cumulative)': '#FFCD00',
  Brazil: '#0C87D1',
  'Brazil (cumulative)': '#002776',
  All: '#732982',
  Target: '#FF7F00',
};

document.addEventListener('DOMContentLoaded', () => {
  const app = new Vue({
    render: (h) => h(App),
  }).$mount();
  document.body.appendChild(app.$el);
});

// The above code uses Vue without the compiler, which means you cannot
// use Vue to target elements in your existing html templates. You would
// need to always use single file components.
// To be able to target elements in your existing html/erb templates,
// comment out the above code and uncomment the below
// Add <%= javascript_pack_tag 'hello_vue' %> to your layout
// Then add this markup to your html template:
//
// <div id='hello'>
//   {{message}}
//   <app></app>
// </div>

// import Vue from 'vue/dist/vue.esm'
// import App from '../app.vue'
//
// document.addEventListener('DOMContentLoaded', () => {
//   const app = new Vue({
//     el: '#hello',
//     data: {
//       message: "Can you say hello?"
//     },
//     components: { App }
//   })
// })
//
//
//
// If the project is using turbolinks, install 'vue-turbolinks':
//
// yarn add vue-turbolinks
//
// Then uncomment the code block below:
//
// import TurbolinksAdapter from 'vue-turbolinks'
// import Vue from 'vue/dist/vue.esm'
// import App from '../app.vue'
//
// Vue.use(TurbolinksAdapter)
//
// document.addEventListener('turbolinks:load', () => {
//   const app = new Vue({
//     el: '#hello',
//     data: () => {
//       return {
//         message: "Can you say hello?"
//       }
//     },
//     components: { App }
//   })
// })
