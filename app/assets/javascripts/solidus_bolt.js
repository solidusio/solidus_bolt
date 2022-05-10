let createBoltAccount = false;

const displayBoltInput = (paymentField, boltContainer, accountCheckbox) => {
  paymentField.mount(boltContainer);
  const statusContainer = document.getElementById("payment-status-container");
  statusContainer.style.display = "";
  accountCheckbox.mount("#account-checkbox")
}

const tokenize = async (paymentField) => {
  await paymentField.tokenize()
  .then((result) => {
    if (result["token"]) {
      // Advance order
    } else {
      console.log(`error ${result["type"]}: ${result["message"]}`);
    }
  });
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
      tokenize(paymentField);
    })
  })
})
