package main

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"

	"github.com/google/generative-ai-go/genai"
	"google.golang.org/api/option"
)

type Content struct {
	Parts []string `json:Parts`
	Role  string   `json:Role`
}
type Candidates struct {
	Content *Content `json:Content`
}
type ContentResponse struct {
	Candidates *[]Candidates `json:Candidates`
}

func GemImgRequest(modeltype, input string, images []string) string {
	ctx := context.Background()
	gemclient, err := genai.NewClient(ctx, option.WithAPIKey(tokens.GeminiToken))
	eror("Error creating gemini client", err)
	defer gemclient.Close()

	final := "err"
	model := gemclient.GenerativeModel(modeltype)

	prompt := []genai.Part{}

	prompt = append(prompt, genai.Part(genai.Text(input)))

	for _, image := range images {
		res, err := http.Get(image)
		eror("Error getting image", err)

		defer res.Body.Close()

		img, err := io.ReadAll(res.Body)
		eror("Error reading image", err)

		prompt = append(prompt, genai.Part(genai.ImageData("png", img)))
	}

	resp, err := model.GenerateContent(ctx, prompt...)
	eror("Error generating response", err)
	marshalResponse, _ := json.MarshalIndent(resp, "", "  ")
	var generateResponse ContentResponse
	eror("Error unmarshaling response", json.Unmarshal(marshalResponse, &generateResponse))
	for _, cad := range *generateResponse.Candidates {
		if cad.Content != nil {
			final = ""
			for _, part := range cad.Content.Parts {
				final += fmt.Sprint(part)
			}
		}
	}
	return final
}

func GemRequest(modeltype, input string) string {
	ctx := context.Background()
	gemclient, err := genai.NewClient(ctx, option.WithAPIKey(tokens.GeminiToken))
	eror("Error creating gemini client", err)
	defer gemclient.Close()

	final := "err"
	model := gemclient.GenerativeModel(modeltype)
	prompt := []genai.Part{
		genai.Text(input),
	}
	resp, err := model.GenerateContent(ctx, prompt...)
	eror("Error generating response", err)
	marshalResponse, _ := json.MarshalIndent(resp, "", "  ")
	var generateResponse ContentResponse
	eror("Error unmarshaling response", json.Unmarshal(marshalResponse, &generateResponse))
	for _, cad := range *generateResponse.Candidates {
		if cad.Content != nil {
			final = ""
			for _, part := range cad.Content.Parts {
				final += fmt.Sprint(part)
			}
		}
	}
	return final
}
