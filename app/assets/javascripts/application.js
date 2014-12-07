// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap.min
//= require chart.min

jQuery(document).ready(function() {
  var fromDate, toDate, dragging = false;
  var baseUri = jQuery('a[rel=index]').attr('href');
  var dates = {};

  jQuery('td[data-date]').each(function(idx, e){
    var elem = jQuery(e);
    dates[elem.attr('data-date')] = elem;
  });

  jQuery('td[data-date]').on('mousedown', function(event) {
    fromDate = event.target.dataset['date'];
    dragging = true;
  }).on('mouseup', function(event) {
    dragging = false;
    if (fromDate) {
      toDate = event.target.dataset['date'];

      if (fromDate < toDate) {
        filter = '?from_time=' + fromDate + '&to_time=' + toDate;
      } else {
        filter = '?from_time=' + toDate + '&to_time=' + fromDate;
      }

      window.location =  baseUri + filter;
    }
  });

  jQuery('table.calendar td[data-date]').on('mouseover', function(event) {
    var currentTarget = jQuery(event.target);
    if (dragging && currentTarget !== undefined) {
      if (currentTarget.attr('data-date')) {
        currentTarget = currentTarget.closest('td');
      }
      var currentDate = currentTarget.attr('data-date');
      var startDate   = (fromDate < currentDate) ? fromDate : currentDate;
      var endDate     = (fromDate > currentDate) ? fromDate : currentDate;

      jQuery.each(dates, function(date, elem) {
        if (date < startDate || date > endDate) {
          elem.removeClass('selected');
        } else {
          elem.addClass('selected');
        }
      });
    }
  });
});

jQuery(document).ready(function(){
  if (document.getElementById('in-out-diagram')) {
    var chartCtx  = document.getElementById('in-out-diagram').getContext('2d');
    var activities     = [];
    var precipitations = [];
    var chartLabels    = [];
    var currentDate    = '';
    var currentIdx     = 0;

    var speciesData = jQuery('thead th.species').map(function(idx, elem) {
      var colour = jQuery(elem).data('diagram-colour');
      return {
          fillColor: "rgba("+ colour +",0.5)",
          strokeColor: "rgba("+ colour +",0.8)",
          highlightFill: "rgba("+ colour +",0.75)",
          highlightStroke: "rgba("+ colour +",1)",
          label: jQuery(elem).text(),
          type: 'bar',
          data: []
        };
    });

    jQuery('tr.dataset').each(function(idx, elem) {
      var e             = jQuery(elem);
      var date          = e.data('date');
      var activity      = parseInt(e.find('.total-activity').text());
      var precipitation = parseFloat(e.find('.precipitation-amount').text());

      if (date != currentDate) {
        if (currentDate != '') currentIdx ++;
        currentDate = date;

        chartLabels[currentIdx]    = date;
        precipitations[currentIdx] = precipitation * 10;
        activities[currentIdx]     = activity;
        e.find('td.species').each(function(i, spec) {
          speciesData[i].data[currentIdx] = parseInt(jQuery(spec).text());
        });
      } else {
        precipitations[currentIdx] += precipitation * 10;
        activities[currentIdx]     += activity;
        e.find('td.species').each(function(i, spec) {
          speciesData[i].data[currentIdx] += parseInt(jQuery(spec).text());
        });
      }
    });

    var chartData = {
      labels: chartLabels,
      datasets: [
        { label: "Niederschlag",
          type: "line",
          bezierCurve: false,
          fillColor: "rgba(220,220,0,0.5)",
          strokeColor: "rgba(220,220,0,0.8)",
          highlightFill: "rgba(220,220,0,0.75)",
          highlightStroke: "rgba(220,220,0,1)",
          data: precipitations
        },
        { label: "Gesamt-Aktivität",
          type: "bar",
          fillColor: "rgba(200,200,200,0.5)",
          strokeColor: "rgba(200,200,200,0.8)",
          highlightFill: "rgba(200,200,200,0.75)",
          highlightStroke: "rgba(200,200,200,1)",
          data: activities
        }
      ]
    };

    jQuery.each(speciesData, function(idx, obj){
      chartData.datasets[idx + 2] = obj;
    });

    var options = {
      //Boolean - Whether the scale should start at zero, or an order of magnitude down from the lowest value
      scaleBeginAtZero: true,

      //Boolean - Whether grid lines are shown across the chart
      scaleShowGridLines: true,

      //String - Colour of the grid lines
      scaleGridLineColor: "rgba(0,0,0,.05)",

      //Number - Width of the grid lines
      scaleGridLineWidth: 1,

      //Boolean - If there is a stroke on each bar
      barShowStroke: true,

      //Number - Pixel width of the bar stroke
      barStrokeWidth: 1,

      //Number - Spacing between each of the X value sets
      barValueSpacing: 5,

      //Number - Spacing between data sets within X values
      barDatasetSpacing: 1,

      responsive: true,
      bezierCurve: false
    };

    var chart = new Chart(chartCtx).Overlay(chartData, options);
  }
});
