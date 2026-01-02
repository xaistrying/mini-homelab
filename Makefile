# ------------------------- Variables -----------------------------
ROOT_DIR := $(CURDIR)

INFRA_DIR = infrastructure
CONF_DIR = configuration
K8S_DIR = kubernetes
SCRIPT_DIR = scripts

INVENTORY_FILE = inventory.ini

# ------------------------- Main Commands -------------------------

up: infra inventory config
	@echo "Lab is ready!"

down: clean
	@echo "Lab is destroyed!"

# ------------------------- Sub tasks -----------------------------

infra:
	cd $(INFRA_DIR) && terraform init && terraform apply -auto-approve

inventory:
	python3 $(SCRIPT_DIR)/generate_inventory.py

config:
	cd $(CONF_DIR)/setup-gateway-layer && ansible-playbook -i $(INVENTORY_FILE) main.yml
	cd $(CONF_DIR)/setup-application-layer && ansible-playbook -i $(INVENTORY_FILE) main.yml

k8s:
	cd ${K8S_DIR}/argocd-init && \
	helm dependency update && \
	helm install argocd ./charts/argo-cd-9.0.6.tgz \
		--create-namespace -n argocd \
		--kubeconfig=$(ROOT_DIR)/$(K8S_DIR)/kubeconfigs/lab.yaml

clean:
	cd $(INFRA_DIR) && terraform destroy -auto-approve
	cd ${CONF_DIR} && find . -type f -name "inventory.ini" -delete
	cd ${K8S_DIR} && rm -rf kubeconfigs
