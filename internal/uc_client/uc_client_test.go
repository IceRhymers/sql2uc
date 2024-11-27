package uc_client

import (
	"context"
	"fmt"
	"github.com/stretchr/testify/suite"
	"github.com/testcontainers/testcontainers-go"
	"github.com/testcontainers/testcontainers-go/wait"
	"testing"
	"time"
)

// Image name for our unity catalog test container, built from this repo.
// TODO: When UC docker is published to dockerhub use that instead
const UC_IMAGE = "unitycatalog/0.2.0"

type UcTestSuite struct {
	suite.Suite
	ctx       context.Context
	container *testcontainers.Container
}

func (s *UcTestSuite) SetupSuite() {
	s.ctx = context.Background()
	req := testcontainers.ContainerRequest{
		Image:        UC_IMAGE,
		ExposedPorts: []string{"8080/tcp"},
		WaitingFor:   wait.ForExposedPort().WithStartupTimeout(120 * time.Second),
	}
	container, err := testcontainers.GenericContainer(s.ctx, testcontainers.GenericContainerRequest{
		ContainerRequest: req,
		Started:          true,
		ProviderType:     testcontainers.ProviderPodman, // TODO: Programmatically set this
	})
	if err != nil {
		s.T().Fatal(err)
	}
	s.container = &container
}

// Stop container after completion
func (s *UcTestSuite) TearDownSuite() {
	defer func() {
		c := *s.container
		err := c.Terminate(s.ctx)
		if err != nil {
			s.Errorf(err, "Failed to terminate container")
		}
	}()
}

// Utility function to create our generated UC Client.
func GetUcClient(s *UcTestSuite) *ClientWithResponses {
	c := *s.container
	port, err := c.MappedPort(context.Background(), "8080")
	if err != nil {
		panic(err)
	}
	host := fmt.Sprintf("http://localhost:%s/api/2.1/unity-catalog", port.Port())
	client, err := NewClientWithResponses(host)
	if err != nil {
		s.Errorf(err, "Failed to create client")
	}
	return client
}

// Testing the initialization of the UC OSS generated client
// For now we're going to trust that the client itself is generated correctly
// From the OpenAPI spec, as long as our client code is generated.
func (s *UcTestSuite) TestInitialClient() {
	c := GetUcClient(s)
	p := ListCatalogsParams{}
	catalogs, err := c.ListCatalogsWithResponse(s.ctx, &p)
	if err != nil {
		s.Errorf(err, "Failed to list catalogs: %v", err)
	}
	// UC default deployment starts with a "unity" catalog initially
	if len(*catalogs.JSON200.Catalogs) != 1 {
		s.Errorf(err, "Expected catalogs size to be one! (the default)")
	}
}

// Custom Test Suite to use unity catalog container.cccccbktbvetvcnirvdgltknbjbglvrneueudtjubvdc
func TestSuite(t *testing.T) {
	s := new(UcTestSuite)
	suite.Run(t, s)
}
