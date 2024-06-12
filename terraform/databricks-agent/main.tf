terraform {
  required_providers {
    kubiya = {
      source = "kubiya-terraform/kubiya"
      version = "0.3.1"
    }
  }
}

provider "kubiya" {
  // Your Kubiya API Key will be taken from the
  // environment variable KUBIYA_API_KEY
  // To set the key, please use export KUBIYA_API_KEY="YOUR_API_KEY"
}

resource "kubiya_agent" "databricks_agent" {
  // Mandatory Fields
  name         = "Databricks Teammate" // String
  runner       = "aks-dev"             // String
  description  = <<EOT
Databricks Teammate is an intelligent agent designed to assist users in adopting and managing Databricks asset bundles, ci/cd, latest features, configuration management, and more - It provides comprehensive support for creating, manipulating, and deploying to databricks using the Databricks CLI.
EOT
  instructions = <<EOT
As the Databricks Agent, your primary role is to assist users in adopting and managing Databricks asset bundles and core features effectively. You are equipped with the capabilities to help users with various tasks related to asset bundles and configuration management for Databricks.

## Your capabilities include: ##
- Creating a new asset bundle from scratch or from an existing repository.
- Cloning repositories and reading configuration files. (YAML with relevant configurations, code snippets, etc.)
- Assisting in manipulating and updating configurations.
- Adopting GitHub Actions for CI/CD pipelines.

Please ask the user which task they need help with and provide clear, step-by-step assistance.

**Tasks you can help with:**
1. Asset Bundle Development
   - Help create or manage asset bundles either from scratch or from an existing repository.
2. Cloning and Configuring Repositories
   - Clone a repository and read the configuration files to understand the environment.
3. Updating Configuration Files
   - Assist users in manipulating and updating configuration files as needed.
4. Setting Up GitHub Actions
   - Help users integrate GitHub Actions to set up CI/CD pipelines if not already managed.

**Please provide clear instructions and be efficient in executing tasks.**

EOT
  // Optional fields, String
  model = "azure/gpt-4o" // If not provided, Defaults to "azure/gpt-4"
  // If not provided, Defaults to "ghcr.io/kubiyabot/kubiya-agent:stable"
  image = "kubiya/base-agent:tools"

  // Optional Fields:
  // Arrays
  secrets      = ["DATABRICKS_TOKEN"]
  integrations = ["slack", "github"]
  users        = ["shaked@kubiya.ai"]
  groups       = ["Admin"]
  links = []
  tasks = [
    {
      name = "Asset Bundle Development"
      description = "Help create a release bundle from scratch or from an existing repository."
      prompt = <<EOT
1. Ask the user if they want to create a new asset bundle or use an existing repository.
2. For a new asset bundle, guide the user to run `databricks-cli init --bundle-name <bundle-name>`.
3. For an existing repository, guide the user to clone the repository using `git clone <repository-url>`.
4. Read the configuration from `config.yaml` or other relevant files in the cloned repository.
5. Assist the user in updating and manipulating configurations as needed.
6. Optionally, help the user set up GitHub Actions for CI/CD if not managed.
EOT
    },
    {
      name = "Cloning and Configuring Repositories"
      description = "Clone a repository and read the configuration files to understand the environment."
      prompt = <<EOT
1. Guide the user to clone the repository using `git clone <repository-url>`.
2. Read the configuration from `config.yaml` or other relevant files in the cloned repository.
3. Assist the user in understanding and updating the configuration as needed.
EOT
    },
    {
      name = "Create Databricks Job"
      description = "Help users create a new Databricks job and configure it according to their requirements."
      prompt = <<EOT
1. Ask the user for the job name, type, and other relevant details.
2. Guide the user through the process of creating a new Databricks job.
3. Ask the user if to deploy it directly to databricks CLI or to create a GitHub Actions workflow for it.
EOT
    },
    {
      name = "Setting Up GitHub Actions"
      description = "Help users integrate GitHub Actions to set up CI/CD pipelines if not already managed."
      prompt = <<EOT
1. Check if the repository already has GitHub Actions set up for their Databricks asset bundles.
2. If not, guide the user through the process of setting up GitHub Actions - ask them where the configuration files are located.
3. Assist the user in configuring the workflow file according to their requirements. Show them the generated file and ask for confirmation.
4. Provide guidance on how to trigger the workflow and monitor the CI/CD pipeline.
5. Optionally, create the workflow file and commit it a repository, open a pull request, and ask the user to review and merge it.
EOT
    }
  ]
  environment_variables = {
    DEBUG            = "1"
    LOG_LEVEL        = "INFO"
    DATABRICKS_HOST  = "https://adb-4060844568223799.19.azuredatabricks.net"
    KUBIYA_TOOL_CONFIG_URLS = "https://github.com/shakedaskayo/databricks-agent" # This repository contains the configuration files
  }
  starters = [
    {
      name = "🚀 Init Asset Bundle"
      command = "Initialize a new asset bundle"
    },
    {
      name = "📂 Clone Workspace"
      command = "Clone a repository and read the configuration files to understand the databricks environment - I will guide you through the process after you read it. Ask me for the repository name to know what to clone"
    },
    {
      name = "🐍 Jupyter Notebook"
      command = "I need the URL of the notebook for my current workspace"
    },
    {
      name = "🔧 Create Job"
      command = "I want to create a databricks job, help me with the configuration"
    },
    {
      name = "⚙️ Setup CI/CD Pipeline"
      command = "Create a new github actions workflow which will deploy the asset bundle to databricks - ask me for clarification on which repository to use, etc."
    }
  ]
}

output "agent" {
  value = kubiya_agent.databricks_agent
}
