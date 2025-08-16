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
	// Разбираем URL
	uri, err := url.Parse(rawURL)
	if err != nil {
		return nil, err
	}

	// streamID из URL
	streamID := getIDFromURL(rawURL)

	// streamCategory — первый сегмент пути
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
	last := parts[len(parts)-1]
	subParts := strings.SplitN(last, "-", 2)
	id, _ := strconv.Atoi(subParts[0])
	return id
}

func (sp *StreamProvider) request(method, reqURL string, headers []string, data url.Values) ([]byte, error) {
	var body io.Reader
	if data != nil {
		body = strings.NewReader(data.Encode())
	}

	req, err := http.NewRequest(method, reqURL, body)
	if err != nil {
		return nil, err
	}

	if data != nil {
		req.Header.Set("Content-Type", "application/x-www-form-urlencoded")
	}
	for _, h := range headers {
		parts := strings.SplitN(h, ":", 2)
		if len(parts) == 2 {
			req.Header.Set(strings.TrimSpace(parts[0]), strings.TrimSpace(parts[1]))
		}
	}

	resp, err := sp.client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	return io.ReadAll(resp.Body)
}

func (sp *StreamProvider) sendRequest() (map[string]interface{}, error) {
	headers := []string{
		"x-requested-with: XMLHttpRequest",
		"Cookie: FILMIXNET=ah3mgjr8vgfe84u86vcvu5gcp9",
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
		return nil, err
	}
	return resp, nil
}

func (sp *StreamProvider) GetStreamData() (map[string]interface{}, error) {
	result := make(map[string]interface{})
	response, err := sp.sendRequest()
	if err != nil {
		return nil, err
	}

	if response["type"] == "success" {
		message := response["message"].(map[string]interface{})
		videos := message["translations"].(map[string]interface{})["video"].(map[string]interface{})

		for translation, rawVideo := range videos {
			video := rawVideo.(string)
			if sp.streamCategory == "film" {
				decoded := sp.decode(video)
				parts := strings.Split(decoded, ",")
				result[translation] = sp.convertFromString(parts)
			} else {
				// сериал
				resp, err := sp.request("GET", sp.decode(video), nil, nil)
				if err != nil {
					return nil, err
				}

				var series []map[string]interface{}
				if err := json.Unmarshal(resp, &series); err != nil {
					return nil, err
				}

				for _, serie := range series {
					title := strings.TrimSpace(serie["title"].(string))
					folders := serie["folder"].([]interface{})
					for _, f := range folders {
						folder := f.(map[string]interface{})
						id := fmt.Sprintf("%v", folder["id"])
						fileStr := folder["file"].(string)
						files := strings.Split(fileStr, ",")

						if result[translation] == nil {
							result[translation] = make(map[string]map[string]map[string]interface{})
						}
						tran := result[translation].(map[string]map[string]map[string]interface{})
						if tran[title] == nil {
							tran[title] = make(map[string]map[string]interface{})
						}
						tran[title][id] = map[string]interface{}{
							"title":   strings.TrimSpace(folder["title"].(string)),
							"quality": sp.convertFromString(files),
						}
					}
				}
			}
		}
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
	tokens := []string{
		":<:bzl3UHQwaWk0MkdXZVM3TDdB",
		":<:SURhQnQwOEM5V2Y3bFlyMGVI",
		":<:bE5qSTlWNVUxZ01uc3h0NFFy",
		":<:Mm93S0RVb0d6c3VMTkV5aE54",
		":<:MTluMWlLQnI4OXVic2tTNXpU",
	}

	clean := str[2:]
	clean = strings.ReplaceAll(clean, `\/`, "/")

	for {
		for _, t := range tokens {
			clean = strings.ReplaceAll(clean, t, "")
		}
		if !strings.Contains(clean, ":<:") {
			break
		}
	}

	decoded, _ := base64.StdEncoding.DecodeString(clean)
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
	fmt.Println(string(jsonBytes))
}
