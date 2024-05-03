.PHONY: all

all: tffmt tflint docs

tffmt:
	@echo "Running terraform fmt"
	terraform fmt

tflint:
	@echo "Running tflint..."
	tflint

docs:
	@echo "Generating Terraform documentation..."
	terraform-docs .

clean:
	@echo "Cleaning up..."
	rm -rf *.tfstate *.tfplan *.tfoutput
