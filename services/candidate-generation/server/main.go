// Package main provides the entry point for the Feature Store server.
package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, _ *http.Request) {
		// Checking the error from Encode to satisfy errcheck
		if err := json.NewEncoder(w).Encode("Hello world from Feature Store"); err != nil {
			log.Printf("failed to encode response: %v", err)
		}
	})

	fmt.Println("Server Listening on port 4000")
	log.Fatal(http.ListenAndServe(":4000", nil))
}
