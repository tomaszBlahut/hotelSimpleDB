var bookingId = 0;
var employeeId = 0;
var changed = [];

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

function notLogged() {
    $("#notLogged").removeClass('hidden');
}

function logged() {
    $("#employeePanel").removeClass('hidden');
}

$("#logOut").click(function() {
    removeCookie('employeeId');
    location.reload();
});

$(document).ready(function () {
    employeeId = getCookie('employeeId');

    if(employeeId == null) {
        notLogged();
        $("#loginBox").removeClass('hidden');
    } else {
        logged();
        $("#employeePanel").removeClass('hidden');
    }

    $.post(
        "../cgi-bin/project1BD/api.py",
        {
            'json': JSON.stringify(
                {
                    'endpoint': 'roomInfo'
                })
        },
        function (response) {            
            response.forEach(function (element) {
                $("#roomSelect").append($("<option></option>")
                    .attr("value", element.roomid)
                    .text(element.roomnumber + ' - ' + element.roomname));
            }, this);
        });

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
                $("#extras").append($("<input class='extra canChange' type='checkbox' id='extras'></input>")
                    .attr("value", element.extrasid));
                $("#extras").append($("<span></span>")
                    .text(element.name));
                $("#extras").append($("<br/>"));
            }, this);
    });

    var url_string = window.location.href;
    var url = new URL(url_string);
    bookingId = url.searchParams.get("bookingId");

    $.post(
        "../cgi-bin/project1BD/api.py",
        {
            'json': JSON.stringify(
                {
                    'endpoint': 'getBookingInfoWithId',
                    'bookingId': String(bookingId)
                })
        },
        function (response) {            
            $("#startDate").val(response[0].startdate);
            $("#endDate").val(response[0].enddate);
            $("#roomSelect").val(response[0].roomid);

            $("#startDate").change(function() { 
                changed.push(String($(this).attr('id')));
            });
            
            $("#endDate").change(function() { 
                changed.push(String($(this).attr('id')));
            });
            
            $("#roomSelect").change(function() { 
                changed.push(String($(this).attr('id')));
            });
    });

    $.post(
        "../cgi-bin/project1BD/api.py",
        {
            'json': JSON.stringify(
                {
                    'endpoint': 'getExtrasForBooking',
                    'bookingId': String(bookingId)
                })
        },
        function (response) {      
            response.forEach(function (element) {       
                $(".extra[value='" + element.extrasid + "']")[0].checked = true;
            });
            
            $("#extras").change(function() { 
                changed.push(String($(this).attr('id')));
            });
    });    
});

$("#change").click(function() {
    var extrasArray = [];
    $(".extra").each(function( index, element ) {
        if(element.checked) {
            extrasArray.push(element.value);
        }
    });    

    $.post(
        "../cgi-bin/project1BD/api.py",
        {
            'json': JSON.stringify(
                {
                    'endpoint': 'changeBooking',
                    'bookingId': String(bookingId),
                    'roomId': changed.includes('roomSelect') ? $("#roomSelect").val() : "null",
                    'startDate': changed.includes('startDate') ? $("#startDate").val() : "null",
                    'endDate': changed.includes('endDate') ? $("#endDate").val() : "null",
                    'extras': changed.includes('extras') ? extrasArray.join(";") : "null",
                    'userId': employeeId
                })
        },
        function (response) {       
            var returnedId = response[0].changebooking;
            if(returnedId === -1)     {
                alert("Nie masz uprawnien, musisz byc co najmniej kieronikiem")
            } else if (returnedId === -2) {
                alert("Nie udało się zmienic rezerwacji pokoju poniewaz rezerwacja koliduje juz z aktualną")
            } else {
                alert("Wprowadzono modyfikacji: " + returnedId);
            }

            changed = [];
        });
});