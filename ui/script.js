// Selectors
let output = document.querySelector("#timer");
let participantsCounter = document.querySelector('#participants-counter');
let playersSection = document.querySelector('.players-section');

// Start Function
let numbers = Array.from(Array(60).keys()).map(String);
for (let i = 0; i < 10; i++) {
  numbers[i] = "0" + numbers[i];
}
numbers.push("00");

let time, loop;
let sec = "00",
  min = "00",
  s = 1,
  m = 1,
  startCheck = false,
  resetCheck = false;

function startFunc(m = 0, s = 3) {
  output.style = "display: block";
  resetFunc();

  let minutes = m;
  let seconds = s;
  startCheck = true;

  // Initial display
  updateDisplay();

  loop = setInterval(function () {
    if (seconds === 0) {
      if (minutes === 0) {
        clearInterval(loop);
        startCheck = false;
        resetFunc();
        return;
      }
      minutes--;
      seconds = 59;
    } else {
      seconds--;
    }

    updateDisplay();
  }, 1000);

  // Helper function to update the display
  function updateDisplay() {
    const min = numbers[minutes];
    const sec = numbers[seconds];
    time = `${min}:${sec}`;
    output.textContent = time;
  }
}

// Stop Function
function stopFunc() {
  output.style = "display: none";

  clearInterval(loop);
  startCheck = false;
}

// Reset Function
function resetFunc() {
  clearInterval(loop);
  time = "00:00";
  output.textContent = time;
  resetCheck = true;
  startCheck = false;
}

let musicPlayer1 = new Audio();
musicPlayer1.volume = 0.2;
let musicPlayer2 = new Audio();
musicPlayer2.volume = 0.2;
musicPlayer2.addEventListener('ended', function() {
  this.currentTime = 0;
  this.play();
}, false);

function playTickTockSound() {
  musicPlayer2.pause();
  musicPlayer2.currentTime = 0;
  musicPlayer2.src = 'tick-tock.mp3';
  musicPlayer2.load();
  musicPlayer2.play();
}

function stopTickTockSound() {
  musicPlayer2.pause();
}

function playSong(songName) {
  musicPlayer1.pause();
  musicPlayer1.currentTime = 0;
  musicPlayer1.src = songName;
  musicPlayer1.load();
  musicPlayer1.play();
}

function stopSong() {
  musicPlayer1.pause();
  musicPlayer1.currentTime = 0;
}

function show() {
  document.querySelector("body").style = "display: flex";
}

function setParticipantsCounter(val) {
  playersSection.style = 'display: block';
  participantsCounter.textContent = `${val}`;
}


window.addEventListener('message', function(event) {
  let item = event.data;

  if (item.show === true) {
    show();
  }

  if (item.show === false) {
    document.querySelector("body").style = "display: none";
  }
  
  if (item.start) {
    startFunc(item.m, item.s);
  }

  if (item.reset) {
    resetFunc();
  }

  if (item.hideTimer) {
    stopFunc();
  }

  if (item.playSong) {
    playSong(item.playSong);
  }

  if (item.stopSong) {
    stopSong();
  }

  if (item.setParticipantsCounter !== undefined) {
    setParticipantsCounter(item.setParticipantsCounter);
  }

  if (item.playTickTockSound) {
    playTickTockSound();
  }

  if (item.stopTickTockSound) {
    stopTickTockSound();
  }

  if (item.hideParticipantsCounter) {
    playersSection.style = "display: none";
  }
});

console.log('init nui');
// show();