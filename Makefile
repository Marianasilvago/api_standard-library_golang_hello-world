EXECUTABLE := hello-golang-api
GITVERSION := $(shell git describe --dirty --always --tags --long)
GOPATH ?= ${HOME}/go
PACKAGENAME := $(shell go list -m -f '{{.Path}}')
TOOLS := ${GOPATH}/bin/swag
SWAGGERSOURCE = $(wildcard server/*.go)

.PHONY: default
default: ${EXECUTABLE}

tools: ${TOOLS}

${GOPATH}/bin/swag:
	go install github.com/swaggo/swag/cmd/swag@latest

.PHONY: swagger
swagger: tools ${SWAGGERSOURCE}
	swag init --dir . --generalInfo server/swagger.go --exclude embed --output embed/swagger/api_docs
	rm embed/swagger/api_docs/docs.go
	
embed/swagger/api_docs/swagger.json: tools ${SWAGGERSOURCE}
	swag init --dir . --generalInfo server/swagger.go --exclude embed --output embed/swagger/api_docs
	rm embed/swagger/api_docs/docs.go

.PHONY: ${EXECUTABLE}
${EXECUTABLE}: tools embed/swagger/api_docs/swagger.json
	# Compiling...
	go build -ldflags "-X ${PACKAGENAME}/conf.Executable=${EXECUTABLE} -X ${PACKAGENAME}/conf.GitVersion=${GITVERSION}" -o ${EXECUTABLE}

.PHONY: test
test:
	go test -cover ./...

.PHONY: vet
vet:
	go vet ./...

.PHONY: fmt
fmt:
	go fmt ./...

.PHONY: mod-down
mod-down:
	go mod download

.PHONY: mod-tidy
mod-tidy:
	go mod tidy
