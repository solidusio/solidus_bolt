let createBoltAccount = false;

const displayBoltInput = (paymentField, boltContainer, accountCheckbox) => {
  paymentField.mount(boltContainer);
  const statusContainer = document.getElementById("payment-status-container");
  statusContainer.style.display = "";

  if (accountCheckbox) {
    accountCheckbox.mount("#account-checkbox")
  }
}

const tokenize = async (paymentField, paymentMethodId, frontend) => {
  await paymentField.tokenize()
  .then((result) => {
    if (result["token"]) {
      updateOrder(result, paymentMethodId, frontend)
    } else {
      const submitButton = document.getElementById("bolt-submit-button")
      submitButton.disabled = false;
      console.log(`error ${result["type"]}: ${result["message"]}`);
    }
  });
}

const redirectToNextStep = (frontend) => {
  if (frontend) {
    window.location.href = '/checkout/confirm';
  } else {
    window.location.href = `/admin/orders/${Spree.current_order_id}/payments`
  }
}

async function getResponseText(response) {
  const text = await response.text();
  return text;
}

const updateOrder = async (card, paymentMethodId, frontend) => {
  await fetch(`/api/checkouts/${Spree.current_order_id}`, {
    method: 'PATCH',
    headers: {
      'Content-Type': 'application/json',
      'X-Spree-Order-Token': Spree.current_order_token
    },
    body: JSON.stringify({
      'state': 'payment',
      'order': {
        'payments_attributes': [{
          'payment_method_id': paymentMethodId,
          'source_attributes': {
            'card_token': card['token'],
            'card_last4': card['last4'],
            'card_bin': card['bin'],
            'card_number': card['number'],
            'card_expiration': card['expiration'],
            'card_postal_code': card['postal_code'],
            'create_bolt_account': createBoltAccount
          }
        }]
      }
    })
  })
  .then((response) => {
    if(response.ok) {
      redirectToNextStep(frontend)
    } else {
      getResponseText(response).then(text => {
        console.error(text);
      });
    }
  })
  .catch((response) => {
    console.log('Error updating order')
    console.log(response)
  });
}

document.addEventListener("DOMContentLoaded", async function () {
  const boltContainer = document.getElementById("bolt-container");

  if (boltContainer) {
    const boltEmbedded = Bolt(boltContainer.dataset.publishableKey);
    let accountCheckbox = null;
    const frontend = boltContainer.dataset.frontend == "true" ? true : false;
    const paymentMethodId = boltContainer.dataset.paymentMethodId
    const cardButton = document.getElementById("bolt-card-button");

    if(boltContainer.dataset["boltUserSignedIn"] != "true") {
      accountCheckbox = boltEmbedded.create("account_checkbox");
      accountCheckbox.on("change", checked => createBoltAccount = checked);
    } else {
      createBoltAccount = true;
    }
    cardButton.addEventListener("click", () => {
      const submitButton = document.getElementById("bolt-submit-button")
      const paymentField = boltEmbedded.create("payment_component");
      displayBoltInput(paymentField, boltContainer, accountCheckbox);
      cardButton.style.display = 'none';

      submitButton.addEventListener("click", () => {
        tokenize(paymentField, paymentMethodId, frontend);
        submitButton.disabled = true;
      })
    })
  }
})
