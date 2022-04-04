// Placeholder manifest file.
// the installer will append this file to the app vendored assets here: vendor/assets/javascripts/spree/frontend/all.js"

let createBoltAccount = false;

const displayBoltInput = (paymentField, boltContainer, accountCheckbox) => {
  paymentField.mount(boltContainer);
  const statusContainer = document.getElementById("payment-status-container");
  statusContainer.style.display = "";
  accountCheckbox.mount("#account-checkbox")
}

const tokenize = async (paymentField) => {
  await paymentField.tokenize();
}

document.addEventListener("DOMContentLoaded", async function () {
  const boltContainer = document.getElementById("bolt-container");
  const boltEmbedded = Bolt(boltContainer.dataset.publishableKey);
  const accountCheckbox = boltEmbedded.create("account_checkbox");

  accountCheckbox.on("change", checked => createBoltAccount = checked);

  document.getElementById("bolt-card-button").addEventListener("click", () => {
    const paymentField = boltEmbedded.create("payment_component");
    displayBoltInput(paymentField, boltContainer, accountCheckbox);

    document.getElementById("bolt-submit-button").addEventListener("click", () => {
      let result = tokenize(paymentField);
      if (result["token"]) {
        // Submit a Payment Authorization POST Request
      } else {
        console.log(`error ${result["type"]}: ${result["message"]}`);
      }
    })
  })
})
