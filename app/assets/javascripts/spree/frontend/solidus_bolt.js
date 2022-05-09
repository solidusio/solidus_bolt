// Placeholder manifest file.
// the installer will append this file to the app vendored assets here: vendor/assets/javascripts/spree/frontend/all.js'

//= require solidus_bolt
//= require authorize_account

const publishableKey = document.querySelector("meta[name=bolt-publishable-key]").getAttribute("content");
const domain = document.querySelector("meta[name=bolt-domain]").getAttribute("content");

document.addEventListener('DOMContentLoaded', function () {
  const emailField = document.getElementById('spree_user_email');
  if (emailField) {
    emailField.onblur = async function () {
      const authorize = new AuthorizeAccount(emailField, publishableKey, domain);
      await authorize.accessRequest();
    }
  }
})
