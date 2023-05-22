# Harness Automation

This repository contains various Terraform modules and configuration used for onboarding Technology areas and AppCI's into the Harness platform.

You can find the pipelines that are setup to run these modules [here](https://app.harness.io/ng/#/account/H6rHO8vtQYKelD_wgjnMpA/cd/orgs/default/projects/Harness_Automation/pipelines).

## Conventions

- Each AppCI will have it's own application created in Harness with the name `<technology_area>-<appci>`. 

- The User Groups will automatically be created by SCIM and the `cd-usergroups` module will automatically attach the proper permissions to them scoped to the new application. 

## Configuration

The configuration is done via a series of YAML files that are merged together to provide the values needed to drive the Terraform modules. 

- `modules`: A collection of Terraform modules used for provisioning resources in Harness
- `config`: A collection of YAML files used as inputs into the Terraform modules
 
The structure of the YAML configuration files is as follows:

```
config
├── TechnologyArea
│   ├── AppCI.yaml
│   └── values.yaml
├── delegate.values.yaml
└── values.yaml
```

- `config`: Root directory for all of the configuration files.
  - `TechnologyArea`: The folder containing all of the configuration for a specific technology area.
    - `APPCI.yaml`: Each AppCI will have it's own YAML file with all configuration needed to provision the resources.
    - `values.yaml`: These are Technology Area specific values that provide defaults for all of the AppCI configurations.
  - `delegate.values.yaml`: These are the values YAML overrides used for installing the Harness CDCG delegates.
  - `values.yaml`: These are global values that provide defaults for every technology area and AppCI.

## Settings

Listed below is the structure for the configuration settings.

### Providers

This configuration is used to create Cloud Providers. Currently the only supported types are `kubernetes`. 

**Example**
```yaml
providers:
  us-east-2-aap-atw-devdrtgw:
    type: kubernetes
    environment: dev
    master_url: https://6898A959BEB29879EB78DB7881972045.gr7.us-east-2.eks.amazonaws.com
  us-east-1-aap-test-atw-qatgw:
    type: kubernetes
    environment: qa
    master_url: https://927E24D146B07A459A48818874DBF8F4.gr7.us-east-1.eks.amazonaws.com
  us-east-2-aap-atw-qadrtgw:
    type: kubernetes
    environment: qa
    master_url: https://75D5257189704D9DB53F26D8EDEA5C71.gr7.us-east-2.eks.amazonaws.com

```


- `<name>`: Each key in the map represents the name of the cloud provider. It will automatically have `<technology_area>-<app_ci>-<environment>` prefixed to it when it is created. 
  - `type`: The type of cloud provider to create. Allowed values are [kubernetes](#provider-kubernetes).
  - `environment`: Each cloud provider should be tied to a specific environment. This name should match one of the environments listed in the [environments](#environments) configuration.

#### <a name="provider-kubernetes"></a>Kubernetes

For cloud providers of type `kubernetes` the following configuration is used.
- `master_url`: The url of the Kubernetes API server.

Currently this module only supports `service account token` authorization. when this module is run, a secret with the name of `<cloudprovider>-token` will be created with a placeholder value. This will need to be manually updated with the proper service account token for the cluster.

### Environments

This configuration is used to create environments within an application. This configuration can be set at the `global`, `technology_area`, or the `app_ci` levels.

**Example**
```yaml
environments:
  dev:
    type: nonprod
    variables: 
      replicas:
        service: usersecurity
        value: 5
        type: text

  qa:
    type: nonprod
    variables: 
    database_connection:
      value: my-db-connection-qa
      type: secret

  stage:
    type: prod

  prod:
    type: prod
```

- `<name>`: Each key in the map represents the name of the cloud environment.
  - `type`: The type of the environment. Valid options are `nonprod` and `prod`.
  - `variables`: A map of variable overrides
    - `<name>`: The name of the config variable to override.
      - `value`: The overriden value of the config variable.
      - `service`: The name of the service the variable is used for. Leave this empty to set this variable for all services.
      - `type`: The type of value provided. Valid options are `text` and `secret`.


### Infrastructure

