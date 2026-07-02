.PHONY: validate

validate:
	test -f policies/access/protect-production-admin-access.intent.kni
	test -f policies/runtime/mitigate-abnormal-source-behavior.intent.kni
	test -f policies/kernloom/runtime-actions-require-safety-metadata.intent.kni

