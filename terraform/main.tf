terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

# Create namespaces
resource "kubernetes_namespace" "ai_training" {
  metadata {
    name = "ai-training"
  }
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

# Create ConfigMap for training code
resource "kubernetes_config_map" "training_code" {
  metadata {
    name      = "training-code"
    namespace = kubernetes_namespace.ai_training.metadata[0].name
  }

  data = {
    "train.py" = file("${path.module}/../training/train.py")
  }
}

# Create PersistentVolume for model storage
resource "kubernetes_persistent_volume" "model_storage" {
  metadata {
    name = "model-storage"
  }

  spec {
    capacity = {
      storage = "10Gi"
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_source {
      host_path {
        path = "/data/models"
        type = "DirectoryOrCreate"
      }
    }
    storage_class_name = "local-storage"
    node_affinity {
      required {
        node_selector_term {
          match_expressions {
            key = "kubernetes.io/hostname"
            operator = "In"
            values = ["kubefix-dev-control-plane"]
          }
        }
      }
    }
  }
}

# Create PersistentVolumeClaim
resource "kubernetes_persistent_volume_claim" "model_storage" {
  metadata {
    name      = "model-storage-claim"
    namespace = kubernetes_namespace.ai_training.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
    storage_class_name = "local-storage"
    volume_name = kubernetes_persistent_volume.model_storage.metadata[0].name
  }
}

# Create ServiceAccount for GPU access
resource "kubernetes_service_account" "gpu_training" {
  metadata {
    name      = "gpu-training-sa"
    namespace = kubernetes_namespace.ai_training.metadata[0].name
  }
}

# Create Role for GPU access
resource "kubernetes_role" "gpu_training" {
  metadata {
    name      = "gpu-training-role"
    namespace = kubernetes_namespace.ai_training.metadata[0].name
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "services"]
    verbs      = ["get", "list", "watch", "create", "delete"]
  }
}

# Create RoleBinding
resource "kubernetes_role_binding" "gpu_training" {
  metadata {
    name      = "gpu-training-rolebinding"
    namespace = kubernetes_namespace.ai_training.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.gpu_training.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.gpu_training.metadata[0].name
    namespace = kubernetes_namespace.ai_training.metadata[0].name
  }
} 