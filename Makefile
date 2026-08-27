FILES ?= _data/160.yml _data/161.yml

.PHONY: test-urls

test-urls:
	@python3 utils/test_urls.py $(FILES)
