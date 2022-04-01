// Placeholder manifest file.
// the installer will append this file to the app vendored assets here: vendor/assets/javascripts/spree/frontend/all.js"

const displayBoltInput = (paymentField, boltContainer) => {
  paymentField.mount(boltContainer);
  const statusContainer = document.getElementById("payment-status-container");
  statusContainer.style.display = "block";
}

const tokenize = async (paymentField) => {
  await paymentField.tokenize()
  .then((result) => {
    if (result["token"]) {
      // Submit a Payment Authorization POST Request
    } else {
      console.log(`error ${result["type"]}: ${result["message"]}`);
    }
  });
}


document.addEventListener("DOMContentLoaded", async function () {
  const boltContainer = document.getElementById("bolt-container");
  const boltEmbedded = Bolt(boltContainer.dataset.publishableKey);

  document.getElementById("bolt-card-button").addEventListener("click", () => {
    const paymentField = boltEmbedded.create("payment_component");
    displayBoltInput(paymentField, boltContainer);

    document.getElementById("bolt-submit-button").addEventListener("click", () => {
      tokenize(paymentField);
    })
  })
})
