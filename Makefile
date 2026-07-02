GOCACHE ?= /tmp/kernloom-gocache
GOMODCACHE ?= /tmp/kernloom-gomodcache

.PHONY: validate compile

validate:
	test -f policies/access/protect-production-admin-access.intent.kni
	test -f policies/runtime/mitigate-abnormal-source-behavior.intent.kni
	test -f policies/kernloom/runtime-actions-require-safety-metadata.intent.kni
	$(MAKE) compile

compile:
	cd ../kernloom-core && GOCACHE=$(GOCACHE) GOMODCACHE=$(GOMODCACHE) go run ./cmd/forge compile --policy-repo ../enterprise-kernloom-policies --core-registry ../kernloom-core-registry --enterprise-registry ../enterprise-kernloom-registry --output-dir /tmp/kernloom-policy-ci
