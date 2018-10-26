var employeeId = 0;

function setCookie(key, value) {
    var expires = new Date();
    expires.setTime(expires.getTime() + (1 * 24 * 60 * 60 * 1000));
    document.cookie = key + '=' + value + ';expires=' + expires.toUTCString();
}

function removeCookie(key) {
    document.cookie = key + '=' + 'null' + ';expires=Thu, 18 Dec 2013 12:00:00 UTC';
}

function getCookie(key) {
    var keyValue = document.cookie.match('(^|;) ?' + key + '=([^;]*)(;|$)');
    return keyValue ? keyValue[2] : null;
}

$(document).ready(function () {
    employeeId = getCookie('employeeId');

    $("#loginBox").addClass('hidden');
    $("#employeePanel").addClass('hidden');

    if(employeeId == null) {
        notLogged();
        $("#loginBox").removeClass('hidden');
    } else {
        logged();
        $("#employeePanel").removeClass('hidden');
    }
});

function notLogged() {
    getEmployees(true);    
}

function logged() {
    getEmployees(false);
    getBookings();
    getExtras();
}

function getEmployees(toLogin) {
    $.post(
        "../cgi-bin/project1BD/api.py",
        {
            'json': JSON.stringify(
                {
                    'endpoint': 'listEmployees'
                })
        },
        function (response) {            
            response.forEach(function (element) {
                $(toLogin ? "#employeeSelect" : "#removeEmployeeSelect").append($("<option></option>")
                    .attr("value", element.employeeid)
                    .text(element.firstname + " " + element.surname));
            }, this);
            if(toLogin) {
                buildHtmlTable('#employeeTable', response);
            }
    });
}

function getBookings() {
    $.post(
        "../cgi-bin/project1BD/api.py",
        {
            'json': JSON.stringify(
                {
                    'endpoint': 'getBookingInfo'
                })
        },
        function (response) {            
            response.forEach(function (element) {                
                $("#bookingSelect").append($("<option></option>")
                    .attr("value", element.bookingid)
                    .text(element.roomnumber + ": " + element.startdate + " - " + element.enddate));
            }, this);
    });
}

function getExtras() {
    $.post(
        "../cgi-bin/project1BD/api.py",
        {
            'json': JSON.stringify(
                {
                    'endpoint': 'getExtras'
                })
        },
        function (response) {            
            response.forEach(function (element) {                
                $("#extrasSelect").append($("<option></option>")
                    .attr("value", element.extrasid)
                    .text(element.name));
            }, this);
    });
}

$("#employeeSelect").change(function() {    
        if($(this).val() > 0) {
            setCookie('employeeId', $(this).val());
            location.reload();
        }
});

$("#logOut").click(function() {
    removeCookie('employeeId');
    location.reload();
});

$("#checkIn").click(function() {
    $.post(
        "../cgi-bin/project1BD/api.py",
        {
            'json': JSON.stringify(
                {
                    'endpoint': 'checkInEmployee',
                    'employeeId': employeeId
                })
        },
        function (response) {            
        });
});

$("#checkOut").click(function() {
    $.post(
        "../cgi-bin/project1BD/api.py",
        {
            'json': JSON.stringify(
                {
                    'endpoint': 'checkOutEmployee',
                    'employeeId': employeeId
                })
        },
        function (response) {            
        });
});

$("#removeEmployee").click(function() {
    $.post(
        "../cgi-bin/project1BD/api.py",
        {
            'json': JSON.stringify(
                {
                    'endpoint': 'removeEmployee',
                    'employeeId': $("#removeEmployeeSelect").val(),
                    'userId': employeeId
                })
        },
        function (response) {       
            var returnedId = response[0].removeemployee;
            if(returnedId === -1)     {
                alert("Nie masz wystarczajacych uprawnien do usuniecia pracownika!")
            } else {
                alert("Usunieto pracownika o numerze indetyfikacyjnym: " + returnedId);
            }
        });
});

$("#addEmployee").click(function() {
    // redirect to add Employee
});

$("#checkInBooking").click(function() {
    $.post(
        "../cgi-bin/project1BD/api.py",
        {
            'json': JSON.stringify(
                {
                    'endpoint': 'checkInBooking',
                    'bookingId': $("#bookingSelect").val(),
                    'userId': employeeId
                })
        },
        function (response) {       
            var result = response[0].checkinbooking;
            if(result === true)     {
                alert("Zameldowano pomyslnie!")
            } else {
                alert("Nie udalo sie zameldowac. Nie masz wystarcajacych uprawnien (zbyt niskie stanowisko lub nie jestes wbity do pracy)");
            }
        });
});

$("#checkOutBooking").click(function() {
    $.post(
        "../cgi-bin/project1BD/api.py",
        {
            'json': JSON.stringify(
                {
                    'endpoint': 'checkOutBooking',
                    'bookingId': $("#bookingSelect").val(),
                    'userId': employeeId
                })
        },
        function (response) {       
            var result = response[0].checkoutbooking;
            if(result === true)     {
                alert("Wymeldowano pomyslnie!")
            } else {
                alert("Nie udalo sie wymeldowac. Nie masz wystarcajacych uprawnien (zbyt niskie stanowisko lub nie jestes wbity do pracy)");
            }
        });
});

$("#closeBooking").click(function() {
    $.post(
        "../cgi-bin/project1BD/api.py",
        {
            'json': JSON.stringify(
                {
                    'endpoint': 'closeBooking',
                    'bookingId': $("#bookingSelect").val(),
                    'userId': employeeId
                })
        },
        function (response) {       
            var result = response[0].closebooking;
            if(result === true)     {
                alert("Zamknieto rezerwacje pomyslnie!")
            } else {
                alert("Nie udalo sie zamknac rezerwacji. Nie masz wystarcajacych uprawnien (zbyt niskie stanowisko lub nie jestes wbity do pracy)");
            }
        });
});

$("#showTotalCostBooking").click(function() {
    $.post(
        "../cgi-bin/project1BD/api.py",
        {
            'json': JSON.stringify(
                {
                    'endpoint': 'getTotalCostOfBooking',
                    'bookingId': $("#bookingSelect").val()
                })
        },
        function (response) {       
            buildHtmlTable('#showCostTable', response);
        });
});

$("#changeBooking").click(function() {
    window.location = 'changeBooking.html?bookingId=' + $("#bookingSelect").val();
});

$("#showBookingWithExtras").click(function() {
    $.post(
        "../cgi-bin/project1BD/api.py",
        {
            'json': JSON.stringify(
                {
                    'endpoint': 'getGetCountOfActiveBookingsWithExtras',
                    'extrasId': $("#extrasSelect").val()
                })
        },
        function (response) {       
            buildHtmlTable('#showBookingsTable', response);
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