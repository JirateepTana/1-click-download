// filepath: d:/Github Project/1-click-download/main.js
const { app, BrowserWindow, ipcMain } = require('electron');
const path = require('path');
const { exec } = require('child_process');

function createWindow() {
  const win = new BrowserWindow({
    width: 800,
    height: 600,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: true,
      nodeIntegration: false,
    },
  });
  win.loadFile('index.html');
}

ipcMain.handle('install-node', async () => {
  return new Promise((resolve, reject) => {
    const psPath = 'C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe';
    const psCommand = '-ExecutionPolicy Bypass -File "./scripts/install.ps1"';
    const env = {
      ...process.env,
      SystemRoot: 'C:\\Windows',
      PATH: process.env.PATH || 'C:\\Windows\\System32;C:\\Windows'
    };
    exec(`"${psPath}" ${psCommand}`, { cwd: __dirname, env }, (error, stdout, stderr) => {
      if (error) {
        resolve(`Error: ${stderr || error.message}`);
      } else {
        resolve(stdout);
      }
    });
  });
});



app.whenReady().then(createWindow);

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') app.quit();
});