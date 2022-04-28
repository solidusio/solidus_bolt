// Placeholder manifest file.
// the installer will append this file to the app vendored assets here: vendor/assets/javascripts/spree/frontend/all.js"

let createBoltAccount = false;

const createBoltPayment = async (creditCard) => {
  return Spree.ajax({
    url: '/transactions/authorize',
    method: 'POST',
    data: {
      order_token: Spree.current_order_token,
      order_id: Spree.current_order_id,
      create_bolt_account: createBoltAccount,
      credit_card: creditCard
    }
  })
}

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
      createBoltPayment(result)
      // then PATH /api/checkouts/order_number
      // then update order state on Bolt's side (maybe via Gateway?)
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
      tokenize(paymentField, boltContainer);
    })
  })
})
