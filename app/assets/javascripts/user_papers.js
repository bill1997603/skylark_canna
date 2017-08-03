function Userpaper() {
  this.init();
}

Userpaper.prototype.init = function() {
  this.select_type(); 
  this.submit_paper();
  this.filter();
  this.redirect_method();
}

Userpaper.prototype.select_type = function() {
  $('.users-papers-container').on('click', '.custom-checkbox', function() {
    var question = $(this).parents('.paper-questions-cell');
    var text = question.find('.cell-type-text').text().trim();
    if(text == '单选') {;
      question.find('.custom-control-input').prop('checked', false);
      $(this).children('.custom-control-input').prop('checked', true);
    }
  })
}

Userpaper.prototype.submit_paper = function () {
  $('#submit-paper-button').on('click', function () {
    $('.problem-cell').each(function (i, n) {
      var options_arr = [];
      canna.user_paper.get_selected_options(n,options_arr);
      var value = options_arr.join(";").trim();
      $(n).find('.selected-options-input').val(value);
    });

    $('#submit_paper').submit();
  });
}

Userpaper.prototype.get_selected_options = function(e,array) {
  $(e).find('.option').each(function(i, n) {
    if($(n).find('.custom-control-input').prop('checked')) {
      array.push($(n).attr("data-id"));
    }
  });
}

Userpaper.prototype.filter = function() {
  $('.all-papers-container').on('click', '.show-filter', function() {
    $('.filter-list').css('display', 'block');
  });
  $('.all-papers-container').on('click', '.return-icon',function() {
    $('.filter-list').css('display', 'none');
  })
}

Userpaper.prototype.redirect_method = function() {
  $('.paper-cell').on('click', function() {
    if ($(this).data('id')) {
      location.href = '/users/papers/' + $(this).data('id');
    }

    if ($(this).data('code')) {
      location.href = '/users/papers/' + $(this).data('code') + '/new';
    }
  });
}
