let createBoltAccount = false;

const displayBoltInput = (paymentField, boltContainer, accountCheckbox) => {
  paymentField.mount(boltContainer);
  const statusContainer = document.getElementById("payment-status-container");
  statusContainer.style.display = "";
  accountCheckbox.mount("#account-checkbox")
}

const tokenize = async (paymentField, paymentMethodId, frontend) => {
  await paymentField.tokenize()
  .then((result) => {
    if (result["token"]) {
      updateOrder(result, paymentMethodId, frontend)
    } else {
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

const updateOrder = async (card, paymentMethodId, frontend) => {
  await fetch(`/api/checkouts/${Spree.current_order_id}`, {
    method: 'PATCH',
    headers: {
      'Content-Type': 'application/json',
      'X-Spree-Order-Token': Spree.current_order_token
    },
    body: JSON.stringify({
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
  .then(() => {
    redirectToNextStep(frontend)
  })
  .catch((response) => {
    console.log('Error updating order')
    console.log(response)
  });
}

document.addEventListener("DOMContentLoaded", async function () {
  const boltContainer = document.getElementById("bolt-container");
  const boltEmbedded = Bolt(boltContainer.dataset.publishableKey);
  const accountCheckbox = boltEmbedded.create("account_checkbox");
  const frontend = boltContainer.dataset.frontend == "true" ? true : false;
  const paymentMethodId = boltContainer.dataset.paymentMethodId
  const cardButton = document.getElementById("bolt-card-button");

  accountCheckbox.on("change", checked => createBoltAccount = checked);
  cardButton.addEventListener("click", () => {
    const paymentField = boltEmbedded.create("payment_component");
    displayBoltInput(paymentField, boltContainer, accountCheckbox);
    cardButton.style.display = 'none';

    document.getElementById("bolt-submit-button").addEventListener("click", () => {
      tokenize(paymentField, paymentMethodId, frontend);
    })
  })
})
