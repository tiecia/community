// Package dadjokes provides details for the DadJokes applet.
package dadjokes

import (
	_ "embed"

	"tidbyt.dev/community/apps/manifest"
)

//go:embed dadjokes.star
var source []byte

// New creates a new instance of the DadJokes applet.
func New() manifest.Manifest {
	return manifest.Manifest{
		ID:          "dadjokes",
		Name:        "DadJokes",
		Author:      "tiecia",
		Summary:     "Displays dad jokes",
		Desc:        "Displays a random dad joke from icanhazdadjoke.com.",
		FileName:    "dadjokes.star",
		PackageName: "dadjokes",
		Source:  source,
	}
}
