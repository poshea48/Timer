$(function() {
  const data = $("#data");
  const startButton = $(".start");
  const stopButton = $(".stop");
  const resetButton = $(".reset");
  const logButton = $(".log");

  startButton.on("click", function(e) {
    e.preventDefault();
    const now = new Date()

    const startDate = now.getFullYear() + '-' + (now.getMonth() + 1) + '-' + now.getDate();
    const startTime = now.getHours() + ':' + now.getMinutes() + ':' + now.getSeconds();

    const xhr = new XMLHttpRequest();
    xhr.open("GET", "")
    data.attr('data-startDate', startDate);
    data.attr('data-startTime', startTime);
    startButton.prop('disabled', true);
    resetButton.prop('disabled', true);
    logButton.prop('disabled', true);
    console.log("Timer has started");
  });
});

// creates new xhr request object
const xhr = new XMLHttpRequest();
const url = 'http://api-to-call.com/endpoint';

// handles response
xhr.responseType = 'json';
xhr.onreadystatechange = function() {
  if (xhr.readyState === XMLHttpRequest.DONE) {
    // code to execute with response
  }
};

// opens request and sends object
xhr.open('GET', url);
xhr.send();
