
// Define the Units.
var UNITS = {
  1: {speed: 'km/h', distance: 'm'},
  2: {speed: 'mph', distance: 'ft'}
};

// When an input is changed, and it is the units selection box, set the
// Label with the units in use.
$(document).on('shiny:inputchanged', function(event) {
  if(event.name === 'units') {
    $("#unitsTxt").html(UNITS[event.value].speed);
  }
});