.PHONY: all

all: tflint docs

tflint:
	@echo "Running tflint..."
	tflint .
	@if [ $? -ne 0 ]; then echo "Tflint found errors. Please fix them before continuing."; exit 1; fi

docs:
	@echo "Generating Terraform documentation..."
	terraform-docs .

clean:
	@echo "Cleaning up..."
	rm -rf *.tfstate *.tfplan *.tfoutput
