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
                    'endpoint': 'getRoles'
                })
        },
        function (response) {            
            response.forEach(function (element) {
                $("#roleSelect").append($("<option></option>")
                    .attr("value", element.roleid)
                    .text(element.name));
            }, this);
        });
});

$("#add").click(function() {
    $.post(
        "../cgi-bin/project1BD/api.py",
        {
            'json': JSON.stringify(
                {
                    'endpoint': 'addEmployee',
                    'firstName': $("#firstname").val(),
                    'surname': $("#surname").val(),
                    'bankAccountNumber': $("#bankAccountNumber").val(),
                    'roleId': $("#roleSelect").val(),
                    'userId': employeeId
                })
        },
        function (response) {       
            var returnedId = response[0].addemployee;
            if(returnedId == -1)     {
                alert("Nie masz takich uprawnien")
            } else {
                alert("Utworzono konto pracownika o numerze indetyfikacyjnym: " + returnedId);
            }
        });
});