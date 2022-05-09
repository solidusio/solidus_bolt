class AuthorizeAccount {
  constructor(emailField, pubKey, domain) {
    this.emailField = emailField;
    this.pubKey = pubKey;
    this.domain = domain;
  }

  async accessRequest() {
    const boltEmbedded = Bolt(this.pubKey);

    if (this.emailField) {
      const email = this.emailField.value
      const encodedEmail = encodeURIComponent(email);
      // Call the endpoint to check if the email already exist on bolt
      const response = await fetch(this.domain + "/v1/account/exists?email=" + encodedEmail);
      const responseAsJson = await response.json();
      this.removeBoltLoginButton();

      if(responseAsJson.has_bolt_account) {
        // SHOW THE SIGN IN WITH BOLT BUTTON
        const boltButton = this.createBoltLoginButton();
        boltButton.addEventListener('click', async (e) => {
          e.preventDefault();

          this.emailField.parentNode.setAttribute("class", "email-div")
          let authorizationComponent = boltEmbedded.create("authorization_component", {style: "callout"});
          await authorizationComponent.mount(".email-div");
          // start OTP modal
          let authorizationResponse = await authorizationComponent.authorize({"email": email});
          if (authorizationResponse) {

            const authorizationCode = authorizationResponse.authorizationCode;
            const scope = authorizationResponse.scope ;

            document.location.href = `/users/auth/bolt?authorization_code=${authorizationCode}&scope=${scope}`
          }
        });
      }
    }
  }

  removeBoltLoginButton() {
    const parentNode = this.emailField.parentNode;
    const eleList = parentNode.getElementsByClassName('bolt-ele');

    while(eleList[0]) {
      parentNode.removeChild(eleList[0]);
    }
  }

  createBoltLoginButton() {
    const parentNode = this.emailField.parentNode;
    const p = document.createElement('p');
    const button = document.createElement('button');

    p.innerHTML = 'Hey, we detected that you have a Bolt acocunt. Do you want to login with your Bolt account ?';
    p.className = 'bolt-ele';
    button.innerHTML = 'Login with Bolt';
    button.className = 'btn btn-primary bolt-ele';

    parentNode.appendChild(p);
    parentNode.appendChild(button);

    return button;
  }

  async hasBoltAccount(email) {
    const encodedEmail = encodeURIComponent(email);
    // Call the endpoint to check if the email already exist on bolt
    const response = await fetch(this.domain + "/v1/account/exists?email=" + encodedEmail);
    const responseAsJson = await response.json();
    return responseAsJson.has_bolt_account
  }
}
