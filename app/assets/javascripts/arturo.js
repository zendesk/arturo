if (typeof(jQuery) === 'function') {
  jQuery.arturo = {
    agentSupportsHTML5Output: ('for' in jQuery('<output />')),

    linkAndShowOutputs: function() {
      if (jQuery.arturo.agentSupportsHTML5Output) {
        jQuery('.features output,.feature_new output,.feature_edit output').each(function(i, output) {
          var output = jQuery(output);
          var input = jQuery('#' + output.attr('for'));
          input.change(function() {
            output.val(input.val());
          });
          output.removeClass('no_js');
        });
      }
    }
  };

  jQuery(function() {
    jQuery.arturo.linkAndShowOutputs();
  });
}
