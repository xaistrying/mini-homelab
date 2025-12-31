# ------------------------- Variables -----------------------------

INFRA_DIR = infrastructure
CONF_DIR = configuration
K8S_DIR = kubernetes
SCRIPT_DIR = scripts

# ------------------------- Main Commands -------------------------

up: infra inventory k8s
	@echo "Lab is ready!"

down: clean_infra clean_inventory
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
	cd ${K8S_DIR}/argocd-init && helm dep install && helm install argocd

clean_infra:
	cd $(INFRA_DIR) && terraform destroy -auto-approve

clean_inventory:
	cd ${CONF_DIR} && find . -type f -name "inventory.ini" -delete
