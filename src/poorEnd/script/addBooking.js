$(document).ready(function () {
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
                    'endpoint': 'getGuestInfo'
                })
        },
        function (response) {            
            response.forEach(function (element) {
                $("#guestSelect").append($("<option></option>")
                    .attr("value", element.guestid)
                    .text(element.firstname + ' - ' + element.surname));
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
                $("#extras").append($("<input class='extra' type='checkbox'></input>")
                    .attr("value", element.extrasid));
                $("#extras").append($("<span></span>")
                    .text(element.name));
                $("#extras").append($("<br/>"));
            }, this);
    });
});

$("#book").click(function() {
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
                    'endpoint': 'addBooking',
                    'roomId': $("#roomSelect").val(),
                    'guestId': $("#guestSelect").val(),
                    'startDate': $("#startDate").val(),
                    'endDate': $("#endDate").val(),
                    'extras': extrasArray.join(";")
                })
        },
        function (response) {       
            var returnedId = response[0].bookroom;
            if(returnedId === -1)     {
                alert("Nie udało się zarezerwowac pokoju poniewaz data rezerwacji jest niepoprawna")
            } else if (returnedId === -2) {
                alert("Nie udało się zarezerwowac pokoju poniewaz rezerwacja koliduje juz z aktualną")
            } else if (returnedId === -3) {
                alert("Nie udało się zarezerwowac pokoju poniewaz próbowano zarejestrowac nieistniejacy pokój lub na nieistniejacego gościa")
            } else if (returnedId === -4) {
                alert("Nie udało się zarezerwowac pokoju poniewaz wystapił błąd krytyczny")
            } else {
                alert("Utworzono konto goscia o numerze indetyfikacyjnym: " + returnedId);
            }
        });
});