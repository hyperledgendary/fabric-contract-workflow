# fabric-contract-workflow
An example of how to build Hyperledger Smart Contracts in GitHub Actions

- Smart Contract is a copy of the one used in the full stack application sample
- It's built in GithubActions and pushed to the github repository

Each organization's Fabric Deployment Workflow would then pull in new versions of this packaged Smart Contract to run as needed
Typically you would follow these steps. 

1. Make change to the implementation
2. Make a PR to update the main branch, compile and tests run
3. Create a new tag & release. 

   This will trigger the publish build that will create the docker image, and push assets to the release notes.

4. The **'gitops'** repo that manages your Fabric Infrastructure can then pick up the updated code
## Workflow Overview

Each workflow has the same basic structure

- _build_ the code as needed and run any unit tests.
  
  Use standard build and test tools per you choice of language and approach. Typically for unit testing you would create some mock objects that represent the functions in the chaincode API

- _publishdocker_ create the docker image for use with the Fabric K8S Builder
  
  The docker image to use for running in K8S. This will be pushed to the ghcr.io registry in this example; but could be pushed to other repositories as needed.  Remember that the chaincode package needs a reference to the *digest* of the docker image. This is only available when the image is push to a repository. If you move the image to another repoisitory check if the digest has been changed. If it has then the chaincode package will need to be updated.

  This step would really only run when a release was tagged. 

- _package_ create the Chaincode Package for instaling to a peer. In the case the K8S Builder this will be information about the docker iamge to use

  `*tgz` file added to the release assets

  This step would really only run when a release was tagged. 

_ _collections-config.json_ added to the release assets as well 

  This step would really only run when a release was tagged. 

## Packaging Chaincode  
The chaincode page is at `tgz` file with a few specific files. Easy to create, but there is a github action specifically for this. For example.

```
    - name: Create package
      uses: hyperledgendary/package-k8s-chaincode-action@ba10aea43e3d4f7991116527faf96e3c2b07abc7
      with:
        chaincode-label: ${{ env.chaincode-label }}
        chaincode-image:  ${{ env.docker-registry }}/${{ github.repository_owner }}/${{ env.image-name }}
        chaincode-digest: ${{ needs.publishdocker.outputs.image_digest }}
```

