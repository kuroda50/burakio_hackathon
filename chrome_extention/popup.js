let mediaRecorder;
let recordedChunks = [];
let startTime;
let timerInterval;

const startBtn = document.getElementById('startBtn');
const stopBtn = document.getElementById('stopBtn');
const timerDisplay = document.getElementById('timer');

// Start ボタンクリックイベント
startBtn.addEventListener('click', () => {
  console.log('Start button clicked');

  startBtn.disabled = true; // ボタン無効化
  stopBtn.disabled = true;  // 一時無効化（成功時に有効化）

  chrome.tabCapture.capture({ audio: true, video: false }, (stream) => {
    if (!stream) {
      alert('録音開始に失敗しました');
      startBtn.disabled = false;
      return;
    }

    console.log('Stream captured:', stream);
    recordedChunks = [];

    try {
      mediaRecorder = new MediaRecorder(stream, { mimeType: 'audio/webm' });
    } catch (err) {
      console.error('MediaRecorder 作成エラー:', err);
      alert('MediaRecorder が作れませんでした');
      startBtn.disabled = false;
      return;
    }

    mediaRecorder.ondataavailable = (event) => {
      if (event.data.size > 0) {
        recordedChunks.push(event.data);
      }
    };

    mediaRecorder.onstop = () => {
      clearInterval(timerInterval);
      timerDisplay.textContent = '00:00';

      const blob = new Blob(recordedChunks, { type: 'audio/webm' });
      const url = URL.createObjectURL(blob);

      // ファイル名：recording-YYYY-MM-DD_HH-MM-SS.webm
      const filename = `recording-${new Date().toISOString().replace(/[:.]/g, '-')}.webm`;

      chrome.downloads.download({
        url: url,
        filename: filename,
        saveAs: true
      }, (downloadId) => {
        if (chrome.runtime.lastError) {
          alert('ダウンロードに失敗しました: ' + chrome.runtime.lastError.message);
        } else {
          console.log('Download started: ', downloadId);
        }
      });

      startBtn.disabled = false;
      stopBtn.disabled = true;
      startBtn.classList.remove('recording');
    };

    try {
      mediaRecorder.start();
      console.log('録音開始');
      stopBtn.disabled = false;

      // UI変更とタイマー開始
      startRecordingTimer();
      startBtn.classList.add('recording');
    } catch (err) {
      console.error('録音開始エラー:', err);
      alert('録音を開始できませんでした');
      startBtn.disabled = false;
    }
  });
});

// Stop ボタンクリックイベント
stopBtn.addEventListener('click', () => {
  console.log('Stop button clicked');

  if (mediaRecorder && mediaRecorder.state === 'recording') {
    mediaRecorder.stop();
    startBtn.disabled = false;
    stopBtn.disabled = true;

    stopRecordingTimer();
    startBtn.classList.remove('recording');
  } else {
    console.warn('録音はすでに停止しています');
  }
});

// タイマー開始
function startRecordingTimer() {
  startTime = Date.now();
  timerInterval = setInterval(() => {
    const elapsed = Date.now() - startTime;
    const minutes = Math.floor(elapsed / 60000).toString().padStart(2, '0');
    const seconds = Math.floor((elapsed % 60000) / 1000).toString().padStart(2, '0');
    timerDisplay.textContent = `${minutes}:${seconds}`;
  }, 1000);
}

// タイマー停止
function stopRecordingTimer() {
  clearInterval(timerInterval);
  timerDisplay.textContent = '00:00';
}
