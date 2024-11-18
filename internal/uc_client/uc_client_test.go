package uc_client

import (
	"context"
	"github.com/stretchr/testify/suite"
	"github.com/testcontainers/testcontainers-go"
	"github.com/testcontainers/testcontainers-go/wait"
	"testing"
)

type UcTestSuite struct {
	suite.Suite
	ctx       context.Context
	container *testcontainers.Container
}

func (s *UcTestSuite) SetupSuite() {
	s.ctx = context.Background()
	req := testcontainers.ContainerRequest{
		// TODO: Use better image tag
		Image:        "unitycatalog/0.2.0",
		ExposedPorts: []string{"8080/tcp"},
		WaitingFor:   wait.ForHealthCheck(),
	}
	container, err := testcontainers.GenericContainer(s.ctx, testcontainers.GenericContainerRequest{
		ContainerRequest: req,
		Started:          true,
	})
	if err != nil {
		s.T().Fatal(err)
	}
	s.container = &container
}

// Individual test methods
func (s *UcTestSuite) TestSomething() {
	// Use s.repository for testing
}

func TestSuite(t *testing.T) {
	suite.Run(t, new(UcTestSuite))
}

// Testing the initialization of the UC OSS generated client
func TestInitClient(t *testing.T) {
	ctx := context.Background()
	c, err := NewClientWithResponses("http://localhost:8080/api/2.1/unity-catalog")
	if err != nil {
		t.Errorf("Failed to create client: %v", err)
	}
	p := ListCatalogsParams{}
	catalogs, err := c.ListCatalogsWithResponse(ctx, &p)
	if err != nil {
		t.Errorf("Failed to list catalogs: %v", err)
	}
	// UC default deployment starts with a "unity" catalog initially
	if len(*catalogs.JSON200.Catalogs) != 1 {
		t.Errorf("Expected catalogs size to be zero")
	}
}
