import "@hotwired/turbo-rails"
import "controllers"


$(document).on('turbo:load', function(e) {
	addCertificate();
	submitEmployeeForm();
});

function addCertificate() {
	$('.add-certicate').on('click', function(e) {
		if($('form .certi-box').length < 10) {
			$('.certificate_list').append($('.certificate_fields.d-none').html());
		} else {
			toastr.error("A maximum of 10 certificates are only allowed!.")
		}
		removeCerticate();
		e.stopImmediatePropagation();
	});
}

function removeCerticate() {
	$('.remove_certi').on('click', function(e) {
		$(this).closest('.certi-box').remove();
		e.stopImmediatePropagation();
	});
}

function submitEmployeeForm() {
	$('.submit-emp-form').on('click', function(e) {

        var foundCerti = ($('form .certi-box').length != 0);
            if(!foundCerti) {
                toastr.error("You need to add atleast one certificate");
                e.preventDefault();
            }

            if(foundCerti) {
                $('form .certificate-file').each(function(index, element) {
                    if($(this).val().length == 0) {
                        foundCerti=false;
                        return false;
                    }
                });
        
                if(!foundCerti) {
                    toastr.error("Certificates Can't be blank");
                    e.preventDefault();
                }
            }

            if(foundCerti) {
                var photoFileExtension = $("#photo").val().split('.').pop().toLowerCase();
                var panCardFileExtension = $("#employeeinfo_pan_card").val().split('.').pop().toLowerCase();
                var allowedFileExtesion = ['png', 'jpeg', 'jpg']
                if(!allowedFileExtesion.includes(photoFileExtension)){
                    toastr.error("Photo must be png/jpeg/jpg only");
                    foundCerti=false;
                    e.preventDefault();
                }
            
                if(foundCerti && !allowedFileExtesion.includes(panCardFileExtension)){
                    toastr.error("Pan card must be png/jpeg/jpg only");
                    foundCerti=false;
                    e.preventDefault();
                }
                       }
	});
}