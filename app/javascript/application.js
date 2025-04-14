import "@hotwired/turbo-rails"
import "controllers"

document.addEventListener('turbo:load', () => {
  handleCertificateAddition();
  handleFormSubmission();
});

function handleCertificateAddition() {
  document.querySelectorAll('.add-certicate').forEach(button => {
    button.addEventListener('click', e => {
      const certiBoxes = document.querySelectorAll('form .certi-box');
      if (certiBoxes.length < 10) {
        const certTemplate = document.querySelector('.certificate_fields.d-none');
        const certList = document.querySelector('.certificate_list');
        if (certTemplate && certList) {
          certList.insertAdjacentHTML('beforeend', certTemplate.innerHTML);
        }
      } else {
        toastr.error("A maximum of 10 certificates are only allowed!");
      }

      attachRemoveCertificateHandlers();
      e.stopImmediatePropagation();
    });
  });
}

function attachRemoveCertificateHandlers() {
  document.querySelectorAll('.remove_certi').forEach(button => {
    button.addEventListener('click', e => {
      const certiBox = button.closest('.certi-box');
      if (certiBox) certiBox.remove();
      e.stopImmediatePropagation();
    });
  });
}

function handleFormSubmission() {
  document.querySelectorAll('.submit-emp-form').forEach(button => {
    button.addEventListener('click', e => {
      const certiBoxes = document.querySelectorAll('form .certi-box');
      if (certiBoxes.length === 0) {
        toastr.error("You need to add at least one certificate.");
        e.preventDefault();
        return;
      }

      const allFilesPresent = Array.from(document.querySelectorAll('form .certificate-file'))
        .every(fileInput => fileInput.value.trim().length > 0);

      if (!allFilesPresent) {
        toastr.error("Certificates can't be blank.");
        e.preventDefault();
        return;
      }

      const allowedExtensions = ['png', 'jpeg', 'jpg'];
      const photo = document.querySelector("#photo");
      const panCard = document.querySelector("#employeeinfo_pan_card");

      if (!hasValidExtension(photo, allowedExtensions)) {
        toastr.error("Photo must be png, jpeg, or jpg.");
        e.preventDefault();
        return;
      }

      if (!hasValidExtension(panCard, allowedExtensions)) {
        toastr.error("Pan card must be png, jpeg, or jpg.");
        e.preventDefault();
        return;
      }
    });
  });
}

function hasValidExtension(fileInput, allowed) {
  if (!fileInput || !fileInput.value) return false;
  const extension = fileInput.value.split('.').pop().toLowerCase();
  return allowed.includes(extension);
}
