# Helm Chart Toolbox

Making comprehensive Helm chart management and testing easier!

## Overview

This repository provides a set of tools and utilities to help with the development, testing, and management of Helm
charts. It includes features for generating documentation, schemas, running tests, and more!

## Tools

### Helm Test

This tool is a comprehensive test suite for checking Helm charts run well in real Kubernetes clusters. It has the 
ability to create many different kinds of Kubernetes clusters, deploy arbitrary dependencies, and run multiple complex
suites of tests against your Helm chart.

Learn more about the Helm Test tool in the [Helm Test README](./tools/helm-test/README.md).

### Doc Generator

This tool generates README.md files from values.yaml files.

### Schema Generator

This tool generates a values.schema.json file from values.yaml files, which can be used to validate Helm chart inputs.

