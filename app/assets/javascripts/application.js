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
    if (fromDate && fromDate !== undefined) {
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
      if (currentTarget == undefined) return;
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
    var canvas         = document.getElementById('in-out-diagram');
    var chartCtx       = canvas.getContext('2d');
    var numberOfData   = jQuery('tr.dataset').size();
    var activities     = [];
    var precipitations = [];
    var chartLabels    = [];
    var currentDate    = '';
    var currentIdx     = 0;

    var speciesData = jQuery('thead th.use-in-graph').map(function(idx, elem) {
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
      var timeElement   = e.find('time');
      var activity      = parseInt(e.find('.total-activity').text());
      var precipitation = parseFloat(e.find('.precipitation-amount').text());

      if (timeElement.attr('date') != currentDate || numberOfData <= 24) {
        if (currentDate != '') {
          currentIdx ++;
        }

        if (numberOfData <= 24) {
          currentDate = String(timeElement.text()).replace(/^\s+|\s+$/g, '');;
        } else {
          currentDate = String(timeElement.attr('date')).replace(/^\s+|\s+$/g, '');;
        }

        chartLabels[currentIdx]    = currentDate;
        precipitations[currentIdx] = precipitation;
        activities[currentIdx]     = activity;
        e.find('td.use-in-graph').each(function(i, spec) {
          speciesData[i].data[currentIdx] = parseInt(jQuery(spec).text());
        });
      } else {
        precipitations[currentIdx] += precipitation;
        activities[currentIdx]     += activity;
        e.find('td.use-in-graph').each(function(i, spec) {
          speciesData[i].data[currentIdx] += parseInt(jQuery(spec).text());
        });
      }
    });

    var chartData = {
      labels: chartLabels,
      datasets: [
        { label: "Niederschlag",
          type: "line",
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
      scaleBeginAtZero: true,
      scaleShowGridLines: true,
      scaleFontSize: 10,
      scaleGridLineColor: 'rgba(0,0,0,0.05)',
      scaleGridLineWidth: 1,
      barShowStroke: true,
      barStrokeWidth: 1,
      barValueSpacing: 4,
      barDatasetSpacing: 1,
      pointDot: true,
      pointDotRadius: 2,
      responsive: true,
      maintainAspectRatio: false,
      bezierCurve: false,
      animation: false,
      tooltipFontSize: 10,
      tooltipTitleFontSize: 11
    };

    var chart = new Chart(chartCtx).Overlay(chartData, options);

    canvas.onclick = function(evt) {
      var activeBars = chart.getPointsAtEvent(evt);
      console.log(activeBars);
    };

  }
});
