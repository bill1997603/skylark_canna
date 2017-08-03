canna = {
};

canna.set_style = function() {
  $('.sidebar').css('min-height',$(window).height() + 'px');
  $('.out-container').css('min-height',$(document).height() + 'px');
  $('.problems-pagination-wrapper').css('width', $('.navbar-wrapper').width() + 'px');
  $('.tr').css('width', ($('.navbar-wrapper').width() -1) + 'px');
  $(window).resize(function() {
    $('.sidebar').css('min-height',$(window).height() + 'px');
    $('.out-container').css('min-height',$(document).height() + 'px');
    $('.problems-pagination-wrapper').css('width', $('.navbar-wrapper').width() + 'px');
    $('.tr').css('width', ($('.navbar-wrapper').width() -1) + 'px');
  });
}

$(document).on("turbolinks:load", function() {
  canna.admin_problem = new Problem();
  canna.admin_paper = new Paper();
  canna.user_paper = new Userpaper();
  canna.set_style();
})