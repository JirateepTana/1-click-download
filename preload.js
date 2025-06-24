const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('electronAPI', {
  installNode: () => ipcRenderer.invoke('install-node')
});