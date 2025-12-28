import { mount } from 'svelte';
import App from './App.svelte';
import './app.css';
import { registerSW } from 'virtual:pwa-register';
import { library } from '@fortawesome/fontawesome-svg-core';
import { faGithub } from '@fortawesome/free-brands-svg-icons';

// Add FontAwesome icons to library
library.add(faGithub);

const updateSW = registerSW({
  onNeedRefresh() {
    console.log('New content available, reload to update.');
  },
  onOfflineReady() {
    console.log('App ready to work offline');
  },
});

const app = mount(App, {
  target: document.getElementById('app')!,
});

export default app;
