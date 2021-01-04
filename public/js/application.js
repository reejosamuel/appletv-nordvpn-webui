$(function () {

    $(".connect").click(function () {
        $(this).addClass("is-loading");
        country = $(this).data("country")
        console.log("connecting to " + country + " VPN");
        item = $(this);

        $.post("/connect", { "country": country }).done(function( data ) {
            console.log("connect success");
            item.removeClass("is-loading");
            $(".status").text("VPN is connected to " + data["country"]);
          });
    });

    $(".disconnect").click(function () {
        $(this).addClass("is-loading");
        console.log("disconnecting...");
        item = $(this);

        $.post("/disconnect").done(function( data ) {
            console.log("disconnect success");
            item.removeClass("is-loading");
            $(".status").text("VPN is disconnected");
          });
    });
});
