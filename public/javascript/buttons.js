
$(function() {
  const data = $("#data");
  const startButton = $(".start");
  const stopButton = $(".stop");
  const resetButton = $(".reset");
  const logButton = $(".log");
  let startTime = data.attr("data-startTime");
  let endTime;
  let todaysDate;
  let secondsWorked = Number(data.attr("data-secondsWorked"));

  data.attr("data-date") || startNewDay();
  if (startTime) {
    startButton.prop("disabled", true);
    resetButton.prop("disabled", true);  // Need to create a function to toggle
    logButton.prop("disabled", true);
  }

  console.log(todaysDate);
  startButton.on("click", function(e) {
    e.preventDefault();
    todaysDate = new Date();
    startTimer();

    console.log("Timer has started");
  });

  stopButton.on("click", function(e) {
    e.preventDefault();
    stopTimer();
    console.log(secondsWorked);
  });

  resetButton.on("click", function(e) {
    e.preventDefault();
    startNewDay();
  });

  displayWorkedHoursToday();

  console.log("Hey");

  function startTimer() {
    startTime = Date.now();
    toggleButtons();
    stopButton.prop("disabled", false);
    data.attr("data-startTime", startTime);
    // startButton.prop("disabled", true);
    // logButton.prop("disabled", true);
    // resetButton.prop("disabled", true);
  }

  function stopTimer() {
    endTime = Date.now();
    stopButton.prop("disabled", true);
    startButton.prop("disabled", false);
    resetButton.prop("disabled", false);
    logButton.prop("disabled", false);
    secondsWorked += (endTime - startTime) / 1000;
    data.attr("secondsWorked", secondsWorked);
    displayWorkedHoursToday();
  }

  function displayWorkedHoursToday() {
    $("#hours-today").text("");
    $("#hours-today").text(convertToHours());
  }

  function toggleButtons() {
    $("button").each(function(index, btn) {
      $(this).disabled ? $(this).prop("disabled", false) : $(this).prop("disabled", true);
    });

  }

  function startNewDay() {
    startTime = '';
    endTime = undefined;
    todaysDate = getJustDate(new Date());
    data.attr("data-startTime", "");
    data.attr("data-date", todaysDate);
    data.attr("data-secondsWorked", "");

    startButton.prop("disabled", false);
    stopButton.prop("disabled", true);
    logButton.prop("disabled", true);
    resetButton.prop("disabled", true);
  }

  function getJustDate(date) {
    return (date.getMonth() + 1) + '-' + date.getDate() + '-' + date.getFullYear();
  }

  function convertToHours() {
    return (Number(secondsWorked) / 3600).toFixed(2);
  }

});
