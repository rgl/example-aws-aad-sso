all: terraform-apply

terraform-init:
	CHECKPOINT_DISABLE=1 \
	TF_LOG=TRACE \
	TF_LOG_PATH=terraform.log \
	terraform init
	CHECKPOINT_DISABLE=1 \
	terraform -v

terraform-plan:
	CHECKPOINT_DISABLE=1 \
	TF_LOG=TRACE \
	TF_LOG_PATH=terraform.log \
	terraform plan -out tfplan

terraform-apply:
	CHECKPOINT_DISABLE=1 \
	TF_LOG=TRACE \
	TF_LOG_PATH=terraform.log \
	terraform apply tfplan

terraform-plan-apply: terraform-plan terraform-apply

terraform-destroy:
	CHECKPOINT_DISABLE=1 \
	TF_LOG=TRACE \
	TF_LOG_PATH=terraform.log \
	terraform destroy

clean:
	rm -rf tmp *.log

.PHONY: all clean terraform-init terraform-apply terraform-destroy
