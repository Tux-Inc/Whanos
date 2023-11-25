#!/bin/bash
LANGUAGE=()

if [[ -f Makefile ]]; then
	LANGUAGE+=("c")
    echo ${LANGUAGE[@]}
    exit 0
fi
if [[ -f app/pom.xml ]]; then
	LANGUAGE+=("java")
    echo ${LANGUAGE[@]}
    exit 0
fi
if [[ -f package.json ]]; then
	LANGUAGE+=("javascript")
    echo ${LANGUAGE[@]}
    exit 0
fi
if [[ -f requirements.txt ]]; then
	LANGUAGE+=("python")
    echo ${LANGUAGE[@]}
    exit 0
fi
if [[ -f app/main.bf ]]; then
    LANGUAGE+=("befunge")
    echo ${LANGUAGE[@]}
    exit 0
fi
