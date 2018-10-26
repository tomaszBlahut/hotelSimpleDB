$(document).ready(function () {
    $.post(
        "../cgi-bin/project1BD/api.py",
        {
            'json': JSON.stringify(
                {
                    'endpoint': 'getRoomCategories'
                })
        },
        function (response) {
            buildHtmlTable('#categoryTable', response);
        });
});

$("#show").click(function() {
        $.post(
            "../cgi-bin/project1BD/api.py",
            {
                'json': JSON.stringify(
                    {
                        'endpoint': 'showActualBookingsForCapacity',
                        'capacity': $("#capacity").val()
                    })
            },
            function (response) {            
                buildHtmlTable('#resultsTable', response);
            });
});

function buildHtmlTable(selector, myList) {
    $(selector).html('');
    var columns = addAllColumnHeaders(myList, selector);    
    for (var i = 0; i < myList.length; i++) {
      var row$ = $('<tr/>');
      for (var colIndex = 0; colIndex < columns.length; colIndex++) {
        var cellValue = (String)(myList[i][columns[colIndex]]);
        //if (cellValue == null) cellValue = "";
        row$.append($('<td/>').html(cellValue));
      }
      $(selector).append(row$);
    }
  }
  
  function addAllColumnHeaders(myList, selector) {
    var columnSet = [];
    var headerTr$ = $('<tr/>');
  
    for (var i = 0; i < myList.length; i++) {
      var rowHash = myList[i];
      for (var key in rowHash) {
        if ($.inArray(key, columnSet) == -1) {
          columnSet.push(key);
          headerTr$.append($('<th/>').html(key));
        }
      }
    }
    $(selector).append(headerTr$);
  
    return columnSet;
  }