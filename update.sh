#!/bin/bash

helm package k8s-telegram-sender --destination ./docs
helm repo index docs --url https://danuk.github.io/k8s-telegram-sender

