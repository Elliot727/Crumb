.PHONY: lint format

lint:
	swift format lint --strict --recursive Sources Tests Examples
	@missing=$$(grep -rL "SPDX-License-Identifier: Apache-2.0" --include='*.swift' Sources Tests Examples); \
	if [ -n "$$missing" ]; then echo "Missing license header:"; echo "$$missing"; exit 1; fi

format:
	swift format --in-place --recursive Sources Tests Examples
