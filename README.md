# SRE-Exercise

Deployment of a functioning VPC with a public subnet and a EC2 instance running Nginx. The `index.html` file located on `src/modules/ec2` gets uploaded and used as the Nginx default landing page.

A workflow should then be manually created on the Github Repository to automatically replace the `index.html` file every time code gets committed to the main branch.
This project uses [this repository](https://github.com/easingthemes/ssh-deploy) as a helper to the workflow action that copies the necessary files to the EC2 instance.

## prerequisites

  * AWS CLI environment configured and initialized with necessary credentials
  * Terraform CLI installed and configured.


## Deployment

  * Clone the repo

  * `npm init` the root of the repository, and add the below 3 dependencies to `package.json`. This file is used by the GitHub Workflow to copy the file to EC2.

    ```
    "dependencies": {
        "command-exists": "1.2.9",
        "node-cmd": "4.0.0",
        "rsyncwrapper": "3.0.1"
      }
    ```

  * Navigate to `src/modules/ec2` and create a private and public key that will be used for the instance. The following command can be used on Unix environments: `ssh-keygen -f mykey.pem`. If a different name is used for the key, update the `main.tf` file to reflect that.

  * Navigate to `/src` and run the following commands:
  ```
  terraform init
  terraform apply
  ```

  After following these steps, you should be able to navigate to the public IP of your instance (which gets displayed as an output on your terminal) and see the Nginx landing page with the content of `src/modules/ec2/index.html`.

## CI/CD

  To automate the deployment of `index.html`, follow these steps on your repository:

  * Navigate to the **settings** of the repository, then **Secrets** and add two secrets

      `EC2_SSH_KEY` : `Paste your instance's Private Key Here`
      `PUBLIC_IP`   : `Paste your instance's public ip here`

  * Navigate to **Workflows**, Create a **Simple Workflow** and paste the following yml configuration:

  ```
  name: CI

  on:
    push:
      branches: [ main ]
    pull_request:
      branches: [ main ]

  jobs:
    build:
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v2
        - name: Install Node.js
          uses: actions/setup-node@v1
          with:
            node-version: '10.x'
        - name: Install npm dependencies
          run: npm install
        - name: Run build task
          run: npm run build --if-present
        - name: Copy file to EC2 Instance
          uses: easingthemes/ssh-deploy@main
          env:
            SSH_PRIVATE_KEY: ${{ secrets.EC2_SSH_KEY }}
            REMOTE_HOST: ${{ secrets.PUBLIC_IP }}
            REMOTE_USER: "ec2-user"
            SOURCE: "src/modules/ec2/index.html"
            TARGET: "/usr/share/nginx/html/index.html"

  ```

  * Test it by making changes to your `index.html` on your local repo, and push the changes to the *main* branch.

## Rollback

  To restore the html file to a previous revision, use the github restore command, with the number of revisions back you need. Example below:

  `restore --source BRANCH~Number of Revisions src/modules/ec2/index.html`

  `restore --source main~2 src/modules/ec2/index.html`

## Troubleshooting

  * Going to the public IP address of the instance doesn't load anything:
    Confirm that the EC2 instance has a public IP address. Manually log in to the EC2 dashboard to check if necessary.

  * Can't SSH
    Make sure you created the public and private keys, and that the name matches the terraform resource arguments in `/src/modules/ec2/main.tf`
