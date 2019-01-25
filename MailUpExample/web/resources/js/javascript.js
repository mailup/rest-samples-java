function startTimer(duration, display) {
    var timer = duration, days, showHours, hours, minutes, seconds;
    setInterval(function () {
        days = Math.floor(timer / (60 * 60 * 24));
        hours = Math.floor((timer % (60 * 60 * 24)) / (60 * 60));
        minutes = Math.floor((timer % (60 * 60)) / 60);
        seconds = Math.floor(timer % (60));

        if (days > 0) {
            days = (days < 10 ? "0" + days : days) + "d ";
            showHours = true;
        } else {
            days = '';
            showHours = false;
        }

        if (hours > 0 || showHours) {
            hours = (hours < 10 ? "0" + hours : hours) + "h ";
        } else {
            hours = '';
        }

        minutes = minutes < 10 ? "0" + minutes : minutes;
        seconds = seconds < 10 ? "0" + seconds : seconds;

        display.textContent = days + hours + minutes + "m " + seconds + "s";

        if (--timer < 0) {
            timer = duration;
        }
    }, 1000);
}

function getCookie(name) {
    var matches = document.cookie.match(new RegExp(
            "(?:^|; )" + name.replace(/([\.$?*|{}\(\)\[\]\\\/\+^])/g, '\\$1') + "=([^;]*)"
            ));
    return matches ? decodeURIComponent(matches[1]) : undefined;
}

$(function () {
    $('.spoiler-body').hide(300);

    $(document).on('click', '.spoiler-head', function (e) {
        e.preventDefault()
        $(this).parents('.spoiler-wrap').toggleClass("active").find('.spoiler-body').slideToggle();
    })
})

$(document).ready(function () {
    $('#txtUsr').keyup(function () {
        if ($(this).val() == '' || $('#txtPwd').val() == '') {
            $('#logOnWithUsernamePassword').prop('disabled', true);
        } else {
            $('#logOnWithUsernamePassword').prop('disabled', false);
        }
    });

    $('#txtPwd').keyup(function () {
        if ($(this).val() == '' || $('#txtUsr').val() == '') {
            $('#logOnWithUsernamePassword').prop('disabled', true);
        } else {
            $('#logOnWithUsernamePassword').prop('disabled', false);
        }
    });

    var timer = $('#expiresInTimerValue').val();
    if (timer > 0) {
        startTimer(timer, document.querySelector('#expiresInTimer'));
    } else {
        var accessTokenExpire = getCookie("access_token_expire");
        if (accessTokenExpire) {
            timer = (accessTokenExpire - (new Date()).getTime()) / 1000;
            startTimer(timer, document.querySelector('#expiresInTimer'));
        } else {
            document.querySelector('#expiresInTimer').textContent = "";
        }
    }
});

document.onreadystatechange = function () {
    var state = document.readyState
    if (state == 'complete') {
        setTimeout(function () {
            document.getElementById('interactive');
            document.getElementById('load').style.visibility = "hidden";
        }, 1000);
    }
}