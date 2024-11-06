# Instructions


The terragrunt repo is using Github actions for CI/CD. 
### Local

#### Terragrunt init
<code>terragrunt run-all init</code>
#### Terragrunt plan
<code>terragrunt run-all plan --terragrunt-non-interactive</code>
#### Terragrunt validate
<code>terragrunt run-all validate</code>
#### Terragrunt apply
<code>terragrunt run-all apply --terragrunt-non-interactive</code>
#### Terragrunt destroy
<code>terragrunt run-all destroy --terragrunt-non-interactive</code>


### CI/CD

* Enable your AWS Access Keys credentials as a secret in your github repo.

* Do your changes using a new branch and push your code.
* Make a pull request. This will trigger a plan using github actions.
* Merge. This executes an apply.
