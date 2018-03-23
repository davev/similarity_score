var yearsActiveRange = function(yearBegin, yearEnd) {
  return (!yearBegin ? '' : yearBegin + ' - ' + yearEnd);
};

var hofIndicator = function(hof) {
  return (hof ? '<i class="fas fa-star"></i>' : '');
};


$(document).on('turbolinks:before-cache', function() {
  $('.selectize-control').remove();
});


$(document).on('turbolinks:load', function() {
  $('.player-select').selectize({
    valueField: 'slug',
    labelField: 'name',
    searchField: 'name',
    options: [],

    render: {
      option: function(item, escape) {
        return '<div class="suggestion">' +
          '<span class="name">' +
          escape(item.name) +
          hofIndicator(item.hof) +
          '</span>' +
          '<span class="years">' + escape(yearsActiveRange(item.active_year_begin, item.active_year_end)) + '</span>' +
        '</div>';
      }
    },

    highlight: false,
    maxItems: 1,
    persist: false,
    closeAfterSelect: true,
    openOnFocus: false,
    // loadThrottle: 250,


    onChange: function(val) {
      if (val != '') {
        let path = "/players/" + val;
        this.clear(true); // hack to handle back button not showing search term

        if (typeof Turbolinks !== 'undefined' && Turbolinks.supported) {
          Turbolinks.visit(path);
        } else {
          window.location.assign(path);
        }
      }
    },

    onFocus: function() {
      let value = this.getValue();
      if (value.length > 0) {
        this.clear(true);
        // this.$control_input.val(value);
      }
    },

    load: function(query, callback) {
      if (!query.length) return callback();
      $.ajax({
        url: '/players?q=' + encodeURIComponent(query),
        type: 'GET',
        error: function() {
          callback();
        },
        success: function(res) {
          callback(res);
        }
      });
    }
  });
});
