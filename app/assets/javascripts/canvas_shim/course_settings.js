function flipIcon(element, threshDisabled) {
  var icon = element.children("i");
  if (threshDisabled) {
    icon.removeClass("icon-edit");
    icon.addClass("icon-trash");
  } else {
    icon.removeClass("icon-trash");
    icon.addClass("icon-edit");
  }
}

$(window).on("load", function(event) {
  var initialVal = $('#passing_threshold').val();
  $('#edit_threshold_btn').click(function(e) {
    e.preventDefault();
    e.stopPropagation();
    var passThreshDisabled = $('#passing_threshold').prop('disabled');
    $('#passing_threshold').prop('disabled', !passThreshDisabled);
    $("#threshold_edited").remove();
    $(this).append("<input type='hidden' id='threshold_edited' name='threshold_edited' value=" + passThreshDisabled + " />")
    if ($('#passing_threshold').prop('disabled')) {
      $('#passing_threshold').val(initialVal);
    }

    flipIcon($(this), passThreshDisabled);
  });

  var initialUnitVal = $('#passing_unit_threshold').val();
  $('#edit_unit_threshold_btn').click(function(e) {
    e.preventDefault();
    e.stopPropagation();
    var unitPassThreshDisabled = $('#passing_unit_threshold').prop('disabled');
    $('#passing_unit_threshold').prop('disabled', !unitPassThreshDisabled);
    $("#unit_threshold_edited").remove();
    $(this).append("<input type='hidden' id='unit_threshold_edited' name='unit_threshold_edited' value=" + unitPassThreshDisabled + " />")
    if ($('#passing_unit_threshold').prop('disabled')) {
      $('#passing_unit_threshold').val(initialUnitVal);
    }

    flipIcon($(this), unitPassThreshDisabled);
  });

  $(".endpoint-btn").click(function(e) {
    e.preventDefault();
    e.stopPropagation();
    var id = $(this).attr("id");
    if (id === "distribute_due_dates" && !(ENV.start_date && ENV.end_date)) {
      return $.flashError(
        "Please save a start and end date to this course before distributing due dates."
      )
    } else if (id === "distribute_due_dates" ) {
      $('.due-date-button-popover').addClass("popover-visible");
      $('.due-date-button-popover').removeClass("popover-close");
      setTimeout(function() {
        $('.due-date-button-popover').removeClass("popover-visible");
        $('.due-date-button-popover').addClass("popover-close");
      }, 8000);

      $('#distribute_due_dates').prop("disabled", "true");
    }
    
    var target = $(this).data("target");
    var id = $(this).attr("id");

    $.ajax({
      url: target,
      type: 'POST',
      success: function() {
        if (id === "clear_due_dates") {
          return $.flashMessage(
            "Your due dates are currently being cleared. They should be removed from the modules page in a few minutes.. "
          )
        }

        return $.flashMessage(
          "Your due dates are currently being distributed. They should be visible on the modules page in a few minutes."
        )
      },
      error: function() {
        return $.flashError(
          "Something went wrong!  Please wait a moment and try again. If the problem persists, contact an administrator."
        )
      }
    });
  });
});
