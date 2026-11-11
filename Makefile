FILES ?= _data/*.yml

.PHONY: test-urls

test-urls:
	@python3 utils/test_urls.py $(FILES)
