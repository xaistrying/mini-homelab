# ------------------------- Variables -----------------------------
ROOT_DIR := $(CURDIR)

INFRA_DIR = infrastructure
CONF_DIR = configuration
K8S_DIR = kubernetes
SCRIPT_DIR = scripts

INVENTORY_FILE = inventory.ini

KUBECONFIG = $(ROOT_DIR)/$(K8S_DIR)/kubeconfigs/lab.yaml

# ------------------------- Main Commands -------------------------

up: infra inventory config k8s
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
	cd ${K8S_DIR}/argocd-init/ && \
	helm dependency update && \
	helm upgrade --install argocd argocd/ \
		--create-namespace -n argocd \
		--kubeconfig=${KUBECONFIG}

	kubectl wait --for=condition=available deployment/argocd-server \
	  -n argocd --timeout=300s \
	  --kubeconfig=$(KUBECONFIG)

	helm template argocd-init . | kubectl apply -f - \
		--kubeconfig=${KUBECONFIG}

	kubectl get secret argocd-initial-admin-secret \
		-nargocd -o jsonpath="{.data.password}" \
		--kubeconfig=${KUBECONFIG} | base64 -d

clean:
	cd $(INFRA_DIR) && terraform destroy -auto-approve
	cd ${CONF_DIR} && find . -type f -name "inventory.ini" -delete
	cd ${CONF_DIR}/cleanup-local && ansible-playbook -i localhost, main.yml
	cd ${K8S_DIR} && rm -rf kubeconfigs
