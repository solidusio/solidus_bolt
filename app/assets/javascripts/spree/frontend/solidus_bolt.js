// Placeholder manifest file.
// the installer will append this file to the app vendored assets here: vendor/assets/javascripts/spree/frontend/all.js"

const createBoltPayment = async (boltContainer, creditCard) => {
  const publishableKey = boltContainer.dataset.publishableKey
  const apiKey =         boltContainer.dataset.apiKey
  const apiUrl =         boltContainer.dataset.apiUrl
  const autoCapture =    boltContainer.dataset.autoCapture === 'true'
  const cart =           JSON.parse(boltContainer.dataset.cart)
  const userIdentifier = JSON.parse(boltContainer.dataset.userIdentifier)
  const userIdentity =   JSON.parse(boltContainer.dataset.userIdentity)

  creditCard["billing_address"] = {
    "street_address1": "888 main street",
    "street_address2": "apt 3021",
    "street_address3": null,
    "street_address4": null,
    "locality": "New York",
    "region": "NY",
    "postal_code": "10044",
    "country_code": "US",
    "country": "United States",
    "name": "Alan Watts",
    "first_name": "Alan",
    "last_name": "Watts",
    "company": "Bolt",
    "phone": "1-867-5309",
    "email": "alan.watts@bolt.com"
    }
  let nonce = Math.floor(100000000000 + Math.random() * 900000000000) // random 12 digit number
  let boltBody = {
    'auto_capture': autoCapture,
    'cart': cart,
    'credit_card': creditCard,
    'division_id': '',
    'source': 'direct_payments',
    'user_identifier': userIdentifier,
    'user_identity': userIdentity,
    'create_bolt_account': true // createBoltAccount
  }
  headers = {
    'Content-Type': 'application/json',
    'X-API-Key': apiKey,
    'X-Nonce': nonce,
    'X-Publishable-Key': publishableKey
  }
  console.log(headers)
  console.log(JSON.stringify(boltBody))
  // api call to bolt
  await fetch(`${apiUrl}/v1/merchant/transactions/authorize`, {
    method: 'POST',
    headers: headers,
    body: JSON.stringify(boltBody)
  })
  .then((response) => {
    // api call to update order
    console.log('success')
    console.log(response)
  })
  .catch((response) => {
    console.log('error')
    console.log(response)
  });
}

const displayBoltInput = (paymentField, boltContainer) => {
  paymentField.mount(boltContainer);
  const statusContainer = document.getElementById("payment-status-container");
  statusContainer.style.display = "block";
}

const tokenize = async (paymentField, boltContainer) => {
  await paymentField.tokenize()
  .then((result) => {
    console.log(result)
    if (result["token"]) {
      // Submit a Payment Authorization POST Request
      createBoltPayment(boltContainer, result)
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
      tokenize(paymentField, boltContainer);
    })
  })
})
