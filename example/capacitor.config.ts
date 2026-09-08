import type { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'com.faceplugin.documentreader',
  appName: 'DocumentReader',
  webDir: 'dist',
  // Transparent so native live preview shows under the WebView.
  backgroundColor: '#00000000',
  plugins: {
    Camera: {
      permissions: {
        camera: 'This app needs camera access to capture ID documents.',
        photos: 'This app needs photo library access to recognize documents from gallery.',
      },
    },
  },
};

export default config;
