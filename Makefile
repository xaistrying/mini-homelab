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
	cd $(CONF_DIR)/setup-local && ansible-playbook -i $(INVENTORY_FILE) manage_hosts.yml -e "state=present"
	cd $(CONF_DIR)/setup-local && ansible-playbook -i $(INVENTORY_FILE) wireguard_setup.yml
	cd $(CONF_DIR)/setup-local && ansible-playbook -i $(INVENTORY_FILE) manage_wireguard.yml -e "state=up"

k8s:
	cd ${K8S_DIR}/argocd-init/ && \
	helm dependency update && \
	echo "Waiting for Traefik CRDs..." && \
	until kubectl get crd ingressroutes.traefik.io --kubeconfig=${KUBECONFIG} 2>/dev/null; do \
		echo "Traefik CRD not ready, waiting 5s..."; \
		sleep 5; \
	done && \
	kubectl wait --for condition=established \
		--timeout=60s crd/ingressroutes.traefik.io \
		--kubeconfig=${KUBECONFIG} && \
	helm upgrade --install argocd argocd/ -n argocd --kubeconfig=${KUBECONFIG} && \
	kubectl wait --for=condition=available deployment/argocd-server \
		-n argocd --timeout=300s \
		--kubeconfig=$(KUBECONFIG) && \
	helm template argocd-init . | kubectl apply -f - \
		--kubeconfig=${KUBECONFIG}
	kubectl get secret argocd-initial-admin-secret \
		-nargocd -o jsonpath="{.data.password}" \
		--kubeconfig=${KUBECONFIG} | base64 -d

clean:
	cd $(INFRA_DIR) && terraform destroy -auto-approve
	cd $(CONF_DIR)/setup-local && ansible-playbook -i $(INVENTORY_FILE) manage_hosts.yml -e "state=absent"
	cd $(CONF_DIR)/setup-local && ansible-playbook -i $(INVENTORY_FILE) manage_wireguard.yml -e "state=down"
	cd ${CONF_DIR} && find . -type f -name "inventory.ini" -delete
	cd ${K8S_DIR} && rm -rf kubeconfigs
