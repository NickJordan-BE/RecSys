package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		json.NewEncoder(w).Encode("Hello world from Candidate gen")
	})

	
	fmt.Println("Server Listening on port 4000")
	log.Fatal(http.ListenAndServe(":4000", nil))
}
