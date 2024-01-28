### THIS README MUST BE MODIFIED WITH THE NEW INFO ###

## DevOps challenge
The backend team has already worked in an AWS very simple lambda to gather information about players. In the structure folder, you can see the code:
* `index.mjs`: The implementation of the lambda
* `simple.test.js`: Integration test of the lambdas.

We need to work on a new infrastructure that will be composed of the following services:
* **API Gateway**: There will be a path `\players` with method GET. That will call for the lambda. ###DONE
* **Lambda**: The source code of the lambda will be the code of the `\lambdas\Players` ###DONE
* **Dynamo**: There will be a table with name `Player`: ###DONE
* **S3**: We need to create two buckets, one to store the lambda and another to store the state of the terraform. ###DONE

There will be two environments, **dev** and **prod** created in different branches.

On the other hand, we need to implement an action that has the following workflow (in all environments):
* On push, it will be deployed.
* Manual deployment.

### Requeriments:
* You need to create a branch for dev and prod.
* The infrastructure must be implemented with HCL.
  * The state will be stored in a bucket. ###DONE
  * As the provider, you will use AWS. ###DONE
  * Make the structure folder as you see fit. ###DONE
* To find out if the test was successful, the backend team must run a Docker. You need to create a `Dockerfile`. To execute the test, you need to run `npm run test` in the `Dockerfile`. ###DONE
* The two points that were previously mentioned must be added to a branch.
  * Create a pull request to merge into main.
  * Please include documentation with the pull request.
* Add the actions mentioned previously (CI).
  * Create a pull request to merge into main.
  * You need to create a branch and commit it to a pull request to merge into main.
* Feel free to add git files as you need them.
* Keep it simple. 🙂
