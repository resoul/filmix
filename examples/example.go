package main

import (
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"regexp"
	"strconv"
	"strings"
	"time"
)

type StreamProvider struct {
	playerDataURL  string
	streamID       int
	streamCategory string
	client         *http.Client
}

func NewStreamProvider(rawURL string) (*StreamProvider, error) {
	uri, err := url.Parse(rawURL)
	if err != nil {
		return nil, fmt.Errorf("failed to parse URL: %w", err)
	}

	streamID := getIDFromURL(rawURL)
	if streamID == 0 {
		return nil, fmt.Errorf("failed to extract stream ID from URL")
	}

	pathParts := strings.Split(strings.Trim(uri.Path, "/"), "/")
	streamCategory := ""
	if len(pathParts) > 0 {
		streamCategory = pathParts[0]
	}

	playerDataURL := fmt.Sprintf("%s://%s/api/movies/player-data?t=%d",
		uri.Scheme, uri.Host, time.Now().Unix())

	return &StreamProvider{
		playerDataURL:  playerDataURL,
		streamID:       streamID,
		streamCategory: streamCategory,
		client: &http.Client{
			Timeout: 10 * time.Second,
		},
	}, nil
}

func getIDFromURL(u string) int {
	parts := strings.Split(u, "/")
	if len(parts) == 0 {
		return 0
	}
	last := parts[len(parts)-1]
	subParts := strings.SplitN(last, "-", 2)
	if len(subParts) == 0 {
		return 0
	}
	id, _ := strconv.Atoi(subParts[0])
	return id
}

func (sp *StreamProvider) request(method, reqURL string, headers map[string]string, data url.Values) ([]byte, error) {
	var body io.Reader
	if data != nil {
		body = strings.NewReader(data.Encode())
	}

	req, err := http.NewRequest(method, reqURL, body)
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %w", err)
	}

	if data != nil {
		req.Header.Set("Content-Type", "application/x-www-form-urlencoded")
	}

	for k, v := range headers {
		req.Header.Set(k, v)
	}

	resp, err := sp.client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("request failed: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("unexpected status code: %d", resp.StatusCode)
	}

	return io.ReadAll(resp.Body)
}

func (sp *StreamProvider) sendRequest() (map[string]interface{}, error) {
	headers := map[string]string{
		"x-requested-with": "XMLHttpRequest",
		"Cookie":           "FILMIXNET=ah3mgjr8vgfe84u86vcvu5gcp9",
	}
	data := url.Values{
		"post_id":  {strconv.Itoa(sp.streamID)},
		"showfull": {"true"},
	}

	respBytes, err := sp.request("POST", sp.playerDataURL, headers, data)
	if err != nil {
		return nil, err
	}

	var resp map[string]interface{}
	if err := json.Unmarshal(respBytes, &resp); err != nil {
		return nil, fmt.Errorf("failed to parse response: %w", err)
	}
	return resp, nil
}

func (sp *StreamProvider) GetStreamData() (map[string]interface{}, error) {
	result := make(map[string]interface{})
	response, err := sp.sendRequest()
	if err != nil {
		return nil, err
	}

	responseType, ok := response["type"].(string)
	if !ok || responseType != "success" {
		return result, nil
	}

	message, ok := response["message"].(map[string]interface{})
	if !ok {
		return nil, fmt.Errorf("invalid message format")
	}

	translations, ok := message["translations"].(map[string]interface{})
	if !ok {
		return nil, fmt.Errorf("invalid translations format")
	}

	videos, ok := translations["video"].(map[string]interface{})
	if !ok {
		return nil, fmt.Errorf("invalid video format")
	}

	for translation, rawVideo := range videos {
		video, ok := rawVideo.(string)
		if !ok {
			continue
		}

		if sp.streamCategory == "film" {
			decoded := sp.decode(video)
			parts := strings.Split(decoded, ",")
			result[translation] = sp.convertFromString(parts)
		} else {
			seriesData, err := sp.processSeriesData(video)
			if err != nil {
				fmt.Printf("Warning: failed to process series data for %s: %v\n", translation, err)
				continue
			}
			result[translation] = seriesData
		}
	}

	return result, nil
}

func (sp *StreamProvider) processSeriesData(video string) (map[string]interface{}, error) {
	decodedURL := sp.decode(video)
	resp, err := sp.request("GET", decodedURL, nil, nil)
	if err != nil {
		return nil, err
	}

	var series []map[string]interface{}
	if err := json.Unmarshal(resp, &series); err != nil {
		return nil, fmt.Errorf("failed to parse series data: %w", err)
	}

	result := make(map[string]interface{})

	for _, serie := range series {
		title, ok := serie["title"].(string)
		if !ok {
			continue
		}
		title = strings.TrimSpace(title)

		folders, ok := serie["folder"].([]interface{})
		if !ok {
			continue
		}

		seasonMap := make(map[string]interface{})

		for _, f := range folders {
			folder, ok := f.(map[string]interface{})
			if !ok {
				continue
			}

			id := fmt.Sprintf("%v", folder["id"])

			folderTitle, ok := folder["title"].(string)
			if !ok {
				continue
			}

			fileStr, ok := folder["file"].(string)
			if !ok {
				continue
			}

			files := strings.Split(fileStr, ",")

			seasonMap[id] = map[string]interface{}{
				"title":   strings.TrimSpace(folderTitle),
				"quality": sp.convertFromString(files),
			}
		}

		result[title] = seasonMap
	}

	return result, nil
}

func (sp *StreamProvider) convertFromString(list []string) map[string]string {
	res := make(map[string]string)
	re := regexp.MustCompile(`\[(.*?)\]`)
	for _, item := range list {
		m := re.FindStringSubmatch(item)
		if len(m) > 1 {
			key := m[1]
			val := strings.TrimSpace(strings.Replace(item, m[0], "", 1))
			res[key] = val
		}
	}
	return res
}

func (sp *StreamProvider) IsMovie() bool {
	return sp.streamCategory == "film"
}

func (sp *StreamProvider) decode(str string) string {
	if len(str) < 2 {
		return str
	}

	tokens := []string{
		":<:bzl3UHQwaWk0MkdXZVM3TDdB",
		":<:SURhQnQwOEM5V2Y3bFlyMGVI",
		":<:bE5qSTlWNVUxZ01uc3h0NFFy",
		":<:Mm93S0RVb0d6c3VMTkV5aE54",
		":<:MTluMWlLQnI4OXVic2tTNXpU",
	}

	clean := str[2:]
	clean = strings.ReplaceAll(clean, `\/`, "/")

	for strings.Contains(clean, ":<:") {
		for _, t := range tokens {
			clean = strings.ReplaceAll(clean, t, "")
		}
	}

	decoded, err := base64.StdEncoding.DecodeString(clean)
	if err != nil {
		return ""
	}
	return string(decoded)
}

func main() {
	sp, err := NewStreamProvider("https://filmix.my/film/triller/173398-v-megan-k-vashim-uslugam-2024.html")
	if err != nil {
		panic(err)
	}

	data, err := sp.GetStreamData()
	if err != nil {
		panic(err)
	}

	jsonBytes, _ := json.MarshalIndent(data, "", "  ")
	fmt.Println("Film data:")
	fmt.Println(string(jsonBytes))
}
