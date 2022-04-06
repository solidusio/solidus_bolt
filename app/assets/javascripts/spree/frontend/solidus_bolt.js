// Placeholder manifest file.
// the installer will append this file to the app vendored assets here: vendor/assets/javascripts/spree/frontend/all.js"

const createBoltPayment = async (boltContainer, token) => {
  const orderNumber = boltContainer.dataset.orderNumber
  const orderToken = boltContainer.dataset.orderToken

  // api call to bolt
  await fetch('https://api-sandbox.bolt.com/v1/merchant/transactions/authorize', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-Nonce': token,
      'X-Publishable-Key': publishableKey
    },
    boltBody,
  });
  // then api call to update order
  return resp
}

const displayBoltInput = (paymentField, boltContainer) => {
  paymentField.mount(boltContainer);
  const statusContainer = document.getElementById("payment-status-container");
  statusContainer.style.display = "block";
}

const tokenize = async (paymentField) => {
  await paymentField.tokenize();
}

document.addEventListener("DOMContentLoaded", async function () {
  const boltContainer = document.getElementById("bolt-container");
  const boltEmbedded = Bolt(boltContainer.dataset.publishableKey);

  document.getElementById("bolt-card-button").addEventListener("click", () => {
    const paymentField = boltEmbedded.create("payment_component");
    displayBoltInput(paymentField, boltContainer);

    document.getElementById("bolt-submit-button").addEventListener("click", () => {
      let result = tokenize(paymentField);
      if (result["token"]) {
        // Submit a Payment Authorization POST Request
        // createBoltPayment(boltContainer)
      } else {
        console.log(`error ${result["type"]}: ${result["message"]}`);
      }
    })
  })
})
