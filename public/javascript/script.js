// var time = 0;
// var running = 0;
//
// function startPause() {
//   if (running == 0) {
//     runnning = 1;
//     increment();
//     document.getElementById('startPause').innerHTML = 'Pause';
//     document.getElementById('startPause').style.backgroundColor = 'red';
//     document.getElementById('startPause').style.borderColor = 'red';
//
//   } else {
//     running = 0;
//     document.getElementById('startPause').innerHTML = 'Resume';
//     document.getElementById('startPause').style.backgroundColor = 'green';
//     document.getElementById('startPause').style.borderColor = 'green';
//   }
// }
//
// function reset() {
//   running = 0;
//   time = 0;
//
//   document.getElementById('startPause').innerHTML = 'Start';
//   document.getElementById('output').innerHTML = '0:00:00:00';
// //   document.getElementById('startPause').style.backgroundColor = 'green';
// //   document.getElementById('startPause').style.borderColor = 'green';
// // }
// //
// // function increment() {
// //   if (running == 1) {
// //     setTimeout(function(){
// //       time += 1;
// //       var mins = Math.floor(time/10/60);
// //       var secs = Math.floor(time/10 % 60);
// //       var hours = Math.floor(time/10/60/60);
// //       var tenths = time % 10;
// //
// //       if (mins < 10) {
// //         mins = '0' + mins;
// //       }
// //       if (secs < 10) {
// //         secs = '0' + secs;
// //       }
// //
// //       document.getElementById('output').innerHTML = hours + ':' + mins + ':' + secs + ':' + tenths + '0';
// //       increment();
// //
// //     }, 100);
// //   }
// // }
//
// var ss = document.getElementByClassName('timer');
//
// [].forEach.call(ss, function (s) {
//   var currentTimer = 0;
//   var interval = 0;
//   var lastUpdateTime = new Date().getTime();
//   var start = s.querySelector('button.start');
//   var stop = s.querySelector('button.stop');
//   var reset = s.querySelector('span.minutes');
//   var secs = s.querySelector('span.seconds');
//   var cents = s.querySelector('span.centiseconds');
//
//   start.addEventListener('click', startTimer);
//   stop.addEventListener('click', stopTimer);
//   reset.addEventListener('click', resetTimer);
//
//   function pad (n) {
//     return ('00' + n).substr(-2);
//   }
//
//   function update () {
//     var now = new Date().getTime();
//     var dt = now - lastUpdateTime;
//
//     currentTimer += dt;
//
//     var time = new Date(currentTimer);
//
//     mins.innerHTML = pad(time.getMinutes());
//     secs.innerHTML = pad(time.getSeconds());
//     cents.innerHTML = pad(Math.floor(time.getMilliseconds() / 10));
//
//     lastUpdateTime = now;
//   }
//
//   function startTimer () {
//     if (!interval) {
//       lastUpdateTime = new Date().getTime();
//       interval = setInterval(update, 1);
//     }
//   }
//
//   function stopTimer () {
//     clearInterval(interval);
//     interval = 0;
//   }
//
//   function resetTimer () {
//     stopTimer();
//
//     currentTimer = 0;
//
//     mins.innerHTML = secs.innerHTML = cents.innerHTML = pad(0);
//   }
// });



var Timer = {
  bindEvents: function() {
    this.startButton.addEventListener('click', this.handleStartButton.bind(this));
    this.stopButton.addEventListener('click', this.handleStopButton);
    this.logButton.addEventListener('click', this.handleLogButton);
    this.resetButton.addEventListener('click', this.handleResetButton);
  },

  handleStartButton: function(e) {
    e.preventDefault();
    let request = new XMLHttpRequest();
    let self = this;
    request.open('POST', '/start_time')
    request.addEventListener('load', function(e) {
      self.startButton.disabled = true;
      self.stopButton.disabled = false;
      self.logButton.disabled = true;
      self.resetButton.disabled = true;
    });

    request.send();
  },

  getSessionInfo: function() {
    let request = new XMLHttpRequest();
    let session;
    request.open('GET', '/session_info');
    request.addEventListener('load', function(e) {
      debugger;
      session = request.response;
    })

    request.send();
  },

  init: function() {
    this.getSessionInfo()
    this.startButton = document.getElementById('start');
    this.stopButton = document.getElementById('stop');
    this.logButton = document.getElementById('log');
    this.resetButton = document.getElementById('reset');
    this.bindEvents();
  }
}

document.addEventListener('DOMContentLoaded', function() {
  Timer.init();
})
