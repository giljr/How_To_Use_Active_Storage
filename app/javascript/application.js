import "@hotwired/turbo-rails"
import "controllers"

document.addEventListener("turbo:load", function () {
  addCertificate();
  submitEmployeeForm();
});

function addCertificate() {
  $(document).on('click', '.add-certicate', function (e) {
    if ($('form .certi-box').length < 10) {
      $('.certificate_list').append($('.certificate_fields.d-none').html());
    } else {
      toastr.error("A maximum of 10 certificates are only allowed!");
    }
    e.stopImmediatePropagation();
  });
}

function submitEmployeeForm() {
  $(document).on('click', '.submit-emp-form', function (e) {
    let foundCerti = ($('form .certi-box').length !== 0);

    if (!foundCerti) {
      toastr.error("You need to add at least one certificate");
      e.preventDefault();
    }

    if (foundCerti) {
      $('form .certificate-file').each(function () {
        if ($(this).val().length === 0) {
          foundCerti = false;
          return false;
        }
      });

      if (!foundCerti) {
        toastr.error("Certificates can't be blank");
        e.preventDefault();
      }
    }

    if (foundCerti) {
      const photoExt = $("#photo").val().split('.').pop().toLowerCase();
      const panExt = $("#employeeinfo_pan_card").val().split('.').pop().toLowerCase();
      const allowed = ['png', 'jpeg', 'jpg'];

      if (!allowed.includes(photoExt)) {
        toastr.error("Photo must be png/jpeg/jpg only");
        foundCerti = false;
        e.preventDefault();
      }

      if (!allowed.includes(panExt)) {
        toastr.error("Pan card must be png/jpeg/jpg only");
        foundCerti = false;
        e.preventDefault();
      }
    }
  });
}
