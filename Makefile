PYTHON ?= python3

.PHONY: check doctor

check:
	$(PYTHON) scripts/check_repo.py

doctor:
	$(PYTHON) scripts/doctor.py
