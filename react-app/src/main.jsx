import React from 'react';
import ReactDOM from 'react-dom';
import App from './app.jsx';

class ReactAppElement extends HTMLElement {
  connectedCallback() {
    console.log('ReactApp Connected');

    const shadowRoot = this.attachShadow({ mode: 'open' });
    const div = document.createElement('div');
    shadowRoot.appendChild(div);

    ReactDOM.render(<App />, div);
  }
}

customElements.define('react-app', ReactAppElement);
