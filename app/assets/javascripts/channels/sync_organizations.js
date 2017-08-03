App.sync_organizations = App.cable.subscriptions.create("SyncOrganizationsChannel", {
  connected: function() {
    return console.log('Connected.');
  },
  disconnected: function() {},
  received: function(data) {
    var update_org = JSON.parse(data.updated_organizations);
    var delete_org = data.deleted_organizations;
    var psedo_children = [{
      'text': 'test',
      'id': 0
    }];
    console.log(data)
    // if (data.parent_id == 'root') {  
    //   if (update_org.length > 0) {
    //     $(update_org).each(function(i,n) {
    //       var elem = '#' + n.id;
    //       n.text = n.name;
    //       if(n.children_count > 0) {
    //         n.children = psedo_children;
    //       }
    //       if($(elem).length > 0) {
    //         $.jstree.reference('#select-organizations').rename_node(elem, n.name);
    //         // if(n.children_count > 0) {
    //         //   //$.jstree.reference('#select-organizations').create_node(elem, psedo_children);
    //         //   //console.log($.jstree.reference('#select-organizations').get_node($(elem)));
    //         //   $.jstree.reference('#select-organizations').open_node($(elem), function() {
    //         //     console.log($.jstree.reference('#select-organizations').get_children_dom($(elem)))
    //         //   });
    //         // } else {

    //         // }
    //       } else {
    //         $.jstree.reference('#select-organizations').create_node('#', n);
    //       }
  
    //     })
    //   }

    //   if(delete_org.length > 0) {
    //     $(delete_org).each(function(i, n) {
    //       var elem = '#' + n;
    //       var dele_node = $.jstree.reference('#select-organizations').get_node($(elem))
    //       $.jstree.reference('#select-organizations').create_node(dele_node);
    //     })
    //   }
    // }
  }
});