// Its not the coffeeScript you requested but its a good example i thought i would add to the repo 
// of jQuery/ajax call to the solr server that populates the auto suggest in the results  

  jQuery(function() {

    $('#text_search').keypress(function() { // hide found text when user starts typing again
        $('#found_name').html('');
    });

    $('#text_search').autocomplete({
       minLength: 2,
      source: function(request, response) {
        $.ajax({
          url: 'https://localhost:8983/solr//select?wt=json&fq=type:Service&start=0&rows=20&q=*:*',
          data: {
            fq: 'title_ac:' + '"' + request.term + '"' 
          },                          
          dataType: 'json',
          // jsonp: 'json.wrf',
          
          success: function(data) {
            response($.map(data.response.docs, function( item ) {
              return {
                label: item.title_ac[0],
                model_id: item.id.replace(/Model /,"")
              }
            }));
          }
        })
      },
      
    });

    $('#text_search').keypress(function() { // hide found text when user starts typing again
        $('#found_name').html('');
    });

  });
