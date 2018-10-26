$("#register").click(function() {
    $.post(
        "../cgi-bin/project1BD/api.py",
        {
            'json': JSON.stringify(
                {
                    'endpoint': 'registerGuest',
                    'firstName': $("#firstname").val(),
                    'surname': $("#surname").val(),
                    'creditCard': $("#creditCard").val(),
                    'email': $("#email").val(),
                    'phoneNumber': $("#phoneNumber").val(),
                    'handicap': String($("#handicap")[0].checked)
                })
        },
        function (response) {       
            var returnedId = response[0].newguestid;
            if(returnedId == undefined)     {
                alert("Nie udało się zarejestrowac goscia :(")
            } else {
                alert("Utworzono konto goscia o numerze indetyfikacyjnym: " + returnedId);
            }
        });
});