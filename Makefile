GOCACHE ?= /tmp/kernloom-gocache
GOMODCACHE ?= /tmp/kernloom-gomodcache
TRIVY ?= trivy
COSIGN ?= cosign
DIST ?= dist

.PHONY: validate compile checksums sbom vuln-scan release-provenance release-sign release-promote-check release-check

validate:
	test -f policies/access/protect-production-admin-access.intent.kni
	test -f policies/runtime/mitigate-abnormal-source-behavior.intent.kni
	test -f policies/kernloom/runtime-actions-require-safety-metadata.intent.kni
	$(MAKE) compile

compile:
	cd ../kernloom-core && GOCACHE=$(GOCACHE) GOMODCACHE=$(GOMODCACHE) go run ./cmd/forge compile --policy-repo ../enterprise-kernloom-policies --core-registry ../kernloom-core-registry --enterprise-registry ../enterprise-kernloom-registry --output-dir /tmp/kernloom-policy-ci

checksums:
	mkdir -p $(DIST)
	tar --sort=name --owner=0 --group=0 --numeric-owner -czf $(DIST)/enterprise-kernloom-policies-artifacts.tar.gz policies generated/artifacts generated/bundles generated/resolved generated/signed generated/reports
	sha256sum $(DIST)/enterprise-kernloom-policies-artifacts.tar.gz > $(DIST)/checksums.txt

release-provenance: checksums
	{ \
		echo "{"; \
		echo "  \"kind\": \"KernloomPolicyReleaseProvenance\","; \
		echo "  \"source_commit\": \"$$(git rev-parse HEAD)\","; \
		echo "  \"checksums\": \"$(DIST)/checksums.txt\""; \
		echo "}"; \
	} > $(DIST)/provenance.json

sbom:
	@command -v $(TRIVY) >/dev/null 2>&1 || { echo "trivy is required for SBOM generation"; exit 127; }
	mkdir -p $(DIST)
	$(TRIVY) fs --format cyclonedx --output $(DIST)/sbom.cdx.json .

vuln-scan:
	@command -v $(TRIVY) >/dev/null 2>&1 || { echo "trivy is required for vulnerability scanning"; exit 127; }
	$(TRIVY) fs --exit-code 1 --severity HIGH,CRITICAL .

release-sign: checksums
	@command -v $(COSIGN) >/dev/null 2>&1 || { echo "cosign is required for release signing"; exit 127; }
	$(COSIGN) sign-blob --yes --output-signature $(DIST)/checksums.txt.sig $(DIST)/checksums.txt

release-promote-check: validate checksums sbom release-provenance
	test -s $(DIST)/checksums.txt
	test -s $(DIST)/sbom.cdx.json
	test -s $(DIST)/provenance.json

release-check: validate checksums sbom vuln-scan release-provenance release-promote-check
