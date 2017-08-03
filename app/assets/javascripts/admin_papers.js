function Paper() {
  this.ids = [];
  this.organizations_loaded = false;
  this.organizations_loaded_ids = [];
  this.current = 1;
  this.init();
}

Paper.prototype.init = function() {
  this.random_modal_methods();
  this.papers_type_methods();
  this.datetimepicker();
  this.create_select_organizations();
  this.select_organizations_methods();
  this.release_modal_methods();
  this.publish_paper_methods();
  this.paper_operate();
  this.index();
  this.input_only_num();
  this.filter();
  this.manually_pagination_methods();
}

Paper.prototype.random_modal_methods = function() {
  $('#randomModal').on('click', '.random-button', function() {
    single_choice = $('#single_choice').val().trim();
    multi_choice = $('#multi_choice').val().trim();

    if (single_choice && multi_choice) {
      location.href = "/admin/papers/new?method=random&single=" + single_choice + "&multi=" + multi_choice;
    } else {
      alert('请输入正确数字');
    }
  });
}

Paper.prototype.papers_type_methods = function() {
  if($('.small-test').prop('checked')) {
    $('.problem-score').empty();
    $('.problem-score').text(5);
    $('.papers-information-right').find('.score').css('display','none');
  } else if($('.large-test').prop('checked')) {
    $('.problem-score').each(function () {
      self = $(this);
      var score = self.text().trim();
      self.empty();
      self.append("<input type='text' class='form-control problem-score-input' value='" + score + "'>");
    });
    $('.papers-information-right').find('.score').css('display','flex');
  }
  $('.papers-type').on('click', '.custom-control-input', function() {
    if($('.small-test').prop('checked')) {
      $('.problem-score').empty();
      $('.problem-score').text(5)
      $('.papers-information-right').find('.score').css('display','none');
    } else {
      $('.problem-score').empty();
      $('.problem-score').append("<input type='text' class='form-control problem-score-input' value='5'>");
      $('.papers-information-right').find('.score').css('display','flex');
    }
  });
}

Paper.prototype.input_only_num = function() {
  $('.main').on('keyup', '.problem-score-input', function() {
    this.value = this.value.replace(/[^\d\.]/g,'');
  })
}

Paper.prototype.datetimepicker = function() {
  $("#datetimepicker").datetimepicker(
    {
      language:'zh-CN',
      autoclose:true
    }
  );
  $('.prev > span').addClass('fa fa-arrow-left');
  $('.next > span').addClass('fa fa-arrow-right');
}

Paper.prototype.create_select_organizations = function() {
  $('.user-range').on('click', function () {
    if (!this.organizations_loaded) {
      $.getJSON('/admin/organizations', function(orgs) {
        for (var org of orgs) {
          org.text = org.name;
          psedo_children = [{
            'text': 'test',
            'id': 0
          }];
          if(org.children_count > 0) {
            org.children = psedo_children;
          }
        }

        $('#select-organizations').jstree({
          'core' : {
            'data' : orgs,
            'check_callback': true
          },
          'plugins' : ['checkbox','wholerow']
        });
      });

      this.organizations_loaded = true;
    }
  }.bind(this));
  $('#select-organizations').on('open_node.jstree', function (event, data) {
    if ($.inArray(data.node.id, canna.admin_paper.organizations_loaded_ids) == -1) {
      var virtual_node = $.jstree.reference('#select-organizations').get_children_dom(data.node).first();
      $.jstree.reference('#select-organizations').delete_node(virtual_node);
      $.getJSON('/admin/organizations/' + data.node.id + '/children', function(orgs) {
        for (var org of orgs) {
          org.text = org.name;
          if(org.children_count > 0) {
            org.children = psedo_children;
          }
          $.jstree.reference('#select-organizations').create_node(data.node.id, org);
        }
        canna.admin_paper.organizations_loaded_ids.push(data.node.id);
      });
    }
  });
}

Paper.prototype.select_organizations_methods = function() {
  $('.papers-user').on('focus', '.user-range', function() {
    $('#select-organizations').css('display', 'block');
    $('.dropdown-icon').addClass('onfocus');
    $(this).addClass('focus');
  });
  $('.papers-user').on('blur', '.user-range', function(e) {
    var isShow_select = false;
    $('#select-organizations').click(function() {
      isShow_select = true;
    });
    setTimeout(function() {
      if(isShow_select) {
        $('.user-range').focus();
      } else {
        $('#select-organizations').css('display', 'none');
        $('.user-range').removeClass('focus');
        $('.dropdown-icon').removeClass('onfocus');
      }
    },200)
  });
  $('.papers-user').on('click', '.removeuser', function() {
    var text = $(this).siblings().text();
    $('.jstree-clicked').each(function(i,n) {
      if($(n).text() == text) {
        $('#select-organizations').jstree().deselect_node($(n));
      }
    });
    $(this).parents('.user-cell').remove();
    if($(".user-cell").length > 1) {
      $('.user-cell').css('display', 'none');
      $('.user-cell').first().css('display', 'flex');
    } else {
      $('.user-cell').css('display', 'none');
      $('.user-cell').first().css('display', 'flex');
      $('.user-overflow-text').css('display', 'none');
    }
  });
  $('#select-organizations').on('changed.jstree', function(e, data) {
    $('.user-cell').remove();
    data.instance.get_selected(true).forEach(function(n,i) {
      $('.user-overflow-text').before("<span class='user-cell'><span class='cell-content'>"+ n.text +"</span><i class='fa fa-times removeuser'></i></span>");
    });
    if($(".user-cell").length > 1) {
      $('.user-cell').css('display', 'none');
      $('.user-cell').first().css('display', 'flex');
      $('.user-overflow-text').css('display', 'flex');
    }else {
      $('.user-cell').css('display', 'none');
      $('.user-cell').first().css('display', 'flex');
      $('.user-overflow-text').css('display', 'none');
    }
  });
}

Paper.prototype.release_modal_methods = function() {
  $('.release-test').on('click', '.releaseButton', function() {
    $('.name-content').text($('.papers-name-val').val());
    $('.papers-close-time').text($('#datetimepicker').val());
    if($('.user-cell').length > 1) {
      $('.user-range-content').text($('.user-cell').first().text());
      $('.overflow-text').css('display', 'inline-block');
    }else {
      $('.user-range-content').text($('.user-cell').first().text());
      $('.overflow-text').css('display', 'none');
    }

    orgs_list = $.jstree.reference('#select-organizations').get_selected().join(';');
    $('#orgs_list').val(orgs_list);

    if($('.manually-papers').length > 0) {
      var num = $('.manually-papers').find('#listdata').children().length;
      $('.prob-number-content').text(num);
      if($('.small-test').prop('checked')) {
        $('.type-content').text("小考");
        $('.total-scores').text(num * 5);
      } else {
        $('.type-content').text("大考");
        var value = 0;
        $('.problem-score-input').each(function(i,n) {
          value += parseFloat($(n).val());
        });
        $('.total-scores').text(value);
      }
      var score_array = [];
      $('.manually-papers').find('#listdata').children().each(function(i,n) {
        if($('.small-test').prop('checked')) {
          score_array.push($(n).attr('data-id')+ '-' +$(n).children('.problem-score').text());
        } else {
          score_array.push($(n).attr('data-id')+ '-' +$(n).children('.problem-score').children().val());
        }
      });
      $('#problems_list').val(score_array.join(";"));
    } else {
      var num = $('#listdata').children().length;
      $('.prob-number-content').text(num);
      if($('.small-test').prop('checked')) {
        $('.type-content').text("小考");
        $('.total-scores').text(num * 5);
      } else {
        $('.type-content').text("大考");
        var value = 0;
        $('.problem-score-input').each(function(i,n) {
          value += parseFloat($(n).val());
        });
        $('.total-scores').text(value);
      }
      var score_array = [];
      $('#listdata').children().each(function(i,n) {
        if($('.small-test').prop('checked')) {
          score_array.push($(n).attr('data-id')+ '-' +$(n).children('.problem-score').text());
        } else {
          score_array.push($(n).attr('data-id')+ '-' +$(n).children('.problem-score').children().val());
        }
      });
      $('#problems_list').val(score_array.join(";"));
    }
  });
}

Paper.prototype.paper_operate = function() {
  $('.main').on('click', '.addtopapers', function() {
    if($.inArray($(this).parents('tr').attr('data-id'), canna.admin_paper.ids) == -1) {
      canna.admin_paper.ids.push($(this).parents('tr').attr('data-id'));
      $('.manually-papers').find('#listdata').prepend($(this).parents('tr').clone());
      $('.manually-papers').find('#listdata > tr:first').children('td:last').remove();
      $('.manually-papers').find('#listdata > tr:first').append("<td><div class='operate'><a class='icon remove-question'><i class='fa fa-minus'></i></a></div></td>");
      if($('.small-test').prop('checked')) {
        $('.manually-papers').find('#listdata > tr:first').append("<td class='problem-score'>5</td>");
      } else {
        $('.manually-papers').find('#listdata > tr:first').append("<td class='problem-score'><input type='text' class='form-control problem-score-input' value='5'></td>");
      }
      canna.admin_paper.manually_create_pagination();
    } else {
      alert('该题目已存在试卷中');
    }
  })

  $('.main').on('click', '.remove-question', function() {
    var question_id = $(this).parents('tr').attr('data-id');
    canna.admin_paper.remove_element_inarray(question_id, canna.admin_paper.ids);
    $(this).parents('tr').remove();
    $('.manually-papers').find('#listdata').find('tr').css('display','flex');
    canna.admin_paper.renew_page();
  })
}

Paper.prototype.remove_element_inarray = function(e, arr) {
  arr.splice($.inArray(e,arr),1);
}

Paper.prototype.publish_paper_methods = function() {
  $('.modal-dialog').on('click', '#publish_paper', function() {
    $('.paper_form').submit();
  });
}

Paper.prototype.index = function() {
  $('.card-wrapper').on('click', '.paper-item', function () {
    window.location.href = '/admin/papers/' + $(this).data('id');
  })
}

Paper.prototype.filter = function() {
  $('.main').on('change','.select-test', function() {
    var value = $('.select-test').find('option:selected').val();
    if(value == "3") {
      location.href = "/admin/papers";
    } else {
      location.href = "/admin/papers?scale=" + value;
    }
  });
  $('.main').on('change','.select-status', function() {
    var value = $('.select-status').find('option:selected').val();
    if(value == "2") {
      location.href = "/admin/papers";
    } else {
      location.href = "/admin/papers?status=" + value;
    }
  });
  $('.main').on('click', '.users-information', function() {
    var window_url = window.location.href;
    if($(this).hasClass('finished')) {
      location.href = window_url + "/users?status=0";
    } else if($(this).hasClass('unfinished')) {
      location.href = window_url + "/users?status=1";
    } else if($(this).hasClass('rank')){
      location.href = window_url + "/users?rank=1";
    } else if($(this).hasClass('failed')) {
      location.href = window_url + "/users?failed=1";
    }
  });
}

Paper.prototype.manually_create_pagination = function() {
  var problems_num = $('.manually-papers').find('#listdata').find('tr').length;
  var page_size = 20;
  var problems_total_page = 0;
  if(problems_num/page_size > parseInt(problems_num/page_size)){
    problems_total_page = parseInt(problems_num/page_size)+1;
  } else {
    problems_total_page = parseInt(problems_num/page_size);
  }
  if(problems_total_page > 1) {
    var insert_html = '';
    for(var i = 1;i <= problems_total_page;i++) {
      insert_html += "<li class='page-item page-item-cell'><a class='page-link'>" + i + "</a></li>";
    }
    $('.papers-pagination-wrapper').find('nav').css('display','block');
    $('.papers-pagination-wrapper').find('.page-item-cell').remove();
    $('.papers-pagination-wrapper').find('.previous').after(insert_html);
    canna.admin_paper.go_page(1,20);
  } else {
    $('.papers-pagination-wrapper').find('nav').css('display','none');
  }
  $('.papers-pagination-wrapper').find('.page-item-cell').first().addClass('active');
}

Paper.prototype.manually_pagination_methods = function() {
  $('.manually-papers-content').on('click', '.previous', function() {
    if(canna.admin_paper.current > 1) {
      canna.admin_paper.current -= 1;
      canna.admin_paper.set_page(canna.admin_paper.current);
    }
  })
  $('.manually-papers-content').on('click', '.next', function() {
    var total_page = $('.papers-pagination-wrapper').find('.page-item-cell').length;
    if(canna.admin_paper.current < total_page) {
      canna.admin_paper.current += 1;
      canna.admin_paper.set_page(canna.admin_paper.current);
    }
  })
  $('.manually-papers-content').on('click', '.first-page', function() {
    canna.admin_paper.current = 1;
    canna.admin_paper.set_page(1);
  })
  $('.manually-papers-content').on('click', '.last-page', function() {
    var total_page = $('.papers-pagination-wrapper').find('.page-item-cell').length;
    canna.admin_paper.current = total_page;
    canna.admin_paper.set_page(total_page);
  })
  $('.manually-papers-content').on('click', '.page-item-cell', function() {
    canna.admin_paper.current = parseInt($(this).text());
    canna.admin_paper.set_page(canna.admin_paper.current);
  })
}

Paper.prototype.set_page = function(current_page) {
  canna.admin_paper.go_page(current_page,20);
  $('.papers-pagination-wrapper').find('.page-item-cell').removeClass('active');
  $('.papers-pagination-wrapper').find('.page-item-cell')[current_page-1].classList.add('active');
}

Paper.prototype.renew_page = function() {
  var problems_num = $('.manually-papers').find('#listdata').find('tr').length;
  var page_size = 20;
  var problems_total_page = 0;
  if(problems_num/page_size > parseInt(problems_num/page_size)){
    problems_total_page = parseInt(problems_num/page_size)+1;
  } else {
    problems_total_page = parseInt(problems_num/page_size);
  }
  if(canna.admin_paper.current > problems_total_page) {
    canna.admin_paper.current = problems_total_page;
  }
  if(problems_total_page > 1) {
    var insert_html = '';
    for(var i = 1;i <= problems_total_page;i++) {
      insert_html += "<li class='page-item page-item-cell'><a class='page-link'>" + i + "</a></li>";
    }
    $('.papers-pagination-wrapper').find('nav').css('display','block');
    $('.papers-pagination-wrapper').find('.page-item-cell').remove();
    $('.papers-pagination-wrapper').find('.previous').after(insert_html);
    canna.admin_paper.go_page(canna.admin_paper.current,20);
  } else {
    $('.papers-pagination-wrapper').find('nav').css('display','none');
  }
  $('.papers-pagination-wrapper').find('.page-item-cell').eq(canna.admin_paper.current - 1).addClass('active');
}

Paper.prototype.go_page = function(pno,psize) {
  var num = $('.manually-papers').find('#listdata').find('tr').length;
  var total_page = 0;
  if(num/psize > parseInt(num/psize)){
    total_page = parseInt(num/psize)+1;
  }else{
    total_page = parseInt(num/psize);
  }
  var current_page = pno;
  var startRow = (current_page - 1) * psize+1;
  var endRow = current_page * psize;
  endRow = (endRow > num)? num : endRow;

  for(var i=1;i<(num+1);i++){
    var irow = $('.manually-papers').find('#listdata').find('tr')[i-1];
    if(i>=startRow && i<=endRow){
      irow.style.display = "flex";
    }else{
      irow.style.display = "none";
    }
  }
}
