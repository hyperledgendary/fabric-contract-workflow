# fabric-contract-workflow
An example of how to build Smart Contracts in GitHub Actions

- Smart Contract is a copy of the one used in the full stack application sample
- It's built in GithubActions and pushed to the github repository

Each organization's Fabric Deployment Workflow would then pull in new versions of this packaged Smart Contract to run as needed


## Workflow Overview

Currently just a typescript example, but all would follow the same basic structure

- _build_ the code as needed and run any unit tests
- _publishdocker_ create the docker image for use with the k8s builder.   **Only on tagged**
- _package_ create the Chaincode Package for instaling to a peer **Only on tagged**



## Typesscript