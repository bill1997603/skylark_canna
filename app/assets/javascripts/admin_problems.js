function Problem() {
  this.is_radio = true;
  this.edit_is_radio = "";
  this.id = "";
  this.init();
}

Problem.prototype.init = function() {
  this.bind_event();
  this.tag_methods();
  this.select_methods();
  this.search_input_methods();
  this.pager_methods();
}

Problem.prototype.bind_event = function() {
  $('.main').on('click', '.createButton', this.new);
  $('.main').on('click', '#labelButton', this.tag.bind(this));
  $('.main').on('click', '.editButton', this.edit);
  $('.main').on('click', '.showButton', this.show);
  $('.main').on('click', '.deleteButton', function() {
    var id = $(this).parents("tr").attr("data-id");
    $('.btn-dele').attr('href', '/admin/problems/' + id);
  });
  $('#uploadButton').on('change', function() {
    $('.import-form').submit();
  });
}

Problem.prototype.new = function() {
  $.get("/admin/problems/new", function(response) {
    $("#createModal").html(response);
    canna.admin_problem.set_form();
    $("#createModal").modal('toggle');
  })
}

Problem.prototype.show = function() {
  canna.admin_problem.id = $(this).parents("tr").attr("data-id");
  var url = "/admin/problems/" + parseInt(canna.admin_problem.id);
  $.get(url, function(response) {
    $("#showModal").html(response);
    $("#showModal").modal('toggle');
    if($('.papers-container').length > 0) {
      $('.modify-btn').remove();
    }
    $('.modify-btn').on('click', '.show-to-edit',function() {
      setTimeout(function() {
        $.get(url+"/edit", function(response) {
          $("#editModal").html(response);
          canna.admin_problem.set_form();
          $("#editModal").modal('toggle');
        })
      }, 1000)
    });
  })
}

Problem.prototype.edit = function() {
  var url = "/admin/problems/"+ $(this).parents('tr').attr('data-id') + "/edit";
  $.get(url, function(response) {
    $("#editModal").html(response);
    if ($('.edit_single').prop('checked')) {
      canna.admin_problem.edit_is_radio = true;
    } else {
      canna.admin_problem.edit_is_radio = false;
    }
    canna.admin_problem.set_form();
    $("#editModal").modal('toggle');
  })
}

Problem.prototype.tag = function() {
  $.get("/admin/tags", function(response) {
    $("#labelModal").html(response);
    $(".input-label-content").children("li").remove();
    canna.admin_problem.init_select2();
    $('#labelModal').modal('toggle');
  })
}

Problem.prototype.set_form =function() {
  $('[data-form-prepend]').on('click', this.add_option);
  $('.create-prob-options').on('click', '.removeOption', function() {
    if ($('.create-prob-options > ol > li').length > 2) {
      $(this).parents('li').remove();
    }
  });
  $('.edit-prob-options').on('click', '.removeOption', function() {
    var li = $('.edit-prob-options > ol > li');
    if (($('.edit-prob-options > ol > li').length - $('.destory').length)> 2) {
      $(this).parents('li').addClass('destory');
      $(this).next().next().prop('checked', true);
    }
  });
  $('.create-prob-type').on('click','.radio',this.create_single_check.bind(this));
  $('.edit-prob-type').on('click','.radio',this.edit_single_check);
  $('.prob-options').on('click', '.checkbox', (function(e) {
    if (this.is_radio) {
      if ($(e.target).prop('checked')) {
        $('.checkbox').prop('checked', false);
        $(e.target).prop('checked', true);
      }
    }
  }).bind(this));
  $('.prob-options').on('click', '.edit-checkbox', (function(e) {
    if (this.edit_is_radio) {
      if ($(e.target).prop('checked')) {
        $('.edit-checkbox').prop('checked', false);
        $(e.target).prop('checked', true);
      }
    }
  }).bind(this));
  canna.admin_problem.init_select2();
  canna.admin_problem.select2_methods();
}

Problem.prototype.init_select2 = function() {
  $.getJSON("/admin/tags.json", function(response) {
    var data = $.map(response, function (obj) {
      obj.text = obj.text || obj.description;
      return obj;
    });
    $(".js-tags").select2({
      data: data,
      closeOnSelect: false,
      tags: true
    });
    $(".js-basic-single").select2({
      data: data
    })
    canna.admin_problem.set_select2_style();
    $('.edit-tags').trigger('select2:loaded');
  });
}

Problem.prototype.set_select2_style = function() {
  $('.select2-selection--single').css('height','35px');
  $('.select2-selection--single').find('.select2-selection__rendered').css('line-height','35px');
  $('.select2-selection--single').find('.select2-selection__arrow').css('height','35px');
  $('.select2-container').css('width', '300px');
}

Problem.prototype.select2_methods = function() {
  $('.main').on('click', '.create-submit', function() {
    var tags_list = [];
    $('.create-select-tags').find('.select2-selection__choice').each(function(i, n) {
      tags_list.push(canna.admin_problem.get_text($(n)));
    })
    var value = tags_list.join(";");
    $('#create-label-input').val(value);
  });
  $('.main').on('click', '.edit-submit', function() {
    var tags_list = [];
    $('.edit-select-tags').find('.select2-selection__choice').each(function(i, n) {
      tags_list.push(canna.admin_problem.get_text($(n)));
    })
    var value = tags_list.join(";");
    $('#edit-label-input').val(value);
  });
}

Problem.prototype.get_text = function(e) {
  var text;
  e.contents().each(function() {
    if(this.nodeType === 3) {
      text = this;
    }
  })
  return text.data;
}

Problem.prototype.add_option = function() {
  var obj = $($(this).attr('data-form-prepend'));
  obj.find('input, select, textarea').each(function() {
    $(this).attr('name', function() {
      return $(this).attr('name').replace('new_record', (new Date()).getTime());
    });
  });
  $('.prob-options > ol').append(obj);
  return false;
}

Problem.prototype.create_single_check = function() {
  if ($('.single').prop('checked')) {
    $('.checkbox').prop('checked', false);
    this.is_radio = true;
  } else {
    this.is_radio = false;
  }
}

Problem.prototype.edit_single_check = function() {
  if ($('.edit_single').prop('checked')) {
    $('.edit-checkbox').prop('checked', false);
    this.edit_is_radio = true;
  } else {
    this.edit_is_radio = false;
  }
}

Problem.prototype.tag_methods = function() {
  $('.main').on('click', '.select-tag', function() {
    $('.selectType').find('option[value=3]').attr('selected',true).css('display','none').siblings().css('display','block').attr('selected',false);
    $('.selectType').find('option[value=3]').text('题型');
    var window_url = window.location.href;
    var text = $('.select2-selection--single').find('.select2-selection__rendered').text();
    if(window_url.indexOf('?') == -1) {
      var url = window_url+'?tag=' + text;
      $('.container-wrapper').load(url + ' .container', canna.admin_problem.reset)
    }else {
      var url = window_url + '&tag=' + text;
      $('.container-wrapper:first').load(url + ' .container:first',canna.admin_problem.reset)
    }
    $('#labelButton').text(text);
  })
}

Problem.prototype.select_methods = function() {
  $('.main').on('change', '.selectType',function() {
    $('#labelButton').text('标签')
    var url = window.location.href;
    var value = parseInt($('.selectType').find('option:selected').val());
    if(value == 3) {
      $('.container-wrapper:first').load(url+" .container:first");
      $('.selectType').find('option[value='+ value + ']').attr('selected',true).css('display','none').siblings().css('display','block').attr('selected',false);
      $('.selectType').find('option[value=3]').text('题型');
    } else {
      if(url.indexOf('?') == -1) {
        $('.container-wrapper:first').load(url + "?form=" + value + " .container:first", function() {
          $('.selectType').find('option[value='+ value + ']').attr('selected',true).css('display','none').siblings().css('display','block').attr('selected',false);
          $('.selectType').find('option[value=3]').text('全部');
        });
      } else {
        $('.container-wrapper:first').load(url+"&form=" + value +" .container:first", function() {
          $('.selectType').find('option[value='+ value + ']').attr('selected',true).css('display','none').siblings().css('display','block').attr('selected',false);
          $('.selectType').find('option[value=3]').text('全部');
        })
      }
    }
  });
}

Problem.prototype.search_input_methods = function() {
  $('#search-problem-input').bind('input propertychange', function() {
    $('#autosearch > li').remove();
    $('#autosearch').css('display', 'block');
    if($('#search-problem-input').val() == '') {
      $('#autosearch').css('display', 'none');
    }
    $.getJSON("/admin/problems/search.json?q=" + $('#search-problem-input').val(), function(response) {
      $(response).each(function(i,n) {
        $('#autosearch').append("<li class='search-result'>"+n.description+"</li>");
      });
    });
  });
  $('#autosearch').on('click', '.search-result', function() {
    $('#search-problem-input').val($(this).text());
    $('#autosearch').css('display', 'none');
  });
  $('.navbar-wrapper').on('blur', '#search-problem-input', function() {
    setTimeout(function() {
      $('#autosearch').css('display', 'none');
    },200)
  });
  $('.navbar-wrapper').bind('keypress','#search-input', function(e) {
    if(e.keyCode == '13') {
      $('#submit-search').submit();
    }
  });
  $('.navbar-wrapper').on('click', '.search', function() {
    $('#submit-search').submit();
  });

}

Problem.prototype.pager_methods = function() {
  $(".main").on("ajax:success", "a[data-remote]", function() {
    var url = $(this).attr('href');
    $('.container-wrapper:first').load(url + " .container:first");
  })
}

Problem.prototype.insert_new_record = function(new_record) {
  if($('.manually-papers').length != 0) {
    var tr_insert = $('.manually-papers').find('#listdata > tr:first');
    $('.manually-papers').find('#listdata').prepend(new_record);
    $('.tr').css('width', ($('.navbar-wrapper').width() -1) + 'px');
    canna.admin_paper.manually_create_pagination();
    $('.manually-papers').find('#listdata > tr:first').children().slice(2,7).remove();
    $('.manually-papers').find('#listdata > tr:first').children('td:last').remove();
    $('.manually-papers').find('#listdata > tr:first').append("<td><div class='operate'><a class='icon remove-question'><i class='fa fa-minus'></i></a></div></td>");
    if($('.small-test').prop('checked')) {
      $('.manually-papers').find('#listdata > tr:first').append("<td class='problem-score'>5</td>");
    } else {
      $('.manually-papers').find('#listdata > tr:first').append("<td class='problem-score'><input type='text' class='form-control problem-score-input' value='5'></td>");
    }
  } else {
    $('#listdata').prepend(new_record);
    $('.tr').css('width', ($('.navbar-wrapper').width() -1) + 'px');
    if ($('#listdata > tr').length == 21) {
      $('#listdata > tr:last').remove();
    }
  }
}
