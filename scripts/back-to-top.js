/**
 * This file contains general scripts for back to top button.
 */
$(document).ready(function () {
  // back to top button
  $(window).scroll(function(event){
    var scroll = $(window).scrollTop();
      if (scroll >= 50) {
        $(".go-top").addClass("show");
      } else {
        $(".go-top").removeClass("show");
      }
  });
  $('a').click(function(){
    $('html, body').animate({
      scrollTop: $( $(this).attr('href') ).offset().top
    }, 1000);
  });
});